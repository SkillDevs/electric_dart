import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:electricsql/src/drivers/drift/converters.dart';

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
  TextColumn get timestamp =>
      text().map(const ElectricTimestampConverter()).nullable()();

  @override
  String? get tableName => 'Dummy';

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class DataTypes extends Table {
  IntColumn get id => integer()();
  TextColumn get date => text().map(const ElectricDateConverter()).nullable()();
  TextColumn get time => text().map(const ElectricTimeConverter()).nullable()();
  TextColumn get timetz =>
      text().map(const ElectricTimeTZConverter()).nullable()();
  TextColumn get timestamp =>
      text().map(const ElectricTimestampConverter()).nullable()();
  TextColumn get timestamptz =>
      text().map(const ElectricTimestampTZConverter()).nullable()();
  BoolColumn get boolCol => boolean().named('bool').nullable()();
  TextColumn get uuid => text().map(const ElectricUUIDConverter()).nullable()();
  IntColumn get int2 =>
      integer().map(const ElectricInt2Converter()).nullable()();
  IntColumn get int4 =>
      integer().map(const ElectricInt4Converter()).nullable()();
  // int2        Int?      @db.SmallInt /// @zod.number.int().gte(-32768).lte(32767)
  // int4        Int?                   /// @zod.number.int().gte(-2147483648).lte(2147483647)
  // float8      Float?    @db.DoublePrecision /// @zod.custom.use(z.number().or(z.nan()))
  IntColumn get relatedId =>
      integer().nullable().named('relatedId').references(Dummy, #id)();

  @override
  String? get tableName => 'DataTypes';

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

@DriftDatabase(tables: [Items, Users, Posts, Profiles, Dummy, DataTypes])
class TestsDatabase extends _$TestsDatabase {
  TestsDatabase(super.e);

  factory TestsDatabase.memory() {
    return TestsDatabase(
      NativeDatabase.memory(
        setup: (db) {
          db.config.doubleQuotedStringLiterals = false;
        },
      ),
    );
  }

  @override
  int get schemaVersion => 1;
}
