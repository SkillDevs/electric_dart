import 'dart:async';
import 'dart:io';
import 'package:electricsql_cli/src/assets.dart';
import 'package:electricsql_cli/src/commands/docker_commands/precheck.dart';
import 'package:electricsql_cli/src/util/util.dart';
import 'package:path/path.dart' as path;

bool _useExternalDockerNetwork(String? networkName) {
  return networkName != null && networkName.isNotEmpty;
}

// Derive network name from the current working directory, matching Docker Compose's default
// naming.
String _deriveNetworkName(String? networkName) {
  if (networkName != null && networkName.isNotEmpty) return networkName;
  return '${path.basename(Directory.current.path)}_ip6net';
}

Future<Process> dockerCompose(
  String command,
  List<String> userArgs, {
  String? containerName,
  Map<String, String> env = const {},
}) async {
  await _assertValidDocker();

  final assetsDir = await getElectricCLIAssetsDir();
  final composeFile = File(path.join(assetsDir.path, 'docker/compose.yaml'));

  final extraComposeFileName = env['DOCKER_NETWORK_USE_EXTERNAL'] == 'host'
      ? 'compose.hostnet.yaml'
      : 'compose.ip6net.yaml';
  final extraComposeFile =
      File(path.join(assetsDir.path, 'docker', extraComposeFileName));

  final args = <String>[
    'compose',
    '--ansi',
    'always',
    '-f',
    composeFile.absolute.path,
    '-f',
    extraComposeFile.absolute.path,
    command,
    ...userArgs,
  ];

  final proc = await Process.start(
    'docker',
    args,
    mode: ProcessStartMode.inheritStdio,
    environment: {
      'ELECTRIC_COMPOSE_NETWORK_IS_EXTERNAL':
          _useExternalDockerNetwork(env['DOCKER_NETWORK_USE_EXTERNAL'])
              .toString(),
      'ELECTRIC_COMPOSE_EXTERNAL_NETWORK_NAME':
          _deriveNetworkName(env['DOCKER_NETWORK_USE_EXTERNAL']),
      ...Platform.environment,
      if (containerName != null) 'COMPOSE_PROJECT_NAME': containerName,
      ...env,
    },
  );

  return proc;
}

Future<Process> dockerComposeUp({
  List<String> userArgs = const [],
  String? containerName,
  Map<String, String> env = const {},
}) {
  // We use the same compose.yaml file for `electric-sql start` and `electric-sql start
  // --with-postgres` and vary the services started by passing them as arguments to `docker
  // compose up`.
  final List<String> services = env['COMPOSE_PROFILES'] == 'with-postgres'
      ? ['postgres', 'electric']
      : ['electric'];
  return dockerCompose(
    'up',
    [...userArgs, ...services],
    containerName: containerName,
    env: env,
  );
}

Future<void> _assertValidDocker() async {
  // Check that a valid Docker is installed
  final res = await checkValidDockerVersion();

  if (res.errorReason != null) {
    throw ConfigException(res.errorReason!);
  }
}
