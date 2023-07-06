import 'package:electric_client/electric_dart.dart';
import 'package:electric_client/src/config/config.dart';
import 'package:electric_client/src/migrators/migrators.dart';
import 'package:electric_client/src/notifiers/notifiers.dart';
import 'package:electric_client/src/satellite/satellite.dart';
import 'package:electric_client/src/sockets/sockets.dart';
import 'package:electric_client/src/util/types.dart';
import 'package:logging/logging.dart';

// These are the options that should be provided to the adapter's electrify
// entrypoint. They are all optional to optionally allow different / mock
// implementations to be passed in to facilitate testing.
class ElectrifyOptions {
  final DatabaseAdapter adapter;
  final Migrator? migrator;
  final Notifier? notifier;
  final SocketFactory socketFactory;
  final Registry? registry;

  ElectrifyOptions({
    required this.adapter,
    required this.socketFactory,
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
  required ElectrifyOptions opts,
}) async {
  setLogLevel((config.debug ?? false) ? Level.ALL : Level.WARNING);

  final adapter = opts.adapter;
  final socketFactory = opts.socketFactory;

  final configWithDefaults = hydrateConfig(config);
  final migrator =
      opts.migrator ?? BundleMigrator(adapter: adapter, migrations: migrations);
  final notifier = opts.notifier ?? EventNotifier(dbName: dbName);
  final registry = opts.registry ?? globalRegistry;

  final electric = ElectricClient(adapter: adapter, notifier: notifier);

  await registry.ensureStarted(
    dbName: dbName,
    adapter: adapter,
    migrator: migrator,
    notifier: notifier,
    socketFactory: socketFactory,
    config: configWithDefaults,
  );

  return electric;
}
