import 'package:electricsql/migrators.dart';
import 'package:electricsql/src/util/types.dart';

// TODO(dart): Implement flag to disable FKs on incoming replication transactions
// commit message: feat (client): flag to disable FKs on incoming TXs in SQLite
// https://github.com/electric-sql/electric/commit/f4f020d97916dd975661ea56ac2e08df3a70fab1

/// A `DatabaseAdapter` adapts a database client to provide the
/// normalised interface defined here.
abstract class DatabaseAdapter {
  //db: AnyDatabase

  Dialect get dialect;

  // Runs the provided sql statement
  Future<RunResult> run(Statement statement);

  // Runs the provided sql as a transaction
  Future<RunResult> runInTransaction(List<Statement> statements);

  // Query the database.
  Future<List<Row>> query(Statement statement);

  /// Runs the provided __non-async__ function inside a transaction.
  ///
  /// The function may not use async/await otherwise the transaction may commit before
  /// the queries are actually executed. This is a limitation of some adapters, that the
  /// function passed to the transaction runs "synchronously" through callbacks without
  /// releasing the event loop.
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
