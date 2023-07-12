import 'dart:async';

import 'package:drift/backends.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:electric_client/drivers/drift.dart';
import 'package:electric_client/electric_dart.dart';
import 'package:electric_client/src/util/types.dart';
import 'package:test/test.dart';

import 'common.dart';

Future<void> main() async {
  late GenericDb db;
  late DatabaseAdapter adapter;

  setUp(() async {
    db = await GenericDb.open(NativeDatabase.memory());
    adapter = DriftAdapter(db);

    await adapter.run(Statement("PRAGMA foreign_keys = ON;"));
    await initDb(adapter);
  });

  tearDown(() async {
    await db.close();
  });

  runTests(() => adapter);
}

class GenericDb extends GeneratedDatabase {
  GenericDb._connect(super.connection) : super.connect();

  @override
  int get schemaVersion => 1;

  static Future<GenericDb> open(DelegatedDatabase executor) async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
    final effectiveExecutor = NoVersionDelegatedDatabase(executor);
    final connection = DatabaseConnection(effectiveExecutor);
    final db = await GenericDb.openFromConnection(connection);

    driftRuntimeOptions.dontWarnAboutMultipleDatabases = false;

    return db;
  }

  static Future<GenericDb> openFromConnection(
    DatabaseConnection connection,
  ) async {
    driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

    final db = GenericDb._connect(connection);

    try {
      // Running this will fail if we are opening an invalid database. Otherwise it will simply open a database
      // with no tables inside. We prefer to detect early if it is not valid, as it is very common to open an
      // already created database.
      // It also provides a chance for Drift to open the database on the first query that is run
      await db.customSelect("PRAGMA schema_version").get();
    } catch (e) {
      await db.close();
      rethrow;
    } finally {
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = false;
    }

    return db;
  }

  @override
  Future<void> close() async {
    await super.close();
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables => [];
}

class NoVersionDelegatedDatabase extends DelegatedDatabase {
  final DelegatedDatabase db;

  NoVersionDelegatedDatabase(
    this.db,
  ) : super(
          _NoVersionDatabaseDelegate(db.delegate),
          logStatements: db.logStatements,
          isSequential: db.isSequential,
        );
}

class _NoVersionDatabaseDelegate extends DatabaseDelegate {
  final DatabaseDelegate delegate;

  _NoVersionDatabaseDelegate(this.delegate);

  @override
  FutureOr<bool> get isOpen => delegate.isOpen;

  @override
  Future<void> open(QueryExecutorUser db) {
    return delegate.open(db);
  }

  @override
  Future<void> runCustom(String statement, List<Object?> args) {
    return delegate.runCustom(statement, args);
  }

  @override
  Future<int> runInsert(String statement, List<Object?> args) {
    return delegate.runInsert(statement, args);
  }

  @override
  Future<QueryResult> runSelect(String statement, List<Object?> args) {
    return delegate.runSelect(statement, args);
  }

  @override
  Future<int> runUpdate(String statement, List<Object?> args) {
    return delegate.runUpdate(statement, args);
  }

  @override
  Future<void> close() {
    return delegate.close();
  }

  @override
  TransactionDelegate get transactionDelegate => delegate.transactionDelegate;

  @override
  DbVersionDelegate get versionDelegate => const NoVersionDelegate();
}
