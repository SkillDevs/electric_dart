import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:electricsql_cli/src/config.dart';
import 'package:electricsql_cli/src/util.dart';
import 'package:mason_logger/mason_logger.dart';

class ShowConfigCommand extends Command<int> {
  ShowConfigCommand({
    required Logger logger,
  }) : _logger = logger;

  @override
  String get description => 'Show the current configuration';

  @override
  String get name => 'show-config';

  // ignore: unused_field
  final Logger _logger;

  @override
  FutureOr<int>? run() async {
    showConfig(
      logger: _logger,
    );
    return 0;
  }
}

void showConfig({Logger? logger}) {
  final finalLogger = logger ?? Logger();
  final config = getConfig();
  finalLogger.info(prettyMap(Map.fromEntries(config.entries)));
}
