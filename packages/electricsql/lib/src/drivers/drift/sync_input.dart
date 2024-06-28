import 'package:drift/drift.dart';
import 'package:electricsql/drivers/drift.dart';
import 'package:electricsql/src/client/model/schema.dart';
import 'package:electricsql/src/drivers/drift/drift.dart';
import 'package:electricsql/src/satellite/shapes/types.dart';

@Deprecated('Use ShapeIncludeBuilder')
typedef SyncIncludeBuilder<T extends Table> = ShapeIncludeBuilder<T>;

@Deprecated('Use ShapeWhereBuilder')
typedef SyncWhereBuilder<T extends Table> = ShapeWhereBuilder<T>;

@Deprecated('Use ShapeInputRelation')
typedef SyncInputRelation<T extends Table> = ShapeInputRelation<T>;

typedef ShapeIncludeBuilder<T extends Table> = List<ShapeInputRelation>
    Function(
  T table,
);
typedef ShapeWhereBuilder<T extends Table> = Expression<bool> Function(T table);

class ShapeInputRelation<T extends Table> {
  final TableRelation<T> relation;
  final ShapeIncludeBuilder<T>? include;
  final ShapeWhereBuilder<T>? where;

  static ShapeInputRelation from<R extends Table>(
    TableRelation<R> relation, {
    ShapeIncludeBuilder<R>? include,
    ShapeWhereBuilder<R>? where,
  }) {
    return ShapeInputRelation<R>._(
      relation,
      include: include,
      where: where,
    );
  }

  ShapeInputRelation._(this.relation, {this.include, this.where});

  ShapeIncludeBuilder<Table>? get _genericInclude =>
      include == null ? null : (Table t) => include!.call(t as T);

  ShapeWhereBuilder<Table>? get _genericWhere =>
      where == null ? null : (Table t) => where!.call(t as T);
}

Shape computeShapeForDrift<T extends Table>(
  GeneratedDatabase db,
  DBSchema dbDescription,
  T table, {
  ShapeIncludeBuilder<T>? include,
  ShapeWhereBuilder<T>? where,
}) {
  final tableInfo = findDriftTableInfo(db, table);
  final tableName = tableInfo.actualTableName;

  if (!dbDescription.hasTable(tableName)) {
    throw Exception(
      "Cannot sync the requested shape. Table '$tableName' does not exist in the database schema.",
    );
  }

  final relationsToInclude = include?.call(table);

  final List<Rel>? rels = relationsToInclude?.map((syncRel) {
    final relationDrift = syncRel.relation;

    final String foreignKey = dbDescription.getForeignKeyFromRelationName(
      tableName,
      relationDrift.relationName,
    );

    return Rel(
      foreignKey: [
        foreignKey,
      ],
      select: computeShapeForDrift(
        db,
        dbDescription,
        relationDrift.getDriftTable(db),
        include: syncRel._genericInclude,
        where: syncRel._genericWhere,
      ),
    );
  }).toList();

  final TableInfo<Table, dynamic> genTable = db.allTables.firstWhere((t) {
    return table == t.asDslTable;
  });

  // print("t $table   $genTable  T $T");

  String? whereStr;
  if (where != null) {
    final Expression<bool> whereExpr =
        // The alias "this" is needed, because it's expected by the Electric service
        where.call(genTable.createAlias('this') as T);

    final generationContext = _PGGenerationContext.fromDb(
      db,
      supportsVariables: false,
    );
    generationContext.hasMultipleTables = true;

    whereExpr.writeInto(generationContext);
    whereStr = generationContext.sql;
  }

  return Shape(
    tablename: genTable.actualTableName,
    where: whereStr,
    include: rels,
  );
}

class _PGGenerationContext extends GenerationContext {
  _PGGenerationContext.fromDb(super.executor, {super.supportsVariables})
      : super.fromDb();

  @override
  SqlDialect get dialect => SqlDialect.postgres;
}
