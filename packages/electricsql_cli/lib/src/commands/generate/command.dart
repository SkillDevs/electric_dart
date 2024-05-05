import 'dart:io';
import 'dart:math';

import 'package:archive/archive_io.dart';
import 'package:args/command_runner.dart';
import 'package:electricsql/migrators.dart';
import 'package:electricsql_cli/src/commands/command_util.dart';
import 'package:electricsql_cli/src/commands/configure/command_with_config.dart';
import 'package:electricsql_cli/src/commands/docker_commands/command_start.dart';
import 'package:electricsql_cli/src/commands/docker_commands/command_stop.dart';
import 'package:electricsql_cli/src/commands/docker_commands/precheck.dart';
import 'package:electricsql_cli/src/commands/generate/builder.dart';
import 'package:electricsql_cli/src/commands/generate/builder/util.dart';
import 'package:electricsql_cli/src/commands/generate/drift_gen_opts.dart';
import 'package:electricsql_cli/src/commands/generate/prisma.dart';
import 'package:electricsql_cli/src/config.dart';
import 'package:electricsql_cli/src/env.dart';
import 'package:electricsql_cli/src/get_port.dart';
import 'package:electricsql_cli/src/logger.dart';
import 'package:electricsql_cli/src/util.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;

const String defaultDriftSchemaFileName = 'drift_schema.dart';
const bool _defaultDebug = false;

/// {@template sample_command}
///
/// `electricsql_cli generate`
/// A [Command] to exemplify a sub command
/// {@endtemplate}
class GenerateElectricClientCommand extends Command<int> {
  GenerateElectricClientCommand({
    required Logger logger,
  }) : _logger = logger {
    addOptionGroupToCommand(this, 'client');

    addSpecificOptionsSeparator(this);

    argParser
      ..addOption(
        'with-migrations',
        valueHelp: 'migrationsCommand',
        help:
            'Optional flag to specify a command to run to generate migrations.\n'
            'With this option the work flow is:\n'
            '1. Start new ElectricSQL and PostgreSQL containers\n'
            '2. Run the provided migrations command\n'
            '3. Generate the client\n'
            '4. Stop and remove the containers\n',
      )
      ..addFlag(
        'int8-as-bigint',
        aliases: ['int8AsBigInt'],
        help: '''
Optional argument to specify whether to use BigInt Dart type for INT8 columns. Defaults to `false`.
More information at: https://drift.simonbinder.eu/docs/getting-started/advanced_dart_tables/#bigint-support''',
        defaultsTo: false,
        negatable: false,
      )
      ..addFlag(
        'debug',
        help: '''
Optional flag to enable debug mode

When enabled, the temporary migration files used to generate the client will be retained for inspection.''',
        defaultsTo: false,
        negatable: false,
      );
  }

  @override
  String get description =>
      'Fetches the migrations from Electric and generates '
      'the drift schema and the Electric migrations';

  @override
  String get name => 'generate';

  final Logger _logger;

  @override
  Future<int> run() async {
    final opts = getOptsFromCommand(this);

    final config = getConfig(opts);

    final bool int8AsBigInt = opts['int8-as-bigint']! as bool;
    final bool debug = opts['debug']! as bool;
    final String? withMigrations = opts['with-migrations'] as String?;

    final _cliDriftGenOpts = _CLIDriftGenOpts(
      int8AsBigInt: int8AsBigInt,
    );

    await runElectricCodeGeneration(
      service: config.read<String>('SERVICE'),
      outFolder: config.read<String>('CLIENT_PATH'),
      proxy: config.read<String>('PROXY'),
      debug: debug,
      withMigrations: withMigrations,
      logger: _logger,
      driftSchemaGenOpts: _cliDriftGenOpts,
    );
    return 0;
  }
}

class _CLIDriftGenOpts extends ElectricDriftGenOpts {
  _CLIDriftGenOpts({
    required super.int8AsBigInt,
  });
}

Future<void> runElectricCodeGeneration({
  String? service,
  String? outFolder,
  String? proxy,
  ElectricDriftGenOpts? driftSchemaGenOpts,
  bool? debug,
  String? withMigrations,
  Logger? logger,
}) async {
  final finalLogger = logger ?? Logger();

  final config = getConfig({
    'SERVICE': service,
    'CLIENT_PATH': outFolder,
    'PROXY': proxy,
  });

  final finalService = config.read<String>('SERVICE');

  final finalOutFolder = config.read<String>('CLIENT_PATH');

  final String? checkErrorReason = await _prechecks(
    // If we run the migrations a temporary docker will be run, so no need to
    // check the input
    service: withMigrations != null ? null : finalService,
    outFolder: finalOutFolder,
    logger: finalLogger,
  );
  if (checkErrorReason != null) {
    throw ConfigException(checkErrorReason);
  }

  final genCommandOpts = _GeneratorOpts(
    config: config,
    driftSchemaGenOpts: driftSchemaGenOpts,
    withMigrations: withMigrations,
    debug: debug ?? _defaultDebug,
    logger: finalLogger,
  );

  await _runGenerator(genCommandOpts);
}

Future<String?> _prechecks({
  required String? service,
  required String outFolder,
  required Logger logger,
}) async {
  if (!(await _isDartProject())) {
    return 'This command must be run inside a Dart project';
  }

  // Service might be null if the CLI creates a temporary docker with the service
  // to run the migrations
  if (service != null && !(await _isElectricServiceReachable(service))) {
    return 'Could not reach Electric service at $service';
  }

  if (File(outFolder).existsSync() && FileSystemEntity.isFileSync(outFolder)) {
    return 'The output path $outFolder is a file';
  }

  // Check that a valid Docker is installed
  final validDockerRes = await checkValidDockerVersion(
    installReason:
        'Docker is required in order to introspect the Postgres database with the Prisma CLI',
  );
  if (validDockerRes.errorReason != null) {
    return validDockerRes.errorReason;
  }

  return null;
}

Future<bool> _isDartProject() async {
  final pubspecFile = File('pubspec.yaml');
  return pubspecFile.exists();
}

Future<bool> _isElectricServiceReachable(String service) async {
  final url = '$service/api';

  try {
    await http.get(Uri.parse(url));
    // If we get here, the service is reachable
    return true;
  } catch (e) {
    return false;
  }
}

class _GeneratorOpts {
  _GeneratorOpts({
    required this.config,
    required this.debug,
    required this.withMigrations,
    required this.driftSchemaGenOpts,
    required this.logger,
  });

  Config config;
  final ElectricDriftGenOpts? driftSchemaGenOpts;
  final String? withMigrations;
  final bool debug;
  final Logger logger;
}

Future<void> _runGenerator(_GeneratorOpts opts) async {
  final logger = opts.logger;
  var config = opts.config;

  logger.info('Generating the Electric client code...');

  try {
    if (opts.withMigrations != null) {
      // Start new ElectricSQL and PostgreSQL containers
      logger.info('Starting ElectricSQL and PostgreSQL containers...');
      // Remove the ELECTRIC_SERVICE and ELECTRIC_PROXY env vars
      // ignore: invalid_use_of_visible_for_testing_member
      programEnv.map.remove('ELECTRIC_SERVICE');
      // ignore: invalid_use_of_visible_for_testing_member
      programEnv.map.remove('ELECTRIC_PROXY');
      config = getConfig({
        ...config.map,
        'SERVICE': null,
        'PROXY': null,
        ...await withMigrationsConfig(config.read<String>('CONTAINER_NAME')),
      });
      opts.config = config;
      await runStartCommand(
        config: config,
        withPostgres: true,
        detach: true,
        exitOnDetached: false,
      );
      // Run the provided migrations command
      logger.info('Running migrations...');
      logger.info('');
      logger.info('${'-' * 27} Migrate output ${'-' * 27}');
      final migrateExitCode = await withConfig(
        command: opts.withMigrations!,
        config: opts.config,
        logger: logger,
      );
      logger.info('Exit code: $migrateExitCode');
      logger.info('-' * 70);
      logger.info('');

      if (migrateExitCode != 0) {
        logger.err(
          'Failed to run migrations, --with-migrations command exited with error. Exit code: $migrateExitCode',
        );
        exit(1);
      }
    }
    logger.info('Service URL: ${opts.config.read<String>('SERVICE')}');
    logger.info(
      'Proxy URL: ${stripPasswordFromUrl(opts.config.read<String>('PROXY'))}',
    );

    // Generate the client
    await _runGeneratorInner(opts);
  } finally {
    if (opts.withMigrations != null) {
      // Stop and remove the containers
      logger.info('Stopping ElectricSQL and PostgreSQL containers...');
      await runStopCommand(
        remove: true,
        config: config,
      );
      logger.info('Done');
    }
  }
}

Future<void> _runGeneratorInner(_GeneratorOpts opts) async {
  final logger = opts.logger;
  final config = opts.config;

  final currentDir = Directory.current;

  // Create a unique temporary folder in which to save
  // intermediate files without risking collisions
  final tmpDir = await currentDir.createTemp('.electric_migrations_tmp_');
  // ignore: unused_local_variable
  bool generationFailed = false;

  try {
    final migrationsPath = path.join(tmpDir.path, 'migrations');
    final migrationsDir = await Directory(migrationsPath).create();

    final service = removeTrailingSlash(config.read<String>('SERVICE'));
    final migrationEndpoint = '$service/api/migrations?dialect=sqlite';

    // Fetch the migrations from Electric endpoint and write them into tmpDir
    await fetchMigrations(migrationEndpoint, migrationsDir, tmpDir);

    final buildSqliteMigrations = await bundleMigrationsFor(
      Dialect.sqlite,
      opts,
      tmpDir: tmpDir,
    );

    final buildPgMigrations = await bundleMigrationsFor(
      Dialect.postgres,
      opts,
      tmpDir: tmpDir,
    );

    final prismaCLIDir =
        await Directory(path.join(tmpDir.path, 'prisma-cli')).create();
    final prismaCLI = PrismaCLI(logger: logger, folder: prismaCLIDir);

    await wrapWithProgress(
      logger,
      () => prismaCLI.install(),
      progressMsg: 'Installing Prisma CLI via Docker',
      completeMsg: 'Prisma CLI installed',
    );

    final prismaSchema =
        await createIntrospectionSchema(tmpDir, config: config);

    // Introspect the created DB to update the Prisma schema
    await wrapWithProgress(
      logger,
      () => introspectDB(prismaCLI, prismaSchema),
      progressMsg: 'Introspecting database',
      completeMsg: 'Database introspected',
    );

    // print(prismaSchemaContent);

    final outFolder = config.read<String>('CLIENT_PATH');

    // Generate the Electric client from the given introspected schema
    await wrapWithProgress(
      logger,
      () => _generateClient(prismaSchema, outFolder, opts),
      progressMsg: 'Generating Drift DB schema',
      completeMsg: 'Drift DB schema generated',
    );

    await wrapWithProgress(
      logger,
      () async {
        await buildSqliteMigrations();
        await buildPgMigrations();
      },
      progressMsg: 'Generating bundled migrations',
      completeMsg: 'Bundled migrations generated',
    );
  } catch (e) {
    generationFailed = true;
    logger.err('generate command failed: $e');
    rethrow;
  } finally {
    if (!opts.debug) {
      await tmpDir.delete(recursive: true);
    }
  }
}

Future<Future<void> Function()> bundleMigrationsFor(
  Dialect dialect,
  _GeneratorOpts opts, {
  required Directory tmpDir,
}) async {
  final config = opts.config;
  final folder = dialect == Dialect.sqlite ? 'migrations' : 'pg-migrations';
  final migrationsPath = path.join(tmpDir.path, folder);
  final migrationsDir = await Directory(migrationsPath).create();

  final service = removeTrailingSlash(config.read<String>('SERVICE'));
  final dialectParam = dialect == Dialect.sqlite ? 'sqlite' : 'postgresql';
  final migrationEndpoint = '$service/api/migrations?dialect=$dialectParam';

  final migrationsFile = _migrationsFilePath(opts, dialect);

  // Fetch the migrations from Electric endpoint and write them into `tmpFolder`
  await fetchMigrations(migrationEndpoint, migrationsDir, tmpDir);

  // Build the migrations
  final builder =
      dialect == Dialect.sqlite ? kSqliteQueryBuilder : kPostgresQueryBuilder;

  return () async {
    await buildMigrations(
      migrationsDir,
      migrationsFile,
      builder,
      constantName: dialect == Dialect.sqlite
          ? 'kSqliteMigrations'
          : 'kPostgresMigrations',
    );
  };
}

Future<void> _generateClient(
  File prismaSchema,
  String outFolder,
  _GeneratorOpts opts,
) async {
  final prismaSchemaContent = await prismaSchema.readAsString();

  final schemaInfo = extractInfoFromPrismaSchema(
    prismaSchemaContent,
    genOpts: opts.driftSchemaGenOpts,
  );
  final driftSchemaFile = resolveDriftSchemaFile(outFolder);

  await buildDriftSchemaDartFile(schemaInfo, driftSchemaFile);
}

File _migrationsFilePath(_GeneratorOpts opts, Dialect dialect) {
  final outFolder = opts.config.read<String>('CLIENT_PATH');
  final migrationsFile = resolveMigrationsFile(outFolder, dialect);
  return migrationsFile;
}

File resolveMigrationsFile(String outFolder, Dialect dialect) {
  final migrationsFileName = dialect == Dialect.sqlite
      ? kSqliteMigrationsFileName
      : kPostgresMigrationsFileName;
  return File(
    path.join(outFolder, migrationsFileName),
  ).absolute;
}

File resolveDriftSchemaFile(String outFolder) {
  return File(
    path.join(outFolder, defaultDriftSchemaFileName),
  ).absolute;
}

/// Fetches the migrations from the provided endpoint,
/// unzips them and writes them to the `writeTo` location.
Future<bool> fetchMigrations(
  String endpoint,
  Directory writeTo,
  Directory tmpFolder,
) async {
  final zipFile = File(path.join(tmpFolder.path, 'migrations.zip'));

  Future<bool> gotNewMigrationsFun() async {
    final response = await http.get(Uri.parse(endpoint));

    if (response.statusCode >= 400) {
      throw Exception(
        'Error while fetching migrations from $endpoint: '
        '${response.statusCode} ${response.reasonPhrase}',
      );
    }

    if (response.statusCode == 204) {
      // No new migrations
      return false;
    } else {
      await zipFile.writeAsBytes(response.bodyBytes);
      return true;
    }
  }

  final gotNewMigrations = await gotNewMigrationsFun();

  // Unzip the migrations
  if (gotNewMigrations) {
    await extractFileToDisk(zipFile.path, writeTo.path);
  }

  return gotNewMigrations;
}

Future<Map<String, Object?>> withMigrationsConfig(String containerName) async {
  final portHandles = <DisposablePort>[
    for (var i = 0; i < 3; i++) await getUnusedPort(),
  ];

  // After all ports are allocated, "dispose" the ports. There is a possible race
  // condition here, while the docker is not started, these ports might get allocated

  for (final portHandle in portHandles) {
    await portHandle.dispose();
  }

  final randomStr =
      List.generate(8, (_) => _random.nextInt(36).toRadixString(36)).join('');

  return <String, Object?>{
    'HTTP_PORT': portHandles[0].port,
    'PG_PROXY_PORT': portHandles[1].port.toString(),
    'DATABASE_PORT': portHandles[2].port,
    'SERVICE_HOST': 'localhost',
    'PG_PROXY_HOST': 'localhost',
    'DATABASE_REQUIRE_SSL': false,
    // Random container name to avoid collisions
    'CONTAINER_NAME': '$containerName-migrations-$randomStr',
  };
}

final _random = Random();

String stripPasswordFromUrl(String url) {
  final parsed = Uri.parse(url);
  String? newUserInfo;
  if (parsed.userInfo.isNotEmpty) {
    final splitted = parsed.userInfo.split(':');
    if (splitted.length > 1) {
      newUserInfo = '${splitted[0]}:********';
    }
  }
  if (newUserInfo == null) {
    return url;
  } else {
    return parsed.replace(userInfo: newUserInfo).toString();
  }
}
