import 'package:drift/drift.dart';

// assuming that your file is called filename.dart. This will give an error at
// first, but it's needed for drift to know about the generated code
part 'database.g.dart';

class Items extends Table {
  TextColumn get value => text()();
  IntColumn get nbr => integer().nullable()();

  @override
  String? get tableName => 'Item';

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
  TextColumn get name => text().unique()();
  TextColumn get contents => text()();
  IntColumn get nbr => integer().nullable()();
  IntColumn get authorId => integer().references(Users, #id)();

  @override
  String? get tableName => 'Post';

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class Profiles extends Table {
  IntColumn get id => integer()();
  TextColumn get bio => text()();
  TextColumn get contents => text()();
  IntColumn get userId => integer().unique().references(Users, #id)();

  @override
  String? get tableName => 'Profile';

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

@DriftDatabase(tables: [Items, Users, Posts, Profiles])
class TestsDatabase extends _$TestsDatabase {
  TestsDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
