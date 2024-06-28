import 'dart:io';

import 'package:electricsql/electricsql.dart';
import 'package:electricsql_cli/src/commands/generate/builder.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  test('generate raw schema code', () async {
    const dbDescription = DBSchemaRaw(
      tableSchemas: {
        'table1': TableSchema(
          fields: {
            'col1': PgType.text,
            'col2': PgType.int2,
          },
          relations: [
            Relation(
              fromField: 'fromField1',
              toField: 'toField1',
              relationName: 'relationName1',
              relatedTable: 'relatedTable1',
            ),
          ],
        ),
        'table2': TableSchema(fields: {'col3': PgType.bool}, relations: []),
      },
      migrations: [],
      pgMigrations: [],
    );

    final contents = generateRawSchemaDartCode(dbDescription);

    final expectedFile = join(
      Directory.current.path,
      'test/fixtures/expected_raw_schema_gen_code.dart',
    );

    // File("out_raw.dart").writeAsStringSync(contents);

    expect(contents, await File(expectedFile).readAsString());
  });
}
