import 'dart:async';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:electricsql_cli/src/commands/command_util.dart';
import 'package:electricsql_cli/src/commands/docker_commands/docker_utils.dart';
import 'package:electricsql_cli/src/config.dart';
import 'package:electricsql_cli/src/util.dart';
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
      config: config,
    );
    return 0;
  }
}

Future<void> start({
  Logger? logger,
  bool? detach,
  bool? exitOnDetached,
  bool? withPostgres,
  required Config config,
}) async {
  final finalLogger = logger ?? Logger();

  final bool finalExitOnDetached = exitOnDetached ?? true;

  finalLogger.info(
    'Starting ElectricSQL sync service${withPostgres == true ? ' and PostgreSQL' : ''}',
  );

  final appName = getAppName() ?? 'electric';

  final env = configToEnv(config);

  final dockerConfig = <String, String>{
    ...env,
    ...(withPostgres == true
        ? {
            'COMPOSE_PROFILES': 'with-postgres',
            'COMPOSE_ELECTRIC_SERVICE': 'electric-with-postgres',
            'DATABASE_URL':
                'postgresql://postgres:${env['DATABASE_PASSWORD'] ?? 'pg_password'}@postgres:${env['DATABASE_PORT'] ?? '5432'}/$appName',
            'LOGICAL_PUBLISHER_HOST': 'electric',
          }
        : {}),
  };
  finalLogger.info('Docker compose config: ${prettyMap(dockerConfig)}');

  final proc = await dockerCompose(
    'up',
    [
      ...(detach == true ? ['--detach'] : []),
    ],
    env: dockerConfig,
  );

  final exitCode = await waitForProcess(proc);

  if (exitCode == 0) {
    if (withPostgres == true && detach == true) {
      finalLogger.info('Waiting for PostgreSQL to be ready...');
      // Await the postgres container to be ready
      final start = DateTime.now().millisecondsSinceEpoch;
      const timeout = 10 * 1000; // 10 seconds
      while (DateTime.now().millisecondsSinceEpoch - start < timeout) {
        if (await checkPostgres(env)) {
          finalLogger.info('PostgreSQL is ready');
          if (finalExitOnDetached) {
            exit(0);
          }
          return;
        }
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
      finalLogger.err(
        "Timed out waiting for PostgreSQL to be ready. Check the output from 'docker compose' above.",
      );
      exit(1);
    } else {
      return;
    }
  } else {
    // Don't log an error if the user pressed Ctrl+C
    if (exitCode != kSigIntExitCode) {
      finalLogger.err(
          "Failed to start the Electric backend. Check the output from 'docker compose' above. "
          'If the error message mentions a port already being allocated or address being already in use, '
          'please change the configuration to an alternative port via the ELECTRIC_HTTP_PORT or '
          'ELECTRIC_PG_PROXY_PORT environment variables.');
    }
    exit(exitCode);
  }
}

Future<bool> checkPostgres(Map<String, String> env) async {
  final proc =
      await dockerCompose('exec', ['postgres', 'pg_isready'], env: env);
  final exitCode = await waitForProcess(proc);
  return exitCode == 0;
}

Map<String, String> configToEnv(Config config) {
  final Map<String, String> env = {};
  for (final entry in config.entries) {
    final key = entry.key;
    final val = entry.value;
    if (val == true) {
      env[key] = 'true';
    } else if (val != null) {
      env[key] = val.toString();
    }
  }
  return env;
}
