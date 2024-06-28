import 'package:electricsql/electricsql.dart';
import 'package:electricsql/src/satellite/shapes/types.dart';
import 'package:equatable/equatable.dart';

typedef FieldName = String;
typedef RelationName = String;

typedef Fields = Map<FieldName, PgType>;

class ElectricMigrations {
  final List<Migration> sqliteMigrations;
  final List<Migration> pgMigrations;

  const ElectricMigrations({
    required this.sqliteMigrations,
    required this.pgMigrations,
  });
}

class TableSchema with EquatableMixin {
  final Fields fields;
  final List<Relation> relations;

  const TableSchema({
    required this.fields,
    required this.relations,
  });

  @override
  List<Object?> get props => [fields, relations];
}

abstract class DBSchema {
  final Map<String, TableSchema> tableSchemas;
  final List<Migration> _migrations;
  final List<Migration> _pgMigrations;

  List<Migration> get migrations => _migrations;
  List<Migration> get pgMigrations => _pgMigrations;

  /// @param tables Description of the database tables
  /// @param migrations Bundled SQLite migrations
  /// @param pgMigrations Bundled Postgres migrations
  const DBSchema({
    required this.tableSchemas,
    required List<Migration> migrations,
    required List<Migration> pgMigrations,
  })  : _migrations = migrations,
        _pgMigrations = pgMigrations;

  bool hasTable(String table) {
    return tableSchemas.containsKey(table);
  }

  TableSchema getTableSchema(String table) {
    return tableSchemas[table]!;
  }

  Fields getFields(String table) {
    return getTableSchema(table).fields;
  }

  List<Relation> getRelations(String table) {
    return getTableSchema(table).relations;
  }

  List<Relation> getOutgoingRelations(TableName table) {
    return getRelations(table).where((r) => r.isOutgoingRelation()).toList();
  }

  List<Relation> getIncomingRelations(TableName table) {
    return getRelations(table).where((r) => r.isIncomingRelation()).toList();
  }

  // RelationName getRelationName(TableName table, FieldName field) {
  //   return getRelations(table)
  //       .firstWhere((r) => r.relationField == field)
  //       .relationName;
  // }

  Relation getRelation(String table, RelationName relationName) {
    return getRelations(table)
        .firstWhere((r) => r.relationName == relationName);
  }

  // TableName getRelatedTable(TableName table, FieldName field) {
  //   final relationName = getRelationName(table, field);
  //   final relation = getRelation(table, relationName);
  //   return relation.relatedTable;
  // }

  // FieldName getForeignKey(TableName table, FieldName field) {
  //   final relationName = getRelationName(table, field);
  //   return getForeignKeyFromRelationName(table, relationName);
  // }

  FieldName getForeignKeyFromRelationName(
    TableName table,
    RelationName relationName,
  ) {
    final relation = getRelation(table, relationName);
    if (relation.isOutgoingRelation()) {
      return relation.fromField;
    }
    // it's an incoming relation
    // we need to fetch the `fromField` from the outgoing relation
    final oppositeRelation = relation.getOppositeRelation(this);
    return oppositeRelation.fromField;
  }
}

class DBSchemaRaw extends DBSchema {
  Map<String, Fields> get fields =>
      tableSchemas.map((k, v) => MapEntry(k, v.fields));

  const DBSchemaRaw({
    required super.tableSchemas,
    required super.migrations,
    required super.pgMigrations,
  });
}

// TODO(dart): Equivalent implementation from official electric to add support for other map based
// operators like "in", "lt", "gt"...
// Also update the test "nested shape is constructed" if this is done
// Reference:
// https://github.com/electric-sql/electric/blob/6adfe2e2859ffef994a60c0c193d49a37abcb091/clients/typescript/src/client/model/table.ts#L1655

/// Compile Prisma-like where-clause object into a SQL where clause that the server can understand.
String makeSqlWhereClause(Map<String, Object?> where) {
  // we wrap it in an array and then flatten it
  // in case the user provided an object instead of an array of objects
  final orConnectedObjects = _extractWhereConditionsFor('OR', where);
  final orSqlClause = orConnectedObjects.isEmpty
      ? ''
      : '(${orConnectedObjects.map((o) => '(${makeSqlWhereClause(o)})').join(' OR ')})';
  final notConnector = _extractWhereConditionsFor('NOT', where);

  final notSqlClause = notConnector.isEmpty
      ? ''
      : 'NOT (${notConnector.map((o) => '(${makeSqlWhereClause(o)})').join(' OR ')})';

  final andConnector = _extractWhereConditionsFor('AND', where);

  final andSqlClause = andConnector.map(makeSqlWhereClause).join(' AND ');
  final fieldSqlClause = where.entries
      .where((entry) => !['AND', 'OR', 'NOT'].contains(entry.key))
      .map((entry) {
    final key = entry.key;
    final value = entry.value;
    if (value is String) {
      return "this.$key = '${value.replaceAll("'", "''")}'";
    } else if (value is num || value is BigInt) {
      return 'this.$key = $value';
    } else {
      throw Exception(
        'Current implementation does not support non-string comparisons',
      );
    }
  }).join(' AND ');
  final clauses = [fieldSqlClause, andSqlClause, orSqlClause, notSqlClause];
  return clauses.where((clause) => clause != '').join(' AND ');
}

List<Map<String, Object?>> _extractWhereConditionsFor(
  String key,
  Map<String, Object?> where,
) {
  final List<Map<String, Object?>> conditions = [];

  if (where.containsKey(key)) {
    final raw = where[key];
    if (raw is List<dynamic>) {
      conditions.addAll(raw.cast<Map<String, Object?>>());
    } else if (raw is Map<String, Object?>) {
      conditions.add(raw);
    } else {
      throw Exception(
        'Invalid where clause, expected List or Map for $key section',
      );
    }
  }

  return conditions;
}

class Relation with EquatableMixin {
  // final String relationField;
  final String fromField;
  final String toField;
  final String relationName;
  final String relatedTable;

  const Relation({
    // required this.relationField,
    required this.fromField,
    required this.toField,
    required this.relationName,
    required this.relatedTable,
  });

  bool isIncomingRelation() {
    return fromField == '' && toField == '';
  }

  bool isOutgoingRelation() {
    return !isIncomingRelation();
  }

  Relation getOppositeRelation(DBSchema dbDescription) {
    return dbDescription.getRelation(relatedTable, relationName);
  }

  @override
  List<Object?> get props => [
        // relationField,
        fromField,
        toField,
        relationName,
        relatedTable,
      ];
}
