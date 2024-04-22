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
        return PgType.bytea;
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
  final SyncWhere where = i.where ?? SyncWhere.raw('');

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

  final whereClause = where.where;
  return Shape(
    tablename: i.tableName,
    include: includedTables.isEmpty ? null : includedTables,
    where: whereClause == '' ? null : whereClause,
  );
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
