import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todos_electrified/database.dart';

final todosProvider = FutureProvider<List<Todo>>((ref) async {
  final db = ref.watch(todosDatabaseProvider);
  return db.fetchTodos();
});
