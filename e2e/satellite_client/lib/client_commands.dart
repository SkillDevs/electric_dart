import 'dart:io';

import 'package:drift/drift.dart';
import 'package:electricsql/electricsql.dart';
import 'package:electricsql/notifiers.dart';
import 'package:electricsql/util.dart';
import 'package:satellite_dart_client/util/generic_db.dart';
import 'package:electricsql/drivers/drift.dart';
import 'package:drift/native.dart';
import 'package:satellite_dart_client/util/json.dart';

Future<GenericDb> makeDb(String dbPath) async {
  final db = await GenericDb.open(NativeDatabase(File(dbPath)));
  return db;
}

Future<DriftElectricClient> electrifyDb(GenericDb db, DbName dbName, String host,
    int port, List<dynamic> migrationsJ) async {
  final config = ElectricConfig(
    url: "electric://$host:$port",
    logger: LoggerConfig(level: Level.debug),
    auth: AuthConfig(token: await mockSecureAuthToken()),
  );
  print("(in electrify_db) config: ${electricConfigToJson(config)}");

  final migrations = migrationsFromJson(migrationsJ);

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

Future<List<Row>> getTables(DriftElectricClient electric) async {
  final rows = await electric.db
      .customSelect("SELECT name FROM sqlite_master WHERE type='table';")
      .get();
  return _toRows(rows);
}

Future<List<Row>> getColumns(DriftElectricClient electric, String table) async {
  final rows = await electric.db.customSelect(
    "SELECT * FROM pragma_table_info(?);",
    variables: [Variable.withString(table)],
  ).get();
  return _toRows(rows);
}

List<Row> _toRows(List<QueryRow> rows) {
  return rows.map((r) => r.data).toList();
}

typedef Row = Map<String, Object?>;
