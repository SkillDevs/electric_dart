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
  ProfileImage,
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

  TextColumn get meta => text().named('meta').nullable()();

  @override
  String? get tableName => 'User';

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  bool get withoutRowId => true;

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
  bool get withoutRowId => true;

  @override
  $PostTableRelations get $relations => const $PostTableRelations();
}

class Profile extends Table with ElectricTableMixin {
  IntColumn get id => customType(ElectricTypes.int4).named('id')();

  TextColumn get bio => text().named('bio')();

  Column<Object> get meta =>
      customType(ElectricTypes.jsonb).named('meta').nullable()();

  IntColumn get userId => customType(ElectricTypes.int4).named('userId')();

  TextColumn get imageId => text().named('imageId').nullable()();

  @override
  String? get tableName => 'Profile';

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  bool get withoutRowId => true;

  @override
  $ProfileTableRelations get $relations => const $ProfileTableRelations();
}

class ProfileImage extends Table with ElectricTableMixin {
  TextColumn get id => text().named('id')();

  BlobColumn get image => blob().named('image')();

  @override
  String? get tableName => 'ProfileImage';

  @override
  Set<Column<Object>>? get primaryKey => {id};

  @override
  bool get withoutRowId => true;

  @override
  $ProfileImageTableRelations get $relations =>
      const $ProfileImageTableRelations();
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

  BlobColumn get bytea => blob().named('bytea').nullable()();

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
  $DataTypesTableRelations get $relations => const $DataTypesTableRelations();
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
  $DummyTableRelations get $relations => const $DummyTableRelations();
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

  TableRelation<ProfileImage> get image => const TableRelation<ProfileImage>(
        fromField: 'imageId',
        toField: 'id',
        relationName: 'ProfileToProfileImage',
      );

  @override
  List<TableRelation<Table>> get $relationsList => [
        user,
        image,
      ];
}

class $ProfileImageTableRelations implements TableRelations {
  const $ProfileImageTableRelations();

  TableRelation<Profile> get profile => const TableRelation<Profile>(
        fromField: '',
        toField: '',
        relationName: 'ProfileToProfileImage',
      );

  @override
  List<TableRelation<Table>> get $relationsList => [profile];
}

class $DataTypesTableRelations implements TableRelations {
  const $DataTypesTableRelations();

  TableRelation<Dummy> get related => const TableRelation<Dummy>(
        fromField: 'relatedId',
        toField: 'id',
        relationName: 'DataTypesToDummy',
      );

  @override
  List<TableRelation<Table>> get $relationsList => [related];
}

class $DummyTableRelations implements TableRelations {
  const $DummyTableRelations();

  TableRelation<DataTypes> get datatype => const TableRelation<DataTypes>(
        fromField: '',
        toField: '',
        relationName: 'DataTypesToDummy',
      );

  @override
  List<TableRelation<Table>> get $relationsList => [datatype];
}
