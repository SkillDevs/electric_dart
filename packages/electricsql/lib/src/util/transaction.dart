import 'package:electricsql/drivers/drivers.dart';
import 'package:electricsql/electricsql.dart';
import 'package:electricsql/util.dart';

/// Runs the provided statements in a transaction and sets the `foreign_keys` pragma based on the `fkChecks` flag.
/// FK checks are enabled if `fkChecks` is `ForeignKeyChecks.enabled`.
/// FK checks are disabled if `fkChecks` is `ForeignKeyChecks.disabled`.
/// FK checks are left untouched if `fkChecks` is `ForeignKeyChecks.inherit`.
/// `fkChecks` should only be set to `ForeignKeyChecks.disabled` when using SQLite as we already disable FK checks for incoming TXs when using Postgres,
/// so the executed SQL code to disable FKs is for SQLite dialect only.
Future<RunResult> runStmtsInTransaction(
  DatabaseAdapter adapter, {
  required ForeignKeyChecks fkChecks,
  required List<Statement> stmts,
}) {
  if (fkChecks == ForeignKeyChecks.inherit) {
    // don't touch the FK pragma
    return adapter.runInTransaction(stmts);
  }

  final desiredPragma = fkChecks == ForeignKeyChecks.disabled ? 0 : 1;

  return adapter.runExclusively((uncoordinatedAdapter) async {
    final res = await uncoordinatedAdapter.query(
      Statement(
        'PRAGMA foreign_keys;',
      ),
    );
    final originalPragma = res.first['foreign_keys']! as int;

    if (originalPragma != desiredPragma) {
      // set the pragma to the desired value
      await uncoordinatedAdapter.run(
        Statement(
          'PRAGMA foreign_keys = $desiredPragma;',
        ),
      );
    }

    try {
      // apply the statements in a TX
      final res = await uncoordinatedAdapter.runInTransaction(stmts);
      return res;
    } finally {
      // Need to restore the pragma also if TX throwed
      if (originalPragma != desiredPragma) {
        // restore the pragma to its original value
        await uncoordinatedAdapter.run(
          Statement(
            'PRAGMA foreign_keys = $originalPragma;',
          ),
        );
      }
    }
  });
}
