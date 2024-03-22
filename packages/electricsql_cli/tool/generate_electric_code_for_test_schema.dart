// Generates the electric code for the database in the [electricsql] test

import 'dart:io';

import 'package:electricsql_cli/electricsql_cli.dart';
import 'package:path/path.dart';

final Directory projectDir =
    Directory(join(File(Platform.script.toFilePath()).parent.path, '../../electricsql'))
        .absolute;

Future<void> main() async {
  final prismaSchemaFile = File(join(projectDir.path, 'test/client/drift/schema.prisma'));

  final prismaSchemaContent = prismaSchemaFile.readAsStringSync();

  final schemaInfo = extractInfoFromPrismaSchema(
    prismaSchemaContent,
  );

  final driftSchemaFile =
      File(join(projectDir.path, 'test/client/drift/generated/electric/drift_schema.dart'));
  await buildDriftSchemaDartFile(schemaInfo, driftSchemaFile);
  // ignore: avoid_print
  print('Code generated! Now run build_runner for drift');
}
