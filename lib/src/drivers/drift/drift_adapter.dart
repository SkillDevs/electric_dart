import 'dart:async';

import 'package:drift/drift.dart';
import 'package:electric_client/src/electric/adapter.dart' as adp;
import 'package:electric_client/src/notifiers/notifiers.dart';
import 'package:electric_client/src/util/debug/debug.dart';
import 'package:electric_client/src/util/types.dart';

class DriftAdapter implements adp.DatabaseAdapter {
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
    return await db.transaction(() async {
      int rowsAffected = 0;
      for (final statement in statements) {
        final changes = await db.customUpdate(
          statement.sql,
          variables: _dynamicArgsToVariables(statement.args),
        );
        rowsAffected += changes;
      }
      return RunResult(rowsAffected: rowsAffected);
    });
  }

  @override
  Future<T> transaction<T>(
    void Function(adp.Transaction tx, void Function(T res) setResult) f,
  ) async {
    final completer = Completer<T>();

    unawaited(
      db.transaction(() async {
        final tx = Transaction(this, (e) => completer.completeError(e));
        f(tx, (T res) {
          completer.complete(res);
        });
      }).catchError((Object e) {
        completer.completeError(e);
      }),
    );

    return await completer.future;
  }

  void Function() hookToNotifier(
    Notifier notifier,
  ) {
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

    final tableUpdateSub = db.tableUpdates().listen((updatedTables) {
      logger.info(
        "Drift tables have been updated $updatedTables. Notifying Electric.",
      );
      notifier.potentiallyChanged();
    });

    return () {
      notifier.unsubscribeFromDataChanges(key);
      tableUpdateSub.cancel();
    };
  }
}

class Transaction implements adp.Transaction {
  final DriftAdapter adapter;
  final void Function(Object reason) signalFailure;

  Transaction(this.adapter, this.signalFailure);

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
        .customUpdate(
      statement.sql,
      variables: _dynamicArgsToVariables(statement.args),
    )
        .then((rowsAffected) {
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
