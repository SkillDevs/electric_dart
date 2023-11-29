// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: depend_on_referenced_packages, prefer_double_quotes

import 'package:drift/drift.dart';
import 'package:electricsql/drivers/drift.dart';
import 'package:myapp/base_model.dart';

const kElectrifiedTables = [
  Project,
  Membership,
  Datatypes,
  Weirdnames,
  GenOptsDriftTable,
];

class Project extends Table {
  TextColumn get id => text()();

  TextColumn get name => text().nullable()();

  TextColumn get ownerId => text().named('owner_id')();

  @override
  String? get tableName => 'projects';

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  bool get withoutRowId => true;
}

class Membership extends Table {
  TextColumn get projectId => text().named('project_id')();

  TextColumn get userId => text().named('user_id')();

  Column<DateTime> get insertedAt =>
      customType(ElectricTypes.date).named('inserted_at')();

  @override
  String? get tableName => 'memberships';

  @override
  Set<Column<Object>>? get primaryKey => {
        projectId,
        userId,
      };

  @override
  bool get withoutRowId => true;
}

class Datatypes extends Table {
  TextColumn get cUuid => customType(ElectricTypes.uuid).named('c_uuid')();

  TextColumn get cText => text().named('c_text')();

  IntColumn get cInt => customType(ElectricTypes.int4).named('c_int')();

  IntColumn get cInt2 => customType(ElectricTypes.int2).named('c_int2')();

  IntColumn get cInt4 => customType(ElectricTypes.int4).named('c_int4')();

  IntColumn get cInt8 => customType(ElectricTypes.int8).named('c_int8')();

  RealColumn get cFloat8 =>
      customType(ElectricTypes.float8).named('c_float8')();

  BoolColumn get cBool => boolean().named('c_bool')();

  Column<DateTime> get cDate =>
      customType(ElectricTypes.date).named('c_date')();

  Column<DateTime> get cTime =>
      customType(ElectricTypes.time).named('c_time')();

  Column<DateTime> get cTimestamp =>
      customType(ElectricTypes.timestamp).named('c_timestamp')();

  Column<DateTime> get cTimestamptz =>
      customType(ElectricTypes.timestampTZ).named('c_timestamptz')();

  @override
  String? get tableName => 'datatypes';

  @override
  Set<Column<Object>>? get primaryKey => {cUuid};

  @override
  bool get withoutRowId => true;
}

class Weirdnames extends Table {
  TextColumn get cUuid => customType(ElectricTypes.uuid).named('c_uuid')();

  TextColumn get val => text().named('1val')();

  TextColumn get textCol => text().named('text')();

  @override
  String? get tableName => 'weirdnames';

  @override
  Set<Column<Object>>? get primaryKey => {cUuid};

  @override
  bool get withoutRowId => true;
}

@DataClassName(
  'MyDataClassName',
  extending: BaseModel,
)
class GenOptsDriftTable extends Table {
  IntColumn get myIdCol => customType(ElectricTypes.int4).named('id')();

  TextColumn get value => text()();

  Column<DateTime> get timestamp => customType(ElectricTypes.timestampTZ)
      .clientDefault(() => DateTime.now())();

  @override
  String? get tableName => 'GenOpts';

  @override
  bool get withoutRowId => true;
}
