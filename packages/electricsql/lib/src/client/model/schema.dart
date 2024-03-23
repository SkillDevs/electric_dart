import 'package:drift/drift.dart';
import 'package:electricsql/electricsql.dart';
import 'package:electricsql/src/client/conversions/custom_types.dart';
import 'package:electricsql/src/client/conversions/types.dart';
import 'package:electricsql/src/satellite/shapes/types.dart';
import 'package:meta/meta.dart';

typedef FieldName = String;

typedef Fields = Map<FieldName, PgType>;

mixin ElectricTableMixin on Table {
  TableRelations? get $relations => null;
}

abstract class DBSchema {
  final Map<String, Fields> _fieldsByTable;
  final List<Migration> _migrations;

  List<Migration> get migrations => _migrations;

  DBSchema({
    required Map<String, Fields> fieldsByTable,
    required List<Migration> migrations,
  })  : _fieldsByTable = fieldsByTable,
        _migrations = migrations;

  bool hasTable(String table) {
    return _fieldsByTable.containsKey(table);
  }

  Fields getFields(String table) {
    return _fieldsByTable[table]!;
  }
}

class DBSchemaDrift extends DBSchema {
  final DatabaseConnectionUser db;

  factory DBSchemaDrift({
    required DatabaseConnectionUser db,
    required List<Migration> migrations,
  }) {
    // ignore: invalid_use_of_visible_for_overriding_member
    final driftDb = db.attachedDatabase;

    final _fieldsByTable = {
      for (final table in driftDb.allTables)
        table.actualTableName: _buildFieldsForTable(table, driftDb),
    };

    return DBSchemaDrift._(
      fieldsByTable: _fieldsByTable,
      migrations: migrations,
      db: db,
    );
  }

  DBSchemaDrift._({
    required super.fieldsByTable,
    required super.migrations,
    required this.db,
  });

  static Fields _buildFieldsForTable(
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

  static PgType? _getPgTypeFromGeneratedDriftColumn(
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
}

@visibleForTesting
class DBSchemaRaw extends DBSchema {
  Map<String, Fields> get fields => _fieldsByTable;

  DBSchemaRaw({
    required Map<String, Fields> fields,
    required super.migrations,
  }) : super(fieldsByTable: fields);
}

@protected
Shape computeShape(SyncInputRaw i) {
  final include = i.include ?? [];
  final where = i.where ?? {};

  Rel includeRelToRel(IncludeRelRaw ir) {
    return Rel(
      foreignKey: ir.foreignKey,
      select: computeShape(
        ir.select,
      ),
    );
  }

  // Recursively go over the included fields
  final List<Rel> includedTables =
      include.map((e) => includeRelToRel(e)).toList();

  final whereClause = _makeSqlWhereClause(where);
  return Shape(
    tablename: i.tableName,
    include: includedTables.isEmpty ? null : includedTables,
    where: whereClause == '' ? null : whereClause,
  );
}

String _makeSqlWhereClause(Object where) {
  // TODO(dart): Implement
  return '';
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
