import 'package:hooks_riverpod/hooks_riverpod.dart';

final Provider<TodosDatabase> todosDatabaseProvider =
    Provider((ref) => throw UnimplementedError());

class TodosDatabase {
  final TodosRepository todosRepo;

  TodosDatabase(this.todosRepo);

  Stream<List<Todo>> watchTodos() {
    return todosRepo.watchTodos();
  }

  Future<void> updateTodo(Todo todo) async {
    return todosRepo.updateTodo(todo);
  }

  Future<void> insertTodo(Todo todo) async {
    return todosRepo.insertTodo(todo);
  }

  Future<void> removeTodo(String id) async {
    return todosRepo.removeTodo(id);
  }

  Future<void> removeAllTodos() async {
    return todosRepo.removeAllTodos();
  }
}

class Todo {
  final String id;
  final String? listId;
  final String? text;
  final DateTime createdAt;
  final DateTime editedAt;
  final bool completed;

  Todo({
    required this.id,
    required this.listId,
    required this.text,
    required this.createdAt,
    required this.editedAt,
    required this.completed,
  });

  Todo copyWith({
    String? Function()? listId,
    String? text,
    DateTime? createdAt,
    DateTime? editedAt,
    bool? completed,
  }) {
    return Todo(
      id: id,
      listId: listId != null ? listId() : this.listId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
      completed: completed ?? this.completed,
    );
  }
}

abstract class TodosRepository {
  Stream<List<Todo>> watchTodos();
  Future<void> updateTodo(Todo todo);
  Future<void> removeTodo(String id);
  Future<void> insertTodo(Todo todo);
  Future<void> removeAllTodos();
  Future<void> close();
}
