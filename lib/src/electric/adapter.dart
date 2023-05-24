import 'package:electric_client/src/util/tablename.dart';
import 'package:electric_client/src/util/types.dart';

abstract class DatabaseAdapter {
  //db: AnyDatabase

  // Runs the provided sql statement
  Future<RunResult> run(Statement statement);

  // Runs the provided sql as a transaction
  Future<RunResult> runInTransaction(List<Statement> statements);

  // Query the database.
  Future<List<Row>> query(Statement statement);

  // Runs the provided function inside a transaction
  // The function may not use async/await otherwise the transaction may commit before the queries are actually executed
  Future<T> transaction<T>(
    void Function(Transaction tx, void Function(T res)) setResult,
  );

  // Get the tables potentially used by the query (so that we
  // can re-query if the data in them changes).
  List<QualifiedTablename> tableNames(Statement statement);
}

abstract class Transaction {
  void run(
    Statement statement,
    void Function(Transaction tx, RunResult result)? successCallback,
    void Function(Object error)? errorCallback,
  );

  void query(
    Statement statement,
    void Function(Transaction tx, List<Row> res) successCallback,
    void Function(Object error)? errorCallback,
  );
}
