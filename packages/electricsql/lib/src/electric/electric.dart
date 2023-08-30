import 'package:electricsql/electricsql.dart';
import 'package:electricsql/src/config/config.dart';
import 'package:electricsql/src/migrators/migrators.dart';
import 'package:electricsql/src/notifiers/notifiers.dart';
import 'package:electricsql/src/satellite/satellite.dart';
import 'package:electricsql/src/util/types.dart';
import 'package:logging/logging.dart';

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
  });
}

class ElectrifyBaseOptions {
  final Migrator? migrator;
  final Notifier? notifier;
  final Registry? registry;

  ElectrifyBaseOptions({
    this.migrator,
    this.notifier,
    this.registry,
  });
}

/// This is the primary `electrify()` endpoint that the individual drivers
/// call once they've constructed their implementations. This function can
/// also be called directly by tests that don't want to go via the adapter
/// entrypoints in order to avoid loading the environment dependencies.
Future<ElectricClient> electrify({
  required DbName dbName,
  required List<Migration> migrations,
  required ElectricConfig config,
  required DatabaseAdapter adapter,
  required SocketFactory socketFactory,
  required ElectrifyBaseOptions opts,
}) async {
  setLogLevel((config.debug ?? false) ? Level.ALL : Level.WARNING);

  final configWithDefaults = hydrateConfig(config);
  final migrator =
      opts.migrator ?? BundleMigrator(adapter: adapter, migrations: migrations);
  final notifier = opts.notifier ?? EventNotifier(dbName: dbName);
  final registry = opts.registry ?? globalRegistry;

  final satellite = await registry.ensureStarted(
    dbName: dbName,
    adapter: adapter,
    migrator: migrator,
    notifier: notifier,
    socketFactory: socketFactory,
    config: configWithDefaults,
  );

  final electric = ElectricClient.create(
    adapter: adapter,
    notifier: notifier,
    satellite: satellite,
  );

  if (satellite.connectivityState != null) {
    electric.setIsConnected(satellite.connectivityState!);
  }

  return electric;
}
