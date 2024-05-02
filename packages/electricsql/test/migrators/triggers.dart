import 'package:electricsql/src/electric/adapter.dart';
import 'package:electricsql/src/migrators/query_builder/query_builder.dart';
import 'package:electricsql/src/migrators/triggers.dart';
import 'package:electricsql/src/satellite/config.dart';
import 'package:electricsql/util.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

@isTestGroup
void triggerTests({
  required DatabaseAdapter Function() getAdapter,
  required Table personTable,
  required Future<void> Function() migratePersonTable,
  required SatelliteOpts defaults,
  required Dialect dialect,
}) {
  test('oplog trigger should separate null blobs from empty blobs', () async {
    final adapter = getAdapter();
    final namespace = personTable.namespace;
    final tableName = personTable.tableName;

    // Migrate the DB with the necessary tables and triggers
    await migratePersonTable();

    // Insert null and empty rows in the table
    final insertRowNullSQL =
        '''INSERT INTO "$namespace"."$tableName" (id, name, age, bmi, int8, blob) VALUES (1, 'John Doe', 30, 25.5, 7, NULL)''';
    final blobValue = dialect == Dialect.postgres ? "'\\x'" : "x''";
    final insertRowEmptySQL =
        '''INSERT INTO "$namespace"."$tableName" (id, name, age, bmi, int8, blob) VALUES (2, 'John Doe', 30, 25.5, 7, $blobValue)''';
    await adapter.run(Statement(insertRowNullSQL));
    await adapter.run(Statement(insertRowEmptySQL));

    // Check that the oplog table contains an entry for the inserted row
    final oplogRows = await adapter.query(
      Statement(
        'SELECT * FROM "${defaults.oplogTable.namespace}"."${defaults.oplogTable.tablename}"',
      ),
    );
    expect(oplogRows.length, 2);
    expect(oplogRows[0]['newRow'], matches(RegExp(r',\s*"blob":\s*null\s*,')));
    expect(oplogRows[1]['newRow'], matches(RegExp(r',\s*"blob":\s*""\s*,')));
  });
}
