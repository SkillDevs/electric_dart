import 'dart:io';

import 'package:electric_client/auth/auth.dart';
import 'package:electric_client/config/config.dart';
import 'package:electric_client/electric/sqlite3_adapter.dart';
import 'package:electric_client/migrators/bundle.dart';
import 'package:electric_client/notifiers/event.dart';
import 'package:electric_client/satellite/client.dart';
import 'package:electric_client/satellite/config.dart';
import 'package:electric_client/satellite/process.dart';
import 'package:electric_client/sockets/io.dart';
import 'package:electric_client/util/debug/debug.dart';
import 'package:logging/logging.dart';
import 'package:sqlite3/sqlite3.dart';

import 'todo_migrations.dart';

void main(List<String> arguments) async {
  final appId = "my-todos";
  final env = "local";

  final replicationConfig = ReplicationConfig(
    host: '127.0.0.1',
    port: 5133,
    ssl: false,
  );
  final dbName = "electric.db";

  final client = SatelliteClient(
    dbName: dbName,
    socketFactory: WebSocketIOFactory(),
    opts: SatelliteClientOpts(
      host: replicationConfig.host,
      port: replicationConfig.port,
      ssl: replicationConfig.ssl,
      pushPeriod: 500,
      timeout: 2000,
    ),
  );

  final dbFile = File(dbName);
  final db = sqlite3.open(dbFile.path);

  final adapter = SqliteAdapter(db);
  final migrator = BundleMigrator(adapter: adapter, migrations: todoMigrations);

  setLogLevel(Level.ALL);

  final satellite = SatelliteProcess(
    client: client,
    config: SatelliteConfig(app: appId, env: env),
    migrator: migrator,
    console: ConsoleHttpClient(
      ElectricConfig(
        app: appId,
        env: env,
        console: ConsoleConfig(
          host: '127.0.0.1',
          port: 4000,
          ssl: false,
        ),
        replication: replicationConfig,
      ),
    ),
    opts: kSatelliteDefaults,
    adapter: adapter,
    dbName: dbName,
    notifier: EventNotifier(dbName: dbName),
  );

  await satellite.start(null);
}
