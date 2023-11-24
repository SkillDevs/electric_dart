// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: depend_on_referenced_packages, prefer_double_quotes

import 'package:drift/drift.dart';
import 'package:electricsql/drivers/drift.dart';

const kElectrifiedTables = [
  Items,
  OtherItems,
  Timestamps,
  Datetimes,
  Bools,
  Uuids,
  Ints,
  Floats,
  Enums,
];

class Items extends Table {
  TextColumn get id => text()();

  TextColumn get content => text()();

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
  Set<Column<Object>>? get primaryKey => {id};

  @override
  bool get withoutRowId => true;
}

class OtherItems extends Table {
  TextColumn get id => text()();

  TextColumn get content => text()();

  TextColumn get itemId => text().named('item_id').nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  bool get withoutRowId => true;
}

class Timestamps extends Table {
  TextColumn get id => text()();

  Column<DateTime> get createdAt =>
      customType(ElectricTypes.timestamp).named('created_at')();

  Column<DateTime> get updatedAt =>
      customType(ElectricTypes.timestampTZ).named('updated_at')();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  bool get withoutRowId => true;
}

class Datetimes extends Table {
  TextColumn get id => text()();

  Column<DateTime> get d => customType(ElectricTypes.date)();

  Column<DateTime> get t => customType(ElectricTypes.time)();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  bool get withoutRowId => true;
}

class Bools extends Table {
  TextColumn get id => text()();

  BoolColumn get b => boolean().nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  bool get withoutRowId => true;
}

class Uuids extends Table {
  TextColumn get id => customType(ElectricTypes.uuid)();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  bool get withoutRowId => true;
}

class Ints extends Table {
  TextColumn get id => text()();

  IntColumn get i2 => customType(ElectricTypes.int2).nullable()();

  IntColumn get i4 => customType(ElectricTypes.int4).nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  bool get withoutRowId => true;
}

class Floats extends Table {
  TextColumn get id => text()();

  RealColumn get f8 => customType(ElectricTypes.float8).nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  bool get withoutRowId => true;
}

class Enums extends Table {
  TextColumn get id => text()();

  TextColumn get c => text().nullable()();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  bool get withoutRowId => true;
}
