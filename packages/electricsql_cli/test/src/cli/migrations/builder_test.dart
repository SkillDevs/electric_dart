import 'dart:io';

import 'package:electricsql/migrators.dart';
import 'package:electricsql_cli/src/commands/generate/builder.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  final migrationsFolder = Directory(
    join(
      Directory.current.path,
      '../electricsql/test/migrators/support/migrations',
    ),
  );

  test('read migration meta data', () async {
    for (final builder in [kSqliteQueryBuilder, kPostgresQueryBuilder]) {
      final migrations = await loadMigrations(migrationsFolder, builder);
      final versions = migrations.map((m) => m.version);
      expect(versions, ['20230613112725_814', '20230613112735_992']);
    }
  });
}
