// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: always_use_package_imports, depend_on_referenced_packages
// ignore_for_file: prefer_double_quotes, require_trailing_commas

import 'package:electricsql/electricsql.dart';

import './migrations.dart';
import './pg_migrations.dart';

const kElectricMigrations = ElectricMigrations(
  sqliteMigrations: kSqliteMigrations,
  pgMigrations: kPostgresMigrations,
);
const DBSchema kDbSchema = DBSchemaRaw(
  tableSchemas: {
    'table1': TableSchema(
      fields: {
        'col1': PgType.text,
        'col2': PgType.int2,
      },
      relations: [
        Relation(
          fromField: 'fromField1',
          toField: 'toField1',
          relationName: 'relationName1',
          relatedTable: 'relatedTable1',
        )
      ],
    ),
    'table2': TableSchema(
      fields: {'col3': PgType.bool},
      relations: [],
    ),
  },
  migrations: kSqliteMigrations,
  pgMigrations: kPostgresMigrations,
);
