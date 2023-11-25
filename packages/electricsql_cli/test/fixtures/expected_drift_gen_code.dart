// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: depend_on_referenced_packages, prefer_double_quotes

import 'package:drift/drift.dart';
import 'package:electricsql/drivers/drift.dart';
import 'package:electricsql/electricsql.dart';
import 'package:myapp/base_model.dart';

const kElectrifiedTables = [
  Project,
  Membership,
  Datatypes,
  Weirdnames,
  GenOptsDriftTable,
  Enums,
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

  Column<DbInteger> get intCol =>
      customType(ElectricEnumTypes.integer).named('int').nullable()();

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

class Enums extends Table {
  TextColumn get id => text()();

  Column<DbColor> get c => customType(ElectricEnumTypes.color).nullable()();

  @override
  String? get tableName => 'enums';

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  bool get withoutRowId => true;
}

// ------------------------------ ENUMS ------------------------------

/// Dart enum for Postgres enum "color"
enum DbColor { red, green, blue }

/// Dart enum for Postgres enum "integer"
enum DbInteger { int$, bool$, double$, $2Float }

/// Codecs for Electric enums
class ElectricEnumCodecs {
  /// Codec for Dart enum "color"
  static final color = ElectricEnumCodec<DbColor>(
    dartEnumToPgEnum: <DbColor, String>{
      DbColor.red: 'RED',
      DbColor.green: 'GREEN',
      DbColor.blue: 'BLUE',
    },
    values: DbColor.values,
  );

  /// Codec for Dart enum "integer"
  static final integer = ElectricEnumCodec<DbInteger>(
    dartEnumToPgEnum: <DbInteger, String>{
      DbInteger.int$: 'int',
      DbInteger.bool$: 'Bool',
      DbInteger.double$: 'DOUBLE',
      DbInteger.$2Float: '2Float',
    },
    values: DbInteger.values,
  );
}

/// Drift custom types for Electric enums
class ElectricEnumTypes {
  /// Codec for Dart enum "color"
  static final color = CustomElectricTypeGeneric(
    codec: ElectricEnumCodecs.color,
    typeName: 'color',
  );

  /// Codec for Dart enum "integer"
  static final integer = CustomElectricTypeGeneric(
    codec: ElectricEnumCodecs.integer,
    typeName: 'integer',
  );
}
