import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:electricsql/electricsql.dart';
import 'package:electricsql/notifiers.dart';
import 'package:electricsql/satellite.dart';
import 'package:electricsql/util.dart';
import 'package:satellite_dart_client/util/generic_db.dart';
import 'package:electricsql/drivers/drift.dart';
import 'package:drift/native.dart';
import 'package:satellite_dart_client/util/json.dart';

Future<GenericDb> makeDb(String dbPath) async {
  final db = await GenericDb.open(NativeDatabase(File(dbPath)));
  return db;
}

Future<DriftElectricClient> electrifyDb(GenericDb db, DbName dbName,
    String host, int port, List<dynamic> migrationsJ) async {
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

void setSubscribers(DriftElectricClient db) {
  db.notifier.subscribeToAuthStateChanges((x) {
    print('auth state changes: ');
    print(x);
  });
  db.notifier.subscribeToPotentialDataChanges((x) {
    print('potential data change: ');
    print(x);
  });
  db.notifier.subscribeToDataChanges((x) {
    print('data changes: ');
    // TODO: To json
    //print(json.encode(x));
  });
}

Future<void> syncTable(DriftElectricClient electric, String table) async {
  if (table == 'items') {
    final ShapeSubscription(:synced) = await electric.syncTables(["items"]);
    return await synced;
  } else if (table == 'other_items') {
    final ShapeSubscription(:synced) = await electric.syncTables(
      ["items", "other_items"],
    );
    return await synced;
  }
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

Future<List<Row>> getItems(DriftElectricClient electric) async {
  final rows = await electric.db
      .customSelect(
        "SELECT * FROM items;",
      )
      .get();
  return _toRows(rows);
}

Future<List<Row>> getItemIds(DriftElectricClient electric) async {
  final rows = await electric.db
      .customSelect(
        "SELECT id FROM items;",
      )
      .get();
  return _toRows(rows);
}

Future<List<Row>> getItemColumns(
    DriftElectricClient electric, String table, String column) async {
  final rows = await electric.db
      .customSelect(
        "SELECT $column FROM $table;",
      )
      .get();
  return _toRows(rows);
}

Future<void> insertItem(DriftElectricClient electric, List<String> keys) async {
  await electric.db.transaction(() async {
    for (final key in keys) {
      await electric.db.customInsert(
        "INSERT INTO items(id, content) VALUES (?,?);",
        variables: [
          Variable.withString(genUUID()),
          Variable.withString(key),
        ],
      );
    }
  });
}

Future<void> insertExtendedItem(
  DriftElectricClient electric,
  Map<String, String> values,
) async {
  final fixedColumns = <String, Object? Function()>{
    "id": genUUID,
  };

  final colToVal = <String, Object?>{
    ...Map.fromEntries(
      fixedColumns.entries.map((e) => MapEntry(e.key, e.value())),
    ),
    ...values,
  };

  final columns = colToVal.keys.toList();
  final columnNames = columns.join(", ");
  final placeholders = columns.map((_) => "?").join(", ");

  final args = colToVal.values.toList();

  await electric.db.customInsert(
    "INSERT INTO items($columnNames) VALUES ($placeholders) RETURNING *;",
    variables: dynamicArgsToVariables(args),
  );
}

Future<void> deleteItem(
  DriftElectricClient electric,
  List<String> keys,
) async {
  for (final key in keys) {
    await electric.db.customUpdate(
      "DELETE FROM items WHERE content = ?;",
      variables: [Variable.withString(key)],
    );
  }
}

Future<List<Row>> getOtherItems(DriftElectricClient electric) async {
  final rows = await electric.db
      .customSelect(
        "SELECT * FROM other_items;",
      )
      .get();
  return _toRows(rows);
}

Future<void> insertOtherItem(
    DriftElectricClient electric, List<String> keys) async {
  await electric.db.customInsert(
    "INSERT INTO items(id, content) VALUES (?,?);",
    variables: [
      Variable.withString("test_id_1"),
      Variable.withString(""),
    ],
  );

  await electric.db.transaction(() async {
    for (final key in keys) {
      await electric.db.customInsert(
        "INSERT INTO other_items(id, content) VALUES (?,?);",
        variables: [
          Variable.withString(genUUID()),
          Variable.withString(key),
        ],
      );
    }
  });
}

Future<void> stop(DriftElectricClient db) async {
  await globalRegistry.stopAll();
}

Future<void> rawStatement(DriftElectricClient db, String statement) async {
  await db.db.customStatement(statement);

  // TODO: Review this
  db.notifier.potentiallyChanged();
}

void changeConnectivity(DriftElectricClient db, String connectivityName) {
  final dbName = db.notifier.dbName;
  final ConnectivityState state = switch (connectivityName) {
    'disconnected' => ConnectivityState.disconnected,
    'connected' => ConnectivityState.connected,
    'available' => ConnectivityState.available,
    _ => throw Exception('Unknown connectivity name: $connectivityName'),
  };

  db.notifier.connectivityStateChanged(dbName, state);
}

/////////////////////////////////

List<Row> _toRows(List<QueryRow> rows) {
  return rows.map((r) {
    final data = r.data;
    return data.map((key, value) {
      final String newVal;
      if (value is String) {
        newVal = "'$value'";
      } else {
        newVal = value.toString();
      }
      return MapEntry(key, newVal);
    });
  }).toList();
}

typedef Row = Map<String, String>;

List<Variable> dynamicArgsToVariables(List<Object?>? args) {
  return (args ?? const [])
      .map((Object? arg) {
        if (arg == null) {
          return const Variable<Object>(null);
        }
        if (arg is bool) {
          return Variable.withBool(arg);
        } else if (arg is int) {
          return Variable.withInt(arg);
        } else if (arg is String) {
          return Variable.withString(arg);
        } else if (arg is double) {
          return Variable.withReal(arg);
        } else if (arg is DateTime) {
          return Variable.withDateTime(arg);
        } else if (arg is Uint8List) {
          return Variable.withBlob(arg);
        } else if (arg is Variable) {
          return arg;
        } else {
          assert(false, 'unknown type $arg');
          return Variable<Object>(arg);
        }
      })
      .cast<Variable>()
      .toList();
}
