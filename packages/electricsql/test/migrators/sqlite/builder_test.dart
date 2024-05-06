import 'package:electricsql/drivers/sqlite3.dart';
import 'package:electricsql/migrators.dart';
import 'package:electricsql/src/util/types.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import '../builder.dart';

void main() {
  const builder = kSqliteQueryBuilder;
  final migrationMetaData = makeMigrationMetaData(builder);

  builderTests(
    migrationMetaData: migrationMetaData,
    builder: builder,
  );

  test('load migration from meta data', () async {
    final migration = makeMigration(migrationMetaData, builder);

    final db = sqlite3.openInMemory();
    final adapter = SqliteAdapter(db);
    final migrator =
        SqliteBundleMigrator(adapter: adapter, migrations: [migration]);

    await migrator.up();

    // Check that the DB is initialized with the stars table
    final tables = await adapter.query(
      Statement(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='stars';",
      ),
    );

    final starIdx = tables.indexWhere((tbl) => tbl['name'] == 'stars');
    expect(starIdx, greaterThanOrEqualTo(0)); // must exist

    final columns = await adapter
        .query(
          Statement(
            'PRAGMA table_info(stars);',
          ),
        )
        .then((columns) => columns.map((column) => column['name']! as String));

    expect(columns, ['id', 'avatar_url', 'name', 'starred_at', 'username']);
  });
}
