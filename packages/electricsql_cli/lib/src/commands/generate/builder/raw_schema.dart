import 'package:code_builder/code_builder.dart';
import 'package:electricsql/electricsql.dart';
import 'package:electricsql_cli/src/commands/generate/builder/migrations.dart';
import 'package:electricsql_cli/src/commands/generate/builder/util.dart';

Field getRawElectricDBSchemaCodeField(DBSchema dbDescription) {
  /*
final dbDescription = DBSchemaRaw(
      tableSchemas: {
        'table': TableSchema(
          fields: {
            'name1': PgType.text,
            'name2': PgType.text,
          },
          relations: [],
        ),
      },
      migrations: [],
      pgMigrations: [],
    );
  */

  final dbSchemaRawRef = refer('DBSchemaRaw', kElectricSqlImport);
  final tableSchemaRef = refer('TableSchema', kElectricSqlImport);
  final pgTypeRef = refer('PgType', kElectricSqlImport);

  // global const immutable field for the schema
  final dbSchemaField = Field(
    (b) => b
      ..name = 'kDbSchema'
      ..type = refer('DBSchema', kElectricSqlImport)
      ..modifier = FieldModifier.constant
      ..assignment = dbSchemaRawRef.newInstance([], {
        'tableSchemas': literalMap(
          dbDescription.tableSchemas.map((tableName, tableSchema) {
            return MapEntry(
              tableName,
              tableSchemaRef.newInstance([], {
                'fields': literalMap({
                  for (final entry in tableSchema.fields.entries)
                    entry.key: pgTypeRef.property(entry.value.name),
                }),
                'relations': literalList(
                  tableSchema.relations.map((relation) {
                    return refer('Relation', kElectricSqlImport)
                        .newInstance([], {
                      'fromField': literalString(relation.fromField),
                      'toField': literalString(relation.toField),
                      'relationName': literalString(relation.relationName),
                      'relatedTable': literalString(relation.relatedTable),
                    });
                  }),
                ),
              }).code,
            );
          }),
        ),
        'migrations': getSqliteMigrationsRef(),
        'pgMigrations': getPgMigrationsRef(),
      }).code,
  );
  return dbSchemaField;
}
