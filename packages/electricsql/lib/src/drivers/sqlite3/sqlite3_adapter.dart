import 'dart:async';

import 'package:electricsql/drivers/drivers.dart';
import 'package:electricsql/src/migrators/query_builder/builder.dart';
import 'package:electricsql/src/util/types.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:synchronized/synchronized.dart';

class SqliteAdapter implements DatabaseAdapter {
  final sqlite.Database db;
  final Lock txLock = Lock();

  @override
  final Dialect dialect = Dialect.sqlite;

  SqliteAdapter(this.db);

  Future<List<Row>> _query(Statement statement) async {
    return db.select(statement.sql, statement.args ?? []);
  }

  Future<RunResult> _run(Statement statement) async {
    db.execute(statement.sql, statement.args ?? []);
    final rowsAffected = db.updatedRows;

    return RunResult(rowsAffected: rowsAffected);
  }

  Future<RunResult> _runInTransaction(List<Statement> statements) async {
    try {
      // SQL-js accepts multiple statements in a string and does
      // not run them as transaction.
      db.execute('BEGIN');

      int rowsAffected = 0;
      for (final statement in statements) {
        db.execute(statement.sql, statement.args ?? []);
        rowsAffected += db.updatedRows;
      }

      db.execute('COMMIT');

      return RunResult(rowsAffected: rowsAffected);
    } catch (error) {
      db.execute('ROLLBACK');

      rethrow; // rejects the promise with the reason for the rollback
    }
  }

  Future<T> _transaction<T>(
    void Function(Transaction tx, void Function(T res) setResult) f,
  ) async {
    db.execute('BEGIN');

    try {
      final txCompleter = Completer<T>();
      final tx = Transaction(this, (e) => txCompleter.completeError(e));

      runZonedGuarded(() {
        f(tx, (T res) {
          // Commit the transaction when the user sets the result.
          // This assumes that the user does not execute any more queries after setting the result.
          db.execute('COMMIT');
          txCompleter.complete(res);
        });
      }, (error, stack) {
        txCompleter.completeError(error);
      });

      return await txCompleter.future;
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  Future<T> _runExclusively<T>(
    Future<T> Function(UncoordinatedDatabaseAdapter adapter) f,
  ) {
    // We create an adapter that does not go through the mutex
    // when used by the function`f`, since we already take the mutex here
    final adapter = _UncoordinatedSqliteDatabaseAdapter(this);
    return f(adapter);
  }

  @override
  Future<List<Row>> query(Statement statement) {
    return txLock.synchronized(() => _query(statement));
  }

  @override
  Future<RunResult> run(Statement statement) {
    return txLock.synchronized(() => _run(statement));
  }

  @override
  Future<RunResult> runInTransaction(List<Statement> statements) {
    return txLock.synchronized(() => _runInTransaction(statements));
  }

  @override
  Future<T> transaction<T>(
    void Function(Transaction tx, void Function(T res) setResult) f,
  ) {
    return txLock.synchronized(() => _transaction(f));
  }

  @override
  Future<T> runExclusively<T>(
    Future<T> Function(UncoordinatedDatabaseAdapter adapter) f,
  ) {
    return txLock.synchronized(() => _runExclusively(f));
  }
}

class Transaction implements DbTransaction {
  final SqliteAdapter adapter;
  final void Function(Object reason) signalFailure;

  Transaction(
    this.adapter,
    this.signalFailure,
  );

  void invokeCallback<T>(
    Future<T> prom,
    void Function(Transaction tx, T result)? successCallback,
    void Function(Object error)? errorCallback,
  ) {
    prom.then((res) {
      successCallback?.call(this, res);
    }).catchError((Object err, _) {
      if (errorCallback != null) errorCallback(err);
      signalFailure(err);
    });
  }

  @override
  void run(
    Statement statement,
    void Function(Transaction tx, RunResult result)? successCallback, [
    void Function(Object error)? errorCallback,
  ]) {
    // uses _runUncoordinated because we're in a transaction that already acquired the lock
    final prom = adapter._run(statement);
    invokeCallback(prom, successCallback, errorCallback);
  }

  @override
  void query(
    Statement statement,
    void Function(Transaction tx, List<Row> res) successCallback, [
    void Function(Object error)? errorCallback,
  ]) {
    // uses _queryUncoordinated because we're in a transaction that already acquired the lock
    final prom = adapter._query(statement);
    invokeCallback(prom, successCallback, errorCallback);
  }
}

class _UncoordinatedSqliteDatabaseAdapter
    implements UncoordinatedDatabaseAdapter {
  final SqliteAdapter adapter;

  _UncoordinatedSqliteDatabaseAdapter(this.adapter);

  @override
  Future<List<Row>> query(Statement statement) {
    return adapter._query(statement);
  }

  @override
  Future<RunResult> run(Statement statement) {
    return adapter._run(statement);
  }

  @override
  Future<RunResult> runInTransaction(List<Statement> statements) {
    return adapter._runInTransaction(statements);
  }

  @override
  Future<T> transaction<T>(
    void Function(DbTransaction tx, void Function(T res) p1) setResult,
  ) {
    return adapter._transaction(setResult);
  }
}
