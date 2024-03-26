import 'package:electricsql_flutter/electricsql_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todos_electrified/auth.dart';
import 'package:todos_electrified/database/drift/database.dart';

import 'package:electricsql_flutter/drivers/drift.dart';
import 'package:todos_electrified/generated/electric/migrations.dart';

final Provider<ElectricClient<AppDatabase>> electricClientProvider =
    Provider((ref) => throw UnimplementedError());

final connectivityStateControllerProvider =
    ChangeNotifierProvider<ConnectivityStateController>(
        (ref) => throw UnimplementedError());

Future<ElectricClient<AppDatabase>> startElectricDrift(
  String dbName,
  AppDatabase db,
) async {
  final client = await electrify<AppDatabase>(
    dbName: dbName,
    db: db,
    migrations: kElectricMigrations,
    config: ElectricConfig(
      logger: LoggerConfig(
        level: Level.debug,
      ),
      // url: '<ELECTRIC_SERVICE_URL>',
    ),
  );

  await client.connect(authToken());

  return client;
}
