import 'package:electric_client/electric_dart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todos_electrified/migrations.dart';
import 'package:logging/logging.dart';

final Provider<Satellite> satelliteProvider =
    Provider((ref) => throw UnimplementedError());

final connectivityStateProvider = StateProvider<ConnectivityState>((ref) {
  return ConnectivityState.disconnected;
});


Future<Satellite> startElectric(String dbPath, DatabaseAdapter adapter) async {
  final dbName = dbPath;

  final replicationConfig = ReplicationConfig(
    host: '127.0.0.1',
    port: 5133,
    ssl: false,
  );

  setLogLevel(Level.ALL);

  final notifier = EventNotifier(dbName: dbName);

  final satellite = await globalRegistry.ensureStarted(
    dbName: dbName,
    adapter: adapter,
    migrator: BundleMigrator(adapter: adapter, migrations: todoMigrations),
    notifier: notifier,
    socketFactory: WebSocketIOFactory(),
    config: HydratedConfig(
      auth: AuthConfig(
        token: await authToken(iss: 'local-development', key: 'local-development-key-minimum-32-symbols'),
      ),
      replication: replicationConfig,
      debug: true,
    ),
  );

  return satellite;
}
