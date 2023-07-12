import 'package:electric_client/drivers/drift.dart';
import 'package:electric_client/electric_dart.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todos_electrified/migrations.dart';

final Provider<ElectricClient> electricClientProvider =
    Provider((ref) => throw UnimplementedError());

final connectivityStateProvider = StateProvider<ConnectivityState>((ref) {
  return ConnectivityState.disconnected;
});

const kElectricAuthConfig = AuthConfig(
  token:
      'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJsb2NhbC1kZXZlbG9wbWVudCIsInR5cGUiOiJhY2Nlc3MiLCJ1c2VyX2lkIjoidGVzdC11c2VyIiwiaWF0IjoxNjg3ODc3OTQ1LCJleHAiOjE2OTc4ODE1NDV9.L5Ui2sA9o5MeYDuy67u9lBV-2FzpOWL9dKcitRvgorg',
);

Future<ElectricClient> startElectricDrift(
  String dbPath,
  ElectricfiedDriftDatabaseMixin db,
) async {
  final dbName = dbPath;

  final namespace = await electrify(
    dbName: dbName,
    db: db,
    migrations: todoMigrations,
    config: ElectricConfig(
      auth: kElectricAuthConfig,
      debug: true,
    ),
  );

  return namespace;
}
