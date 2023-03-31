import 'package:electric_client/util/tablename.dart';
import 'package:electric_client/util/types.dart';

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

class DummyDatabaseAdapter extends DatabaseAdapter {
  @override
  Future<List<Row>> query(Statement statement) async {
    print("QUERY $statement");

    return [];
  }

  @override
  Future<RunResult> run(Statement statement) async {
    print("RUN $statement");

    return RunResult(rowsAffected: 0);
  }

  @override
  Future<RunResult> runInTransaction(List<Statement> statements) async {
    print("RUN In Transaction $statements");

    return RunResult(rowsAffected: 0);
  }

  @override
  List<QualifiedTablename> tableNames(Statement statement) {
    print("Table names $statement");
    return [];
  }

  @override
  Future<T> transaction<T>(void Function(Transaction tx, void Function(T res) p1) setResult) {
    print("Transaction $setResult");

    throw UnimplementedError();
    // return setResult();
  }
}
