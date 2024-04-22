import 'package:drift/drift.dart';
import 'package:todos_electrified/database/database.dart' as m;

import 'database.dart';
import 'connection/connection.dart' as impl;

Future<DriftRepository> initDriftTodosDatabase(String userId) async {
  final db = AppDatabase(impl.connect(userId));

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
  Future<void> insertTodo(m.Todo todo) async {
    await db.todo.insertOne(
      TodoCompanion.insert(
        id: todo.id,
        completed: todo.completed,
        listid: Value(todo.listId),
        text$: Value(todo.text),
        editedAt: todo.editedAt,
      ),
    );
  }

  @override
  Future<void> removeTodo(String id) async {
    await db.todo.deleteWhere((tbl) => tbl.id.equals(id));
  }

  @override
  Future<void> updateTodo(m.Todo item) async {
    await (db.todo.update()
          ..where(
            (tbl) => tbl.id.equals(item.id),
          ))
        .write(
      TodoCompanion(
        completed: Value(item.completed),
        listid: Value(item.listId),
        text$: Value(item.text),
        editedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Stream<List<m.Todo>> watchTodos() {
    return (db.todo.select()
          ..orderBy(
            [(tbl) => OrderingTerm(expression: tbl.text$.lower())],
          ))
        .map(
          (todo) => m.Todo(
            completed: todo.completed,
            id: todo.id,
            listId: todo.listid,
            editedAt: todo.editedAt,
            text: todo.text$!,
          ),
        )
        .watch();
  }
}
