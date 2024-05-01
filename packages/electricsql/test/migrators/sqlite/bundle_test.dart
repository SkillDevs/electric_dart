import 'package:electricsql/src/drivers/sqlite3/sqlite3_adapter.dart';
import 'package:electricsql/src/electric/adapter.dart';
import 'package:electricsql/src/migrators/bundle.dart';
import 'package:electricsql/src/util/random.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import '../../support/migrations.dart';
import '../../util/io.dart';
import '../../util/sqlite.dart';
import '../bundle.dart';

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

  bundleTests(
    getDbName: () => dbName,
    getAdapter: () => adapter,
    getMigrator: (adapter, migrations) => SqliteBundleMigrator(
      adapter: adapter,
      migrations: migrations,
    ),
    migrations: kTestSqliteMigrations,
  );
}
