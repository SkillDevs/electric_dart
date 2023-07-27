import 'package:electric_client/src/drivers/sqlite3/sqlite3_adapter.dart';
import 'package:electric_client/src/electric/adapter.dart';
import 'package:electric_client/src/migrators/bundle.dart';
import 'package:electric_client/src/migrators/migrators.dart';
import 'package:electric_client/src/util/random.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import '../support/migrations.dart';
import '../util/io.dart';

void main() {
  late Database db;
  late String dbName;
  late DatabaseAdapter adapter;

  setUp(() {
    dbName = 'bundle-migrator-${randomValue()}.db';
    db = sqlite3.open(dbName);
    adapter = SqliteAdapter(db);
  });

  tearDown(() async {
    await removeFile(dbName);
    await removeFile('$dbName-journal');
  });

  test('run the bundle migrator', () async {
    final migrator =
        BundleMigrator(adapter: adapter, migrations: kTestMigrations);
    await expectLater(await migrator.up(), 3);
    await expectLater(await migrator.up(), 0);
  });

  test('applyIfNotAlready applies new migrations', () async {
    final migrations = kTestMigrations;
    final allButLastMigrations =
        migrations.sublist(0, kTestMigrations.length - 1);
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
        BundleMigrator(adapter: adapter, migrations: kTestMigrations);
    expect(await migrator.up(), 3);

    final wasApplied = await migrator.applyIfNotAlready(
      makeStmtMigration(kTestMigrations[0]),
    );
    expect(!wasApplied, isTrue);
  });
}
