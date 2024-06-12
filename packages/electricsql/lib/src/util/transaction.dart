import 'package:electricsql/electricsql.dart';
import 'package:electricsql/util.dart';

/// Runs the provided statements in a transaction and disables FK checks if `disableFKs` is true.
/// FK checks are enabled if `disableFKs` is false.
/// FK checks are left untouched if `disableFKs` is undefined.
/// `disableFKs` should only be set to true when using SQLite as we already disable FK checks for incoming TXs when using Postgres,
/// so the executed SQL code to disable FKs is for SQLite dialect only.
Future<RunResult> runStmtsInTransaction(
  DatabaseAdapter adapter, {
  required bool? disableFKs,
  required List<Statement> stmts,
}) {
  if (disableFKs == null) {
    // don't touch the FK pragma
    return adapter.runInTransaction(stmts);
  }

  final desiredPragma = disableFKs ? 0 : 1;

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
