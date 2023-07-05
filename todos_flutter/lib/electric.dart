import 'package:electric_client/electric_dart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todos_electrified/migrations.dart';
import 'package:logging/logging.dart';

final Provider<Satellite> satelliteProvider =
    Provider((ref) => throw UnimplementedError());

final connectivityStateProvider = StateProvider<ConnectivityState>((ref) {
  return ConnectivityState.disconnected;
});

const kElectricAuthConfig = AuthConfig(
  token:
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJsb2NhbC1kZXZlbG9wbWVudCIsInR5cGUiOiJhY2Nlc3MiLCJ1c2VyX2lkIjoidGVzdC11c2VyIiwiaWF0IjoxNjg3ODc3OTQ1LCJleHAiOjE2OTc4ODE1NDV9.L5Ui2sA9o5MeYDuy67u9lBV-2FzpOWL9dKcitRvgorg',
);

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
      auth: kElectricAuthConfig,
      replication: replicationConfig,
      debug: true,
    ),
  );

  return satellite;
}
