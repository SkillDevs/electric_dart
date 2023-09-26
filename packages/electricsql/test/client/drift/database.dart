import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:electricsql/src/drivers/drift/converters.dart';

// assuming that your file is called filename.dart. This will give an error at
// first, but it's needed for drift to know about the generated code
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
  TextColumn get timetz => text().map(const ElectricTimeTZConverter()).nullable()();
  TextColumn get timestamp =>
      text().map(const ElectricTimestampConverter()).nullable()();
  TextColumn get timestamptz =>
      text().map(const ElectricTimestampTZConverter()).nullable()();
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
