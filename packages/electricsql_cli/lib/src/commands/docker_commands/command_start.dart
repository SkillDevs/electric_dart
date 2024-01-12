import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:electricsql_cli/src/commands/command_util.dart';
import 'package:electricsql_cli/src/config.dart';
import 'package:mason_logger/mason_logger.dart';

class DockerStartCommand extends Command<int> {
  DockerStartCommand({
    required Logger logger,
  }) : _logger = logger {
    addOptionGroupToCommand(this, 'electric');

    argParser.addFlag(
      'detach',
      help: 'Run in the background instead of printing logs to the console',
      defaultsTo: false,
      negatable: false,
    );
  }

  @override
  String get description =>
      'Start the ElectricSQL sync service, and an optional PostgreSQL';

  @override
  String get name => 'start';

  final Logger _logger;

  @override
  FutureOr<int>? run() async {
    if (argResults!['database-url'] != null &&
        argResults!['with-postgres'] != null) {
      _logger.err('You cannot set --database-url when using --with-postgres.');
      return 1;
    }

    final opts = getOptsFromCommand(this);
    final config = getConfig(opts);
    if (!config.read<bool>('WITH_POSTGRES') &&
        config.read<String>('DATABASE_URL').isEmpty) {
      _logger.err(
        'You must set --database-url or the ELECTRIC_DATABASE_URL env var when not using --with-postgres.',
      );
      return 1;
    }

    await start(
      logger: _logger,
      detach: opts['detach'] as bool?,
      withPostgres: config.read<bool>('WITH_POSTGRES'),
    );
    return 0;
  }
}

Future<void> start({
  Logger? logger,
  bool? detach,
  bool? withPostgres,
}) async {
  print('Starting ElectricSQL sync service...');
  print("detach: $detach");
  print("withPostgres: $withPostgres");
}
