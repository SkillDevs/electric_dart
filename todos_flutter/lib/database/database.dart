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
}

class Todo {
  final String id;
  final String? listId;
  final String? text;
  final DateTime editedAt;
  final bool completed;

  Todo({
    required this.id,
    required this.listId,
    required this.text,
    required this.editedAt,
    required this.completed,
  });

  Todo copyWith({
    String? Function()? listId,
    String? text,
    DateTime? editedAt,
    bool? completed,
  }) {
    return Todo(
      id: id,
      listId: listId != null ? listId() : this.listId,
      text: text ?? this.text,
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
  Future<void> close();
}
