import 'package:electricsql/src/client/model/schema.dart';

@Deprecated('Use ShapeInputRaw')
typedef SyncInputRaw = ShapeInputRaw;

@Deprecated('Use ShapeWhere')
typedef SyncWhere = ShapeWhere;

class ShapeInputRaw {
  final String tableName;
  final List<IncludeRelRaw>? include;
  final ShapeWhere? where;

  /// Unique key for a shape subscription, allowing shape modification and unsubscribe
  final String? key;

  ShapeInputRaw({
    required this.tableName,
    this.include,
    this.where,
    this.key,
  });
}

class IncludeRelRaw {
  final List<String> foreignKey;
  final ShapeInputRaw select;

  IncludeRelRaw({
    required this.foreignKey,
    required this.select,
  });
}

class ShapeWhere {
  final String where;

  ShapeWhere(Map<String, Object> map) : where = makeSqlWhereClause(map);

  ShapeWhere.raw(this.where);
}
