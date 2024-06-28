@Tags(['postgres'])
library;

import 'package:electricsql/drivers/drift.dart';
import 'package:electricsql/drivers/drivers.dart';
import 'package:electricsql/src/migrators/bundle.dart';
import 'package:electricsql/src/util/random.dart';
import 'package:test/test.dart';

import '../../support/pg_migrations.dart';
import '../../support/postgres.dart';
import '../bundle.dart';

void main() {
  const port = 5532;
  late String dbName;
  late DatabaseAdapter adapter;

  late EmbeddedPostgresDb pgEmbedded;
  late ScopedPgDb scopedDb;

  setUpAll(() async {
    pgEmbedded = await makePgDatabase('bundle-migrator-tests', port);
  });

  tearDownAll(() async {
    await pgEmbedded.dispose();
  });

  setUp(() async {
    dbName = 'bundle-migrator-${randomValue()}.db';
    scopedDb = await initScopedPostgresDatabase(pgEmbedded, dbName);
    adapter = DriftAdapter(scopedDb.db);
  });

  tearDown(() async {
    await scopedDb.dispose();
  });

  bundleTests(
    getDbName: () => dbName,
    getAdapter: () => adapter,
    getMigrator: (adapter, migrations) => PgBundleMigrator(
      adapter: adapter,
      migrations: migrations,
    ),
    migrations: kTestPostgresMigrations,
  );
}
