import 'package:electricsql_flutter/electricsql_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todos_electrified/database/drift/database.dart';

import 'package:electricsql_flutter/drivers/drift.dart';
import 'package:todos_electrified/generated/electric/drift_schema.dart';

final Provider<ElectricClient<AppDatabase>> electricClientProvider =
    Provider((ref) => throw UnimplementedError());

final connectivityStateControllerProvider =
    ChangeNotifierProvider<ConnectivityStateController>(
        (ref) => throw UnimplementedError());

Future<ElectricClient<AppDatabase>> startElectricDrift(
  String dbName,
  AppDatabase db,
) async {
  // ##### IMPORTANT #####
  // If you are running the app on a physical device or emulator, localhost
  // won't work, you need to use the IP address of your computer when developing
  // locally. (192.168.x.x:5133)
  const String electricURL = 'http://localhost:5133';

  print("Electrifying database...");
  print("Electric URL: $electricURL");

  final client = await electrify<AppDatabase>(
    dbName: dbName,
    db: db,
    migrations: kElectricMigrations,
    config: ElectricConfig(
      url: electricURL,
      logger: LoggerConfig(
        level: Level.debug,
      ),
    ),
  );

  print("Database electrified!");

  return client;
}
