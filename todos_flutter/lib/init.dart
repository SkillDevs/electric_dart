import 'dart:async';

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
import 'package:todos_electrified/theme.dart';
import 'package:todos_electrified/util/confirmation_dialog.dart';
import 'package:todos_electrified/database/drift/connection/connection.dart'
    as impl;

typedef InitData = ({
  TodosDatabase todosDb,
  ElectricClient electricClient,
  ConnectivityStateController connectivityStateController,
});

void useInitializeApp(ValueNotifier<InitData?> initDataVN) {
  final retryVN = useState(0);

  final context = useContext();

  useEffect(() {
    InitData? initData;

    Future<void> init() async {
      final driftRepo = await initDriftTodosDatabase();
      if (!context.mounted) return;

      final todosDb = TodosDatabase(driftRepo);
      // final sqliteRepo = initSqliteRepository(dbPath);
      // final todosDb = TodosDatabase(sqliteRepo);
      // final adapter = SqliteAdapter(sqliteRepo.db);

      const dbName = "todos_db";

      final DriftElectricClient<AppDatabase> electricClient;
      try {
        electricClient = await startElectricDrift(dbName, driftRepo.db);
      } on SatelliteException catch (e) {
        if (context.mounted) {
          if (e.code == SatelliteErrorCode.unknownSchemaVersion) {
            // Ask to delete the database
            final shouldDeleteLocal = await launchConfirmationDialog(
              title: "Local schema doesn't match server's",
              content: const Text("Delete local state and retry?"),
              context: context,
              barrierDismissible: false,
            );

            if (shouldDeleteLocal == true) {
              await driftRepo.close();

              if (!kIsWeb) {
                await impl.deleteTodosDbFile();

                retryVN.value++;
                return;
              } else {
                // On web, we cannot properly retry automatically, so just ask the user to refresh
                // the page

                unawaited(impl.deleteTodosDbFile());
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
          }
        }

        rethrow;
      }

      if (!context.mounted) return;

      final connectivityStateController =
          ConnectivityStateController(electricClient)..init();

      initData = (
        todosDb: todosDb,
        electricClient: electricClient,
        connectivityStateController: connectivityStateController,
      );
      initDataVN.value = initData;
    }

    init();

    return null;
  }, [retryVN.value]);
}

class InitAppLoader extends HookWidget {
  final ValueNotifier<InitData?> initDataVN;

  const InitAppLoader({super.key, required this.initDataVN});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.from(
        useMaterial3: true,
        colorScheme: kElectricColorScheme,
      ),
      home: HookBuilder(builder: (context) {
        useInitializeApp(initDataVN);

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
