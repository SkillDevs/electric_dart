// ignore_for_file: unreachable_from_main

import 'package:electricsql/src/electric/adapter.dart';
import 'package:electricsql/src/migrators/migrators.dart';
import 'package:electricsql/src/notifiers/mock.dart';
import 'package:electricsql/src/satellite/config.dart';
import 'package:electricsql/src/satellite/mock.dart';
import 'package:electricsql/src/satellite/process.dart';
import 'package:electricsql/src/util/types.dart';
import 'package:test/test.dart';

import '../support/satellite_helpers.dart';
import 'common.dart';

/*
 * This file defines the tests for the process timing of Satellite.
 * These tests are common to both SQLite and Postgres.
 * Only their context differs.
 * Therefore, the SQLite and Postgres test files
 * setup their context and then call the tests from this file.
 */

late SatelliteTestContext context;

DatabaseAdapter get adapter => context.adapter;
Migrator get migrator => context.migrator;
MockNotifier get notifier => context.notifier;
TableInfo get tableInfo => context.tableInfo;
DateTime get timestamp => context.timestamp;
SatelliteProcess get satellite => context.satellite;
MockSatelliteClient get client => context.client;
String get dbName => context.dbName;
String get namespace => context.namespace;

SatelliteOpts opts(String namespace) => satelliteDefaults(namespace).copyWith(
      minSnapshotWindow: const Duration(milliseconds: 80),
      pollingInterval: const Duration(milliseconds: 500),
    );

void processTimingTests({
  required SatelliteTestContext Function() getContext,
}) {
  setUp(() async {
    context = getContext();
  });

  test('throttled snapshot respects window', () async {
    await context.runMigrations();

    satellite.setAuthState(context.authState);
    await satellite.throttledSnapshot?.call();
    final numNotifications = notifier.notifications.length;

    const sql = "INSERT INTO parent(id) VALUES ('1'),('2')";
    await adapter.run(Statement(sql));
    await satellite.throttledSnapshot?.call();

    expect(notifier.notifications.length, numNotifications);

    await Future<void>.delayed(opts(namespace).minSnapshotWindow);

    expect(notifier.notifications.length, numNotifications + 1);
  });
}
