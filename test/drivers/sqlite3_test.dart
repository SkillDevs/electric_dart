import 'package:electric_client/src/drivers/sqlite3/sqlite3_adapter.dart';
import 'package:electric_client/src/electric/adapter.dart';
import 'package:electric_client/src/util/types.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import 'common.dart';

Future<void> main() async {
  late Database db;
  late DatabaseAdapter adapter;

  setUp(() async {
    db = sqlite3.openInMemory();
    adapter = SqliteAdapter(db);

    await adapter.run(Statement("PRAGMA foreign_keys = ON;"));
    await initDb(adapter);
  });

  tearDown(() async {
    db.dispose();
  });

  runTests(() => adapter);
}
