import 'dart:async';

import 'package:electricsql/electricsql.dart';
import 'package:electricsql/util.dart' show genUUID;
import 'package:electricsql_flutter/drivers/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:todos_electrified/database/database.dart';

import 'package:todos_electrified/electric.dart';
import 'package:todos_electrified/features/init_app.dart';
import 'package:todos_electrified/presentation/theme.dart';
import 'package:todos_electrified/features/todos.dart';
import 'package:animated_emoji/animated_emoji.dart';
import 'package:todos_electrified/features/delete_local_db.dart';
import 'package:todos_electrified/features/electric_connection.dart';
import 'package:todos_electrified/presentation/util/input_text_dialog.dart';
import 'package:todos_electrified/presentation/util/platform.dart';

const kListId = "LIST-ID-SAMPLE";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(_Entrypoint());
}

class _Entrypoint extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final initDataVN = useState<InitData?>(null);

    final initData = initDataVN.value;

    useEffect(() {
      // Cleanup resources on app unmount
      return () {
        () async {
          if (initData != null) {
            await initData.electricClient.close();
            await initData.todosDb.todosRepo.close();
            print("Everything closed");
          }
        }();
      };
    }, [initData]);

    if (initData == null) {
      // This will initialize the app and will update the initData ValueNotifer
      return InitAppLoader(initDataVN: initDataVN);
    }

    // Database and Electric are ready
    return ProviderScope(
      overrides: [
        todosDatabaseProvider.overrideWithValue(initData.todosDb),
        electricClientProvider.overrideWithValue(initData.electricClient),
        connectivityStateControllerProvider.overrideWith(
          (ref) => initData.connectivityStateController,
        ),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todos Electrified',
      theme: ThemeData.from(
        useMaterial3: true,
        colorScheme: kElectricColorScheme,
      ),
      home: Consumer(
        builder: (context, ref, _) {
          final dbDeleted = ref.watch(dbDeletedProvider);

          if (dbDeleted) {
            return const DeleteDbScreen();
          }

          return const MyHomePage();
        },
      ),
    );
  }
}

class MyHomePage extends HookConsumerWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAV = ref.watch(todosProvider);

    final electricClient = ref.watch(electricClientProvider);
    final db = electricClient.db;

    // Let the Devtools know how to reset the local database
    ElectricDevtoolsBinding.registerDbResetCallback(
      electricClient,
      () async => deleteLocalDb(ref),
    );

    // Connect to Electric, and listen for connection success/failure
    final connectToElectricAV = useConnectToElectric(ref);

    useEffect(() {
      // Only define sync shapes if connected to Electric
      if (connectToElectricAV.hasValue) {
        // Sync todo list and all its todos through the Foreign Key relationship
        electricClient.syncTable(
          db.todolist,
          include: (tl) => [
            SyncInputRelation.from(tl.$relations.todo),
          ],
        );
      }

      return null;
    }, [connectToElectricAV]);

    return Scaffold(
      appBar: AppBar(
        leading: const Center(
          child: FlutterLogo(
            size: 35,
          ),
        ),
        title: Row(
          children: [
            const Text("todos", style: TextStyle(fontSize: 30)),
            const SizedBox(width: 20),
            Icon(getIconForPlatform()),
            const SizedBox(width: 5),
            Text(getPlatformName()),
            const SizedBox(width: 10),
            const AnimatedEmoji(
              AnimatedEmojis.electricity,
              size: 24,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          connectToElectricAV.isLoading
              ? const ConnectingToElectric()
              : const ConnectivityButton(),
          const SizedBox(height: 10),
          Expanded(
            child: todosAV.when(
              data: (todos) {
                return _TodosLoaded(todos: todos);
              },
              error: (e, st) {
                return Center(child: Text(e.toString()));
              },
              loading: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  const Text(
                    "Unofficial Dart client running on top of\nthe sync service powered by",
                    textAlign: TextAlign.center,
                  ),
                  SvgPicture.asset(
                    "assets/electric.svg",
                    height: 40,
                  ),
                ],
              ),
            ),
          ),
          const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: DeleteLocalDbButton(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodosLoaded extends HookConsumerWidget {
  const _TodosLoaded({required this.todos});

  final List<Todo> todos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textController = useTextEditingController();

    final doneTodos = todos.where((t) => t.completed).length;

    return Align(
      alignment: Alignment.topCenter,
      child: Card(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 500),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Symbols.check_circle_outline, size: 16),
                    const SizedBox(width: 5),
                    Text("$doneTodos / ${todos.length}"),
                  ],
                ),
                TextField(
                  controller: textController,
                  decoration: const InputDecoration(
                    hintText: "What needs to be done?",
                  ),
                  onEditingComplete: () async {
                    final text = textController.text;
                    if (text.trim().isEmpty) {
                      // clear focus
                      FocusScope.of(context).requestFocus(FocusNode());
                      return;
                    }
                    print("done");
                    final db = ref.read(todosDatabaseProvider);
                    final now = DateTime.now();
                    await db.insertTodo(
                      Todo(
                        id: genUUID(),
                        listId: kListId,
                        text: textController.text,
                        createdAt: now,
                        editedAt: now,
                        completed: false,
                      ),
                    );

                    textController.clear();
                  },
                ),
                const SizedBox(
                  height: 15,
                ),
                Flexible(
                  child: todos.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text("No todos yet"),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          separatorBuilder: (context, i) => const Divider(
                            height: 0,
                          ),
                          itemBuilder: (context, i) {
                            return TodoTile(todo: todos[i]);
                          },
                          itemCount: todos.length,
                        ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () async {
                      final db = ref.read(todosDatabaseProvider);
                      await db.removeAllTodos();
                    },
                    icon: const Icon(Symbols.delete),
                    label: const Text("Delete all todos"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TodoTile extends ConsumerWidget {
  final Todo todo;
  const TodoTile({super.key, required this.todo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      leading: IconButton(
        onPressed: () async {
          final db = ref.read(todosDatabaseProvider);
          await db.updateTodo(todo.copyWith(completed: !todo.completed));
        },
        icon: todo.completed
            ? Icon(
                Symbols.check_circle_outline,
                color: Theme.of(context).colorScheme.primary,
              )
            : const Icon(Symbols.circle),
      ),
      title: Text(
        todo.text ?? "",
        style: TextStyle(
          decoration: todo.completed ? TextDecoration.lineThrough : null,
          color: todo.completed ? Colors.grey : null,
        ),
      ),
      subtitle: Text(
        "Last edited: ${DateFormat.yMMMd().add_jm().format(todo.editedAt)}",
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _onEdit(ref),
            icon: const Icon(Symbols.edit),
          ),
          IconButton(
            onPressed: () async {
              final db = ref.read(todosDatabaseProvider);
              await db.removeTodo(todo.id);
            },
            icon: const Icon(Symbols.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _onEdit(WidgetRef ref) async {
    final newText = await showDialog<String>(
      context: ref.context,
      builder: (context) {
        return InputTextDialog(
          title: "Edit todo",
          initialValue: todo.text,
          hint: "Todo",
          action: "Save",
        );
      },
    );

    if (newText == null) return;

    final db = ref.read(todosDatabaseProvider);
    await db.updateTodo(todo.copyWith(text: newText));
  }
}
