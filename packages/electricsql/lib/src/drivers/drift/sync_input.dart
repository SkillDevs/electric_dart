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
  final Expression<bool>? whereExpr = where?.call(table);
  final relationsToInclude = include?.call(table);

  final List<Rel>? rels = relationsToInclude?.map((syncRel) {
    final relatedDriftTable = syncRel.relation.getDriftTable(db);

    return Rel(
      foreignKey: [
        // TODO(dart)
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

  return Shape(
    tablename: genTable.actualTableName,
    include: rels,
    // TODO(dart): implement where
    // where: syncInputBuilder?.call(table)?.where,
  );
}
