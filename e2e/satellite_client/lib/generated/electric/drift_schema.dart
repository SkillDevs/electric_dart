// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: always_use_package_imports, depend_on_referenced_packages
// ignore_for_file: prefer_double_quotes, require_trailing_commas

import 'package:drift/drift.dart';
import 'package:electricsql/drivers/drift.dart';
import 'package:electricsql/electricsql.dart';

import './migrations.dart';
import './pg_migrations.dart';

const kElectricMigrations = ElectricMigrations(
  sqliteMigrations: kSqliteMigrations,
  pgMigrations: kPostgresMigrations,
);
const kElectrifiedTables = [
  Blobs,
  Bools,
  Datetimes,
  Enums,
  Floats,
  Ints,
  Items,
  Jsons,
  OtherItems,
  Timestamps,
  Uuids,
];

class Blobs extends Table {
  TextColumn get id => text().named('id')();

  BlobColumn get blob$ => blob().named('blob').nullable()();

  @override
  String? get tableName => 'blobs';

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Bools extends Table {
  TextColumn get id => text().named('id')();

  BoolColumn get b => boolean().named('b').nullable()();

  @override
  String? get tableName => 'bools';

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Datetimes extends Table {
  TextColumn get id => text().named('id')();

  Column<DateTime> get d => customType(ElectricTypes.date).named('d')();

  Column<DateTime> get t => customType(ElectricTypes.time).named('t')();

  @override
  String? get tableName => 'datetimes';

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Enums extends Table {
  TextColumn get id => text().named('id')();

  Column<DbColor> get c =>
      customType(ElectricEnumTypes.color).named('c').nullable()();

  @override
  String? get tableName => 'enums';

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Floats extends Table {
  TextColumn get id => text().named('id')();

  RealColumn get f4 =>
      customType(ElectricTypes.float4).named('f4').nullable()();

  RealColumn get f8 =>
      customType(ElectricTypes.float8).named('f8').nullable()();

  @override
  String? get tableName => 'floats';

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Ints extends Table {
  TextColumn get id => text().named('id')();

  IntColumn get i2 => customType(ElectricTypes.int2).named('i2').nullable()();

  IntColumn get i4 => customType(ElectricTypes.int4).named('i4').nullable()();

  Int64Column get i8 => int64().named('i8').nullable()();

  @override
  String? get tableName => 'ints';

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Items extends Table with ElectricTableMixin {
  TextColumn get id => text().named('id')();

  TextColumn get content => text().named('content')();

  TextColumn get contentTextNull =>
      text().named('content_text_null').nullable()();

  TextColumn get contentTextNullDefault =>
      text().named('content_text_null_default').nullable()();

  IntColumn get intvalueNull =>
      customType(ElectricTypes.int4).named('intvalue_null').nullable()();

  IntColumn get intvalueNullDefault => customType(ElectricTypes.int4)
      .named('intvalue_null_default')
      .nullable()();

  @override
  String? get tableName => 'items';

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  $ItemsTableRelations get $relations => const $ItemsTableRelations();
}

class Jsons extends Table {
  TextColumn get id => text().named('id')();

  Column<Object> get jsb =>
      customType(ElectricTypes.jsonb).named('jsb').nullable()();

  @override
  String? get tableName => 'jsons';

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class OtherItems extends Table with ElectricTableMixin {
  TextColumn get id => text().named('id')();

  TextColumn get content => text().named('content')();

  TextColumn get itemId => text().named('item_id').nullable()();

  @override
  String? get tableName => 'other_items';

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  $OtherItemsTableRelations get $relations => const $OtherItemsTableRelations();
}

class Timestamps extends Table {
  TextColumn get id => text().named('id')();

  Column<DateTime> get createdAt =>
      customType(ElectricTypes.timestamp).named('created_at')();

  Column<DateTime> get updatedAt =>
      customType(ElectricTypes.timestampTZ).named('updated_at')();

  @override
  String? get tableName => 'timestamps';

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Uuids extends Table {
  TextColumn get id => customType(ElectricTypes.uuid).named('id')();

  @override
  String? get tableName => 'uuids';

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

// ------------------------------ ENUMS ------------------------------

/// Dart enum for Postgres enum "Color"
enum DbColor { red, green, blue }

/// Codecs for Electric enums
class ElectricEnumCodecs {
  /// Codec for Dart enum "Color"
  static final color = ElectricEnumCodec<DbColor>(
    dartEnumToPgEnum: <DbColor, String>{
      DbColor.red: 'RED',
      DbColor.green: 'GREEN',
      DbColor.blue: 'BLUE',
    },
    values: DbColor.values,
  );
}

/// Drift custom types for Electric enums
class ElectricEnumTypes {
  /// Codec for Dart enum "Color"
  static final color = CustomElectricTypeEnum(
    codec: ElectricEnumCodecs.color,
    typeName: 'Color',
  );
}

// ------------------------------ RELATIONS ------------------------------

class $ItemsTableRelations implements TableRelations {
  const $ItemsTableRelations();

  TableRelation<OtherItems> get otherItems => const TableRelation<OtherItems>(
        fromField: '',
        toField: '',
        relationName: 'OtherItemsToItems',
      );

  @override
  List<TableRelation<Table>> get $relationsList => [otherItems];
}

class $OtherItemsTableRelations implements TableRelations {
  const $OtherItemsTableRelations();

  TableRelation<Items> get items => const TableRelation<Items>(
        fromField: 'item_id',
        toField: 'id',
        relationName: 'OtherItemsToItems',
      );

  @override
  List<TableRelation<Table>> get $relationsList => [items];
}
