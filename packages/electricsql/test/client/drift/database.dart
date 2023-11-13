import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:electricsql/src/client/conversions/custom_types.dart';

part 'database.g.dart';

class Items extends Table {
  TextColumn get value => text()();
  IntColumn get nbr => integer().nullable()();

  @override
  String? get tableName => 'Items';

  @override
  Set<Column<Object>>? get primaryKey => {value};
}

class Users extends Table {
  IntColumn get id => integer()();
  TextColumn get name => text().nullable()();

  @override
  String? get tableName => 'User';

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Posts extends Table {
  IntColumn get id => integer()();
  TextColumn get title => text().unique()();
  TextColumn get contents => text()();
  IntColumn get nbr => integer().nullable()();
  IntColumn get authorId =>
      integer().named('authorId').references(Users, #id)();

  @override
  String? get tableName => 'Post';

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Profiles extends Table {
  IntColumn get id => integer()();
  TextColumn get bio => text()();
  TextColumn get contents => text()();
  IntColumn get userId =>
      integer().unique().named('userId').references(Users, #id)();

  @override
  String? get tableName => 'Profile';

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Dummy extends Table {
  IntColumn get id => integer()();
  Column<DateTime> get timestamp =>
      customType(ElectricTypes.timestamp).nullable()();

  @override
  String? get tableName => 'Dummy';

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class DataTypes extends Table {
  IntColumn get id => integer()();
  Column<DateTime> get date => customType(ElectricTypes.date).nullable()();
  Column<DateTime> get time => customType(ElectricTypes.time).nullable()();
  Column<DateTime> get timetz => customType(ElectricTypes.timeTZ).nullable()();
  Column<DateTime> get timestamp =>
      customType(ElectricTypes.timestamp).nullable()();
  Column<DateTime> get timestamptz =>
      customType(ElectricTypes.timestampTZ).nullable()();
  BoolColumn get boolCol => boolean().named('bool').nullable()();
  TextColumn get uuid => customType(ElectricTypes.uuid).nullable()();
  IntColumn get int2 => customType(ElectricTypes.int2).nullable()();
  IntColumn get int4 => customType(ElectricTypes.int4).nullable()();
  RealColumn get float8 => customType(ElectricTypes.float8).nullable()();
  Column<Object> get json => customType(ElectricTypes.json).nullable()();

  IntColumn get relatedId =>
      integer().nullable().named('relatedId').references(Dummy, #id)();

  @override
  String? get tableName => 'DataTypes';

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

@DriftDatabase(
  tables: [Items, Users, Posts, Profiles, Dummy, DataTypes],
  include: {'./other_tables.drift'},
)
class TestsDatabase extends _$TestsDatabase {
  TestsDatabase(super.e);

  factory TestsDatabase.memory() {
    return TestsDatabase(
      NativeDatabase.memory(
        setup: (db) {
          db.config.doubleQuotedStringLiterals = false;
        },
        // logStatements: true,
      ),
    );
  }

  @override
  int get schemaVersion => 1;
}
