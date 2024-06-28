import 'package:electricsql/electricsql.dart';
import 'package:electricsql/src/client/model/sync.dart';
import 'package:electricsql/src/client/model/transform.dart' as transform_lib;
import 'package:electricsql/src/client/model/transform.dart'
    hide setReplicationTransform;
import 'package:electricsql/src/migrators/query_builder/query_builder.dart';
import 'package:electricsql/src/notifiers/notifiers.dart';
import 'package:electricsql/src/satellite/satellite.dart';
import 'package:electricsql/util.dart';
import 'package:meta/meta.dart';

abstract interface class BaseElectricClient {
  // ElectricNamespace methods
  String get dbName;
  DatabaseAdapter get adapter;
  Notifier get notifier;
  Registry get registry;

  bool get isConnected;

  void setIsConnected(ConnectivityState connectivityState);

  void potentiallyChanged();

  Future<void> close();

  // ElectricClient methods
  DBSchema get dbDescription;
  Satellite get satellite;
  SyncManager get syncManager;
  @internal
  IReplicationTransformManager get replicationTransformManager;
  Future<void> connect([String? token]);
  void disconnect();
}

abstract interface class ElectricClientRaw implements BaseElectricClient {
  void setReplicationTransform(
    QualifiedTablename qualifiedTableName,
    ReplicatedRowTransformer<DbRecord> i,
  );
}

class ElectricClientRawImpl extends ElectricNamespace
    implements ElectricClientRaw {
  @override
  final Satellite satellite;

  @protected
  late final IShapeManager shapeManager;

  @override
  @internal
  late final IReplicationTransformManager replicationTransformManager;

  @override
  final DBSchema dbDescription;

  @override
  late final SyncManager syncManager = _SyncManagerImpl(baseClient: this);

  final Dialect dialect;

  /// Connects to the Electric sync service.
  /// This method is idempotent, it is safe to call it multiple times.
  /// @param token - The JWT token to use to connect to the Electric sync service.
  ///                This token is required on first connection but can be left out when reconnecting
  ///                in which case the last seen token is reused.
  @override
  Future<void> connect([String? token]) async {
    if (token == null && !satellite.hasToken()) {
      throw Exception('A token is required the first time you connect.');
    }
    if (token != null) {
      satellite.setToken(token);
    }
    await satellite.connectWithBackoff();
  }

  @override
  void disconnect() {
    satellite.clientDisconnect();
  }

  factory ElectricClientRawImpl.create({
    required String dbName,
    required DatabaseAdapter adapter,
    required DBSchema dbDescription,
    required Notifier notifier,
    required Satellite satellite,
    required Registry registry,
    required Dialect dialect,
  }) {
    return ElectricClientRawImpl.internal(
      dbName: dbName,
      adapter: adapter,
      notifier: notifier,
      satellite: satellite,
      dbDescription: dbDescription,
      registry: registry,
      dialect: dialect,
    );
  }

  @protected
  ElectricClientRawImpl.internal({
    required super.dbName,
    required super.adapter,
    required super.notifier,
    required super.registry,
    required this.satellite,
    required this.dbDescription,
    required this.dialect,
  }) : super() {
    replicationTransformManager = ReplicationTransformManager(satellite);
  }

  @override
  void setReplicationTransform(
    QualifiedTablename qualifiedTableName,
    ReplicatedRowTransformer<DbRecord> i,
  ) {
    transform_lib.setReplicationTransform(
      dbDescription: dbDescription,
      replicationTransformManager: replicationTransformManager,
      qualifiedTableName: qualifiedTableName,
      validateFun: null,
      transformInbound: i.transformInbound,
      transformOutbound: i.transformOutbound,
      toRecord: (r) => r,
      fromRecord: (r) => r,
    );
  }
}

class _SyncManagerImpl implements SyncManager {
  final BaseElectricClient baseClient;

  _SyncManagerImpl({required this.baseClient});

  @override
  Future<ShapeSubscription> subscribe(
    ShapeInputRaw i, [
    String? key,
  ]) {
    return syncShape(baseClient.satellite, baseClient.dbDescription, i, key);
  }

  @override
  Future<void> unsubscribe(List<String> keys) {
    return baseClient.satellite.unsubscribe(keys);
  }

  @override
  SyncStatus syncStatus(String key) {
    return baseClient.satellite.syncStatus(key);
  }
}
