import 'package:electricsql/util.dart';
import 'package:electricsql_flutter/drivers/drift.dart';
import 'package:electricsql_flutter/electricsql_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:todos_electrified/database/database.dart';
import 'package:todos_electrified/database/drift/database.dart';
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

void useInitializeApp(ValueNotifier<InitData?> initDataVN,
    {required String userId}) {
  final retryVN = useState(0);

  final context = useContext();

  useEffect(() {
    bool mounted = true;
    InitData? initData;

    Future<void> init() async {
      final driftRepo = await initDriftTodosDatabase();
      if (!mounted) return;

      final todosDb = TodosDatabase(driftRepo);
      // final sqliteRepo = initSqliteRepository(dbPath);
      // final todosDb = TodosDatabase(sqliteRepo);
      // final adapter = SqliteAdapter(sqliteRepo.db);

      const dbName = "todos_db";

      final DriftElectricClient<AppDatabase> electricClient;
      try {
        print("Starting electric with userId $userId");
        electricClient =
            await startElectricDrift(dbName, driftRepo.db, userId: userId);
      } on SatelliteException catch (e) {
        if (mounted) {
          if (!kIsWeb && e.code == SatelliteErrorCode.unknownSchemaVersion) {
            // Ask to delete the database
            final shouldDeleteLocal = await launchConfirmationDialog(
              title: "Local schema doesn't match server's",
              content: const Text("Delete local state and retry?"),
              context: context,
            );

            if (shouldDeleteLocal == true) {
              await driftRepo.close();

              await impl.deleteTodosDbFile();

              retryVN.value++;
              return;
            }
          }
        }

        rethrow;
      }

      if (!mounted) return;

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

    return () {
      mounted = false;
    };
  }, [retryVN.value]);
}

class LoginScreen extends HookWidget {
  final ValueNotifier<String?> userVN;
  const LoginScreen({super.key, required this.userVN});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          UserTile(userId: "1", userVN: userVN),
          UserTile(userId: "2", userVN: userVN),
        ],
      ),
    );
  }
}

class UserTile extends StatelessWidget {
  final String userId;
  final ValueNotifier<String?> userVN;

  const UserTile({super.key, required this.userId, required this.userVN});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.arrow_forward),
      label: Text("User $userId"),
      onPressed: () {
        userVN.value = userId;
      },
    );
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
          ? LoginScreen(userVN: userVN)
          : HookBuilder(builder: (context) {
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
