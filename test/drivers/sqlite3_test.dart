import 'package:electric_client/src/drivers/sqlite3/sqlite3_adapter.dart';
import 'package:electric_client/src/electric/adapter.dart';
import 'package:electric_client/src/util/types.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

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

  test("run+query", () async {
    await adapter.run(Statement("INSERT INTO items VALUES ('foo');"));
    final result = await adapter.query(Statement("SELECT * FROM items;"));
    expect(result, [
      {"value": "foo"}
    ]);
  });

  group("transaction", () {
    test('successful', () async {
      final res = await adapter.transaction<bool>((tx, setResult) async {
        tx.run(
          Statement("INSERT INTO items VALUES ('foo');"),
          (tx, res) {
            setResult(true);
          },
          (_) {
            fail("should not fail");
          },
        );
      });
      expect(res, true);

      final result = await adapter.query(Statement("SELECT * FROM items;"));
      expect(result, [
        {"value": "foo"},
      ]);

      // Can open a new transaction
      await adapter.runInTransaction([Statement("SELECT 1")]);
    });

    test('rollback', () async {
      try {
        await adapter.transaction<bool>((tx, setResult) async {
          tx.run(
            Statement("wrong sql;"),
            (tx, res) {
              fail("should fail");
            },
            (e) {},
          );
        });
        fail("should fail");
      } catch (e) {
        expect(
          e,
          isA<SqliteException>().having((p0) => p0.resultCode, "code", 1),
        );
      }

      final result = await adapter.query(Statement("SELECT * FROM items;"));
      expect(result, isEmpty);

      // Can open a new transaction
      await adapter.runInTransaction([Statement("SELECT 1")]);
    });
  });

  group("runInTransaction", () {
    test('successful', () async {
      final transRes = await adapter.runInTransaction([
        Statement("INSERT INTO items VALUES ('foo');"),
        Statement("INSERT INTO items VALUES ('bar');"),
      ]);
      expect(transRes.rowsAffected, 2);

      final result = await adapter.query(Statement("SELECT * FROM items;"));
      expect(result, [
        {"value": "bar"},
        {"value": "foo"},
      ]);

      // Can open a new transaction
      await adapter.runInTransaction([Statement("SELECT 1")]);
    });

    test('rollback', () async {
      try {
        await adapter.runInTransaction([
          Statement("INSERT INTO items VALUES ('foo');"),
          Statement("wrong"),
        ]);

        fail("should fail");
      } catch (e) {
        expect(
          e,
          isA<SqliteException>().having((p0) => p0.resultCode, "code", 1),
        );
      }

      final result = await adapter.query(Statement("SELECT * FROM items;"));
      expect(result, isEmpty);

      // Can open a new transaction
      await adapter.runInTransaction([Statement("SELECT 1")]);
    });

    test('rollback on COMMIT', () async {
      // To trigger an error at COMMIT time
      await adapter.run(Statement("PRAGMA defer_foreign_keys = ON;"));

      try {
        await adapter.runInTransaction([
          Statement("INSERT INTO child(id, parent) VALUES (1, 2);"),
        ]);

        fail("should fail");
      } catch (e) {
        expect(
          e,
          // FOREIGN KEY constraint failed, constraint failed
          isA<SqliteException>()
              .having((p0) => p0.extendedResultCode, "code", 787),
        );
      }

      final result = await adapter.query(Statement("SELECT * FROM items;"));
      expect(result, isEmpty);

      // Can open a new transaction
      await adapter.runInTransaction([Statement("SELECT 1")]);
    });
  });
}

Future<void> initDb(DatabaseAdapter adapter) async {
  final stmts = [
    'CREATE TABLE IF NOT EXISTS items (\n  value TEXT PRIMARY KEY NOT NULL\n) WITHOUT ROWID;',
    'CREATE TABLE IF NOT EXISTS parent (\n  id INTEGER PRIMARY KEY NOT NULL,\n  value TEXT,\n  other INTEGER DEFAULT 0\n) WITHOUT ROWID;',
    'CREATE TABLE IF NOT EXISTS child (\n  id INTEGER PRIMARY KEY NOT NULL,\n  parent INTEGER NOT NULL,\n  FOREIGN KEY(parent) REFERENCES parent(id)\n) WITHOUT ROWID;',
  ];

  for (final stmt in stmts) {
    await adapter.run(Statement(stmt));
  }
}
