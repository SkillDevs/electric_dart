import 'dart:async';
import 'dart:io';
import 'package:electricsql_cli/src/assets.dart';
import 'package:electricsql_cli/src/util.dart';
import 'package:path/path.dart' as path;

Future<Process> dockerCompose(
  String command,
  List<String> userArgs, {
  Map<String, String> env = const {},
}) async {
  final appName = getAppName() ?? 'electric';

  final assetsDir = await getElectricCLIAssetsDir();
  final composeFile = File(path.join(assetsDir.path, 'docker/compose.yaml'));

  final args = <String>[
    'compose',
    '--ansi',
    'always',
    '-f',
    composeFile.absolute.path,
    command,
    ...userArgs,
  ];

  final proc = await Process.start(
    'docker',
    args,
    mode: ProcessStartMode.inheritStdio,
    environment: {
      ...Platform.environment,
      'APP_NAME': appName,
      'COMPOSE_PROJECT_NAME': appName,
      ...env,
    },
  );

  return proc;
}
