import 'dart:convert';
import 'dart:io';

import 'package:electricsql/electricsql.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

Future<void> main() async {
  test('Check that protocol version matches reference commit in Electric',
      () async {
    expect(
      kElectricProtocolVersion.split('').where((c) => c == '.').length,
      1,
      reason: 'kElectricProtocolVersion should be in the form of x.y',
    );

    final regexp = RegExp(r'\* Commit: `([a-f0-9]+)`');
    const readmePath = '../../README.md';
    final readmeContent = await File(readmePath).readAsString();
    final match = regexp.firstMatch(readmeContent)!;
    final referenceCommit = match.group(1)!;

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
}
