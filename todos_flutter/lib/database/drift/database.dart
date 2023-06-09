import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:electric_client/electric_dart.dart';
import 'package:todos_electrified/database/database.dart' as m;

part 'database.g.dart';

class Todos extends Table {
  @override
  bool get withoutRowId => true;

  @override
  String? get tableName => "todo";

  @override
  Set<Column<Object>>? get primaryKey => {id};

  TextColumn get id => text()();
  TextColumn get listid => text().nullable()();
  TextColumn get textCol => text().named("text").nullable()();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
}

class TodoLists extends Table {
  @override
  bool get withoutRowId => true;

  @override
  String? get tableName => "todolist";

  @override
  Set<Column<Object>>? get primaryKey => {id};

  TextColumn get id => text()();
  TextColumn get filter => text().nullable()();
  TextColumn get editing => text().nullable()();
}

Future<DriftRepository> initDriftTodosDatabase(String dbPath) async {
  print("Using todos database at path $dbPath");

  final db = AppDatabase(dbPath);

  await db.customSelect("SELECT 1").get();

  return DriftRepository(db);
}

class DriftRepository implements m.TodosRepository {
  final AppDatabase db;

  DriftRepository(this.db);

  @override
  Future<List<m.Todo>> fetchTodos() async {
    return db.todos
        .select()
        .map(
          (todo) => m.Todo(
              completed: todo.completed,
              id: todo.id,
              listId: todo.listid,
              text: todo.textCol!),
        )
        .get();
  }

  @override
  Future<void> insertTodo(m.Todo todo) async {
    await db.todos.insertOne(
      TodosCompanion.insert(
        id: todo.id,
        completed: Value(todo.completed),
        listid: Value(todo.listId),
        textCol: Value(todo.text),
      ),
    );
  }

  @override
  Future<void> removeTodo(String id) async {
    await db.todos.deleteWhere((tbl) => tbl.id.equals(id));
  }

  @override
  Future<void> updateTodo(m.Todo todo) async {
    await (db.todos.update()
          ..where(
            (tbl) => tbl.id.equals(todo.id),
          ))
        .write(
      TodosCompanion(
        completed: Value(todo.completed),
        listid: Value(todo.listId),
        textCol: Value(todo.text),
      ),
    );
  }

  @override
  Stream<List<m.Todo>> watchTodos() {
    return db.todos
        .select()
        .map(
          (todo) => m.Todo(
              completed: todo.completed,
              id: todo.id,
              listId: todo.listid,
              text: todo.textCol!),
        )
        .watch();
  }
}

@DriftDatabase(tables: [Todos, TodoLists])
class AppDatabase extends _$AppDatabase with ElectricfiedDriftDatabaseMixin {
  final String dbPath;
  AppDatabase(this.dbPath) : super(_openConnection(dbPath));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        //
        print("Dummy onCreate");
      },
    );
  }
}

QueryExecutor _openConnection(String dbPath) {
  final file = File(dbPath);
  return NativeDatabase.createInBackground(file);
}
