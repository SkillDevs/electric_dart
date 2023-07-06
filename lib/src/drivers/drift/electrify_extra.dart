import 'package:drift/drift.dart';
import 'package:electric_client/src/notifiers/notifiers.dart';

mixin ElectricfiedDriftDatabaseMixin on DatabaseConnectionUser {
  Notifier? _electricNotifier;

  void setElectricNotifier(Notifier? notifier) {
    _electricNotifier = notifier;
  }

  late final ElectrifiedExecutor _electrifiedExecutor =
      ElectrifiedExecutor(super.executor, this);

  @override
  QueryExecutor get executor => _electrifiedExecutor;
}

class ElectrifiedExecutor implements QueryExecutor {
  final QueryExecutor delegate;
  final ElectricfiedDriftDatabaseMixin database;

  ElectrifiedExecutor(this.delegate, this.database);

  Notifier? get notifier => database._electricNotifier;

  @override
  TransactionExecutor beginTransaction() {
    return delegate.beginTransaction();
  }

  @override
  Future<void> close() {
    return delegate.close();
  }

  @override
  SqlDialect get dialect => delegate.dialect;

  @override
  Future<bool> ensureOpen(QueryExecutorUser user) {
    return delegate.ensureOpen(user);
  }

  @override
  Future<void> runBatched(BatchedStatements statements) async {
    await delegate.runBatched(statements);
    notifier?.potentiallyChanged();
  }

  @override
  Future<void> runCustom(String statement, [List<Object?>? args]) async {
    await delegate.runCustom(statement, args);
    notifier?.potentiallyChanged();
  }

  @override
  Future<int> runDelete(String statement, List<Object?> args) async {
    final res = await delegate.runDelete(statement, args);
    notifier?.potentiallyChanged();
    return res;
  }

  @override
  Future<int> runInsert(String statement, List<Object?> args) async {
    final rowId = await delegate.runInsert(statement, args);
    notifier?.potentiallyChanged();
    return rowId;
  }

  @override
  Future<List<Map<String, Object?>>> runSelect(
    String statement,
    List<Object?> args,
  ) {
    return delegate.runSelect(statement, args);
  }

  @override
  Future<int> runUpdate(String statement, List<Object?> args) async {
    final res = await delegate.runUpdate(statement, args);
    notifier?.potentiallyChanged();
    return res;
  }
}
