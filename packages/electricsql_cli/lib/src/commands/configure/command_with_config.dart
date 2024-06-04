import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:electricsql_cli/src/config.dart';
import 'package:electricsql_cli/src/env.dart';
import 'package:electricsql_cli/src/logger.dart';
import 'package:electricsql_cli/src/util/util.dart';

class CommandWithConfigCommand extends Command<int> {
  CommandWithConfigCommand({
    required Logger logger,
  }) : _logger = logger;

  @override
  String get description => 'Run a command with config arguments substituted';

  @override
  String get name => 'with-config';

  // ignore: unused_field
  final Logger _logger;

  @override
  FutureOr<int>? run() async {
    await withConfig(
      logger: _logger,
      command: argResults!.rest.first,
    );
    return 0;
  }
}

Future<int> withConfig({
  required String command,
  Config? config,
  Logger? logger,
}) async {
  final _config = config ?? getConfig();
  // ignore: invalid_use_of_visible_for_testing_member
  final env = programEnv.map;
  final re = RegExp(r'\{{([A-Z_]+)}}');
  final cmd = command.replaceAllMapped(re, (match) {
    final envVar = match.group(1)!;

    final Object? value = envVar.startsWith('ELECTRIC_')
        ? _config.read(envVar.substring('ELECTRIC_'.length)) ?? env[envVar]
        : env[envVar];
    if (value == null) {
      return match.group(0)!;
    } else if (value is String) {
      return value;
    } else {
      return value.toString();
    }
  }).split(' ');

  final proc = await Process.start(
    cmd[0],
    cmd.sublist(1),
    mode: ProcessStartMode.inheritStdio,
    runInShell: true,
    environment: {
      ...env,
      ...envFromConfig(_config),
    },
  );
  final exitCode = await waitForProcess(proc);
  return exitCode;
}
