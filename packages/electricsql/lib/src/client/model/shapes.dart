import 'package:electricsql/src/satellite/satellite.dart';
import 'package:electricsql/src/satellite/shapes/types.dart';

typedef TableName = String;

class Shape {
  final List<TableName> tables;

  Shape({required this.tables});
}

abstract interface class IShapeManager {
  Future<ShapeSubscription> sync(Shape shape);
  bool hasBeenSubscribed(TableName table);
}

abstract class BaseShapeManager implements IShapeManager {
  final Set<TableName> tablesPreviouslySubscribed = {};

  @override
  bool hasBeenSubscribed(TableName table) {
    return tablesPreviouslySubscribed.contains(table);
  }
}

class ShapeManager extends BaseShapeManager {
  final Satellite satellite;

  ShapeManager(this.satellite);

  @override
  Future<ShapeSubscription> sync(Shape shape) async {
    // Convert the shape to the format expected by the Satellite process
    final shapeDef = ClientShapeDefinition(
      selects: shape.tables.map((tbl) {
        return ShapeSelect(
          tablename: tbl,
        );
      }).toList(),
    );

    final sub = await satellite.subscribe([shapeDef]);

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

class ShapeManagerMock extends BaseShapeManager {
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
