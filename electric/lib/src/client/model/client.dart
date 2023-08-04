import 'package:electric_client/src/client/model/shapes.dart';
import 'package:electric_client/src/electric/namespace.dart';
import 'package:electric_client/src/satellite/satellite.dart';

class ElectricClient extends ElectricNamespace {
  ElectricClient({required super.adapter, required super.notifier}) : super();

  Future<ShapeSubscription> syncTables(List<String> tables) async {
    return await shapeManager.sync(Shape(tables: tables));
  }
}
