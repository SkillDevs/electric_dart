import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:electricsql_cli/src/commands/command_util.dart';
import 'package:electricsql_cli/src/commands/docker_commands/docker_utils.dart';
import 'package:electricsql_cli/src/util.dart';
import 'package:mason_logger/mason_logger.dart';

class DockerStopCommand extends Command<int> {
  DockerStopCommand({
    required Logger logger,
  }) : _logger = logger {
    argParser.addFlag(
      'remove',
      abbr: 'r',
      help: 'Also remove the containers and volumes',
      defaultsTo: false,
      negatable: false,
    );
  }

  @override
  String get description =>
      'Stop the ElectricSQL sync service, and any optional PostgreSQL';

  @override
  String get name => 'stop';

  // ignore: unused_field
  final Logger _logger;

  @override
  FutureOr<int>? run() async {
    final opts = getOptsFromCommand(this);
    await stop(
      logger: _logger,
      remove: opts['remove'] as bool?,
    );
    return 0;
  }
}

Future<void> stop({
  Logger? logger,
  bool? remove,
}) async {
  final finalLogger = logger ?? Logger();

  const env = <String, String>{
    'COMPOSE_PROFILES': 'with-postgres', // Stop any PostgreSQL containers too
  };
  Process proc;
  if (remove == true) {
    proc = await dockerCompose('down', ['--volumes'], env: env);
  } else {
    proc = await dockerCompose('stop', [], env: env);
  }

  final code = await waitForProcess(proc);

  if (code != 0) {
    finalLogger.err('Failed to stop the ElectricSQL sync service.');
    exit(1);
  }
}
