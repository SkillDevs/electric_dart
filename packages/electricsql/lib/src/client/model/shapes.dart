import 'package:electricsql/src/satellite/satellite.dart';
import 'package:electricsql/src/satellite/shapes/types.dart';

typedef TableName = String;

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
    final sub = await satellite.subscribe([shape]);
    final tables = _getTableNames(shape);

    final dataReceivedProm = sub.synced.then((_) {
      // When all data is received
      // we store the fact that these tables are synced
      for (final tbl in tables) {
        tablesPreviouslySubscribed.add(tbl);
      }
    });

    return ShapeSubscription(
      id: sub.id,
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
    for (final tbl in _getTableNames(shape)) {
      tablesPreviouslySubscribed.add(tbl);
    }

    return ShapeSubscription(
      id: 'unknown',
      synced: Future.value(),
    );
  }
}

List<TableName> _getTableNames(Shape shape) {
  return [
    shape.tablename,
    ...(shape.include ?? []).expand((rel) => _getTableNames(rel.select)),
  ];
}
