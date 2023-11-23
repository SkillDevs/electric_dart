import 'dart:io';

import 'package:code_builder/code_builder.dart';
import 'package:electricsql_cli/src/commands/generate/builder.dart';
import 'package:electricsql_cli/src/commands/generate/drift_gen_opts.dart';
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
}

class CustomElectricDriftGenOpts extends ElectricDriftGenOpts {
  @override
  DriftTableGenOpts? tableGenOpts(String sqlTableName) {
    switch (sqlTableName) {
      case 'GenOpts':
        return DriftTableGenOpts(
          driftTableName: 'GenOptsDriftTable',
          dataClassName: DataClassNameInfo(
            'MyDataClassName',
            extending: refer('BaseModel', 'package:myapp/base_model.dart'),
          ),
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
