import 'dart:io';

import 'package:code_builder/code_builder.dart';
import 'package:electricsql_cli/src/commands/generate/builder.dart';
import 'package:electricsql_cli/src/commands/generate/drift_gen_opts.dart';
import 'package:electricsql_cli/src/commands/generate/drift_schema.dart';
import 'package:electricsql_cli/src/commands/generate/prisma.dart';
import 'package:electricsql_cli/src/drift_gen_util.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  test('generate drift schema code', () async {
    final _prismaSchemaFile = join(
      Directory.current.path,
      'test/fixtures/schema.prisma',
    );
    final _prismaSchema = File(_prismaSchemaFile).readAsStringSync();
    final schemaInfo = extractInfoFromPrismaSchema(
      _prismaSchema,
      genOpts: CustomElectricDriftGenOpts(),
    );

    final contents = generateDriftSchemaDartCode(schemaInfo);

    final expectedFile = join(
      Directory.current.path,
      'test/fixtures/expected_drift_gen_code.dart',
    );

    // File("out.dart").writeAsStringSync(contents);

    expect(contents, await File(expectedFile).readAsString());
  });

  test('generate drift schema code with BigInts', () async {
    const _prismaSchema = '''
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model sample {
  c_id          String   @id @db.Uuid
  c_bigint      BigInt   @db.BigInt
}
''';
    final schemaInfo = extractInfoFromPrismaSchema(
      _prismaSchema,
      genOpts: UseBigIntsGenOps(),
    );

    final contents = generateDriftSchemaDartCode(schemaInfo);

    expect(
      contents,
      contains("Int64Column get cBigint => int64().named('c_bigint')();"),
    );

    final table =
        schemaInfo.tables.firstWhere((info) => info.tableName == 'sample');
    final column =
        table.columns.firstWhere((element) => element.columnName == 'c_bigint');
    expect(column.type, DriftElectricColumnType.bigint);
  });
}

class CustomElectricDriftGenOpts extends ElectricDriftGenOpts {
  @override
  DriftTableGenOpts? tableGenOpts(String sqlTableName) {
    switch (sqlTableName) {
      case 'GenOpts':
        return DriftTableGenOpts(
          driftTableName: 'GenOptsDriftTable',
          annotations: [
            dataClassNameAnnotation(
              'MyDataClassName',
              extending: refer('BaseModel', 'package:myapp/base_model.dart'),
            ),
          ],
        );

      case 'TableWithCustomRowClass':
        return DriftTableGenOpts(
          annotations: [
            useRowClassAnnotation(
              refer('MyCustomRowClass', 'package:myapp/custom_row_class.dart'),
              constructor: 'fromDb',
            ),
          ],
        );
    }
    return null;
  }

  @override
  DriftColumnGenOpts? columnGenOpts(String sqlTableName, String sqlColumnName) {
    if (sqlTableName == 'GenOpts') {
      if (sqlColumnName == 'id') {
        return DriftColumnGenOpts(
          driftColumnName: 'myIdCol',
        );
      } else if (sqlColumnName == 'timestamp') {
        return DriftColumnGenOpts(
          columnBuilderModifier: (e) => clientDefaultExpression(
            e,
            value: dateTimeNowExpression,
          ),
        );
      }
    }

    return null;
  }
}

class UseBigIntsGenOps extends ElectricDriftGenOpts {
  @override
  bool? get int8AsBigInt => true;
}
