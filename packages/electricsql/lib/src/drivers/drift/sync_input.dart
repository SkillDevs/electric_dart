import 'package:drift/drift.dart';
import 'package:electricsql/electricsql.dart';
import 'package:electricsql/src/satellite/shapes/types.dart';

typedef SyncIncludeBuilder<T extends Table> = List<SyncInputRelation> Function(
  T table,
);
typedef SyncWhereBuilder<T extends Table> = Expression<bool> Function(T table);

class SyncInput {
  final Expression<bool>? where;
  final List<SyncInputRelation>? include;

  SyncInput({this.where, this.include});
}

class SyncInputRelation<T extends Table> {
  final TableRelation<T> relation;
  final SyncIncludeBuilder<T>? include;
  final SyncWhereBuilder<T>? where;

  static SyncInputRelation from<R extends Table>(
    TableRelation<R> relation, {
    SyncIncludeBuilder<R>? include,
    SyncWhereBuilder<R>? where,
  }) {
    return SyncInputRelation<R>._(
      relation,
      include: include,
      where: where,
    );
  }

  SyncInputRelation._(this.relation, {this.include, this.where});

  SyncIncludeBuilder<Table>? get _genericInclude =>
      include == null ? null : (Table t) => include!.call(t as T);

  SyncWhereBuilder<Table>? get _genericWhere =>
      where == null ? null : (Table t) => where!.call(t as T);
}

Shape computeShapeForDrift<T extends Table>(
  GeneratedDatabase db,
  T table, {
  SyncIncludeBuilder<T>? include,
  SyncWhereBuilder<T>? where,
}) {
  final relationsToInclude = include?.call(table);

  final List<Rel>? rels = relationsToInclude?.map((syncRel) {
    final relation = syncRel.relation;
    final relatedDriftTable = relation.getDriftTable(db);

    final String foreignKey = _getForeignKey(db, relation);

    return Rel(
      foreignKey: [
        foreignKey,
      ],
      select: computeShapeForDrift(
        db,
        relatedDriftTable,
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

String _getForeignKey(GeneratedDatabase db, TableRelation<Table> relation) {
  if (relation.isOutgoingRelation()) {
    return relation.fromField;
  }
  // it's an incoming relation
  // we need to fetch the `fromField` from the outgoing relation
  final oppositeRelation = relation.getOppositeRelation(db);
  return oppositeRelation.fromField;
}

class _PGGenerationContext extends GenerationContext {
  _PGGenerationContext.fromDb(super.executor, {super.supportsVariables})
      : super.fromDb();

  @override
  SqlDialect get dialect => SqlDialect.postgres;
}
