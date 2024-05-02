import 'dart:convert';

import 'package:electricsql/drivers/sqlite3.dart';
import 'package:electricsql/src/drivers/drift/drift_adapter.dart';
import 'package:electricsql/src/electric/adapter.dart';
import 'package:electricsql/src/migrators/query_builder/query_builder.dart';
import 'package:electricsql/src/migrators/triggers.dart';
import 'package:electricsql/src/satellite/config.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import '../../drivers/drift_test.dart';
import '../../satellite/common.dart';
import '../../support/postgres.dart';
import '../triggers.dart';

const port = 5300;

late EmbeddedPostgresDb pgEmbedded;
late ScopedPgDb scopedPgDb;

late GenericDb db;
late DatabaseAdapter adapter;

final defaults = satelliteDefaults('public');
final oplogTable =
    '"${defaults.oplogTable.namespace}"."${defaults.oplogTable.tablename}"';

final personTable = getPersonTable('public');
final personNamespace = personTable.namespace;
final personTableName = personTable.tableName;
final qualifiedPersonTable = '"$personNamespace"."$personTableName"';

Future<void> migratePersonTable() async {
  await migrateDb(adapter, personTable, kPostgresQueryBuilder);
}

int i = 1;

void main() {
  setUpAll(() async {
    pgEmbedded = await makePgDatabase('bundle-migrator-tests', port);
  });

  tearDownAll(() async {
    await pgEmbedded.dispose();
  });

  setUp(() async {
    final dbName = 'triggers-test-${i++}';
    scopedPgDb = await initScopedPostgresDatabase(pgEmbedded, dbName);
    db = scopedPgDb.db;
    adapter = DriftAdapter(db);
    addTearDown(() => scopedPgDb.dispose());
  });

  test('generateTableTriggers should create correct triggers for a table', () {
    // Generate the oplog triggers
    final triggers = generateTableTriggers(personTable, kPostgresQueryBuilder);

    // Check that the oplog triggers are correct
    final triggersSQL = triggers.map((t) => t.sql).join('\n');

    expect(
      triggersSQL.contains(
        '''
        CREATE TRIGGER insert_public_personTable_into_oplog
          AFTER INSERT ON "public"."personTable"
            FOR EACH ROW
              EXECUTE FUNCTION insert_public_personTable_into_oplog_function();''',
      ),
      isTrue,
    );

    print(triggersSQL);

    expect(
      triggersSQL.contains('''
      CREATE OR REPLACE FUNCTION insert_public_personTable_into_oplog_function()
      RETURNS TRIGGER AS \$\$
      BEGIN
        DECLARE
          flag_value INTEGER;
        BEGIN
          -- Get the flag value from _electric_trigger_settings
          SELECT flag INTO flag_value FROM "public"._electric_trigger_settings WHERE namespace = 'public' AND tablename = 'personTable';
  
          IF flag_value = 1 THEN
            -- Insert into _electric_oplog
            INSERT INTO "public"._electric_oplog (namespace, tablename, optype, "primaryKey", "newRow", "oldRow", timestamp)
            VALUES (
              'public',
              'personTable',
              'INSERT',
              json_strip_nulls(json_build_object('id', cast(new."id" as TEXT))),
              jsonb_build_object('age', new."age", 'blob', CASE WHEN new."blob" IS NOT NULL THEN encode(new."blob"::bytea, 'hex') ELSE NULL END, 'bmi', cast(new."bmi" as TEXT), 'id', cast(new."id" as TEXT), 'int8', cast(new."int8" as TEXT), 'name', new."name"),
              NULL,
              NULL
            );
          END IF;
  
          RETURN NEW;
        END;
      END;
      \$\$ LANGUAGE plpgsql;
      '''),
      isTrue,
    );

    expect(
      triggersSQL.contains(
        '''
        CREATE TRIGGER update_public_personTable_into_oplog
          AFTER UPDATE ON "public"."personTable"
            FOR EACH ROW
              EXECUTE FUNCTION update_public_personTable_into_oplog_function();
      ''',
      ),
      isTrue,
    );

    expect(
      triggersSQL.contains(
        '''
      CREATE OR REPLACE FUNCTION update_public_personTable_into_oplog_function()
      RETURNS TRIGGER AS \$\$
      BEGIN
        DECLARE
          flag_value INTEGER;
        BEGIN
          -- Get the flag value from _electric_trigger_settings
          SELECT flag INTO flag_value FROM "public"._electric_trigger_settings WHERE namespace = 'public' AND tablename = 'personTable';
  
          IF flag_value = 1 THEN
            -- Insert into _electric_oplog
            INSERT INTO "public"._electric_oplog (namespace, tablename, optype, "primaryKey", "newRow", "oldRow", timestamp)
            VALUES (
              'public',
              'personTable',
              'UPDATE',
              json_strip_nulls(json_build_object('id', cast(new."id" as TEXT))),
              jsonb_build_object('age', new."age", 'blob', CASE WHEN new."blob" IS NOT NULL THEN encode(new."blob"::bytea, 'hex') ELSE NULL END, 'bmi', cast(new."bmi" as TEXT), 'id', cast(new."id" as TEXT), 'int8', cast(new."int8" as TEXT), 'name', new."name"),
              jsonb_build_object('age', old."age", 'blob', CASE WHEN old."blob" IS NOT NULL THEN encode(old."blob"::bytea, 'hex') ELSE NULL END, 'bmi', cast(old."bmi" as TEXT), 'id', cast(old."id" as TEXT), 'int8', cast(old."int8" as TEXT), 'name', old."name"),
              NULL
            );
          END IF;
  
          RETURN NEW;
        END;
      END;
      \$\$ LANGUAGE plpgsql;
      ''',
      ),
      isTrue,
    );

    expect(
      triggersSQL.contains(
        '''
        CREATE TRIGGER delete_public_personTable_into_oplog
          AFTER DELETE ON "public"."personTable"
            FOR EACH ROW
              EXECUTE FUNCTION delete_public_personTable_into_oplog_function();
      ''',
      ),
      isTrue,
    );

    expect(
      triggersSQL.contains(
        '''
      CREATE OR REPLACE FUNCTION delete_public_personTable_into_oplog_function()
      RETURNS TRIGGER AS \$\$
      BEGIN
        DECLARE
          flag_value INTEGER;
        BEGIN
          -- Get the flag value from _electric_trigger_settings
          SELECT flag INTO flag_value FROM "public"._electric_trigger_settings WHERE namespace = 'public' AND tablename = 'personTable';
  
          IF flag_value = 1 THEN
            -- Insert into _electric_oplog
            INSERT INTO "public"._electric_oplog (namespace, tablename, optype, "primaryKey", "newRow", "oldRow", timestamp)
            VALUES (
              'public',
              'personTable',
              'DELETE',
              json_strip_nulls(json_build_object('id', cast(old."id" as TEXT))),
              NULL,
              jsonb_build_object('age', old."age", 'blob', CASE WHEN old."blob" IS NOT NULL THEN encode(old."blob"::bytea, 'hex') ELSE NULL END, 'bmi', cast(old."bmi" as TEXT), 'id', cast(old."id" as TEXT), 'int8', cast(old."int8" as TEXT), 'name', old."name"),
              NULL
            );
          END IF;
  
          RETURN NEW;
        END;
      END;
      \$\$ LANGUAGE plpgsql;
      ''',
      ),
      isTrue,
    );
  });

  test('oplog insertion trigger should insert row into oplog table', () async {
    // Migrate the DB with the necessary tables and triggers
    await migratePersonTable();

    // Insert a row in the table
    final insertRowSQL =
        "INSERT INTO $qualifiedPersonTable (id, name, age, bmi, int8, blob) VALUES (1, 'John Doe', 30, 25.5, 7, '\\x0001ff')";
    await db.customStatement(insertRowSQL);

    // Check that the oplog table contains an entry for the inserted row
    final oplogRows = await db.customSelect('SELECT * FROM $oplogTable').get();

    expect(oplogRows.length, 1);
    expect(oplogRows[0], {
      'namespace': 'public',
      'tablename': personTableName,
      'optype': 'INSERT',
      // `id` and `bmi` values are stored as strings
      // because we cast REAL values to text in the trigger
      // to circumvent SQLite's bug in the `json_object` function
      // that is used in the triggers.
      // cf. `joinColsForJSON` function in `src/migrators/triggers.ts`
      // These strings are then parsed back into real numbers
      // by the `deserialiseRow` function in `src/satellite/oplog.ts`
      'primaryKey': '{"id":"1"}',
      // BigInts are serialized as strings in the oplog,
      'newRow':
          '{"id": "1", "age": 30, "bmi": "25.5", "blob": "0001ff", "int8": "7", "name": "John Doe"}',
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
        "INSERT INTO $qualifiedPersonTable (id, name, age, bmi, int8) VALUES ('-Infinity', 'John Doe', 30, 'Infinity', 7)";
    await db.customStatement(insertRowSQL);

    // Check that the oplog table contains an entry for the inserted row
    final oplogRows = await db.customSelect('SELECT * FROM $oplogTable').get();
    expect(oplogRows.length, 1);
    expect(oplogRows[0], {
      'namespace': 'public',
      'tablename': tableName,
      'optype': 'INSERT',
      // `id` and `bmi` values are stored as strings
      // because we cast REAL values to text in the trigger
      // to circumvent SQLite's bug in the `json_object` function
      // that is used in the triggers.
      // cf. `joinColsForJSON` function in `src/migrators/triggers.ts`
      // These strings are then parsed back into real numbers
      // by the `deserialiseRow` function in `src/satellite/oplog.ts`
      'primaryKey': '{"id":"-Infinity"}',
      // BigInts are serialized as strings in the oplog,
      'newRow':
          '{"id": "-Infinity", "age": 30, "bmi": "Infinity", "blob": null, "int8": "7", "name": "John Doe"}',
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
