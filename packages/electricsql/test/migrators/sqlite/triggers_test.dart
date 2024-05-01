import 'dart:convert';

import 'package:electricsql/drivers/sqlite3.dart';
import 'package:electricsql/src/electric/adapter.dart';
import 'package:electricsql/src/migrators/query_builder/query_builder.dart';
import 'package:electricsql/src/migrators/triggers.dart';
import 'package:electricsql/src/satellite/config.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import '../../satellite/common.dart';
import '../../util/sqlite.dart';
import '../triggers.dart';

late Database db;
late DatabaseAdapter adapter;

final defaults = satelliteDefaults('main');
final oplogTable =
    '"${defaults.oplogTable.namespace}"."${defaults.oplogTable.tablename}"';
final personTable = getPersonTable('main');

Future<void> migratePersonTable() async {
  await migrateDb(adapter, personTable, kSqliteQueryBuilder);
}

void main() {
  setUp(() {
    db = openSqliteDbMemory();
    adapter = SqliteAdapter(db);
    addTearDown(() => db.dispose());
  });

  test('generateTableTriggers should create correct triggers for a table', () {
    // Generate the oplog triggers
    final triggers = generateTableTriggers(personTable, kSqliteQueryBuilder);

    // Check that the oplog triggers are correct
    final triggersSQL = triggers.map((t) => t.sql).join('\n');

    expect(
      triggersSQL.contains(
        '''
CREATE TRIGGER insert_main_personTable_into_oplog
  AFTER INSERT ON "main"."personTable"
  WHEN 1 = (SELECT flag from _electric_trigger_settings WHERE namespace = 'main' AND tablename = 'personTable')
BEGIN
  INSERT INTO _electric_oplog (namespace, tablename, optype, primaryKey, newRow, oldRow, timestamp)
  VALUES ('main', 'personTable', 'INSERT', json_patch('{}', json_object('id', cast(new."id" as TEXT))), json_object('age', new."age", 'blob', CASE WHEN new."blob" IS NOT NULL THEN hex(new."blob") ELSE NULL END, 'bmi', cast(new."bmi" as TEXT), 'id', cast(new."id" as TEXT), 'int8', cast(new."int8" as TEXT), 'name', new."name"), NULL, NULL);
END;''',
      ),
      isTrue,
    );

    expect(
      triggersSQL.contains('''
CREATE TRIGGER update_main_personTable_into_oplog
  AFTER UPDATE ON "main"."personTable"
  WHEN 1 = (SELECT flag from _electric_trigger_settings WHERE namespace = 'main' AND tablename = 'personTable')
BEGIN
  INSERT INTO _electric_oplog (namespace, tablename, optype, primaryKey, newRow, oldRow, timestamp)
  VALUES ('main', 'personTable', 'UPDATE', json_patch('{}', json_object('id', cast(new."id" as TEXT))), json_object('age', new."age", 'blob', CASE WHEN new."blob" IS NOT NULL THEN hex(new."blob") ELSE NULL END, 'bmi', cast(new."bmi" as TEXT), 'id', cast(new."id" as TEXT), 'int8', cast(new."int8" as TEXT), 'name', new."name"), json_object('age', old."age", 'blob', CASE WHEN old."blob" IS NOT NULL THEN hex(old."blob") ELSE NULL END, 'bmi', cast(old."bmi" as TEXT), 'id', cast(old."id" as TEXT), 'int8', cast(old."int8" as TEXT), 'name', old."name"), NULL);
END;'''),
      isTrue,
    );

    expect(
      triggersSQL.contains(
        '''
CREATE TRIGGER delete_main_personTable_into_oplog
  AFTER DELETE ON "main"."personTable"
  WHEN 1 = (SELECT flag from _electric_trigger_settings WHERE namespace = 'main' AND tablename = 'personTable')
BEGIN
  INSERT INTO _electric_oplog (namespace, tablename, optype, primaryKey, newRow, oldRow, timestamp)
  VALUES ('main', 'personTable', 'DELETE', json_patch('{}', json_object('id', cast(old."id" as TEXT))), NULL, json_object('age', old."age", 'blob', CASE WHEN old."blob" IS NOT NULL THEN hex(old."blob") ELSE NULL END, 'bmi', cast(old."bmi" as TEXT), 'id', cast(old."id" as TEXT), 'int8', cast(old."int8" as TEXT), 'name', old."name"), NULL);
END;''',
      ),
      isTrue,
    );
  });

  test('oplog insertion trigger should insert row into oplog table', () async {
    final tableName = personTable.tableName;

    // Migrate the DB with the necessary tables and triggers
    await migratePersonTable();

    // Insert a row in the table
    final insertRowSQL =
        "INSERT INTO $tableName (id, name, age, bmi, int8, blob) VALUES (1, 'John Doe', 30, 25.5, 7, x'0001ff')";
    db.execute(insertRowSQL);

    // Check that the oplog table contains an entry for the inserted row
    final oplogRows = db.select('SELECT * FROM $oplogTable').toList();

    expect(oplogRows.length, 1);
    expect(oplogRows[0], {
      'namespace': 'main',
      'tablename': tableName,
      'optype': 'INSERT',
      // `id` and `bmi` values are stored as strings
      // because we cast REAL values to text in the trigger
      // to circumvent SQLite's bug in the `json_object` function
      // that is used in the triggers.
      // cf. `joinColsForJSON` function in `src/migrators/triggers.ts`
      // These strings are then parsed back into real numbers
      // by the `deserialiseRow` function in `src/satellite/oplog.ts`
      'primaryKey': json.encode({'id': '1.0'}),
      'newRow': json.encode({
        'age': 30,
        'blob': '0001FF', // Blobs are serialized as hex strings in the op
        'bmi': '25.5',
        'id': '1.0',
        'int8': '7', // BigInts are serialized as strings in the oplog
        'name': 'John Doe',
      }),
      'oldRow': null,
      'timestamp': null,
      'rowid': 1,
      'clearTags': '[]',
    });
  });

  test('oplog trigger should handle Infinity values correctly', () async {
    final tableName = personTable.tableName;

    // Migrate the DB with the necessary tables and triggers
    await migratePersonTable();

    // Insert a row in the table
    final insertRowSQL =
        "INSERT INTO $tableName (id, name, age, bmi, int8, blob) VALUES (-9e999, 'John Doe', 30, 9e999, 7, x'0001ff')";
    db.execute(insertRowSQL);

    // Check that the oplog table contains an entry for the inserted row
    final oplogRows = db.select('SELECT * FROM $oplogTable');
    expect(oplogRows.length, 1);
    expect(oplogRows[0], {
      'namespace': 'main',
      'tablename': tableName,
      'optype': 'INSERT',
      // `id` and `bmi` values are stored as strings
      // because we cast REAL values to text in the trigger
      // to circumvent SQLite's bug in the `json_object` function
      // that is used in the triggers.
      // cf. `joinColsForJSON` function in `src/migrators/triggers.ts`
      // These strings are then parsed back into real numbers
      // by the `deserialiseRow` function in `src/satellite/oplog.ts`
      'primaryKey': json.encode({'id': '-Inf'}),
      'newRow': json.encode({
        'age': 30,
        'blob': '0001FF', // Blobs are serialized as hex strings in the op
        'bmi': 'Inf',
        'id': '-Inf',
        'int8': '7', // BigInts are serialized as strings in the oplog
        'name': 'John Doe',
      }),
      'oldRow': null,
      'timestamp': null,
      'rowid': 1,
      'clearTags': '[]',
    });
  });

  triggerTests(
    getAdapter: () => adapter,
    personTable: personTable,
    migratePersonTable: migratePersonTable,
    defaults: defaults,
  );
}
