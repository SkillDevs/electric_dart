import 'dart:convert';
import 'dart:io';

import 'package:electricsql/electricsql.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

Future<void> main() async {
  final (commit: referenceCommit, version: referenceVersion) =
      await getReferenceVersion();

  test('Check that protocol version matches reference commit in Electric',
      () async {
    expect(
      kElectricProtocolVersion.split('').where((c) => c == '.').length,
      1,
      reason: 'kElectricProtocolVersion should be in the form of x.y',
    );

    final electricGHJsonUrl =
        'https://raw.githubusercontent.com/electric-sql/electric/$referenceCommit/components/electric/package.json';

    final res = await http.get(Uri.parse(electricGHJsonUrl));

    if (res.statusCode != 200) {
      throw Exception(
        'Failed to fetch Electric package.json from GitHub. Status code: ${res.statusCode} Url: $electricGHJsonUrl',
      );
    }
    final j = json.decode(res.body) as Map<String, Object?>;
    final electricServiceVersion = j['version']! as String;

    expect(
      electricServiceVersion.startsWith('$kElectricProtocolVersion.'),
      isTrue,
      reason:
          'Reference commit Electric version $electricServiceVersion does not match '
          'protocol version $kElectricProtocolVersion in electric_dart',
    );
  });

  test('Check that the Typecript client version matches the reference version',
      () async {
    final electricGHJsonUrl =
        'https://raw.githubusercontent.com/electric-sql/electric/$referenceCommit/clients/typescript/package.json';

    final res = await http.get(Uri.parse(electricGHJsonUrl));

    if (res.statusCode != 200) {
      throw Exception(
        'Failed to fetch Electric TS client package.json from GitHub. Status code: ${res.statusCode} Url: $electricGHJsonUrl',
      );
    }
    final j = json.decode(res.body) as Map<String, Object?>;
    final tsClientVersion = j['version']! as String;

    final validVersions = [
      'v$tsClientVersion',
      'v$tsClientVersion-dev',
    ];

    expect(
      validVersions.contains(referenceVersion),
      isTrue,
      reason:
          'Reference version $referenceVersion does not match the version in the Electric TS client $tsClientVersion. '
          'Valid versions are: ${validVersions.join(', ')}',
    );
  });

  test('Check version in pubspec matches client version constant', () async {
    final pubspecContent = await File('pubspec.yaml').readAsString();

    final versionRegexp = RegExp('version: (.+)');
    final version = versionRegexp.firstMatch(pubspecContent)!.group(1)!;

    expect(
      version,
      kElectricClientVersion,
      reason:
          'Version in pubspec.yaml $version does not match the client version constant $kElectricClientVersion',
    );
  
  });
}

Future<({String commit, String version})> getReferenceVersion() async {
  const readmePath = '../../README.md';
  final readmeContent = await File(readmePath).readAsString();

  final commitRegexp = RegExp(r'\* Commit: `([a-f0-9]+)`');
  final commit = commitRegexp.firstMatch(readmeContent)!.group(1)!;

  final versionRegexp = RegExp(r'\* Version `(.+)`');
  final version = versionRegexp.firstMatch(readmeContent)!.group(1)!;

  return (commit: commit, version: version);
}
