import 'package:drift/drift.dart';
import 'package:electricsql_flutter/drivers/drift.dart';
import 'package:todos_electrified/database/database.dart' as m;
import 'connection/connection.dart' as impl;

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
  Column<DateTime> get editedAt =>
      customType(ElectricTypes.timestampTZ).named('edited_at')();
  BoolColumn get completed => boolean()();
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

Future<DriftRepository> initDriftTodosDatabase() async {
  final db = AppDatabase();

  await db.customSelect("SELECT 1").get();

  return DriftRepository(db);
}

class DriftRepository implements m.TodosRepository {
  final AppDatabase db;

  DriftRepository(this.db);

  @override
  Future<void> close() async {
    await db.close();
  }

  @override
  Future<List<m.Todo>> fetchTodos() async {
    return (db.todos.select()
          ..orderBy(
            [(tbl) => OrderingTerm(expression: tbl.textCol.lower())],
          ))
        .map(
          (todo) => m.Todo(
            completed: todo.completed,
            id: todo.id,
            listId: todo.listid,
            editedAt: todo.editedAt,
            text: todo.textCol!,
          ),
        )
        .get();
  }

  @override
  Future<void> insertTodo(m.Todo todo) async {
    await db.todos.insertOne(
      TodosCompanion.insert(
        id: todo.id,
        completed: todo.completed,
        listid: Value(todo.listId),
        textCol: Value(todo.text),
        editedAt: todo.editedAt,
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
        editedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Stream<List<m.Todo>> watchTodos() {
    return (db.todos.select()
          ..orderBy(
            [(tbl) => OrderingTerm(expression: tbl.textCol.lower())],
          ))
        .map(
          (todo) => m.Todo(
            completed: todo.completed,
            id: todo.id,
            listId: todo.listid,
            editedAt: todo.editedAt,
            text: todo.textCol!,
          ),
        )
        .watch();
  }
}

@DriftDatabase(tables: [Todos, TodoLists])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(impl.connect());

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
