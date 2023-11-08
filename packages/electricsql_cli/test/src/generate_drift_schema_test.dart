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
  String? resolveTableName(String sqlTableName) {
    switch (sqlTableName) {
      case 'GenOpts':
        return 'GenOptsDriftTable';
    }
    return null;
  }

  @override
  DataClassNameInfo? resolveDataClassName(String sqlTableName) {
    switch (sqlTableName) {
      case 'GenOpts':
        return DataClassNameInfo(
          'MyDataClassName',
          extending: refer('BaseModel', 'package:myapp/base_model.dart'),
        );
    }
    return null;
  }

  @override
  String? resolveColumnName(String sqlTableName, String sqlColumnName) {
    if (sqlTableName == 'GenOpts' && sqlColumnName == 'id') {
      return 'myIdCol';
    }
    return null;
  }

  @override
  Expression? extendColumnDefinition(
    String sqlTableName,
    String sqlColumnName,
    Expression columnBuilderExpression,
  ) {
    if (sqlTableName == 'GenOpts' && sqlColumnName == 'timestamp') {
      return clientDefaultDateTimeNowExpression(columnBuilderExpression);
    }
    return null;
  }
}
