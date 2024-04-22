import 'dart:async';

import 'package:drift/drift.dart' hide Column;
import 'package:electricsql/util.dart';
import 'package:electricsql_flutter/drivers/drift.dart';
import 'package:electricsql_flutter/electricsql_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:todos_electrified/database/database.dart';
import 'package:todos_electrified/database/drift/database.dart';
import 'package:todos_electrified/database/drift/drift_repository.dart';
import 'package:todos_electrified/electric.dart';
import 'package:todos_electrified/features/auth.dart';
import 'package:todos_electrified/main.dart';
import 'package:todos_electrified/presentation/theme.dart';
import 'package:todos_electrified/presentation/util/confirmation_dialog.dart';
import 'package:todos_electrified/database/drift/connection/connection.dart'
    as db_lib;

typedef InitData = ({
  TodosDatabase todosDb,
  ElectricClient<AppDatabase> electricClient,
  ConnectivityStateController connectivityStateController,
  String userId,
});

/// Initialize the app by opening the local database and electrifying it
/// and handle errors in the process
void useInitializeApp(
  ValueNotifier<InitData?> initDataVN, {
  required String userId,
}) {
  final retryVN = useState(0);

  final context = useContext();

  useEffect(() {
    InitData? initData;

    Future<bool> init() async {
      final driftRepo = await initDriftTodosDatabase(userId);
      if (!context.mounted) return false;

      final todosDb = TodosDatabase(driftRepo);
      // final sqliteRepo = initSqliteRepository(dbPath);
      // final todosDb = TodosDatabase(sqliteRepo);
      // final adapter = SqliteAdapter(sqliteRepo.db);

      final dbName = "todos_db_user-$userId";

      ElectricClient<AppDatabase>? electricClient;
      try {
        // Electrify
        electricClient = await startElectricDrift(dbName, driftRepo.db);

        await _populateList(electricClient.db);
      } catch (e, st) {
        print("Unexpected error occurred when starting: $e\n$st");

        if (!context.mounted) return false;

        final bool shouldDelete = await _askUserToDeleteLocalState(
          context,
          error: e,
          stackTrace: st,
        );
        if (!context.mounted) return false;

        if (shouldDelete) {
          await deleteLocalStateAndRetry(
            context,
            driftRepo: driftRepo,
            electricClient: electricClient,
            retryVN: retryVN,
            userId: userId,
          );
        }

        return false;
      }

      if (!context.mounted) return false;

      final connectivityStateController =
          ConnectivityStateController(electricClient)..init();

      // Everything started successfully
      initData = (
        todosDb: todosDb,
        electricClient: electricClient,
        connectivityStateController: connectivityStateController,
        userId: userId,
      );
      initDataVN.value = initData;

      return true;
    }

    init();

    return null;
  }, [retryVN.value]);
}

Future<void> _populateList(AppDatabase db) async {
  final list = await (db.todolist.select()..where((l) => l.id.equals(kListId)))
      .getSingleOrNull();
  if (list == null) {
    await db.todolist.insertOne(TodolistCompanion.insert(id: kListId));
  }
}

class InitAppLoader extends HookWidget {
  final ValueNotifier<InitData?> initDataVN;

  const InitAppLoader({super.key, required this.initDataVN});

  @override
  Widget build(BuildContext context) {
    final userVN = useState<String?>(null);

    return MaterialApp(
      theme: ThemeData.from(
        useMaterial3: true,
        colorScheme: kElectricColorScheme,
      ),
      home: userVN.value == null
          ? LoginScreen(userVN: userVN) : HookBuilder(builder: (context) {
        useInitializeApp(initDataVN, userId: userVN.value!);

        return Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Initializing the app...",
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 20),
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

Future<bool> _askUserToDeleteLocalState(
  BuildContext context, {
  required Object error,
  required StackTrace stackTrace,
}) async {
  final String dialogTitle;

  if (error is SatelliteException &&
      error.code == SatelliteErrorCode.unknownSchemaVersion) {
    dialogTitle = "Local schema doesn't match server's";
  } else {
    dialogTitle = "Unexpected error occurred when starting. Check logs.";
  }

  // Ask to delete the database
  final shouldDeleteLocal = await launchConfirmationDialog(
    title: dialogTitle,
    content: const Text("Delete local state and retry?"),
    context: context,
    barrierDismissible: false,
  );

  return shouldDeleteLocal == true;
}

Future<void> deleteLocalStateAndRetry(
  BuildContext context, {
  required ElectricClient<AppDatabase>? electricClient,
  required DriftRepository driftRepo,
  required ValueNotifier<int> retryVN,
  required String userId,
}) async {
  await electricClient?.close();

  await driftRepo.close();

  if (!kIsWeb) {
    await db_lib.deleteTodosDbFile(userId);

    retryVN.value++;
    return;
  } else {
    // On web, we cannot properly retry automatically, so just ask the user to refresh
    // the page

    unawaited(db_lib.deleteTodosDbFile(userId));
    await Future<void>.delayed(const Duration(milliseconds: 200));

    if (!context.mounted) return;

    await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const AlertDialog(
            title: Text("Local database deleted"),
            content: Text("Please refresh the page"),
          );
        });

    // Wait indefinitely until user refreshes
    await Future<void>.delayed(const Duration(days: 9999));
  }
}
