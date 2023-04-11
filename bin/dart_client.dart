import 'dart:io';

import 'package:electric_client/auth/auth.dart';
import 'package:electric_client/config/config.dart';
import 'package:electric_client/electric/adapter.dart';
import 'package:electric_client/electric/sqlite3_adapter.dart';
import 'package:electric_client/migrators/bundle.dart';
import 'package:electric_client/satellite/client.dart';
import 'package:electric_client/satellite/config.dart';
import 'package:electric_client/satellite/process.dart';
import 'package:electric_client/sockets/io.dart';
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

  final satellite = Satellite(
    client: client,
    config: SatelliteConfig(app: appId, env: env),
    migrator: migrator,
    console: ConsoleClient(
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
  );

  satellite.client.on("error", (data) => print("Client error $data"));

  await satellite.start(null);
}

void initDb(Database db) {
  final oplogTable = kSatelliteDefaults.oplogTable;
  final metaTable = kSatelliteDefaults.metaTable;
  final migrationsTable = kSatelliteDefaults.migrationsTable;
  final triggersTable = kSatelliteDefaults.triggersTable;
  final shadowTable = kSatelliteDefaults.shadowTable;

  final statements = [
    //`-- The ops log table\n`,
    'CREATE TABLE IF NOT EXISTS $oplogTable (\n  rowid INTEGER PRIMARY KEY AUTOINCREMENT,\n  namespace String NOT NULL,\n  tablename String NOT NULL,\n  optype String NOT NULL,\n  primaryKey String NOT NULL,\n  newRow String,\n  oldRow String,\n  timestamp TEXT,  clearTags TEXT DEFAULT "[]" NOT NULL\n);',
    //`-- Somewhere to keep our metadata\n`,
    'CREATE TABLE IF NOT EXISTS $metaTable (\n  key TEXT PRIMARY KEY,\n  value BLOB\n);',
    //`-- Somewhere to track migrations\n`,
    'CREATE TABLE IF NOT EXISTS $migrationsTable (\n  id INTEGER PRIMARY KEY AUTOINCREMENT,\n  name TEXT NOT NULL UNIQUE,\n  sha256 TEXT NOT NULL,\n  applied_at TEXT NOT NULL\n);',
    //`-- Initialisation of the metadata table\n`,
    '''INSERT INTO $metaTable (key, value) VALUES ('compensations', 0), ('lastAckdRowId','0'), ('lastSentRowId', '0'), ('lsn', ''), ('clientId', ''), ('token', 'INITIAL_INVALID_TOKEN'), ('refreshToken', '');''',
    //`-- These are toggles for turning the triggers on and off\n`,
    'DROP TABLE IF EXISTS $triggersTable;',
    'CREATE TABLE $triggersTable (tablename STRING PRIMARY KEY, flag INTEGER);',
    //`-- Somewhere to keep dependency tracking information\n`,
    'CREATE TABLE $shadowTable (\n  namespace String NOT NULL,\n  tablename String NOT NULL,\n  primaryKey String NOT NULL,\n  tags TEXT NOT NULL,\n  PRIMARY KEY (namespace, tablename, primaryKey));',
  ];
  for (var statement in statements) {
    db.execute(statement);
  }
}
