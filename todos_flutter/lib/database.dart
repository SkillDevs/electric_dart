import 'dart:io';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

final Provider<TodosDatabase> todosDatabaseProvider = Provider((ref) => throw UnimplementedError());

Future<TodosDatabase> initTodosDatabase() async {
  final appDocsDir = await getApplicationDocumentsDirectory();
  final appDir = Directory(join(appDocsDir.path, "todos-electric"));
  if (!await appDir.exists()) {
    await appDir.create(recursive: true);
  }

  final todosDbPath = join(appDir.path, "todos.db");

  print("Using todos database at path $todosDbPath");
  final db = sqlite3.open(todosDbPath);

  return TodosDatabase(
    db,
    dbPath: todosDbPath,
  );
}

class TodosDatabase {
  final Database db;
  final String dbPath;

  TodosDatabase(
    this.db, {
    required this.dbPath,
  });

  Future<List<Todo>> fetchTodos() async {
    const query = "SELECT * FROM todo";
    final rows = db.select(query);

    return rows.map((row) {
      return Todo(
        id: row['id'],
        listId: row['listid'],
        text: row['text'] as String,
        completed: row['completed'] == 1,
      );
    }).toList();
  }

  Future<void> updateTodo(Todo todo) async {
    const query = '''
UPDATE todo SET text = ?, completed = ?, listid = ?
WHERE id = ?''';
    db.execute(query, [todo.text, todo.completed, todo.listId, todo.id]);
  }

  Future<void> insertTodo(Todo todo) async {
    const query = "INSERT INTO todo (id, listid, text, completed) VALUES (?, ?, ?, ?)";
    db.execute(query, [todo.id, todo.listId, todo.text, todo.completed ? 1 : 0]);
  }

  Future<void> removeTodo(String id) async {
    const query = "DELETE FROM todo WHERE id = ?";
    db.execute(query, [id]);
  }
}

class Todo {
  final String id;
  final String? listId;
  final String text;
  final bool completed;

  Todo({
    required this.id,
    required this.listId,
    required this.text,
    required this.completed,
  });

  Todo copyWith({
    String? Function()? listId,
    String? text,
    bool? completed,
  }) {
    return Todo(
      id: id,
      listId: listId != null ? listId() : this.listId,
      text: text ?? this.text,
      completed: completed ?? this.completed,
    );
  }
}
