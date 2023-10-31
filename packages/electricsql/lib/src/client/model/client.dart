import 'package:electricsql/electricsql.dart';
import 'package:electricsql/src/client/model/schema.dart';
import 'package:electricsql/src/client/model/shapes.dart';
import 'package:electricsql/src/notifiers/notifiers.dart';
import 'package:electricsql/src/satellite/satellite.dart';
import 'package:meta/meta.dart';

abstract interface class ElectricClient {
  // ElectricNamespace methods
  DatabaseAdapter get adapter;
  Notifier get notifier;
  DBSchema get dbDescription;

  bool get isConnected;

  void setIsConnected(ConnectivityState connectivityState);

  void potentiallyChanged();

  void dispose();

  // ElectricClient methods

  Satellite get satellite;

  Future<ShapeSubscription> syncTables(List<String> tables);
}

class ElectricClientImpl extends ElectricNamespace implements ElectricClient {
  @override
  final Satellite satellite;

  @protected
  final IShapeManager shapeManager;

  @override
  final DBSchema dbDescription;

  factory ElectricClientImpl.create({
    required DatabaseAdapter adapter,
    required DBSchema dbDescription,
    required Notifier notifier,
    required Satellite satellite,
  }) {
    final shapeManager = ShapeManager(satellite);

    return ElectricClientImpl.internal(
      adapter: adapter,
      notifier: notifier,
      satellite: satellite,
      shapeManager: shapeManager,
      dbDescription: dbDescription,
    );
  }

  @protected
  ElectricClientImpl.internal({
    required super.adapter,
    required super.notifier,
    required this.satellite,
    required this.shapeManager,
    required this.dbDescription,
  }) : super();

  @override
  Future<ShapeSubscription> syncTables(List<String> tables) async {
    return shapeManager.sync(Shape(tables: tables));
  }
}
