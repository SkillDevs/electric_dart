import 'package:drift/drift.dart';
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

  Fields _buildFieldsForTable(TableInfo<dynamic, dynamic> table, GeneratedDatabase genDb) {
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
      case CustomSqlType<Object>():
        if (type is CustomElectricType) {
          return type.pgType;
        } else {
          return null;
        }
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
      case DriftSqlType.blob:
      case DriftSqlType.bigInt:
      case DriftSqlType.any:
        // Unsupported
        return null;
    }
  }

  @override
  Fields getFields(String table) {
    return _fieldsByTable[table]!;
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
}
