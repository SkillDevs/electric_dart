import 'dart:async';
import 'dart:io';
import 'dart:async';
import 'dart:io';
import 'package:electricsql_cli/src/assets.dart';
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

  final disposeExitSignals = _handleExitSignals(
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

typedef DisposeFun = Future<void> Function();

DisposeFun _handleExitSignals({
  required Future<bool> Function(ProcessSignal) onExit,
}) {
  StreamSubscription<ProcessSignal>? s1, s2;

  Future<void> dispose() async {
    await s1?.cancel();
    await s2?.cancel();
  }

  Future<void> effectiveOnExit(ProcessSignal signal) async {
    final exitRes = await onExit(signal);

    if (exitRes) {
      await dispose();
      print("Exit syscall has been called");
      exit(1);
    }
  }

  s1 = ProcessSignal.sigint.watch().listen(effectiveOnExit);

  // SIGTERM is not supported on Windows. Attempting to register a SIGTERM
  // handler raises an exception.
  if (!Platform.isWindows) {
    s2 = ProcessSignal.sigterm.watch().listen(effectiveOnExit);
  }

  return dispose;
}
