import 'dart:io';

import 'package:electricsql_cli/src/util/util.dart';
import 'package:yaml/yaml.dart';

final String kElectricLibVersion = _kParsedPubspecLockInfo.electricLibVersion;
final String kElectricCliVersion = _kParsedPubspecLockInfo.electricCliVersion;
final bool kElectricIsGitDependency =
    _kParsedPubspecLockInfo.electricIsGitDependency;

ParsedPubspecLockInfo? kDebugMockParsedPubspecLockInfo;

void setDebugMockParsedPubspecLockInfo() {
  kDebugMockParsedPubspecLockInfo = ParsedPubspecLockInfo(
    electricLibVersion: 'unknown',
    electricCliVersion: 'unknown',
    electricIsGitDependency: false,
  );
}

final ParsedPubspecLockInfo _kParsedPubspecLockInfo =
    kDebugMockParsedPubspecLockInfo ?? _parsePubspecLockInfo();

ParsedPubspecLockInfo _parsePubspecLockInfo() {
  final lockFile = kAppPubspecLockFile;
  if (!lockFile.existsSync()) {
    throw ConfigException(
      'Could not find a pubspec.lock file. The CLI must be run inside a Dart project.',
    );
  }

  final lockFileContent = lockFile.readAsStringSync();

  final yaml = loadYaml(lockFileContent);

  final yamlMap = yaml as YamlMap;
  final packages = yamlMap['packages'] as YamlMap;
  final electricsqlEntry = packages['electricsql'] as YamlMap?;
  final electricsqlCliEntry = packages['electricsql_cli'] as YamlMap?;

  if (electricsqlCliEntry == null) {
    throw ConfigException(
      'electricsql_cli is not installed in the current Dart project. Add it as a dev dependency in the pubspec.yaml.\nCWD: ${Directory.current.path}',
    );
  }

  if (electricsqlEntry == null) {
    throw ConfigException(
      'electricsql is not installed in the current Dart project. Add it as a dependency in the pubspec.yaml.\nCWD: ${Directory.current.path}',
    );
  }

  try {
    final electricVersion = electricsqlEntry['version'] as String;
    final electricCliVersion = electricsqlCliEntry['version'] as String;

    final isGitDependency = electricsqlEntry['source'] == 'git';

    return ParsedPubspecLockInfo(
      electricLibVersion: electricVersion,
      electricCliVersion: electricCliVersion,
      electricIsGitDependency: isGitDependency,
    );
  } catch (e, st) {
    throw Exception(
      'Error parsing the project pubspec.lock file. Error: $e\nStackTrace: $st',
    );
  }
}

class ParsedPubspecLockInfo {
  final String electricLibVersion;
  final String electricCliVersion;
  final bool electricIsGitDependency;

  ParsedPubspecLockInfo({
    required this.electricLibVersion,
    required this.electricCliVersion,
    required this.electricIsGitDependency,
  });
}
