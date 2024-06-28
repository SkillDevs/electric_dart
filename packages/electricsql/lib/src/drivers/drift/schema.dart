import 'package:drift/drift.dart';
import 'package:electricsql/drivers/drift.dart';
import 'package:electricsql/electricsql.dart';
import 'package:electricsql/src/client/model/schema.dart';
import 'package:electricsql/src/drivers/drift/relation.dart';

mixin ElectricTableMixin on Table {
  TableRelations? get $relations => null;
}

class DBSchemaDrift extends DBSchema {
  final GeneratedDatabase db;

  factory DBSchemaDrift({
    required GeneratedDatabase db,
    required List<Migration> migrations,
    required List<Migration> pgMigrations,
  }) {
    // ignore: invalid_use_of_visible_for_overriding_member
    final driftDb = db.attachedDatabase;

    final _tableSchemas = {
      for (final table in driftDb.allTables)
        table.actualTableName: TableSchema(
          fields: _buildFieldsForTable(table, driftDb),
          relations: getTableRelations(table)
                  ?.$relationsList
                  .map(
                    (TableRelation tr) => Relation(
                      fromField: tr.fromField,
                      toField: tr.toField,
                      relationName: tr.relationName,
                      // relationField: "",
                      relatedTable: tr.getDriftTable(db).actualTableName,
                    ),
                  )
                  .toList() ??
              [],
        ),
    };

    return DBSchemaDrift._(
      tableSchemas: _tableSchemas,
      migrations: migrations,
      pgMigrations: pgMigrations,
      db: db,
    );
  }

  DBSchemaDrift._({
    required super.tableSchemas,
    required super.migrations,
    required super.pgMigrations,
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
