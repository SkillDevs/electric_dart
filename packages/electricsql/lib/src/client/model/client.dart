import 'package:electricsql/electricsql.dart';
import 'package:electricsql/src/client/model/schema.dart';
import 'package:electricsql/src/client/model/shapes.dart';
import 'package:electricsql/src/notifiers/notifiers.dart';
import 'package:electricsql/src/satellite/satellite.dart';
import 'package:meta/meta.dart';

abstract interface class ElectricClient {
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
  void disconnect();

  // ElectricClient methods

  Satellite get satellite;

  Future<void> connect([String? token]);
  Future<ShapeSubscription> syncTables(List<String> tables);
}

class ElectricClientImpl extends ElectricNamespace implements ElectricClient {
  @override
  final Satellite satellite;

  @protected
  final IShapeManager shapeManager;

  @override
  final DBSchema dbDescription;

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
  }) {
    final shapeManager = ShapeManager(satellite);

    return ElectricClientImpl.internal(
      dbName: dbName,
      adapter: adapter,
      notifier: notifier,
      satellite: satellite,
      shapeManager: shapeManager,
      dbDescription: dbDescription,
      registry: registry,
    );
  }

  @protected
  ElectricClientImpl.internal({
    required super.dbName,
    required super.adapter,
    required super.notifier,
    required super.registry,
    required this.satellite,
    required this.shapeManager,
    required this.dbDescription,
  }) : super();

  @override
  Future<ShapeSubscription> syncTables(List<String> tables) async {
    return shapeManager.sync(Shape(tables: tables));
  }
}
