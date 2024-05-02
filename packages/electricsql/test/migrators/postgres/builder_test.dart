
import 'package:electricsql/drivers/drift.dart';
import 'package:electricsql/drivers/sqlite3.dart';
import 'package:electricsql/migrators.dart';
import 'package:electricsql/src/util/types.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import '../../support/postgres.dart';
import '../builder.dart';

void main() {
  const builder = kPostgresQueryBuilder;
  final migrationMetaData = makeMigrationMetaData(builder);

  builderTests(
    migrationMetaData: migrationMetaData,
    builder: builder,
  );

  test('load migration from meta data', () async {
    final migration = makeMigration(migrationMetaData, builder);

    final pgEmbedded = await makePgDatabase('load-migration-meta-data', 5500);
    addTearDown(() => pgEmbedded.dispose());

    final adapter = DriftAdapter(pgEmbedded.db);
    final migrator =
        PgBundleMigrator(adapter: adapter, migrations: [migration]);

    await migrator.up();

    // Check that the DB is initialized with the stars table
    final tables = await adapter.query(
      Statement(
        '''
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public' AND table_name = 'stars';''',
      ),
    );

    final starIdx = tables.indexWhere((tbl) => tbl['table_name'] == 'stars');
    expect(starIdx, greaterThanOrEqualTo(0)); // must exist

    final columns = await adapter
        .query(
          Statement(
            '''
SELECT column_name
FROM information_schema.columns
WHERE table_name = 'stars';
''',
          ),
        )
        .then((columns) => columns.map((column) => column['column_name']! as String));

    expect(columns, ['id', 'avatar_url', 'name', 'starred_at', 'username']);
  });
}
