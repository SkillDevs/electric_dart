import 'dart:async';
import 'dart:io';
import 'package:electricsql_cli/src/assets.dart';
import 'package:path/path.dart' as path;

Future<Process> dockerCompose(
  String command,
  List<String> userArgs, {
  String? containerName,
  Map<String, String> env = const {},
}) async {
  final assetsDir = await getElectricCLIAssetsDir();
  final composeFile = File(path.join(assetsDir.path, 'docker/compose.yaml'));
  final composeFileWithPostgres =
      File(path.join(assetsDir.path, 'docker/compose-with-postgres.yaml'));

  final withPostgres = env['COMPOSE_PROFILES'] == 'with-postgres';
  final args = <String>[
    'compose',
    '--ansi',
    'always',
    '-f',
    (withPostgres ? composeFileWithPostgres : composeFile).absolute.path,
    command,
    ...userArgs,
  ];

  final proc = await Process.start(
    'docker',
    args,
    mode: ProcessStartMode.inheritStdio,
    environment: {
      ...Platform.environment,
      if (containerName != null) 'COMPOSE_PROJECT_NAME': containerName,
      ...env,
    },
  );

  return proc;
}
