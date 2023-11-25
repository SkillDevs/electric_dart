import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:electricsql/electricsql.dart';
import 'package:electricsql/notifiers.dart';
import 'package:electricsql/satellite.dart';
import 'package:electricsql/util.dart';
import 'package:satellite_dart_client/drift/database.dart';
import 'package:electricsql/drivers/drift.dart';
import 'package:drift/native.dart';
import 'package:satellite_dart_client/util/json.dart';
import 'package:satellite_dart_client/util/pretty_output.dart';

late String dbName;

typedef MyDriftElectricClient = DriftElectricClient<ClientDatabase>;

Future<ClientDatabase> makeDb(String dbPath) async {
  final db = ClientDatabase(NativeDatabase(File(dbPath)));
  await db.customSelect('PRAGMA foreign_keys = ON;').get();
  dbName = dbPath;
  return db;
}

Future<MyDriftElectricClient> electrifyDb(
    ClientDatabase db, String host, int port, List<dynamic> migrationsJ) async {
  final config = ElectricConfig(
    url: "electric://$host:$port",
    logger: LoggerConfig(level: Level.debug, colored: false),
    auth: AuthConfig(token: await mockSecureAuthToken()),
  );
  print("(in electrify_db) config: ${electricConfigToJson(config)}");

  final migrations = migrationsFromJson(migrationsJ);

  final result = await electrify<ClientDatabase>(
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
    print(x.toMap());
  });
}

Future<void> syncTable(DriftElectricClient electric, String table) async {
  if (table == 'other_items') {
    final ShapeSubscription(:synced) = await electric.syncTables(
      ["items", "other_items"],
    );

    return await synced;
  } else {
    final satellite = globalRegistry.satellites[dbName]!;
    final ShapeSubscription(:synced) = await satellite.subscribe([
      ClientShapeDefinition(selects: [ShapeSelect(tablename: table)])
    ]);
    return await synced;
  }
}

Future<Rows> getTables(DriftElectricClient electric) async {
  final rows = await electric.db
      .customSelect("SELECT name FROM sqlite_master WHERE type='table';")
      .get();
  return _toRows(rows);
}

Future<Rows> getColumns(DriftElectricClient electric, String table) async {
  final rows = await electric.db.customSelect(
    "SELECT * FROM pragma_table_info(?);",
    variables: [Variable.withString(table)],
  ).get();
  return _toRows(rows);
}

Future<Rows> getRows(DriftElectricClient electric, String table) async {
  final rows = await electric.db
      .customSelect(
        "SELECT * FROM $table;",
      )
      .get();
  return _toRows(rows);
}

Future<void> getTimestamps(MyDriftElectricClient electric) async {
  throw UnimplementedError();
  //await electric.db.timestamps.findMany();
}

Future<void> writeTimestamp(
    MyDriftElectricClient electric, Map<String, Object?> timestampMap) async {
  final companion = TimestampsCompanion.insert(
    id: timestampMap['id'] as String,
    createdAt: DateTime.parse(timestampMap['created_at'] as String),
    updatedAt: DateTime.parse(timestampMap['updated_at'] as String),
  );
  await electric.db.timestamps.insert().insert(companion);
}

Future<void> writeDatetime(
    MyDriftElectricClient electric, Map<String, Object?> datetimeMap) async {
  final companion = DatetimesCompanion.insert(
    id: datetimeMap['id'] as String,
    d: DateTime.parse(datetimeMap['d'] as String),
    t: DateTime.parse(datetimeMap['t'] as String),
  );
  await electric.db.datetimes.insert().insert(companion);
}

Future<Timestamp?> getTimestamp(
    MyDriftElectricClient electric, String id) async {
  final timestamp = await (electric.db.timestamps.select()
        ..where((tbl) => tbl.id.equals(id)))
      .getSingleOrNull();
  return timestamp;
}

Future<Datetime?> getDatetime(MyDriftElectricClient electric, String id) async {
  final datetime = await (electric.db.datetimes.select()
        ..where((tbl) => tbl.id.equals(id)))
      .getSingleOrNull();

  final rowJ = JsonEncoder.withIndent('  ')
      .convert(toColumns(datetime)?.map((key, value) {
    final Object? effectiveValue;
    if (value is DateTime) {
      effectiveValue = value.toIso8601String();
    } else {
      effectiveValue = value;
    }
    return MapEntry(key, effectiveValue);
  }));
  print('Found date time?:\n$rowJ');

  return datetime;
}

Future<bool> assertTimestamp(MyDriftElectricClient electric, String id,
    String expectedCreatedAt, String expectedUpdatedAt) async {
  final timestamp = await getTimestamp(electric, id);
  final matches =
      checkTimestamp(timestamp, expectedCreatedAt, expectedUpdatedAt);
  return matches;
}

Future<bool> assertDatetime(MyDriftElectricClient electric, String id,
    String expectedDate, String expectedTime) async {
  final datetime = await getDatetime(electric, id);
  final matches = checkDatetime(datetime, expectedDate, expectedTime);
  return matches;
}

bool checkTimestamp(
    Timestamp? timestamp, String expectedCreatedAt, String expectedUpdatedAt) {
  if (timestamp == null) return false;

  return timestamp.createdAt.millisecondsSinceEpoch ==
          DateTime.parse(expectedCreatedAt).millisecondsSinceEpoch &&
      timestamp.updatedAt.millisecondsSinceEpoch ==
          DateTime.parse(expectedUpdatedAt).millisecondsSinceEpoch;
}

bool checkDatetime(
    Datetime? datetime, String expectedDate, String expectedTime) {
  if (datetime == null) return false;
  return datetime.d.millisecondsSinceEpoch ==
          DateTime.parse(expectedDate).millisecondsSinceEpoch &&
      datetime.t.millisecondsSinceEpoch ==
          DateTime.parse(expectedTime).millisecondsSinceEpoch;
}

Future<SingleRow> writeBool(
    MyDriftElectricClient electric, String id, bool b) async {
  final row = await electric.db.bools.insertReturning(
    BoolsCompanion.insert(
      id: id,
      b: Value(b),
    ),
  );
  return SingleRow.fromItem(row);
}

Future<bool?> getBool(MyDriftElectricClient electric, String id) async {
  final row = await (electric.db.bools.select()..where((t) => t.id.equals(id)))
      .getSingle();
  return row.b;
}

Future<void> getDatetimes(MyDriftElectricClient electric) async {
  // final rows = await electric.db.datetimes.select().get();
  throw UnimplementedError();
}

Future<Rows> getItems(DriftElectricClient electric) async {
  final rows = await electric.db
      .customSelect(
        "SELECT * FROM items;",
      )
      .get();
  return _toRows(rows);
}

Future<Rows> getItemIds(DriftElectricClient electric) async {
  final rows = await electric.db
      .customSelect(
        "SELECT id FROM items;",
      )
      .get();
  return _toRows(rows);
}

Future<SingleRow> getUUID(MyDriftElectricClient electric, String id) async {
  final row = await (electric.db.uuids.select()..where((t) => t.id.equals(id)))
      .getSingle();
  return SingleRow.fromItem(row);
}

Future<Rows> getUUIDs(MyDriftElectricClient electric) async {
  final rows = await electric.db
      .customSelect(
        "SELECT * FROM Uuids;",
      )
      .get();
  return _toRows(rows);
}

Future<SingleRow> writeUUID(MyDriftElectricClient electric, String id) async {
  final item = await electric.db.uuids.insertReturning(
    UuidsCompanion.insert(
      id: id,
    ),
  );
  return SingleRow.fromItem(item);
}

Future<SingleRow> getInt(MyDriftElectricClient electric, String id) async {
  final item = await (electric.db.ints.select()..where((t) => t.id.equals(id)))
      .getSingle();
  return SingleRow.fromItem(item);
}

Future<SingleRow> writeInt(
    MyDriftElectricClient electric, String id, int i2, int i4) async {
  final item = await electric.db.ints.insertReturning(
    IntsCompanion.insert(
      id: id,
      i2: Value(i2),
      i4: Value(i4),
    ),
  );
  return SingleRow.fromItem(item);
}

Future<SingleRow> getFloat(MyDriftElectricClient electric, String id) async {
  final item = await (electric.db.floats.select()
        ..where((t) => t.id.equals(id)))
      .getSingle();
  return SingleRow.fromItem(item);
}

Future<SingleRow> writeFloat(
    MyDriftElectricClient electric, String id, double f8) async {
  final item = await electric.db.floats.insertReturning(
    FloatsCompanion.insert(
      id: id,
      f8: Value(f8),
    ),
  );
  return SingleRow.fromItem(item);
}

Future<Rows> getItemColumns(
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
  Map<String, Object?> values,
) async {
  insertExtendedInto(electric, "items", values);
}

Future<void> insertExtendedInto(
  DriftElectricClient electric,
  String table,
  Map<String, Object?> values,
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
    "INSERT INTO $table($columnNames) VALUES ($placeholders) RETURNING *;",
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

Future<Rows> getOtherItems(DriftElectricClient electric) async {
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

// It has a custom toString to match Lux expects
Rows _toRows(List<QueryRow> rows) {
  return Rows(
    rows.map((r) {
      final data = r.data;
      return data;
    }).toList(),
  );
}

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

class Rows {
  final List<Map<String, Object?>> rows;

  Rows(this.rows);

  @override
  String toString() {
    return listToPrettyStr(rows, withNewLine: true);
  }
}

class SingleRow {
  final Map<String, Object?> row;

  SingleRow(this.row);

  factory SingleRow.fromItem(Insertable item) {
    return SingleRow(toColumns(item)!);
  }

  factory SingleRow.fromColumns(Map<String, Object?> cols) {
    return SingleRow(cols);
  }

  @override
  String toString() {
    return mapToPrettyStr(row);
  }
}

Map<String, Object?>? toColumns(Insertable? o) {
  if (o == null) return null;
  final cols = o.toColumns(false);
  return cols.map((key, value) => MapEntry(key, (value as Variable).value));
}
