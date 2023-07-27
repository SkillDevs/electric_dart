import 'package:electric_client/src/drivers/sqlite3/sqlite3_adapter.dart';
import 'package:electric_client/src/electric/adapter.dart';
import 'package:electric_client/src/migrators/bundle.dart';
import 'package:electric_client/src/satellite/config.dart';
import 'package:electric_client/src/util/random.dart';
import 'package:electric_client/src/util/types.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import '../support/migrations.dart';
import '../util/io.dart';
import '../util/sqlite.dart';
import '../util/sqlite_errors.dart';

void main() {
  late Database db;
  late String dbName;
  late DatabaseAdapter adapter;

  setupSqliteOpen();

  setUp(() {
    dbName = 'schema-migrations-${randomValue()}.db';
    db = sqlite3.open(dbName);
    adapter = SqliteAdapter(db);
  });

  tearDown(() async {
    await removeFile(dbName);
    await removeFile('$dbName-journal');
  });

  test('check schema keys are unique', () async {
    final migrator =
        BundleMigrator(adapter: adapter, migrations: kTestMigrations);
    await migrator.up();

    await adapter.run(
      Statement(
        "INSERT INTO ${kSatelliteDefaults.metaTable}(key, value) values ('key', 'value')",
      ),
    );
    try {
      await adapter.run(
        Statement(
          "INSERT INTO ${kSatelliteDefaults.metaTable}(key, value) values ('key', 'value')",
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
