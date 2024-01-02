import 'dart:async';
import 'dart:io';
import 'dart:async';
import 'dart:io';
import 'package:electricsql_cli/src/assets.dart';
import 'package:electricsql_cli/src/exit_signals.dart';
import 'package:path/path.dart' as path;

// final String currentScriptDir = Platform.script.path;
// final String envrcFile = path.join(currentScriptDir, '../../backend/.envrc');
// final String composeFile =
//     path.join(currentScriptDir, '../../backend/docker-compose.yaml');

Future<int> dockerCompose(
  String command,
  List<String> userArgs, {
  Map<String, String> env = const {},
}) async {
  // TODO(dart): appname
  const appName = 'electric';
  //const appName = getAppName() ?? 'electric'

  final tempDir = Directory.systemTemp.createTempSync('electric_sql_cli');
  final composeFile = File(path.join(tempDir.path, 'compose.yaml'));
  await composeFile.writeAsString(kComposeYaml);

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
    },
  );

  final disposeExitSignals = handleExitSignals(
    onExit: (_) async {
      // Don't exit, let the docker subprocess handle it
      return false;
    },
  );

  try {
    final exitCode = await proc.exitCode;
    return exitCode;
  } finally {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }

    await disposeExitSignals();
  }
}
