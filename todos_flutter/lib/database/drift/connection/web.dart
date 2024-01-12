import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:flutter/foundation.dart';

const webDbName = "todo-app";

final _sqlite3Uri = Uri.parse('/sqlite3.wasm');
final _driftWorkerUri = Uri.parse('/drift_worker.js');

/// Obtains a database connection for running drift on the web.
DatabaseConnection connect() {
  return DatabaseConnection.delayed(Future(() async {
    final db = await WasmDatabase.open(
      databaseName: webDbName,
      sqlite3Uri: _sqlite3Uri,
      driftWorkerUri: _driftWorkerUri,
    );

    if (db.missingFeatures.isNotEmpty) {
      debugPrint('Using ${db.chosenImplementation} due to unsupported '
          'browser features: ${db.missingFeatures}');
    }

    print("Chosen Web sqlite implementation: ${db.chosenImplementation}");

    final conn = db.resolvedExecutor;
    return conn;
  }));
}

Future<void> deleteTodosDbFile() async {
  final probeRes = await WasmDatabase.probe(
    sqlite3Uri: _sqlite3Uri,
    driftWorkerUri: _driftWorkerUri,
    databaseName: webDbName,
  );

  final db = _firstWhereOrNull(
    probeRes.existingDatabases,
    (dbInfo) => dbInfo.$2 == webDbName,
  );

  if (db != null) {
    await probeRes.deleteDatabase(db);
    print("deleted web database");
  }
}

T? _firstWhereOrNull<T>(Iterable<T> l, bool Function(T element) test) {
  for (var element in l) {
    if (test(element)) return element;
  }
  return null;
}
