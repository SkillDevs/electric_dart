import 'dart:io';

import 'package:electric_client/auth/mock.dart';
import 'package:electric_client/electric/adapter.dart';
import 'package:electric_client/electric/sqlite3_adapter.dart';
import 'package:electric_client/migrators/bundle.dart';
import 'package:electric_client/migrators/migrators.dart';
import 'package:electric_client/notifiers/mock.dart';
import 'package:electric_client/satellite/config.dart';
import 'package:electric_client/satellite/mock.dart';
import 'package:electric_client/satellite/process.dart';
import 'package:electric_client/util/random.dart';
import 'package:electric_client/util/types.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import '../support/migrations.dart';
import '../support/satellite_helpers.dart';
import '../util/io.dart';

final opts = kSatelliteDefaults.copyWith(
  minSnapshotWindow: const Duration(milliseconds: 80),
  pollingInterval: const Duration(milliseconds: 500),
);

final satelliteConfig = SatelliteConfig(
  app: 'test',
  env: 'default',
);

late Database db;
late DatabaseAdapter adapter;
late Migrator migrator;
late MockNotifier notifier;
late TableInfo tableInfo;
late int timestamp;
late SatelliteProcess satellite;
late MockSatelliteClient client;
late String dbName;

Future<void> runMigrations() async {
  await migrator.up();
}

void main() {
  setUp(() async {
    await Directory(".tmp").create(recursive: true);

    dbName = '.tmp/test-${randomValue()}.db';
    db = sqlite3.open(dbName);
    adapter = SqliteAdapter(db);
    migrator = BundleMigrator(adapter: adapter, migrations: kTestMigrations);
    notifier = MockNotifier(dbName);
    client = MockSatelliteClient();
    final console = MockConsoleClient();
    satellite = SatelliteProcess(
      dbName: dbName,
      adapter: adapter,
      migrator: migrator,
      notifier: notifier,
      client: client,
      console: console,
      config: satelliteConfig,
      opts: opts,
    );

    tableInfo = initTableInfo();
    timestamp = DateTime.now().millisecondsSinceEpoch;
  });

  tearDown(() async {
    await removeFile(dbName);
    await removeFile("$dbName-journal");

    await satellite.stop();
  });

  test('throttled snapshot respects window', () async {
    await runMigrations();

    await satellite.setAuthState(null);
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
