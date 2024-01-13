import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:flutter/foundation.dart';

final _sqlite3Uri = Uri.parse('/sqlite3.wasm');
final _driftWorkerUri = Uri.parse('/drift_worker.js');

String _buildDbName(String userId) => "todo-app_$userId";

/// Obtains a database connection for running drift on the web.
DatabaseConnection connect(String userId) {
  return DatabaseConnection.delayed(Future(() async {
    final userDbName = _buildDbName(userId);

    final db = await WasmDatabase.open(
      databaseName: userDbName,
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

Future<void> deleteTodosDbFile(String userId) async {
  final userDbName = _buildDbName(userId);

  final probeRes = await WasmDatabase.probe(
    sqlite3Uri: _sqlite3Uri,
    driftWorkerUri: _driftWorkerUri,
    databaseName: userDbName,
  );

  final db = _firstWhereOrNull(
    probeRes.existingDatabases,
    (dbInfo) => dbInfo.$2 == userDbName,
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
