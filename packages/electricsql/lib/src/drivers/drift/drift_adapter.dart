import 'dart:async';

import 'package:drift/drift.dart';
import 'package:electricsql/src/electric/adapter.dart';
import 'package:electricsql/src/util/debug/debug.dart';
import 'package:electricsql/src/util/types.dart';

class DriftAdapter implements DatabaseAdapter {
  final DatabaseConnectionUser db;

  DriftAdapter(this.db);

  @override
  Future<List<Row>> query(Statement statement) async {
    final rows = await _wrapQuery(db, statement);
    return rows.map((e) => e.data).toList();
  }

  @override
  Future<RunResult> run(Statement statement) async {
    final numChanges = await _wrapUpdate(db, statement);
    return RunResult(rowsAffected: numChanges);
  }

  @override
  Future<RunResult> runInTransaction(List<Statement> statements) async {
    return db.transaction(() async {
      int rowsAffected = 0;
      for (final statement in statements) {
        final changes = await _wrapUpdate(db, statement);
        rowsAffected += changes;
      }
      return RunResult(rowsAffected: rowsAffected);
    });
  }

  @override
  Future<T> transaction<T>(
    void Function(DbTransaction tx, void Function(T res) setResult) f,
  ) async {
    final completer = Completer<T>();

    return db.transaction(() {
      final tx = Transaction(this, (e) {
        completer.completeError(e);
      });

      runZonedGuarded(() {
        f(tx, (T res) {
          completer.complete(res);
        });
      }, (error, stack) {
        completer.completeError(error);
      });

      return completer.future;
    });
  }
}

class Transaction implements DbTransaction {
  final DriftAdapter adapter;
  final void Function(Object reason) signalFailure;

  Transaction(this.adapter, this.signalFailure);

  @override
  void query(
    Statement statement,
    void Function(DbTransaction tx, List<Row> res) successCallback, [
    void Function(Object error)? errorCallback,
  ]) {
    _wrapQuery(adapter.db, statement).then((rows) {
      successCallback(
        this,
        rows.map((e) => e.data).toList(),
      );
    }).catchError((Object e) {
      errorCallback?.call(e);
      signalFailure(e);
    });
  }

  @override
  void run(
    Statement statement,
    void Function(DbTransaction tx, RunResult result)? successCallback, [
    void Function(Object error)? errorCallback,
  ]) {
    _wrapUpdate(adapter.db, statement).then((rowsAffected) {
      successCallback?.call(
        this,
        RunResult(
          rowsAffected: rowsAffected,
        ),
      );
    }).catchError((Object e) {
      errorCallback?.call(e);
      signalFailure(e);
    });
  }
}

Future<List<QueryRow>> _wrapQuery(
  DatabaseConnectionUser db,
  Statement stmt,
) async {
  try {
    // print("STATEMENT: ${_statementToString(stmt)}");
    final variables = _dynamicArgsToVariables(stmt.args);
    return await db.customSelect(stmt.sql, variables: variables).get();
  } catch (e) {
    logger.error('Query error: $e\n\tStatement: ${_statementToString(stmt)}');
    rethrow;
  }
}

Future<int> _wrapUpdate(
  DatabaseConnectionUser db,
  Statement stmt,
) async {
  try {
    // print("STATEMENT: ${_statementToString(stmt)}");
    final variables = _dynamicArgsToVariables(stmt.args);
    return await db.customUpdate(stmt.sql, variables: variables);
  } catch (e) {
    logger.error('Query error: $e\n\tStatement: ${_statementToString(stmt)}');
    rethrow;
  }
}

String _statementToString(Statement stmt) {
  return '${stmt.sql} - args: ${stmt.args?.map((a) => '$a - ${a.runtimeType}').toList()}';
}

List<Variable> _dynamicArgsToVariables(List<Object?>? args) {
  return (args ?? const [])
      .map((Object? arg) {
        if (arg == null) {
          return const Variable<Object>(null);
        }
        if (arg is bool) {
          return Variable.withBool(arg);
        } else if (arg is int) {
          return Variable.withInt(arg);
        } else if (arg is String) {
          return Variable.withString(arg);
        } else if (arg is double) {
          return Variable.withReal(arg);
        } else if (arg is DateTime) {
          return Variable.withDateTime(arg);
        } else if (arg is Uint8List) {
          return Variable.withBlob(arg);
        } else if (arg is Variable) {
          return arg;
        } else {
          assert(false, 'unknown type $arg');
          return Variable<Object>(arg);
        }
      })
      .cast<Variable>()
      .toList();
}
