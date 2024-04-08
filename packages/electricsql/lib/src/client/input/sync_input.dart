import 'package:electricsql/src/client/model/schema.dart';

class SyncInputRaw {
  final String tableName;
  final List<IncludeRelRaw>? include;
  final SyncWhere? where;

  SyncInputRaw({required this.tableName, this.include, this.where});
}

class IncludeRelRaw {
  final List<String> foreignKey;
  final SyncInputRaw select;

  IncludeRelRaw({
    required this.foreignKey,
    required this.select,
  });
}

class SyncWhere {
  final String where;

  SyncWhere(Map<String, Object> map) : where = makeSqlWhereClause(map);

  SyncWhere.raw(this.where);
}
