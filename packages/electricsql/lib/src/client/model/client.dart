import 'package:electricsql/electricsql.dart';
import 'package:electricsql/src/client/model/shapes.dart';
import 'package:electricsql/src/electric/namespace.dart';
import 'package:electricsql/src/notifiers/notifiers.dart';
import 'package:electricsql/src/satellite/satellite.dart';

class ElectricClient extends ElectricNamespace {
  final Satellite satellite;
  final IShapeManager shapeManager;

  factory ElectricClient.create({
    required DatabaseAdapter adapter,
    required Notifier notifier,
    required Satellite satellite,
  }) {
    final shapeManager = ShapeManager(satellite);

    return ElectricClient._(
      adapter: adapter,
      notifier: notifier,
      satellite: satellite,
      shapeManager: shapeManager,
    );
  }

  ElectricClient._({
    required super.adapter,
    required super.notifier,
    required this.satellite,
    required this.shapeManager,
  }) : super();

  Future<ShapeSubscription> syncTables(List<String> tables) async {
    return shapeManager.sync(Shape(tables: tables));
  }
}
