import 'package:electricsql/electricsql.dart';
import 'package:electricsql/src/client/model/schema.dart';
import 'package:electricsql/src/client/model/shapes.dart';
import 'package:electricsql/src/client/model/transform.dart';
import 'package:electricsql/src/migrators/query_builder/query_builder.dart';
import 'package:electricsql/src/notifiers/notifiers.dart';
import 'package:electricsql/src/satellite/satellite.dart';
import 'package:electricsql/src/satellite/shapes/types.dart';
import 'package:meta/meta.dart';

abstract interface class BaseElectricClient {
  // ElectricNamespace methods
  String get dbName;
  DatabaseAdapter get adapter;
  Notifier get notifier;
  DBSchema get dbDescription;
  Registry get registry;

  bool get isConnected;

  void setIsConnected(ConnectivityState connectivityState);

  void potentiallyChanged();

  Future<void> close();

  // ElectricClient methods
  Satellite get satellite;
  Future<void> connect([String? token]);
  void disconnect();
}

abstract interface class ElectricClientRaw implements BaseElectricClient {
  Future<ShapeSubscription> sync(SyncInputRaw sync);

  @protected
  Future<ShapeSubscription> syncShapeInternal(Shape shape);
}

class ElectricClientImpl extends ElectricNamespace
    implements ElectricClientRaw {
  @override
  final Satellite satellite;

  @protected
  late final IShapeManager shapeManager;

  @protected
  late final IReplicationTransformManager replicationTransformManager;

  @override
  final DBSchema dbDescription;

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
    satellite.disconnect(null);
  }

  factory ElectricClientImpl.create({
    required String dbName,
    required DatabaseAdapter adapter,
    required DBSchema dbDescription,
    required Notifier notifier,
    required Satellite satellite,
    required Registry registry,
    required Dialect dialect,
  }) {
    return ElectricClientImpl.internal(
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
  ElectricClientImpl.internal({
    required super.dbName,
    required super.adapter,
    required super.notifier,
    required super.registry,
    required this.satellite,
    required this.dbDescription,
    required this.dialect,
  }) : super() {
    shapeManager = ShapeManager(satellite);
    replicationTransformManager = ReplicationTransformManager(satellite);
  }

  @override
  Future<ShapeSubscription> sync(SyncInputRaw syncInput) async {
    final shape = computeShape(syncInput);
    return syncShapeInternal(shape);
  }

  @override
  Future<ShapeSubscription> syncShapeInternal(Shape shape) {
    return shapeManager.sync(shape);
  }
}
