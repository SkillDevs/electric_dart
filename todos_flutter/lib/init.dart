import 'package:electricsql_flutter/electricsql_flutter.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:todos_electrified/database/database.dart';
import 'package:todos_electrified/database/drift/database.dart';
import 'package:todos_electrified/electric.dart';

typedef InitData = ({
  TodosDatabase todosDb,
  ElectricClient electricClient,
  ConnectivityStateController connectivityStateController,
});

InitData? useInitData() {
  final initDataVN = useState<InitData?>(null);

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
      final electricClient = await startElectricDrift(dbName, driftRepo.db);
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
      
      initData?.connectivityStateController.dispose();
      initData?.electricClient.dispose();
    };
  }, []);

  final initData = initDataVN.value;
  return initData;
}
