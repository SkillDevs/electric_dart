// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: depend_on_referenced_packages, prefer_double_quotes

import 'package:drift/drift.dart';
import 'package:electricsql/drivers/drift.dart';
import 'package:electricsql/electricsql.dart';

const kElectrifiedTables = [
  Items,
  User,
  Post,
  Profile,
  DataTypes,
  Dummy,
];

class Items extends Table {
  TextColumn get value => text().named('value')();

  IntColumn get nbr => customType(ElectricTypes.int4).named('nbr').nullable()();

  @override
  String? get tableName => 'Items';

  @override
  Set<Column<Object>>? get primaryKey => {value};

  @override
  bool get withoutRowId => true;
}

class User extends Table with ElectricTableMixin {
  IntColumn get id => customType(ElectricTypes.int4).named('id')();

  TextColumn get name => text().named('name').nullable()();

  @override
  String? get tableName => 'User';

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  bool get withoutRowId => true;

  @override
  _$UserRelations get $relations => const _$UserRelations();
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
  bool get withoutRowId => true;

  @override
  _$PostRelations get $relations => const _$PostRelations();
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
  bool get withoutRowId => true;

  @override
  _$ProfileRelations get $relations => const _$ProfileRelations();
}

class DataTypes extends Table with ElectricTableMixin {
  IntColumn get id => customType(ElectricTypes.int4).named('id')();

  Column<DateTime> get date =>
      customType(ElectricTypes.date).named('date').nullable()();

  Column<DateTime> get time =>
      customType(ElectricTypes.time).named('time').nullable()();

  Column<DateTime> get timetz =>
      customType(ElectricTypes.timeTZ).named('timetz').nullable()();

  Column<DateTime> get timestamp =>
      customType(ElectricTypes.timestamp).named('timestamp').nullable()();

  Column<DateTime> get timestamptz =>
      customType(ElectricTypes.timestampTZ).named('timestamptz').nullable()();

  BoolColumn get bool$ => boolean().named('bool').nullable()();

  TextColumn get uuid =>
      customType(ElectricTypes.uuid).named('uuid').nullable()();

  IntColumn get int2 =>
      customType(ElectricTypes.int2).named('int2').nullable()();

  IntColumn get int4 =>
      customType(ElectricTypes.int4).named('int4').nullable()();

  IntColumn get int8 =>
      customType(ElectricTypes.int8).named('int8').nullable()();

  RealColumn get float4 =>
      customType(ElectricTypes.float4).named('float4').nullable()();

  RealColumn get float8 =>
      customType(ElectricTypes.float8).named('float8').nullable()();

  Column<Object> get json =>
      customType(ElectricTypes.jsonb).named('json').nullable()();

  Column<DbColor> get enum$ =>
      customType(ElectricEnumTypes.color).named('enum').nullable()();

  IntColumn get relatedId =>
      customType(ElectricTypes.int4).named('relatedId').nullable()();

  @override
  String? get tableName => 'DataTypes';

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  bool get withoutRowId => true;

  @override
  _$DataTypesRelations get $relations => const _$DataTypesRelations();
}

class Dummy extends Table with ElectricTableMixin {
  IntColumn get id => customType(ElectricTypes.int4).named('id')();

  Column<DateTime> get timestamp =>
      customType(ElectricTypes.timestamp).named('timestamp').nullable()();

  @override
  String? get tableName => 'Dummy';

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  bool get withoutRowId => true;

  @override
  _$DummyRelations get $relations => const _$DummyRelations();
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

class _$UserRelations implements TableRelations {
  const _$UserRelations();

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

class _$PostRelations implements TableRelations {
  const _$PostRelations();

  TableRelation<User> get author => const TableRelation<User>(
        fromField: 'authorId',
        toField: 'id',
        relationName: 'PostToUser',
      );

  @override
  List<TableRelation<Table>> get $relationsList => [author];
}

class _$ProfileRelations implements TableRelations {
  const _$ProfileRelations();

  TableRelation<User> get user => const TableRelation<User>(
        fromField: 'userId',
        toField: 'id',
        relationName: 'ProfileToUser',
      );

  @override
  List<TableRelation<Table>> get $relationsList => [user];
}

class _$DataTypesRelations implements TableRelations {
  const _$DataTypesRelations();

  TableRelation<Dummy> get related => const TableRelation<Dummy>(
        fromField: 'relatedId',
        toField: 'id',
        relationName: 'DataTypesToDummy',
      );

  @override
  List<TableRelation<Table>> get $relationsList => [related];
}

class _$DummyRelations implements TableRelations {
  const _$DummyRelations();

  TableRelation<DataTypes> get datatype => const TableRelation<DataTypes>(
        fromField: '',
        toField: '',
        relationName: 'DataTypesToDummy',
      );

  @override
  List<TableRelation<Table>> get $relationsList => [datatype];
}
