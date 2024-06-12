import 'package:electricsql/drivers/drivers.dart';
import 'package:electricsql/src/util/types.dart';
import 'package:meta/meta.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

@isTestGroup
void runTests(DatabaseAdapter Function() getAdapter) {
  test('run+query', () async {
    final adapter = getAdapter();
    await adapter.run(Statement("INSERT INTO items VALUES ('foo');"));
    final result = await adapter.query(Statement('SELECT * FROM items;'));
    expect(result, [
      {'value': 'foo'},
    ]);
  });

  group('transaction', () {
    test('successful', () async {
      final adapter = getAdapter();

      final res = await adapter.transaction<bool>((tx, setResult) {
        tx.run(
          Statement("INSERT INTO items VALUES ('foo');"),
          (tx, res) {
            setResult(true);
          },
          (_) {
            fail('should not fail');
          },
        );
      });
      expect(res, true);

      final result = await adapter.query(Statement('SELECT * FROM items;'));
      expect(result, [
        {'value': 'foo'},
      ]);

      // Can open a new transaction
      await adapter.runInTransaction([Statement('SELECT 1')]);
    });

    test('rollback', () async {
      final adapter = getAdapter();
      try {
        await adapter.transaction<bool>((tx, setResult) {
          tx.run(
            Statement('wrong sql;'),
            (tx, res) {
              fail('should fail');
            },
            (e) {},
          );
        });
        fail('should fail');
      } catch (e) {
        expect(
          e,
          isA<SqliteException>().having((p0) => p0.resultCode, 'code', 1),
        );
      }

      final result = await adapter.query(Statement('SELECT * FROM items;'));
      expect(result, isEmpty);

      // Can open a new transaction
      await adapter.runInTransaction([Statement('SELECT 1')]);
    });

    test('handle exception', () async {
      final adapter = getAdapter();
      try {
        await adapter.transaction<bool>((tx, setResult) {
          throw Exception('my error');
        });
        fail('should fail');
      } catch (e) {
        expect(
          e,
          isA<Exception>()
              .having((p0) => p0.toString(), 'message', 'Exception: my error'),
        );
      }

      // Can open a new transaction
      await adapter.runInTransaction([Statement('SELECT 1')]);
    });

    test('handle async exception', () async {
      final adapter = getAdapter();
      try {
        await adapter.transaction<bool>((tx, setResult) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          throw Exception('my error');
        });
        fail('should fail');
      } catch (e) {
        expect(
          e,
          isA<Exception>()
              .having((p0) => p0.toString(), 'message', 'Exception: my error'),
        );
      }

      // Can open a new transaction
      await adapter.runInTransaction([Statement('SELECT 1')]);
    });

    test('chain', () async {
      final adapter = getAdapter();

      final selectQ = Statement('SELECT * FROM items;');
      Statement buildInsertQ(int i) =>
          Statement("INSERT INTO items VALUES ('foo$i');");

      final result = await adapter.transaction<List<String>>((tx, setResult) {
        tx.run(
          buildInsertQ(1),
          (tx, _) => tx.run(
            buildInsertQ(2),
            (tx, _) => tx.run(
              buildInsertQ(3),
              (tx, __) => tx.query(
                selectQ,
                (tx, res) => setResult(
                  res.map((row) => row['value']! as String).toList(),
                ),
              ),
            ),
          ),
        );
      });

      expect(result, ['foo1', 'foo2', 'foo3']);
    });

    test('chain with error', () async {
      final adapter = getAdapter();

      final wrongStatementQ = Statement('WRONG QUERY');
      Statement buildInsertQ(int i) =>
          Statement("INSERT INTO items VALUES ('foo$i');");

      bool captured = false;
      await expectLater(
        () => adapter.transaction<List<String>>((tx, setResult) {
          tx.run(
            buildInsertQ(1),
            (tx, _) => tx.run(
              buildInsertQ(2),
              (tx, _) => tx.run(
                buildInsertQ(3),
                (tx, __) => tx.query(
                  wrongStatementQ,
                  (tx, res) => fail('should fail'),
                  (e) {
                    // Error callback
                    captured = true;
                  },
                ),
              ),
            ),
          );
        }),
        throwsException,
      );

      expect(captured, true);

      final result = await adapter.query(Statement('SELECT * FROM items;'));
      expect(result, isEmpty);

      // Can open a new transaction
      await adapter.runInTransaction([Statement('SELECT 1')]);
    });

    test('rollback on COMMIT', () async {
      // To trigger an error at COMMIT time
      final adapter = getAdapter();
      await adapter.run(Statement('PRAGMA defer_foreign_keys = ON;'));

      try {
        await adapter.transaction<bool>((tx, setResult) {
          tx.run(
            Statement('INSERT INTO child(id, parent) VALUES (1, 2);'),
            (tx, res) {
              setResult(true);
            },
          );
        });

        fail('should fail at COMMIT time');
      } catch (e) {
        expect(
          e,
          // FOREIGN KEY constraint failed, constraint failed
          isA<SqliteException>()
              .having((p0) => p0.extendedResultCode, 'code', 787),
        );
      }

      final result = await adapter.query(Statement('SELECT * FROM items;'));
      expect(result, isEmpty);

      // Can open a new transaction
      await adapter.runInTransaction([Statement('SELECT 1')]);
    });
  });

  group('runInTransaction', () {
    test('successful', () async {
      final adapter = getAdapter();
      final transRes = await adapter.runInTransaction([
        Statement("INSERT INTO items VALUES ('foo');"),
        Statement("INSERT INTO items VALUES ('bar');"),
      ]);
      expect(transRes.rowsAffected, 2);

      final result = await adapter.query(Statement('SELECT * FROM items;'));
      expect(result, [
        {'value': 'foo'},
        {'value': 'bar'},
      ]);

      // Can open a new transaction
      await adapter.runInTransaction([Statement('SELECT 1')]);
    });

    test('rollback', () async {
      final adapter = getAdapter();
      try {
        await adapter.runInTransaction([
          Statement("INSERT INTO items VALUES ('foo');"),
          Statement('wrong'),
        ]);

        fail('should fail');
      } catch (e) {
        expect(
          e,
          isA<SqliteException>().having((p0) => p0.resultCode, 'code', 1),
        );
      }

      final result = await adapter.query(Statement('SELECT * FROM items;'));
      expect(result, isEmpty);

      // Can open a new transaction
      await adapter.runInTransaction([Statement('SELECT 1')]);
    });

    test('rollback on COMMIT', () async {
      // To trigger an error at COMMIT time
      final adapter = getAdapter();
      await adapter.run(Statement('PRAGMA defer_foreign_keys = ON;'));

      try {
        await adapter.runInTransaction([
          Statement('INSERT INTO child(id, parent) VALUES (1, 2);'),
        ]);

        fail('should fail');
      } catch (e) {
        expect(
          e,
          // FOREIGN KEY constraint failed, constraint failed
          isA<SqliteException>()
              .having((p0) => p0.extendedResultCode, 'code', 787),
        );
      }

      final result = await adapter.query(Statement('SELECT * FROM items;'));
      expect(result, isEmpty);

      // Can open a new transaction
      await adapter.runInTransaction([Statement('SELECT 1')]);
    });
  });

  test('grouped queries are isolated from other queries/transactions',
      () async {
    final adapter = getAdapter();

    bool query1Finished = false;

    // Make a slow grouped query and check that it is not interleaved with other queries/transactions
    Future<int> slowQuery(UncoordinatedDatabaseAdapter adapter) async {
      await Future<void>.delayed(const Duration(milliseconds: 100));
      await adapter.query(Statement('SELECT 1'));
      query1Finished = true;
      return 7;
    }

    final fut1 = adapter.runExclusively(slowQuery);
    final fut2 = adapter.transaction<int>((_tx, setResult) async {
      expect(query1Finished, true);
      setResult(5);
    });

    final results = await Future.wait<void>([fut1, fut2]);
    expect(results, [7, 5]);
  });
}

Future<void> initDb(DatabaseAdapter adapter) async {
  final stmts = [
    'CREATE TABLE IF NOT EXISTS items (\n  value TEXT PRIMARY KEY NOT NULL\n);',
    'CREATE TABLE IF NOT EXISTS parent (\n  id INTEGER PRIMARY KEY NOT NULL,\n  value TEXT,\n  other INTEGER DEFAULT 0\n);',
    'CREATE TABLE IF NOT EXISTS child (\n  id INTEGER PRIMARY KEY NOT NULL,\n  parent INTEGER NOT NULL,\n  FOREIGN KEY(parent) REFERENCES parent(id)\n);',
  ];

  for (final stmt in stmts) {
    await adapter.run(Statement(stmt));
  }
}
