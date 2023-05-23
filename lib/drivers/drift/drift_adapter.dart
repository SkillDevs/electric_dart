import 'dart:async';

import 'package:drift/drift.dart';
import 'package:electric_client/electric/adapter.dart' as adp;
import 'package:electric_client/notifiers/notifiers.dart';
import 'package:electric_client/util/debug/debug.dart';
import 'package:electric_client/util/tablename.dart';
import 'package:electric_client/util/types.dart';

class DriftAdapter extends adp.DatabaseAdapter {
  final DatabaseConnectionUser db;

  DriftAdapter(this.db);

  @override
  Future<List<Row>> query(Statement statement) async {
    final rows = await db
        .customSelect(
          statement.sql,
          variables: _dynamicArgsToVariables(statement.args),
        )
        .get();

    return rows.map((e) => e.data).toList();
  }

  @override
  Future<RunResult> run(Statement statement) async {
    final numChanges = await db.customUpdate(
      statement.sql,
      variables: _dynamicArgsToVariables(statement.args),
    );

    return RunResult(rowsAffected: numChanges);
  }

  @override
  Future<RunResult> runInTransaction(List<Statement> statements) async {
    await db.transaction(() async {
      for (final statement in statements) {
        await db.customStatement(statement.sql, statement.args);
      }
    });

    // TODO(dart): Should runInTransaction return the rows affected?
    return RunResult(rowsAffected: 0);
  }

  @override
  List<QualifiedTablename> tableNames(Statement statement) {
    // TODO(dart): implement tableNames
    throw UnimplementedError();
  }

  @override
  Future<T> transaction<T>(
    void Function(adp.Transaction tx, void Function(T res) setResult) f,
  ) async {
    final completer = Completer<T>();

    unawaited(
      db.transaction(() async {
        final tx = Transaction(this);
        f(tx, (T res) {
          completer.complete(res);
        });
      }).catchError((Object e) {
        completer.completeError(e);
      }),
    );

    return await completer.future;
  }

  void Function() hookToNotifier(Notifier notifier) {
    final key = notifier.subscribeToDataChanges(
      (notification) {
        final tablesChanged = notification.changes.map((e) {
          final tableName = e.qualifiedTablename.tablename;
          return tableName;
        }).toSet();

        final tableUpdates = tablesChanged.map((e) => TableUpdate(e)).toSet();
        logger.info("Notifying table changes to drift: $tablesChanged");
        db.notifyUpdates(tableUpdates);
      },
    );

    return () {
      notifier.unsubscribeFromDataChanges(key);
    };
  }
}

class Transaction implements adp.Transaction {
  final DriftAdapter adapter;

  Transaction(this.adapter);

  @override
  void query(
    Statement statement,
    void Function(adp.Transaction tx, List<Row> res) successCallback,
    void Function(Object error)? errorCallback,
  ) {
    adapter.db
        .customSelect(
          statement.sql,
          variables: _dynamicArgsToVariables(statement.args),
        )
        .get()
        .catchError((Object e) {
      errorCallback?.call(e);
      return <QueryRow>[];
    }).then((rows) {
      successCallback(
        this,
        rows.map((e) => e.data).toList(),
      );
    });
  }

  @override
  void run(
    Statement statement,
    void Function(adp.Transaction tx, RunResult result)? successCallback,
    void Function(Object error)? errorCallback,
  ) {
    adapter.db
        .customStatement(
      statement.sql,
      statement.args,
    )
        .catchError((Object e) {
      errorCallback?.call(e);
    }).then((_) {
      successCallback?.call(
        this,
        RunResult(
          rowsAffected: 0,
        ), // TODO(dart): we could call select changes()
      );
    });
  }
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
          assert(false, "unknown type $arg");
          return Variable<Object>(arg);
        }
      })
      .cast<Variable>()
      .toList();
}
