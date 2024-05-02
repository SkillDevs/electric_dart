import 'package:electricsql/drivers/drift.dart';
import 'package:electricsql/src/electric/adapter.dart';
import 'package:electricsql/src/migrators/bundle.dart';
import 'package:electricsql/src/satellite/config.dart';
import 'package:electricsql/src/util/random.dart';
import 'package:electricsql/src/util/types.dart';
import 'package:postgres/postgres.dart' as pg;
import 'package:test/test.dart';

import '../../drivers/drift_test.dart';
import '../../support/pg_migrations.dart';
import '../../support/postgres.dart';

const port = 2934;

void main() {
  late EmbeddedPostgresDb pgEmbedded;
  late ScopedPgDb scopedPgDb;

  late GenericDb db;
  late DatabaseAdapter adapter;

  setUpAll(() async {
    pgEmbedded = await makePgDatabase('schema-migrations-tests', port);
  });

  tearDownAll(() async {
    await pgEmbedded.dispose();
  });

  setUp(() async {
    final dbName = 'schema-migrations-${randomValue()}';
    scopedPgDb = await initScopedPostgresDatabase(pgEmbedded, dbName);
    db = scopedPgDb.db;
    adapter = DriftAdapter(db);
    addTearDown(() => scopedPgDb.dispose());
  });

  test('check schema keys are unique', () async {
    final migrator =
        PgBundleMigrator(adapter: adapter, migrations: kTestPostgresMigrations);
    await migrator.up();
    final defaults = satelliteDefaults(migrator.queryBuilder.defaultNamespace);
    final metaTable =
        '"${defaults.metaTable.namespace}"."${defaults.metaTable.tablename}"';
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
      final errPg = err as pg.ServerException;
      expect(errPg.code, '23505');
      expect(errPg.detail, 'Key (key)=(key) already exists.');
    }
  });
}
