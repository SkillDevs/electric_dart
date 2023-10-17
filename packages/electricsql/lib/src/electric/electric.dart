import 'package:electricsql/electricsql.dart';
import 'package:electricsql/migrators.dart';
import 'package:electricsql/notifiers.dart';
import 'package:electricsql/satellite.dart';
import 'package:electricsql/sockets.dart';
import 'package:electricsql/src/client/model/client.dart';
import 'package:electricsql/src/client/model/schema.dart';
import 'package:electricsql/src/config/config.dart';
import 'package:electricsql/util.dart';

// These are the options that should be provided to the adapter's electrify
// entrypoint. They are all optional to optionally allow different / mock
// implementations to be passed in to facilitate testing.
class ElectrifyOptions extends ElectrifyBaseOptions {
  final DatabaseAdapter? adapter;
  final SocketFactory? socketFactory;

  ElectrifyOptions({
    this.adapter,
    this.socketFactory,
    super.migrator,
    super.notifier,
    super.registry,
    super.prepare,
  });
}

class ElectrifyBaseOptions {
  final Migrator? migrator;
  final Notifier? notifier;
  final Registry? registry;

  /// Function that prepares the database connection.
  /// If not overridden, the default prepare function
  /// enables the `foreign_key` pragma on the DB connection.
  /// @param connection The database connection.
  /// @returns A promise that resolves when the database connection is prepared.
  final Future<void> Function(DatabaseAdapter connection)? prepare;

  ElectrifyBaseOptions({
    this.migrator,
    this.notifier,
    this.registry,
    this.prepare,
  });
}

Future<void> defaultPrepare(DatabaseAdapter connection) async {
  await connection.run(Statement('PRAGMA foreign_keys = ON;'));
}

/// This is the primary `electrify()` endpoint that the individual drivers
/// call once they've constructed their implementations. This function can
/// also be called directly by tests that don't want to go via the adapter
/// entrypoints in order to avoid loading the environment dependencies.
Future<ElectricClient> electrifyBase<DB extends DBSchema>({
  required DbName dbName,
  required DB dbDescription,
  required ElectricConfig config,
  required DatabaseAdapter adapter,
  required SocketFactory socketFactory,
  required ElectrifyBaseOptions opts,
}) async {
  configureElectricLogger(
    LoggerConfig(
      level: config.logger?.level ?? Level.warning,
      colored: config.logger?.colored ?? true,
    ),
  );

  final prepare = opts.prepare ?? defaultPrepare;
  await prepare(adapter);

  final configWithDefaults = hydrateConfig(config);
  final migrator =
      opts.migrator ?? BundleMigrator(adapter: adapter, migrations: dbDescription.migrations);
  final notifier = opts.notifier ?? EventNotifier(dbName: dbName);
  final registry = opts.registry ?? globalRegistry;

  final satellite = await registry.ensureStarted(
    dbName: dbName,
    dbDescription: dbDescription,
    adapter: adapter,
    migrator: migrator,
    notifier: notifier,
    socketFactory: socketFactory,
    config: configWithDefaults,
  );

  final electric = ElectricClientImpl.create(
    adapter: adapter,
    notifier: notifier,
    satellite: satellite,
  );

  if (satellite.connectivityState != null) {
    electric.setIsConnected(satellite.connectivityState!);
  }

  return electric;
}
