// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: always_use_package_imports, depend_on_referenced_packages
// ignore_for_file: prefer_double_quotes

import 'package:drift/drift.dart';
import 'package:electricsql/drivers/drift.dart';
import 'package:electricsql/electricsql.dart';
import 'package:myapp/base_model.dart';
import 'package:myapp/custom_row_class.dart';

import './migrations.dart';
import './pg_migrations.dart';

const kElectricMigrations = ElectricMigrations(
  sqliteMigrations: kSqliteMigrations,
  pgMigrations: kPostgresMigrations,
);
const kElectrifiedTables = [
  Project,
  Membership,
  Datatypes,
  Weirdnames,
  GenOptsDriftTable,
  TableWithCustomRowClass,
  Enums,
  User,
  Post,
  Profile,
  Message,
];

class Project extends Table with ElectricTableMixin {
  TextColumn get id => text().named('id')();

  TextColumn get name => text().named('name').nullable()();

  TextColumn get ownerId => text().named('owner_id')();

  @override
  String? get tableName => 'projects';

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  $ProjectTableRelations get $relations => const $ProjectTableRelations();
}

class Membership extends Table with ElectricTableMixin {
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
  $MembershipTableRelations get $relations => const $MembershipTableRelations();
}

class Datatypes extends Table {
  TextColumn get cUuid => customType(ElectricTypes.uuid).named('c_uuid')();

  TextColumn get cText => text().named('c_text')();

  IntColumn get cInt => customType(ElectricTypes.int4).named('c_int')();

  IntColumn get cInt2 => customType(ElectricTypes.int2).named('c_int2')();

  IntColumn get cInt4 => customType(ElectricTypes.int4).named('c_int4')();

  IntColumn get cInt8 => customType(ElectricTypes.int8).named('c_int8')();

  RealColumn get cFloat4 =>
      customType(ElectricTypes.float4).named('c_float4')();

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

  Column<Object> get cJson => customType(ElectricTypes.json).named('c_json')();

  Column<Object> get cJsonb =>
      customType(ElectricTypes.jsonb).named('c_jsonb')();

  BlobColumn get cBytea => blob().named('c_bytea')();

  @override
  String? get tableName => 'datatypes';

  @override
  Set<Column<Object>>? get primaryKey => {cUuid};
}

class Weirdnames extends Table {
  TextColumn get cUuid => customType(ElectricTypes.uuid).named('c_uuid')();

  TextColumn get val => text().named('1val')();

  TextColumn get text$ => text().named('text')();

  Column<Object> get braces => customType(ElectricTypes.json).named('braces')();

  Column<DbInteger> get int$ =>
      customType(ElectricEnumTypes.integer).named('int').nullable()();

  @override
  String? get tableName => 'weirdnames';

  @override
  Set<Column<Object>>? get primaryKey => {cUuid};
}

@DataClassName(
  'MyDataClassName',
  extending: BaseModel,
)
class GenOptsDriftTable extends Table {
  @JsonKey('my_id')
  IntColumn get myIdCol => customType(ElectricTypes.int4).named('id')();

  TextColumn get value => text().named('value')();

  Column<DateTime> get timestamp => customType(ElectricTypes.timestampTZ)
      .named('timestamp')
      .clientDefault(() => DateTime.now())();

  @override
  String? get tableName => 'GenOpts';
}

@UseRowClass(
  MyCustomRowClass,
  constructor: 'fromDb',
)
class TableWithCustomRowClass extends Table {
  IntColumn get id => customType(ElectricTypes.int4).named('id')();

  TextColumn get value => text().named('value')();

  RealColumn get d => customType(ElectricTypes.float4).named('d')();

  @override
  String? get tableName => 'TableWithCustomRowClass';
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

class User extends Table with ElectricTableMixin {
  IntColumn get id => customType(ElectricTypes.int4).named('id')();

  TextColumn get name => text().named('name').nullable()();

  @override
  String? get tableName => 'User';

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  $UserTableRelations get $relations => const $UserTableRelations();
}

class Post extends Table with ElectricTableMixin {
  IntColumn get id => customType(ElectricTypes.int4).named('id')();

  TextColumn get title => text().named('title')();

  TextColumn get contents => text().named('contents')();

  IntColumn get nbr => customType(ElectricTypes.int4).named('nbr').nullable()();

  IntColumn get authorId => customType(ElectricTypes.int4).named('authorId')();

  @override
  String? get tableName => 'Post';

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  $PostTableRelations get $relations => const $PostTableRelations();
}

class Profile extends Table with ElectricTableMixin {
  IntColumn get id => customType(ElectricTypes.int4).named('id')();

  TextColumn get bio => text().named('bio')();

  IntColumn get userId => customType(ElectricTypes.int4).named('userId')();

  @override
  String? get tableName => 'Profile';

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  $ProfileTableRelations get $relations => const $ProfileTableRelations();
}

class Message extends Table with ElectricTableMixin {
  TextColumn get id => text().named('id')();

  @override
  String? get tableName => 'message';

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  $MessageTableRelations get $relations => const $MessageTableRelations();
}

// ------------------------------ ENUMS ------------------------------

/// Dart enum for Postgres enum "color"
enum DbColor { red, green, blue }

/// Dart enum for Postgres enum "integer"
enum DbInteger {
  int$,
  bool$,
  double$,
  float,
  someVal,
  value$1,
  value$2,
  value$3,
  rdValue,
  weIRdStuFf
}

/// Dart enum for Postgres enum "snake_case_enum"
enum DbSnakeCaseEnum { v1, v2 }

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
      DbInteger.float: '2Float',
      DbInteger.someVal: '_some_val',
      DbInteger.value$1: '01 value',
      DbInteger.value$2: '2 value',
      DbInteger.value$3: '2Value',
      DbInteger.rdValue: '3rd value',
      DbInteger.weIRdStuFf: 'WeIRd*Stu(ff)',
    },
    values: DbInteger.values,
  );

  /// Codec for Dart enum "snake_case_enum"
  static final snakeCaseEnum = ElectricEnumCodec<DbSnakeCaseEnum>(
    dartEnumToPgEnum: <DbSnakeCaseEnum, String>{
      DbSnakeCaseEnum.v1: 'v1',
      DbSnakeCaseEnum.v2: 'v2',
    },
    values: DbSnakeCaseEnum.values,
  );
}

/// Drift custom types for Electric enums
class ElectricEnumTypes {
  /// Codec for Dart enum "color"
  static final color = CustomElectricTypeEnum(
    codec: ElectricEnumCodecs.color,
    typeName: 'color',
  );

  /// Codec for Dart enum "integer"
  static final integer = CustomElectricTypeEnum(
    codec: ElectricEnumCodecs.integer,
    typeName: 'integer',
  );

  /// Codec for Dart enum "snake_case_enum"
  static final snakeCaseEnum = CustomElectricTypeEnum(
    codec: ElectricEnumCodecs.snakeCaseEnum,
    typeName: 'snake_case_enum',
  );
}

// ------------------------------ RELATIONS ------------------------------

class $ProjectTableRelations implements TableRelations {
  const $ProjectTableRelations();

  TableRelation<Membership> get memberships => const TableRelation<Membership>(
        fromField: '',
        toField: '',
        relationName: 'MembershipToProject',
      );

  @override
  List<TableRelation<Table>> get $relationsList => [memberships];
}

class $MembershipTableRelations implements TableRelations {
  const $MembershipTableRelations();

  TableRelation<Project> get project => const TableRelation<Project>(
        fromField: 'project_id',
        toField: 'id',
        relationName: 'MembershipToProject',
      );

  @override
  List<TableRelation<Table>> get $relationsList => [project];
}

class $UserTableRelations implements TableRelations {
  const $UserTableRelations();

  TableRelation<Post> get posts => const TableRelation<Post>(
        fromField: '',
        toField: '',
        relationName: 'PostToUser',
      );

  TableRelation<Profile> get profile => const TableRelation<Profile>(
        fromField: '',
        toField: '',
        relationName: 'ProfileToUser',
      );

  @override
  List<TableRelation<Table>> get $relationsList => [
        posts,
        profile,
      ];
}

class $PostTableRelations implements TableRelations {
  const $PostTableRelations();

  TableRelation<User> get author => const TableRelation<User>(
        fromField: 'authorId',
        toField: 'id',
        relationName: 'PostToUser',
      );

  @override
  List<TableRelation<Table>> get $relationsList => [author];
}

class $ProfileTableRelations implements TableRelations {
  const $ProfileTableRelations();

  TableRelation<User> get user => const TableRelation<User>(
        fromField: 'userId',
        toField: 'id',
        relationName: 'ProfileToUser',
      );

  @override
  List<TableRelation<Table>> get $relationsList => [user];
}

class $MessageTableRelations implements TableRelations {
  const $MessageTableRelations();

  TableRelation<Message> get message => const TableRelation<Message>(
        fromField: 'parent_id',
        toField: 'id',
        relationName: 'messageTomessage',
      );

  TableRelation<Message> get otherMessage => const TableRelation<Message>(
        fromField: '',
        toField: '',
        relationName: 'messageTomessage',
      );

  @override
  List<TableRelation<Table>> get $relationsList => [
        message,
        otherMessage,
      ];
}
