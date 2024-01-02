import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:electricsql_cli/src/commands/docker_commands/docker_utils.dart';
import 'package:mason_logger/mason_logger.dart';

class DockerStatusCommand extends Command<int> {
  DockerStatusCommand({
    required Logger logger,
  }) : _logger = logger;

  @override
  String get description =>
      'Show status of the ElectricSQL sync service docker containers';

  @override
  String get name => 'status';

  final Logger _logger;

  @override
  FutureOr<int>? run() async {
    await dockerCompose('ps', []);
    return 0;
  }
}
