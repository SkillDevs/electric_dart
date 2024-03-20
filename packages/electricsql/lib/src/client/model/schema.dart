import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:electricsql/electricsql.dart';
import 'package:electricsql/satellite.dart';
import 'package:electricsql/src/client/conversions/custom_types.dart';
import 'package:electricsql/src/client/conversions/types.dart';
import 'package:electricsql/src/migrators/index.dart';
import 'package:meta/meta.dart';

typedef FieldName = String;

typedef Fields = Map<FieldName, PgType>;

abstract interface class DBSchema {
  List<Migration> get migrations;

  bool hasTable(String table);

  Fields getFields(String table);

  FieldName getForeignKey(String table, FieldName field);
}

class DBSchemaDrift implements DBSchema {
  @override
  final List<Migration> migrations;

  final DatabaseConnectionUser db;

  late final Map<String, Fields> _fieldsByTable;

  @override
  bool hasTable(String tableName) {
    // ignore: invalid_use_of_visible_for_overriding_member
    final driftDb = db.attachedDatabase;
    return driftDb.allTables.any((t) => t.actualTableName == tableName);
  }

  DBSchemaDrift({
    required this.db,
    required this.migrations,
  }) {
    // ignore: invalid_use_of_visible_for_overriding_member
    final driftDb = db.attachedDatabase;

    _fieldsByTable = {
      for (final table in driftDb.allTables)
        table.actualTableName: _buildFieldsForTable(table, driftDb),
    };
  }

  Fields _buildFieldsForTable(
    TableInfo<dynamic, dynamic> table,
    GeneratedDatabase genDb,
  ) {
    final Map<FieldName, PgType> fields = {};

    for (final column in table.$columns) {
      final pgType = _getPgTypeFromGeneratedDriftColumn(genDb, column);
      if (pgType != null) {
        fields[column.name] = pgType;
      }
    }
    return fields;
  }

  PgType? _getPgTypeFromGeneratedDriftColumn(
    GeneratedDatabase genDb,
    GeneratedColumn<Object> c,
  ) {
    //print("Column: ${c.name}  ${c.type}   ${c.driftSqlType}");
    final type = c.type;
    switch (type) {
      case CustomElectricType():
        return type.pgType;
      case CustomSqlType<Object>():
        return null;
      case DriftSqlType.bool:
        return PgType.bool;
      case DriftSqlType.string:
        return PgType.text;
      case DriftSqlType.int:
        return PgType.integer;
      case DriftSqlType.dateTime:
        return genDb.typeMapping.storeDateTimesAsText
            ? PgType.text
            : PgType.integer;
      case DriftSqlType.double:
        return PgType.real;
      case DriftSqlType.bigInt:
        return PgType.int8;
      case DriftSqlType.blob:
      case DriftSqlType.any:
        // Unsupported
        return null;
      default:
        return null;
    }
  }

  @override
  Fields getFields(String table) {
    return _fieldsByTable[table]!;
  }

  @override
  FieldName getForeignKey(String table, FieldName field) {
    // TODO(dart): Implement
    // const relationName = this.getRelationName(table, field)
    // const relation = this.getRelation(table, relationName)
    // if (relation.isOutgoingRelation()) {
    //   return relation.fromField
    // }
    // // it's an incoming relation
    // // we need to fetch the `fromField` from the outgoing relation
    // const oppositeRelation = relation.getOppositeRelation(this)
    // return oppositeRelation.fromField
    throw UnimplementedError();
  }
}

@visibleForTesting
class DBSchemaRaw implements DBSchema {
  @override
  final List<Migration> migrations;
  final Map<String, Fields> fields;

  DBSchemaRaw({
    required this.fields,
    required this.migrations,
  });

  @override
  Fields getFields(String table) {
    return fields[table]!;
  }

  @override
  bool hasTable(String table) {
    return fields.containsKey(table);
  }

  @override
  FieldName getForeignKey(String table, FieldName field) {
    // TODO(dart): implement getForeignKey
    throw UnimplementedError();
  }
}

  // TODO(dart): Implement
/* Shape computeShape(DBSchema schema, String tableName, SyncInput i) {
  // Recursively go over the included fields
  final include = i.include ?? {};
  final where = i.where ?? {};
  final includedFields = include.keys.toList();
  final includedTables = includedFields.map((String field) {
    // Fetch the table that is included
    final relatedTableName = schema.getRelatedTable(
      tableName,
      field,
    );
    final fkk = schema.getForeignKey(tableName, field);
    // final relatedTable = this._tables.get(relatedTableName)!

    // And follow nested includes
    final includedObj = include[field];
    if ((includedObj is Map<String, Object?>? || includedObj is SyncInput?) &&
        includedObj != null) {
      // There is a nested include, follow it
      final SyncInput recursiveInput;
      if (includedObj is SyncInput) {
        recursiveInput = includedObj;
      } else if (includedObj is Map<String, Object?>) {
        recursiveInput = SyncInput(
          include: includedObj['include'] as Map<String, Object?>?,
          where: includedObj['where'] as Map<String, Object?>?,
        );
      } else {
        throw StateError('Unexpected type');
      }
          
      return Rel(
        foreignKey: [fkk],
        select: computeShape(
          schema,
          relatedTableName,
          recursiveInput,
        ),
      );
    } else if (includedObj == true) {
      return Rel(
        foreignKey: [fkk],
        select: Shape(
          tablename: relatedTableName,
        ),
      );
    } else {
      throw Exception(
        'Unexpected value in include tree for sync: ${json.encode(includedObj)}',
      );
    }
  }).toList();

  final whereClause = _makeSqlWhereClause(where);
  return Shape(
    tablename: tableName,
    include: includedTables,
    where: whereClause == '' ? null : whereClause,
  );
}
 */
String _makeSqlWhereClause(Object where) {
  // TODO(dart): Implement
  throw UnimplementedError();
  // we wrap it in an array and then flatten it
  // in case the user provided an object instead of an array of objects
  /*  const orConnectedObjects = [
    (where as { OR?: object | object[] })['OR'] ?? [],
  ].flat()
  const orSqlClause =
    orConnectedObjects.length === 0
      ? ''
      : '(' +
        orConnectedObjects
          .map((o) => `(${makeSqlWhereClause(o)})`)
          .join(' OR ') +
        ')'
  const notConnector = [
    (where as { NOT?: object | object[] })['NOT'] ?? [],
  ].flat()
  const notSqlClause =
    notConnector.length === 0
      ? ''
      : 'NOT (' +
        notConnector.map((o) => `(${makeSqlWhereClause(o)})`).join(' OR ') +
        ')'
  const andConnector = [
    (where as { AND?: object | object[] })['AND'] ?? [],
  ].flat()
  const andSqlClause = andConnector.map(makeSqlWhereClause).join(' AND ')
  const fieldSqlClause = Object.entries(where)
    .filter(([key, _]) => !['AND', 'OR', 'NOT'].includes(key))
    .map(([key, value]) => {
      if (typeof value === 'string') {
        return `this.${key} = '${value.replace("'", "''")}'`
      } else if (typeof value === 'number' || typeof value === 'bigint') {
        return `this.${key} = ${value}`
      } else {
        throw new Error(
          'Current implementation does not support non-string comparisons'
        )
      }
    })
    .join(' AND ')
  const clauses = [fieldSqlClause, andSqlClause, orSqlClause, notSqlClause]
  return clauses.filter((clause) => clause !== '').join(' AND ') */
}
