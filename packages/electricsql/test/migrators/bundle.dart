import 'package:electricsql/src/electric/adapter.dart';
import 'package:electricsql/src/migrators/bundle.dart';
import 'package:electricsql/src/migrators/migrators.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';


@isTestGroup
void bundleTests({
  required String Function() getDbName,
  required DatabaseAdapter Function() getAdapter,
  required BundleMigratorBase Function(
    DatabaseAdapter adapter,
    List<Migration> migrations,
  ) getMigrator,
  required List<Migration> migrations,
}) {
  test('run the bundle migrator', () async {
    final adapter = getAdapter();
    final migrator = getMigrator(adapter, migrations);
    await expectLater(await migrator.up(), 3);
    await expectLater(await migrator.up(), 0);
  });

  test('applyIfNotAlready applies new migrations', () async {
    final adapter = getAdapter();
    final allButLastMigrations = migrations.sublist(0, migrations.length - 1);
    final lastMigration = makeStmtMigration(migrations[migrations.length - 1]);

    final migrator = getMigrator(
      adapter,
      allButLastMigrations,
    );
    expect(await migrator.up(), 2);

    final wasApplied = await migrator.applyIfNotAlready(lastMigration);
    expect(wasApplied, isTrue);
  });

  test('applyIfNotAlready ignores already applied migrations', () async {
    final adapter = getAdapter();
    final migrator = getMigrator(adapter, migrations);
    expect(await migrator.up(), 3);

    final wasApplied = await migrator.applyIfNotAlready(
      makeStmtMigration(migrations[0]),
    );
    expect(!wasApplied, isTrue);
  });
}
