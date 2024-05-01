import 'package:electricsql/src/drivers/sqlite3/sqlite3_adapter.dart';
import 'package:electricsql/src/electric/adapter.dart';
import 'package:electricsql/src/migrators/bundle.dart';
import 'package:electricsql/src/migrators/migrators.dart';
import 'package:electricsql/src/util/random.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import '../support/migrations.dart';
import '../util/io.dart';
import '../util/sqlite.dart';

void main() {
  late Database db;
  late String dbName;
  late DatabaseAdapter adapter;

  setUp(() {
    dbName = 'bundle-migrator-${randomValue()}.db';
    db = openSqliteDb(dbName);
    adapter = SqliteAdapter(db);
  });

  tearDown(() async {
    await removeFile(dbName);
    await removeFile('$dbName-journal');
  });

  test('run the bundle migrator', () async {
    final migrator =
        BundleMigrator(adapter: adapter, migrations: kTestSqliteMigrations);
    await expectLater(await migrator.up(), 3);
    await expectLater(await migrator.up(), 0);
  });

  test('applyIfNotAlready applies new migrations', () async {
    final migrations = kTestSqliteMigrations;
    final allButLastMigrations =
        migrations.sublist(0, kTestSqliteMigrations.length - 1);
    final lastMigration = makeStmtMigration(migrations[migrations.length - 1]);

    final migrator = BundleMigrator(
      adapter: adapter,
      migrations: allButLastMigrations,
    );
    expect(await migrator.up(), 2);

    final wasApplied = await migrator.applyIfNotAlready(lastMigration);
    expect(wasApplied, isTrue);
  });

  test('applyIfNotAlready ignores already applied migrations', () async {
    final migrator =
        BundleMigrator(adapter: adapter, migrations: kTestSqliteMigrations);
    expect(await migrator.up(), 3);

    final wasApplied = await migrator.applyIfNotAlready(
      makeStmtMigration(kTestSqliteMigrations[0]),
    );
    expect(!wasApplied, isTrue);
  });
}
