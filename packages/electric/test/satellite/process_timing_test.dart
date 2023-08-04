// ignore_for_file: unreachable_from_main

import 'package:electric_client/src/electric/adapter.dart';
import 'package:electric_client/src/migrators/migrators.dart';
import 'package:electric_client/src/notifiers/mock.dart';
import 'package:electric_client/src/satellite/config.dart';
import 'package:electric_client/src/satellite/mock.dart';
import 'package:electric_client/src/satellite/process.dart';
import 'package:electric_client/src/util/types.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import '../support/satellite_helpers.dart';
import 'common.dart';

late SatelliteTestContext context;

Database get db => context.db;
DatabaseAdapter get adapter => context.adapter;
Migrator get migrator => context.migrator;
MockNotifier get notifier => context.notifier;
TableInfo get tableInfo => context.tableInfo;
DateTime get timestamp => context.timestamp;
SatelliteProcess get satellite => context.satellite;
MockSatelliteClient get client => context.client;
String get dbName => context.dbName;

final opts = kSatelliteDefaults.copyWith(
  minSnapshotWindow: const Duration(milliseconds: 80),
  pollingInterval: const Duration(milliseconds: 500),
);

void main() {
  setUp(() async {
    context = await makeContext(options: opts);
  });

  tearDown(() async {
    await context.clean();
  });

  test('throttled snapshot respects window', () async {
    await context.runMigrations();

    await satellite.setAuthState(context.authState);
    await satellite.throttledSnapshot();
    final numNotifications = notifier.notifications.length;

    const sql = "INSERT INTO parent(id) VALUES ('1'),('2')";
    await adapter.run(Statement(sql));
    await satellite.throttledSnapshot();

    expect(notifier.notifications.length, numNotifications);

    await Future<void>.delayed(opts.minSnapshotWindow);

    expect(notifier.notifications.length, numNotifications + 1);
  });
}
