import 'dart:async';

import 'package:drift/drift.dart';
import 'package:electricsql/src/electric/adapter.dart';
import 'package:electricsql/src/util/debug/debug.dart';
import 'package:electricsql/src/util/types.dart';

// TODO(dart):: Conditional import
import 'package:postgres/postgres.dart' as pg;

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
    final variables =
        _dynamicArgsToVariables(db.typeMapping.dialect, stmt.args);
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
    final variables =
        _dynamicArgsToVariables(db.typeMapping.dialect, stmt.args);
    return await db.customUpdate(stmt.sql, variables: variables);
  } catch (e) {
    logger.error('Query error: $e\n\tStatement: ${_statementToString(stmt)}');
    rethrow;
  }
}

String _statementToString(Statement stmt) {
  return '${stmt.sql} - args: ${stmt.args?.map((a) => '$a - ${a.runtimeType}').toList()}';
}

List<Variable> _dynamicArgsToVariables(
  SqlDialect dialect,
  List<Object?>? args,
) {
  return (args ?? const [])
      .map((Object? arg) {
        return Variable(_mapVariable(dialect, arg));
      })
      .cast<Variable>()
      .toList();
}

Object? _mapVariable(SqlDialect dialect, Object? value) {
  if (value == null) {
    return null;
  }

  if (dialect == SqlDialect.postgres) {
    if (value is double) {
      if (value.isNaN || value.isInfinite) {
        return pg.TypedValue(pg.Type.double, value);
      }
    } else if (value is List<int>) {
      return pg.TypedValue(pg.Type.byteArray, value);
    } else if (value is BigInt) {
      return pg.TypedValue(pg.Type.bigInteger, value.rangeCheckedToInt());
    }

    return pg.TypedValue(pg.Type.unspecified, value);
  }

  return value;
}

extension on BigInt {
  static final _bigIntMinValue64 = BigInt.from(-9223372036854775808);
  static final _bigIntMaxValue64 = BigInt.from(9223372036854775807);

  int rangeCheckedToInt() {
    if (this < _bigIntMinValue64 || this > _bigIntMaxValue64) {
      throw ArgumentError.value(
        this,
        'this',
        'BigInt value exceeds the range of 64 bits',
      );
    }

    return toInt();
  }
}
