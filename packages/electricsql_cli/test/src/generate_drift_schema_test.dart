import 'dart:io';

import 'package:code_builder/code_builder.dart';
import 'package:electricsql_cli/src/commands/generate_migrations/builder.dart';
import 'package:electricsql_cli/src/commands/generate_migrations/drift_gen_opts.dart';
import 'package:electricsql_cli/src/commands/generate_migrations/prisma.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  test('generate drift schema code', () async {
    final _prismaSchemaFile = join(
      Directory.current.path,
      'test/fixtures/schema.prisma',
    );
    final _prismaSchema = File(_prismaSchemaFile).readAsStringSync();
    final schemaInfo = extractInfoFromPrismaSchema(_prismaSchema);

    final contents = generateDriftSchemaDartCode(schemaInfo);

    final expectedFile = join(
      Directory.current.path,
      'test/fixtures/expected_drift_gen_code.dart',
    );

    // File("out.dart").writeAsStringSync(contents);

    expect(contents, await File(expectedFile).readAsString());
  });
}
