import 'dart:async';

import 'package:electricsql/src/client/model/schema.dart';
import 'package:electricsql/src/config/config.dart';
import 'package:electricsql/src/electric/adapter.dart';
import 'package:electricsql/src/migrators/migrators.dart';
import 'package:electricsql/src/notifiers/notifiers.dart';
import 'package:electricsql/src/satellite/client.dart';
import 'package:electricsql/src/satellite/config.dart';
import 'package:electricsql/src/satellite/process.dart';
import 'package:electricsql/src/satellite/satellite.dart';
import 'package:electricsql/src/sockets/sockets.dart';
import 'package:electricsql/src/util/types.dart';

abstract class BaseRegistry implements Registry {
  final Map<DbName, Satellite> satellites = {};
  final Map<DbName, Future<Satellite>> startingPromises = {};
  final Map<DbName, Future<void>> stoppingPromises = {};

  Future<Satellite> startProcess({
    required DbName dbName,
    required DBSchema dbDescription,
    required DatabaseAdapter adapter,
    required Migrator migrator,
    required Notifier notifier,
    required SocketFactory socketFactory,
    required HydratedConfig config,
    SatelliteOverrides? overrides,
  });

  @override
  Future<Satellite> ensureStarted({
    required DbName dbName,
    required DBSchema dbDescription,
    required DatabaseAdapter adapter,
    required Migrator migrator,
    required Notifier notifier,
    required SocketFactory socketFactory,
    required HydratedConfig config,
    SatelliteOverrides? opts,
  }) async {
    // If we're in the process of stopping the satellite process for this
    // dbName, then we wait for the process to be stopped and then we
    // call this function again to retry starting it.
    final stoppingPromises = this.stoppingPromises;
    final stopping = stoppingPromises[dbName];
    if (stopping != null) {
      return stopping.then(
        (_) => ensureStarted(
          dbName: dbName,
          dbDescription: dbDescription,
          adapter: adapter,
          migrator: migrator,
          notifier: notifier,
          socketFactory: socketFactory,
          config: config,
          opts: opts,
        ),
      );
    }

    // If we're in the process of starting the satellite process for this
    // dbName, then we short circuit and return that process. Note that
    // this assumes that the previous call to start the process for this
    // dbName would have passed in functionally equivalent `dbAdapter`,
    // `fs` and `notifier` arguments. Which is *probably* a safe assumption
    // in the case where this might happen, which is multiple components
    // in the same app opening a connection to the same db at the same time.
    final starting = startingPromises[dbName];
    if (starting != null) {
      return starting;
    }

    // If we already have a satellite process running for this db, then
    // return it.
    final satellite = satellites[dbName];
    if (satellite != null) {
      return satellite;
    }

    // Otherwise we need to fire it up!
    final startingPromise = startProcess(
      dbName: dbName,
      dbDescription: dbDescription,
      adapter: adapter,
      migrator: migrator,
      notifier: notifier,
      socketFactory: socketFactory,
      config: config,
    ).then((satellite) {
      satellites[dbName] = satellite;

      return satellite;
    }).whenComplete(() {
      startingPromises.remove(dbName);
    });

    startingPromises[dbName] = startingPromise;
    return startingPromise;
  }

  @override
  Future<Satellite> ensureAlreadyStarted(DbName dbName) async {
    final starting = startingPromises[dbName];
    if (starting != null) {
      return starting;
    }

    final satellite = satellites[dbName];
    if (satellite != null) {
      return satellite;
    }

    throw Exception('Satellite not running for db: $dbName');
  }

  @override
  Future<void> stop(DbName dbName, {bool shouldIncludeStarting = true}) async {
    // If in the process of starting, wait for it to start and then stop it.
    if (shouldIncludeStarting) {
      final starting = startingPromises[dbName];
      if (starting != null) {
        return starting.then((_satellite) => stop(dbName));
      }
    }

    // If already stopping then return that promise.

    final stopping = stoppingPromises[dbName];
    if (stopping != null) {
      return stopping;
    }

    // Otherwise, if running then stop.
    final satellite = satellites[dbName];
    if (satellite != null) {
      final stoppingPromise = satellite.stop(shutdown: true).then((_) {
        satellites.remove(dbName);
        stoppingPromises.remove(dbName);
      });

      stoppingPromises[dbName] = stoppingPromise;
      return stoppingPromise;
    }
  }

  @override
  Future<void> stopAll({bool shouldIncludeStarting = true}) async {
    final running = satellites.keys.map((dbName) => stop(dbName)).toList();
    final stopping = stoppingPromises.values.toList();

    var promisesToStop = <Future<dynamic>>[...running, ...stopping];
    if (shouldIncludeStarting) {
      final starting = startingPromises.entries.map((entry) {
        final dbName = entry.key;
        final started = entry.value;
        return started.then((_) => stop(dbName));
      }).toList();
      promisesToStop = [...promisesToStop, ...starting];
    }

    await Future.wait<void>(promisesToStop);
  }
}

class GlobalRegistry extends BaseRegistry {
  @override
  Future<Satellite> startProcess({
    required DbName dbName,
    required DBSchema dbDescription,
    required DatabaseAdapter adapter,
    required Migrator migrator,
    required Notifier notifier,
    required SocketFactory socketFactory,
    required HydratedConfig config,
    SatelliteOverrides? overrides,
  }) async {
    // validateConfig should not be necessary, because we are already using a typed class
    // final foundErrors = validateConfig(config);
    // if (foundErrors.length > 0) {
    //   throw Exception("invalid config: ${foundErrors}");
    // }

    final satelliteClientOpts = SatelliteClientOpts(
      host: config.replication.host,
      port: config.replication.port,
      ssl: config.replication.ssl,
      timeout: config.replication.timeout.inMilliseconds,
    );

    final client = SatelliteClient(
      dbDescription: dbDescription,
      socketFactory: socketFactory,
      opts: satelliteClientOpts,
    );

    final SatelliteOpts satelliteOpts = kSatelliteDefaults.copyWith(
      connectionBackoffOptions: config.connectionBackoffOptions,
    );

    final satellite = SatelliteProcess(
      dbName: dbName,
      adapter: adapter,
      migrator: migrator,
      notifier: notifier,
      client: client,
      opts: satelliteOpts,
    );
    await satellite.start(config.auth);

    return satellite;
  }
}

final globalRegistry = GlobalRegistry();
