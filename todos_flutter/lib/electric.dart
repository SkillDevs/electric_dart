import 'package:drift/drift.dart';
import 'package:electricsql_flutter/electricsql_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todos_electrified/generated/electric_migrations.dart';

import 'package:electricsql_flutter/drivers/drift.dart';

final Provider<ElectricClient> electricClientProvider =
    Provider((ref) => throw UnimplementedError());

final connectivityStateControllerProvider =
    ChangeNotifierProvider<ConnectivityStateController>(
        (ref) => throw UnimplementedError());

Future<ElectricClient> startElectricDrift(
  String dbName,
  DatabaseConnectionUser db,
) async {
  final namespace = await electrify(
    dbName: dbName,
    db: db,
    migrations: kElectricMigrations,
    config: ElectricConfig(
      auth: AuthConfig(
        token: await mockSecureAuthToken(
            iss: 'local-development',
            key: 'local-development-key-minimum-32-symbols'),
      ),
      debug: true,
    ),
  );

  return namespace;
}
