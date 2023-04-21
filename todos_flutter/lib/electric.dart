import 'package:electric_client/auth/auth.dart';
import 'package:electric_client/config/config.dart';
import 'package:electric_client/electric/sqlite3_adapter.dart';
import 'package:electric_client/migrators/bundle.dart';
import 'package:electric_client/notifiers/event.dart';
import 'package:electric_client/satellite/registry.dart';
import 'package:electric_client/satellite/satellite.dart';
import 'package:electric_client/sockets/io.dart';
import 'package:electric_client/util/debug/debug.dart';
import 'package:electric_client/util/types.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todos_electrified/database.dart';
import 'package:todos_electrified/migrations.dart';
import 'package:logging/logging.dart';

final Provider<Satellite> satelliteProvider = Provider((ref) => throw UnimplementedError());

final connectivityStateProvider = StateProvider<ConnectivityState>((ref) {
  return ConnectivityState.disconnected;
});

Future<Satellite> startElectric(TodosDatabase database) async {
  final dbName = database.dbPath;
  const app = "my-todos";
  const env = "local";

  final replicationConfig = ReplicationConfig(
    host: '127.0.0.1',
    port: 5133,
    ssl: false,
  );

  final adapter = SqliteAdapter(database.db);
  final consoleConfig = ConsoleConfig(
    host: '127.0.0.1',
    port: 4000,
    ssl: false,
  );

  setLogLevel(Level.ALL);

  final notifier = EventNotifier(dbName: dbName);


  final satellite = await globalRegistry.ensureStarted(
    dbName: database.dbPath,
    adapter: adapter,
    migrator: BundleMigrator(adapter: adapter, migrations: todoMigrations),
    notifier: notifier,
    socketFactory: WebSocketIOFactory(),
    console: ConsoleHttpClient(
      ElectricConfig(
        app: app,
        env: env,
        console: consoleConfig,
        migrations: todoMigrations,
        replication: replicationConfig,
      ),
    ),
    config: ElectricConfigFilled(
      app: app,
      env: env,
      console: consoleConfig,
      migrations: todoMigrations,
      replication: replicationConfig,
      debug: true,
    ),
  );

  return satellite;
}
