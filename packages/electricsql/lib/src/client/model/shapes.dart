import 'package:electricsql/src/satellite/satellite.dart';
import 'package:electricsql/src/satellite/shapes/types.dart';

typedef TableName = String;

class Shape {
  final List<TableName> tables;

  Shape({required this.tables});
}

abstract class IShapeManager {
  void init(Satellite satellite);
  Future<ShapeSubscription> sync(Shape shape);
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
  Future<ShapeSubscription> sync(Shape shape) async {
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

    final dataReceivedProm = sub.synced.then((_) {
      // When all data is received
      // we store the fact that these tables are synced
      for (final tbl in shape.tables) {
        tablesPreviouslySubscribed.add(tbl);
      }
    });

    return ShapeSubscription(
      synced: dataReceivedProm,
    );
  }

  @override
  bool hasBeenSubscribed(TableName table) {
    return tablesPreviouslySubscribed.contains(table);
  }
}

class ShapeManagerMock extends ShapeManager {
  @override
  Future<ShapeSubscription> sync(Shape shape) async {
    // Do not contact the server but directly store the synced tables
    for (final tbl in shape.tables) {
      tablesPreviouslySubscribed.add(tbl);
    }

    return ShapeSubscription(
      synced: Future.value(),
    );
  }
}

// a shape manager singleton
final shapeManager = ShapeManager();
