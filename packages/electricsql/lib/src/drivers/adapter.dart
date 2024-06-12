import 'package:electricsql/migrators.dart';
import 'package:electricsql/src/util/types.dart';

abstract interface class UncoordinatedDatabaseAdapter {
  Future<RunResult> run(Statement statement);
  Future<RunResult> runInTransaction(List<Statement> statements);
  Future<List<Row>> query(Statement statement);
  Future<T> transaction<T>(
    void Function(DbTransaction tx, void Function(T res)) setResult,
  );
}

/// A `DatabaseAdapter` adapts a database client to provide the
/// normalised interface defined here.
abstract class DatabaseAdapter implements UncoordinatedDatabaseAdapter {
  //db: AnyDatabase

  Dialect get dialect;

  // Runs the provided sql statement
  @override
  Future<RunResult> run(Statement statement);

  // Runs the provided sql as a transaction
  @override
  Future<RunResult> runInTransaction(List<Statement> statements);

  /// This method is useful to execute several queries in isolation from any other queries/transactions executed through this adapter.
  /// Useful to execute queries that cannot be executed inside a transaction (e.g. SQLite does not allow the `foreign_keys` PRAGMA to be modified in a transaction).
  /// In that case we can use this `group` method:
  ///  ```
  ///  await adapter.runExclusively(async (adapter) => {
  ///    await adapter.run({ sql: 'PRAGMA foreign_keys = OFF;' })
  ///    ...
  ///    await adapter.run({ sql: 'PRAGMA foreign_keys = ON;' })
  ///  })
  ///  ```
  /// This snippet above ensures that no other query/transaction will be interleaved when the foreign keys are disabled.
  /// @param f Function that is guaranteed to be executed in isolation from other queries/transactions executed by this adapter.
  Future<T> runExclusively<T>(
    Future<T> Function(UncoordinatedDatabaseAdapter) f,
  );

  // Query the database.
  @override
  Future<List<Row>> query(Statement statement);

  /// Runs the provided __non-async__ function inside a transaction.
  ///
  /// The function may not use async/await otherwise the transaction may commit before
  /// the queries are actually executed. This is a limitation of some adapters, that the
  /// function passed to the transaction runs "synchronously" through callbacks without
  /// releasing the event loop.
  @override
  Future<T> transaction<T>(
    void Function(DbTransaction tx, void Function(T res)) setResult,
  );
}

abstract class DbTransaction {
  void run(
    Statement statement,
    void Function(DbTransaction tx, RunResult result)? successCallback, [
    void Function(Object error)? errorCallback,
  ]);

  void query(
    Statement statement,
    void Function(DbTransaction tx, List<Row> res) successCallback, [
    void Function(Object error)? errorCallback,
  ]);
}
