import 'dart:async';

import 'package:args/command_runner.dart';
import 'package:electricsql_cli/src/commands/command_util.dart';
import 'package:electricsql_cli/src/commands/docker_commands/docker_utils.dart';
import 'package:electricsql_cli/src/config.dart';
import 'package:electricsql_cli/src/util.dart';
import 'package:mason_logger/mason_logger.dart';

class DockerPsqlCommand extends Command<int> {
  DockerPsqlCommand({
    required Logger logger,
  }) : _logger = logger {
    addOptionGroupToCommand(this, 'proxy');

    // addSpecificOptionsSeparator(this);
  }

  @override
  String get description =>
      'Connect with psql to the ElectricSQL PostgreSQL proxy';

  @override
  String get name => 'psql';

  // ignore: unused_field
  final Logger _logger;

  @override
  FutureOr<int>? run() async {
    final opts = getOptsFromCommand(this);
    final config = getConfig(opts);
    await runPsqlCommand(
      logger: _logger,
      config: config,
    );
    return 0;
  }
}

Future<void> runPsqlCommand({
  Logger? logger,
  required Config config,
}) async {
  // As we are connecting to the proxy from within the docker network, we have to
  // use the container name instead of localhost.
  final containerDbUrl = buildDatabaseURL(
    user: config.read<String>('DATABASE_USER'),
    password: config.read<String>('PG_PROXY_PASSWORD'),
    host: 'electric',
    port: parsePgProxyPort(config.read<String>('PG_PROXY_PORT')).port,
    dbName: config.read<String>('DATABASE_NAME'),
  );
  final proc = await dockerCompose(
    'exec',
    ['-it', 'postgres', 'psql', containerDbUrl],
    containerName: config.read<String>('CONTAINER_NAME'),
  );
  await waitForProcess(proc);
}
