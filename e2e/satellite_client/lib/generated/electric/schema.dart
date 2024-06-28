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
    'items': TableSchema(
      fields: {
        'id': PgType.text,
        'content': PgType.text,
        'content_text_null': PgType.text,
        'content_text_null_default': PgType.text,
        'intvalue_null': PgType.int4,
        'intvalue_null_default': PgType.int4,
      },
      relations: [
        Relation(
          fromField: '',
          toField: '',
          relationName: 'other_items_item_idToitems',
          relatedTable: 'other_items',
        )
      ],
    ),
    'other_items': TableSchema(
      fields: {
        'id': PgType.text,
        'content': PgType.text,
        'item_id': PgType.text,
      },
      relations: [
        Relation(
          fromField: 'item_id',
          toField: 'id',
          relationName: 'other_items_item_idToitems',
          relatedTable: 'items',
        )
      ],
    ),
    'timestamps': TableSchema(
      fields: {
        'id': PgType.text,
        'created_at': PgType.timestamp,
        'updated_at': PgType.timestampTz,
      },
      relations: [],
    ),
    'datetimes': TableSchema(
      fields: {
        'id': PgType.text,
        'd': PgType.date,
        't': PgType.time,
      },
      relations: [],
    ),
    'bools': TableSchema(
      fields: {
        'id': PgType.text,
        'b': PgType.bool,
      },
      relations: [],
    ),
    'uuids': TableSchema(
      fields: {'id': PgType.uuid},
      relations: [],
    ),
    'ints': TableSchema(
      fields: {
        'id': PgType.text,
        'i2': PgType.int2,
        'i4': PgType.int4,
        'i8': PgType.int8,
      },
      relations: [],
    ),
    'floats': TableSchema(
      fields: {
        'id': PgType.text,
        'f4': PgType.float4,
        'f8': PgType.float8,
      },
      relations: [],
    ),
    'jsons': TableSchema(
      fields: {
        'id': PgType.text,
        'jsb': PgType.jsonb,
      },
      relations: [],
    ),
    'enums': TableSchema(
      fields: {
        'id': PgType.text,
        'c': PgType.text,
      },
      relations: [],
    ),
    'blobs': TableSchema(
      fields: {
        'id': PgType.text,
        'blob': PgType.bytea,
      },
      relations: [],
    ),
  },
  migrations: kSqliteMigrations,
  pgMigrations: kPostgresMigrations,
);
