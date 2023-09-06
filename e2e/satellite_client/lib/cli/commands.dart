import 'dart:convert';
import 'dart:io';

import 'package:electricsql/electricsql.dart';
import 'package:electricsql/notifiers.dart';
import 'package:electricsql/util.dart';
import 'package:satellite_dart_client/generic_db.dart';
import 'package:satellite_dart_client/state.dart';
import 'package:electricsql/drivers/drift.dart';
import 'package:drift/native.dart';

Future<GenericDb> makeDb(String dbPath) async {
  final db = await GenericDb.open(NativeDatabase(File(dbPath)));
  return db;
}

Future<ElectricClient> electrifyDb(GenericDb db, DbName dbName, String host,
    int port, String migrationsJ) async {
  final config = ElectricConfig(
    url: "electric://$host:$port",
    logger: LoggerConfig(level: Level.debug),
    auth: AuthConfig(token: await mockSecureAuthToken()),
  );
  print("(in electrify_db) config: ${jsonConfig(config)}");

  final migrations = _migrationsFromJson(migrationsJ);

  final result = await electrify<GenericDb>(
    dbName: dbName,
    db: db,
    migrations: migrations,
    config: config,
  );

  result.notifier.subscribeToConnectivityStateChanges(
    (ConnectivityStateChangeNotification x) => print(
        "Connectivity state changed (${x.dbName}, ${x.connectivityState})"),
  );

  return result;
}

String jsonConfig(ElectricConfig config) {
  final map = {
    "url": config.url,
    "logger": _jsonLogger(config.logger),
    "auth": _jsonAuth(config.auth),
  };

  return json.encode(map);
}

Map<String, Object?> _jsonLogger(LoggerConfig? logger) {
  if (logger == null) return {};

  return {
    "level": logger.level.toString(),
  };
}

Map<String, Object?> _jsonAuth(AuthConfig auth) {
  return {
    "token": auth.token,
  };
}

List<Migration> _migrationsFromJson(String migrationsJ) {
  final migrations = json.decode(migrationsJ);

  return migrations.map((m) => _migrationFromJson(m)).toList();
}

Migration _migrationFromJson(Map<String, Object?> m) {
  final statements =
      (m["statements"] as List<Object?>).map((s) => s as String).toList();
  final version = m["version"] as String;

  return Migration(
    statements: statements,
    version: version,
  );
}
