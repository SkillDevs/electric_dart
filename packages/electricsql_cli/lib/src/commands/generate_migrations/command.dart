import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:args/command_runner.dart';
import 'package:code_builder/code_builder.dart';
import 'package:electricsql_cli/src/commands/generate_migrations/builder.dart';
import 'package:electricsql_cli/src/commands/generate_migrations/drift_gen_opts.dart';
import 'package:electricsql_cli/src/commands/generate_migrations/prisma.dart';
import 'package:http/http.dart' as http;
import 'package:mason_logger/mason_logger.dart';
import 'package:path/path.dart' as path;

/// {@template sample_command}
///
/// `electricsql_cli generate_migrations`
/// A [Command] to exemplify a sub command
/// {@endtemplate}
class GenerateMigrationsCommand extends Command<int> {
  GenerateMigrationsCommand({
    required Logger logger,
  }) : _logger = logger {
    argParser
      ..addOption(
        'service',
        help: '''
Optional argument providing the url to connect to Electric.
If not provided, it uses the url set in the `ELECTRIC_URL`
environment variable. If that variable is not set, it
resorts to the default url which is `http://127.0.0.1:5133''',
        valueHelp: 'url',
      )
      ..addOption(
        'proxy',
        help: '''
Optional argument providing the url to connect to the PG database via the proxy.
 *    If not provided, it uses the url set in the `PG_PROXY_URL` environment variable.
 *    If that variable is not set, it resorts to the default url which is
 *    'postgresql://prisma:password@localhost:65432/electric'.
 *    NOTE: the generator introspects the PG database via the proxy,
 *          the URL must therefore connect using the "prisma" user.''',
        valueHelp: 'url',
      )
      ..addOption(
        'out',
        help: '''
Optional argument to specify where to write the generated files.
If this argument is not provided they are written to
`lib/generated/electric`''',
        valueHelp: 'file_path',
      );
  }

  @override
  String get description =>
      'Fetches the migrations from Electric and generates '
      'the migrations file';

  @override
  String get name => 'generate_migrations';

  final Logger _logger;

  static const String defaultMigrationsFileName = 'migrations.dart';
  static const String defaultDriftSchemaFileName = 'drift_schema.dart';

  @override
  Future<int> run() async {
    final String defaultService =
        Platform.environment['ELECTRIC_URL'] ?? 'http://127.0.0.1:5133';
    String service = (argResults?['service'] as String?) ?? defaultService;
    if (service.endsWith('/')) {
      service = service.substring(0, service.length - 1);
    }

    final outFolder =
        (argResults?['out'] as String?) ?? 'lib/generated/electric';

    final String defaultProxy = Platform.environment['ELECTRIC_PROXY_URL'] ??
        'postgresql://prisma:proxy_password@localhost:65432/electric';
    final String proxy = (argResults?['proxy'] as String?) ?? defaultProxy;

    final valid = await _prechecks(service: service, outFolder: outFolder);
    if (!valid) {
      return ExitCode.config.code;
    }

    await _runGenerator(
      service: service,
      outFolder: outFolder,
      proxy: proxy,
    );

    return ExitCode.success.code;
  }

  Future<bool> _prechecks({
    required String service,
    required String outFolder,
  }) async {
    if (!(await _isDartProject())) {
      _logger.err('ERROR: This command must be run inside a Dart project');
      return false;
    }

    if (!(await _isElectricServiceReachable(service))) {
      _logger.err('ERROR: Could not reach Electric service at $service');
      return false;
    }

    if (File(outFolder).existsSync() &&
        FileSystemEntity.isFileSync(outFolder)) {
      _logger.err('ERROR: The output path $outFolder is a file');
      return false;
    }

    // Check that Docker is installed
    final dockerRes = await Process.run('docker', ['--version']);
    if (dockerRes.exitCode != 0) {
      _logger.err('ERROR: Could not run docker command');
      _logger.err(
        'Docker is required in order to introspect the Postgres database with the Prisma CLI',
      );
      _logger.err('Exit code: ${dockerRes.exitCode}');
      _logger.err('Stderr: ${dockerRes.stderr}');
      _logger.err('Stdout: ${dockerRes.stdout}');
      return false;
    }

    return true;
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

  Future<void> _runGenerator({
    required String service,
    required String outFolder,
    required String proxy,
    required ElectricDriftGenOpts? driftSchemaGenOpts,
  }) async {
    _logger.info('Generating migrations file...');

    final currentDir = Directory.current;

    // Create a unique temporary folder in which to save
    // intermediate files without risking collisions
    final tmpDir = await currentDir.createTemp('.electric_migrations_tmp_');

    try {
      final migrationsPath = path.join(tmpDir.path, 'migrations');
      final migrationsDir = await Directory(migrationsPath).create();

      final migrationEndpoint = '$service/api/migrations?dialect=sqlite';

      // Fetch the migrations from Electric endpoint and write them into tmpDir
      await fetchMigrations(migrationEndpoint, migrationsDir, tmpDir);

      final prismaCLIDir =
          await Directory(path.join(tmpDir.path, 'prisma-cli')).create();
      final prismaCLI = PrismaCLI(logger: _logger, folder: prismaCLIDir);
      _logger.info('Installing Prisma CLI via Docker...');
      await prismaCLI.install();

      final prismaSchema = await createPrismaSchema(tmpDir, proxy: proxy);

      // Introspect the created DB to update the Prisma schema
      _logger.info('Introspecting database...');
      await introspectDB(prismaCLI, prismaSchema);

      final prismaSchemaContent = prismaSchema.readAsStringSync();

      // Add custom validators (such as uuid) to the Prisma schema
      // await addValidators(prismaSchema);
      final schemaInfo = extractInfoFromPrismaSchema(
        prismaSchemaContent,
        genOpts: driftSchemaGenOpts,
      );
      _logger.info('Building Drift DB schema...');
      final driftSchemaFile = resolveDriftSchemaFile(outFolder);
      await buildDriftSchemaDartFile(schemaInfo, driftSchemaFile);

      _logger.info('Building migrations...');
      final migrationsFile = resolveMigrationsFile(outFolder);
      await buildMigrations(migrationsDir, migrationsFile);
    } finally {
      // Delete the temporary folder
      await tmpDir.delete(recursive: true);
    }
  }

  File resolveMigrationsFile(String outFolder) {
    return File(
      path.join(outFolder, defaultMigrationsFileName),
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
}
