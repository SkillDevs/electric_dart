import 'package:electricsql/electricsql.dart';
import 'package:electricsql/satellite.dart';

Future<ShapeSubscription> syncShape(
  IShapeManager shapeManager,
  DBSchema dbDescription,
  ShapeInputRaw i, [
  String? key,
]) async {
  // Check which table the user wants to sync
  final tableName = i.tableName;

  if (tableName.isEmpty) {
    throw Exception(
      'Cannot sync the requested shape. Table name must be a non-empty string',
    );
  }

  final shape = computeShape(dbDescription, i);
  return shapeManager.subscribe([shape], key);
}

Shape computeShape(DBSchema dbSchema, ShapeInputRaw i) {
  if (!dbSchema.hasTable(i.tableName)) {
    throw Exception(
      "Cannot sync the requested shape. Table '${i.tableName}' does not exist in the database schema.",
    );
  }

  final include = i.include ?? [];
  final ShapeWhere where = i.where ?? ShapeWhere.raw('');

  // Recursively go over the included fields
  final List<Rel> includedTables =
      include.map((e) => _createShapeRelation(dbSchema, e)).toList();

  final whereClause = where.where;
  return Shape(
    tablename: i.tableName,
    include: includedTables.isEmpty ? null : includedTables,
    where: whereClause == '' ? null : whereClause,
  );
}

Rel _createShapeRelation(DBSchema dbSchema, IncludeRelRaw ir) {
  return Rel(
    foreignKey: ir.foreignKey,
    select: computeShape(
      dbSchema,
      ir.select,
    ),
  );
}
