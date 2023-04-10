import 'package:electric_client/electric/adapter.dart';
import 'package:electric_client/electric/sqlite3_adapter.dart';
import 'package:electric_client/migrators/bundle.dart';
import 'package:electric_client/util/random.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import '../support/migrations.dart';
import '../util/io.dart';

void main() {
  late Database db;
  late String dbName;
  late DatabaseAdapter adapter;

  setUp(() {
    dbName = "bundle-migrator-${randomValue()}.db";
    db = sqlite3.open(dbName);
    adapter = SqliteAdapter(db);
  });

  tearDown(() async {
    await removeFile(dbName);
    await removeFile("$dbName-journal");
  });

  test('run the bundle migrator', () async {
    final migrator = BundleMigrator(adapter: adapter, migrations: kTestMigrations);
    expectLater(await migrator.up(), 3);
    expectLater(await migrator.up(), 0);
  });
}
