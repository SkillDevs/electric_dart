import 'package:electricsql/drivers/drivers.dart';
import 'package:electricsql/drivers/sqlite3.dart';
import 'package:electricsql/electricsql.dart';
import 'package:electricsql/src/util/index.dart';
import 'package:electricsql/src/util/transaction.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import 'sqlite.dart';

void main() {
  late Database db;
  late DatabaseAdapter adapter;

  setUp(() async {
    db = openSqliteDbMemory();
    adapter = SqliteAdapter(db);

    await adapter.runInTransaction([
      Statement(
        "CREATE TABLE IF NOT EXISTS parent('pid' TEXT NOT NULL PRIMARY KEY);",
      ),
      Statement(
        "CREATE TABLE IF NOT EXISTS child('cid' TEXT NOT NULL PRIMARY KEY, 'p' TEXT NOT NULL REFERENCES parent(pid));",
      ),
    ]);
  });

  tearDown(() {
    db.dispose();
  });

  test('runInTransaction disables FK checks when flag is set to disabled',
      () async {
    await adapter.run(Statement('PRAGMA foreign_keys = ON;'));

    // Should succeed even though the FK is not valid
    final res = await runStmtsInTransaction(
      adapter,
      fkChecks: ForeignKeyChecks.disabled,
      stmts: [
        Statement(
          "INSERT INTO child (cid, p) VALUES ('c1', 'p1');",
        ),
      ],
    );

    expect(res.rowsAffected, 1);

    // Check that the row is in the database
    final childRow = await adapter.query(Statement('SELECT * FROM child;'));
    expect(childRow.length, 1);
    expect(childRow[0], {'cid': 'c1', 'p': 'p1'});

    // Check that the FK pragma is re-enabled
    final fkRow = await adapter.query(
      Statement(
        'PRAGMA foreign_keys;',
      ),
    );
    expect(fkRow.first['foreign_keys'], 1);
  });

  test(
      'runInTransaction disables FK checks when flag is set to disabled and FK pragma is already disabled',
      () async {
    await adapter.run(Statement('PRAGMA foreign_keys = OFF;'));

    // Should succeed even though the FK is not valid
    final res = await runStmtsInTransaction(
      adapter,
      fkChecks: ForeignKeyChecks.disabled,
      stmts: [
        Statement(
          "INSERT INTO child (cid, p) VALUES ('c1', 'p1');",
        ),
      ],
    );

    expect(res.rowsAffected, 1);

    // Check that the row is in the database
    final childRows = await adapter.query(Statement('SELECT * FROM child;'));
    expect(childRows.length, 1);
    expect(childRows[0], {'cid': 'c1', 'p': 'p1'});

    // Check that the FK pragma is still disabled
    final fkRow = await adapter.query(
      Statement(
        'PRAGMA foreign_keys;',
      ),
    );
    expect(fkRow.first['foreign_keys'], 0);
  });

  test('runInTransaction enables FK checks when flag is set to enabled',
      () async {
    await adapter.run(Statement('PRAGMA foreign_keys = OFF;'));

    // Should fail because the FK is not valid
    await expectLater(
      () => runStmtsInTransaction(
        adapter,
        fkChecks: ForeignKeyChecks.enabled,
        stmts: [
          Statement(
            "INSERT INTO child (cid, p) VALUES ('c1', 'p1');",
          ),
        ],
      ),
      throwsA(
        isA<SqliteException>().having(
          (e) => e.toString(),
          'message',
          contains('FOREIGN KEY constraint failed'),
        ),
      ),
    );

    final childRows = await adapter.query(Statement('SELECT * FROM child;'));
    expect(childRows.length, 0);

    // Now insert a parent row and a child row pointing to the parent
    await runStmtsInTransaction(
      adapter,
      fkChecks: ForeignKeyChecks.enabled,
      stmts: [
        Statement("INSERT INTO parent (pid) VALUES ('p1');"),
        Statement("INSERT INTO child (cid, p) VALUES ('c1', 'p1');"),
      ],
    );

    // Check that the rows are in the database
    final parentRows = await adapter.query(Statement('SELECT * FROM parent;'));
    expect(parentRows.length, 1);
    expect(parentRows[0], {'pid': 'p1'});

    final childRowsAfterInsert = await adapter.query(
      Statement(
        'SELECT * FROM child;',
      ),
    );
    expect(childRowsAfterInsert.length, 1);
    expect(childRowsAfterInsert[0], {'cid': 'c1', 'p': 'p1'});

    // Check that the FK pragma is re-disabled
    final fkRow = await adapter.query(
      Statement(
        'PRAGMA foreign_keys;',
      ),
    );
    expect(fkRow.first['foreign_keys'], 0);
  });

  test(
      'runInTransaction enables FK checks when flag is set to enabled and pragma is already enabled',
      () async {
    await adapter.run(Statement('PRAGMA foreign_keys = ON;'));

    // Should fail because the FK is not valid
    await expectLater(
      () => runStmtsInTransaction(
        adapter,
        fkChecks: ForeignKeyChecks.enabled,
        stmts: [
          Statement(
            "INSERT INTO child (cid, p) VALUES ('c1', 'p1');",
          ),
        ],
      ),
      throwsA(
        isA<SqliteException>().having(
          (e) => e.toString(),
          'message',
          contains('FOREIGN KEY constraint failed'),
        ),
      ),
    );

    final childRows = await adapter.query(Statement('SELECT * FROM child;'));
    expect(childRows.length, 0);

    // Now insert a parent row and a child row pointing to the parent
    await runStmtsInTransaction(
      adapter,
      fkChecks: ForeignKeyChecks.enabled,
      stmts: [
        Statement("INSERT INTO parent (pid) VALUES ('p1');"),
        Statement("INSERT INTO child (cid, p) VALUES ('c1', 'p1');"),
      ],
    );

    // Check that the rows are in the database
    final parentRows = await adapter.query(Statement('SELECT * FROM parent;'));
    expect(parentRows.length, 1);
    expect(parentRows[0], {'pid': 'p1'});

    final childRowsAfterInsert = await adapter.query(
      Statement(
        'SELECT * FROM child;',
      ),
    );
    expect(childRowsAfterInsert.length, 1);
    expect(childRowsAfterInsert[0], {'cid': 'c1', 'p': 'p1'});

    // Check that the FK pragma is re-enabled
    final fkRow = await adapter.query(
      Statement(
        'PRAGMA foreign_keys;',
      ),
    );
    expect(fkRow.first['foreign_keys'], 1);
  });

  test('runInTransaction does not touch enabled FK pragma when flag is inherit',
      () async {
    await adapter.run(Statement('PRAGMA foreign_keys = ON;'));

    // Should fail because the FK is not valid
    await expectLater(
      () => runStmtsInTransaction(
        adapter,
        fkChecks: ForeignKeyChecks.inherit,
        stmts: [
          Statement(
            "INSERT INTO child (cid, p) VALUES ('c1', 'p1');",
          ),
        ],
      ),
      throwsA(
        isA<SqliteException>().having(
          (e) => e.toString(),
          'message',
          contains('FOREIGN KEY constraint failed'),
        ),
      ),
    );

    final childRows = await adapter.query(Statement('SELECT * FROM child;'));
    expect(childRows.length, 0);

    // Check that the FK pragma is left untouched
    final fkRow1 = await adapter.query(
      Statement(
        'PRAGMA foreign_keys;',
      ),
    );
    final fk1 = fkRow1.first['foreign_keys'];
    expect(fk1, 1);

    // Now insert a parent row and a child row pointing to the parent
    await runStmtsInTransaction(
      adapter,
      fkChecks: ForeignKeyChecks.inherit,
      stmts: [
        Statement("INSERT INTO parent (pid) VALUES ('p1');"),
        Statement("INSERT INTO child (cid, p) VALUES ('c1', 'p1');"),
      ],
    );

    // Check that the rows are in the database
    final parentRows = await adapter.query(Statement('SELECT * FROM parent;'));
    expect(parentRows.length, 1);
    expect(parentRows[0], {'pid': 'p1'});

    final childRowsAfterInsert = await adapter.query(
      Statement(
        'SELECT * FROM child;',
      ),
    );
    expect(childRowsAfterInsert.length, 1);
    expect(childRowsAfterInsert[0], {'cid': 'c1', 'p': 'p1'});

    // Check that the FK pragma is left untouched
    final fkRow2 = await adapter.query(
      Statement(
        'PRAGMA foreign_keys;',
      ),
    );
    final fk2 = fkRow2.first['foreign_keys'];

    expect(fk2, 1);
  });

  test(
      'runInTransaction does not touch disabled FK pragma when flag is inherit',
      () async {
    await adapter.run(Statement('PRAGMA foreign_keys = OFF;'));

    // Should succeed even though the FK is not valid
    // because we disabled the FK pragma
    // and passed `inherit` for the `fkChecks` flag
    // which means the FK pragma is used as is
    final res = await runStmtsInTransaction(
      adapter,
      fkChecks: ForeignKeyChecks.inherit,
      stmts: [
        Statement(
          "INSERT INTO child (cid, p) VALUES ('c1', 'p1');",
        ),
      ],
    );

    expect(res.rowsAffected, 1);

    // Check that the row is in the database
    final childRow = await adapter.query(Statement('SELECT * FROM child;'));
    expect(childRow.length, 1);
    expect(childRow[0], {'cid': 'c1', 'p': 'p1'});

    // Check that the FK pragma is still disabled
    final fkRow = await adapter.query(
      Statement(
        'PRAGMA foreign_keys;',
      ),
    );
    expect(fkRow.first['foreign_keys'], 0);
  });
}
