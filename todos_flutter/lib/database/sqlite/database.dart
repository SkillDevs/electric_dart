import 'package:sqlite3/sqlite3.dart';
import 'package:todos_electrified/database/database.dart';

TodosRepositorySqlite initSqliteRepository(String dbPath) {
  print("Using todos database at path $dbPath");
  final db = sqlite3.open(dbPath);

  final repository = TodosRepositorySqlite(db);

  return repository;
}

class TodosRepositorySqlite implements TodosRepository {
  final Database db;

  TodosRepositorySqlite(this.db);

  @override
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

  @override
  Future<void> updateTodo(Todo todo) async {
    const query = '''
UPDATE todo SET text = ?, completed = ?, listid = ?
WHERE id = ?''';
    db.execute(query, [todo.text, todo.completed, todo.listId, todo.id]);
  }

  @override
  Future<void> insertTodo(Todo todo) async {
    const query =
        "INSERT INTO todo (id, listid, text, completed) VALUES (?, ?, ?, ?)";
    db.execute(
        query, [todo.id, todo.listId, todo.text, todo.completed ? 1 : 0]);
  }

  @override
  Future<void> removeTodo(String id) async {
    const query = "DELETE FROM todo WHERE id = ?";
    db.execute(query, [id]);
  }

  @override
  Stream<List<Todo>> watchTodos() {
    throw UnimplementedError();
  }
}
