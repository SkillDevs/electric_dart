import 'package:electric_client/src/satellite/process.dart';
import 'package:electric_client/src/satellite/satellite.dart';
import 'package:electric_client/src/satellite/shapes/types.dart';

typedef TableName = String;

class Shape {
  final List<TableName> tables;

  Shape({required this.tables});
}

abstract class IShapeManager {
  void init(Satellite satellite);
  Future<Sub> sync(Shape shape);
  bool hasBeenSubscribed(TableName shape);
}

class ShapeManager implements IShapeManager {
  final Set<TableName> tablesPreviouslySubscribed = {};
  Satellite? satellite;

  @override
  void init(Satellite satellite) {
    this.satellite = satellite;
  }

  @override
  Future<Sub> sync(Shape shape) async {
    final _satellite = satellite;
    if (_satellite == null) {
      throw Exception(
        'Shape cannot be synced because the `ShapeManager` is not yet initialised.',
      );
    }

    // Convert the shape to the format expected by the Satellite process
    final shapeDef = ClientShapeDefinition(
      selects: shape.tables.map((tbl) {
        return ShapeSelect(
          tablename: tbl,
        );
      }).toList(),
    );

    final sub = await _satellite.subscribe([shapeDef]);

    final dataReceivedProm = sub.dataReceived.then((_) {
      // When all data is received
      // we store the fact that these tables are synced
      shape.tables.forEach((tbl) => tablesPreviouslySubscribed.add(tbl));
    });

    return Sub(
      dataReceived: dataReceivedProm,
    );
  }

  @override
  bool hasBeenSubscribed(TableName table) {
    return tablesPreviouslySubscribed.contains(table);
  }
}

class ShapeManagerMock extends ShapeManager {
  @override
  Future<Sub> sync(Shape shape) async {
    // Do not contact the server but directly store the synced tables
    shape.tables.forEach((tbl) => tablesPreviouslySubscribed.add(tbl));

    return Sub(
      dataReceived: Future.value(),
    );
  }
}

// a shape manager singleton
final shapeManager = ShapeManager();
