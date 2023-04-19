import 'dart:async';

import 'package:electric_client/auth/auth.dart';
import 'package:electric_client/config/config.dart';
import 'package:electric_client/electric/adapter.dart';
import 'package:electric_client/migrators/migrators.dart';
import 'package:electric_client/notifiers/notifiers.dart';
import 'package:electric_client/satellite/client.dart';
import 'package:electric_client/satellite/config.dart';
import 'package:electric_client/satellite/process.dart';
import 'package:electric_client/satellite/satellite.dart';
import 'package:electric_client/sockets/sockets.dart';
import 'package:electric_client/util/types.dart';

abstract class BaseRegistry implements Registry {
  final Map<DbName, Satellite> satellites = {};
  final Map<DbName, Future<Satellite>> startingPromises = {};
  final Map<DbName, Future<void>> stoppingPromises = {};

  Future<Satellite> startProcess({
    required DbName dbName,
    required DatabaseAdapter adapter,
    required Migrator migrator,
    required Notifier notifier,
    required SocketFactory socketFactory,
    required ConsoleClient console,
    required ElectricConfigFilled config,
    AuthState? authState,
    SatelliteOverrides? opts,
  }) {
    throw "Subclasses must implement startProcess";
  }

  @override
  Future<Satellite> ensureStarted({
    required DbName dbName,
    required DatabaseAdapter adapter,
    required Migrator migrator,
    required Notifier notifier,
    required SocketFactory socketFactory,
    required ConsoleClient console,
    required ElectricConfigFilled config,
    AuthState? authState,
    SatelliteOverrides? opts,
  }) async {
    // If we're in the process of stopping the satellite process for this
    // dbName, then we wait for the process to be stopped and then we
    // call this function again to retry starting it.
    final stoppingPromises = this.stoppingPromises;
    final stopping = stoppingPromises[dbName];
    if (stopping != null) {
      return stopping.then((_) => this.ensureStarted(
          dbName: dbName,
          adapter: adapter,
          migrator: migrator,
          notifier: notifier,
          socketFactory: socketFactory,
          console: console,
          config: config,
          authState: authState,
          opts: opts));
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
            adapter: adapter,
            migrator: migrator,
            notifier: notifier,
            socketFactory: socketFactory,
            console: console,
            config: config,
            authState: authState)
        .then((satellite) {
      startingPromises.remove(dbName);

      satellites[dbName] = satellite;

      return satellite;
    });

    startingPromises[dbName] = startingPromise;
    return startingPromise;
  }

  Future<Satellite> ensureAlreadyStarted(DbName dbName) async {
    final starting = this.startingPromises[dbName];
    if (starting != null) {
      return starting;
    }

    final satellite = this.satellites[dbName];
    if (satellite != null) {
      return satellite;
    }

    throw new Exception("Satellite not running for db: ${dbName}");
  }

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
      final stoppingPromise = satellite.stop().then((_) {
        satellites.remove(dbName);
        stoppingPromises.remove(dbName);
      });

      stoppingPromises[dbName] = stoppingPromise;
      return stoppingPromise;
    }
  }

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
  Future<Satellite> startProcess({
    required DbName dbName,
    required DatabaseAdapter adapter,
    required Migrator migrator,
    required Notifier notifier,
    required SocketFactory socketFactory,
    required ConsoleClient console,
    required ElectricConfigFilled config,
    AuthState? authState,
    SatelliteOverrides? opts,
  }) async {
    // validateConfig should not be necessary, because we are already using a typed class
    // final foundErrors = validateConfig(config);
    // if (foundErrors.length > 0) {
    //   throw Exception("invalid config: ${foundErrors}");
    // }

    final satelliteConfig = SatelliteConfig(
      app: config.app,
      env: config.env,
    );

    final satelliteClientOpts = SatelliteClientOpts(
      host: config.replication.host,
      port: config.replication.port,
      ssl: config.replication.ssl,
    );

    final client = SatelliteClient(
      dbName: dbName,
      socketFactory: socketFactory,
      notifier: notifier,
      opts: satelliteClientOpts,
    );
    final satellite = SatelliteProcess(
      dbName: dbName,
      adapter: adapter,
      migrator: migrator,
      notifier: notifier,
      client: client,
      console: console,
      config: satelliteConfig,
      opts: kSatelliteDefaults,
    );
    unawaited(satellite.start(authState));

    return satellite;
  }
}
