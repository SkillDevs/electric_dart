import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todos_electrified/database/database.dart';

// Stream query that watches for changes in the todos
final todosProvider = StreamProvider<List<Todo>>((ref) {
  final db = ref.watch(todosDatabaseProvider);

  return db.watchTodos();
});

// NON-STREAM QUERY
// final todosProvider = FutureProvider<List<Todo>>((ref) async {
//   final db = ref.watch(todosDatabaseProvider);

//   return db.fetchTodos();
// });