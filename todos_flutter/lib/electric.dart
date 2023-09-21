import 'package:electricsql_flutter/electricsql_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todos_electrified/auth.dart';
import 'package:todos_electrified/database/drift/database.dart';
import 'package:todos_electrified/generated/electric_migrations.dart';

import 'package:electricsql_flutter/drivers/drift.dart';

final Provider<ElectricClient> electricClientProvider =
    Provider((ref) => throw UnimplementedError());

final connectivityStateControllerProvider =
    ChangeNotifierProvider<ConnectivityStateController>(
        (ref) => throw UnimplementedError());

Future<DriftElectricClient<AppDatabase>> startElectricDrift(
  String dbName,
  AppDatabase db, {
  required String userId,
}) async {
  final client = await electrify<AppDatabase>(
    dbName: dbName,
    db: db,
    migrations: kElectricMigrations,
    config: ElectricConfig(
      auth: AuthConfig(
        token: authToken(userId),
      ),
      logger: LoggerConfig(
        level: Level.debug,
      ),
      // url: '<ELECTRIC_SERVICE_URL>',
    ),
  );

  return client;
}
