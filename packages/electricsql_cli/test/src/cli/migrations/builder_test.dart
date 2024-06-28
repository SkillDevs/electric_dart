import 'dart:io';

import 'package:electricsql/electricsql.dart';
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
      final (:migrations, :dbDescription) =
          await loadMigrations(migrationsFolder, builder);
      final versions = migrations.map((m) => m.version);
      expect(versions, ['20230613112725_814', '20230613112735_992']);

      expect(dbDescription.tableSchemas, <String, TableSchema>{
        'stars': const TableSchema(
          fields: {
            'id': PgType.text,
            'avatar_url': PgType.text,
            'name': PgType.text,
            'starred_at': PgType.text,
            'username': PgType.text,
          },
          relations: [
            Relation(
              // 'beers',
              fromField: '',
              toField: '',
              relatedTable: 'beers',
              relationName: 'beers_star_idTostars',
              // 'many'
            ),
          ],
        ),
        'beers': const TableSchema(
          fields: {
            'id': PgType.text,
            'star_id': PgType.text,
          },
          relations: [
            Relation(
              // 'stars',
              fromField: 'star_id',
              toField: 'id',
              relatedTable: 'stars',
              relationName: 'beers_star_idTostars',
              // 'one'
            ),
          ],
        ),
      });
    }
  });
}
