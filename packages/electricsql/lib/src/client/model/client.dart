import 'package:electricsql/src/client/model/shapes.dart';
import 'package:electricsql/src/electric/namespace.dart';
import 'package:electricsql/src/satellite/satellite.dart';

class ElectricClient extends ElectricNamespace {
  ElectricClient({required super.adapter, required super.notifier}) : super();

  Future<ShapeSubscription> syncTables(List<String> tables) async {
    return shapeManager.sync(Shape(tables: tables));
  }
}
