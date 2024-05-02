import 'package:electricsql/src/drivers/sqlite3/sqlite3_adapter.dart';
import 'package:electricsql/src/electric/adapter.dart';
import 'package:electricsql/src/migrators/bundle.dart';
import 'package:electricsql/src/satellite/config.dart';
import 'package:electricsql/src/util/random.dart';
import 'package:electricsql/src/util/types.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import '../../support/migrations.dart';
import '../../util/db_errors.dart';
import '../../util/io.dart';
import '../../util/sqlite.dart';

void main() {
  late Database db;
  late String dbName;
  late DatabaseAdapter adapter;

  setUp(() {
    dbName = 'schema-migrations-${randomValue()}.db';
    db = openSqliteDb(dbName);
    adapter = SqliteAdapter(db);
  });

  tearDown(() async {
    await removeFile(dbName);
    await removeFile('$dbName-journal');
  });

  test('check schema keys are unique', () async {
    final migrator = SqliteBundleMigrator(
      adapter: adapter,
      migrations: kTestSqliteMigrations,
    );
    await migrator.up();
    final defaults = satelliteDefaults(migrator.queryBuilder.defaultNamespace);
    final metaTable = '${defaults.metaTable}';
    await adapter.run(
      Statement(
        "INSERT INTO $metaTable (key, value) values ('key', 'value')",
      ),
    );
    try {
      await adapter.run(
        Statement(
          "INSERT INTO $metaTable (key, value) values ('key', 'value')",
        ),
      );
      fail('should not occur');
    } catch (err) {
      final errSqlite = err as SqliteException;
      expect(
        errSqlite.extendedResultCode,
        SqliteErrors.SQLITE_CONSTRAINT_PRIMARYKEY,
      );
    }
  });
}
