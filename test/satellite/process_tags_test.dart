import 'dart:io';

import 'package:electric_client/auth/mock.dart';
import 'package:electric_client/electric/adapter.dart';
import 'package:electric_client/electric/sqlite3_adapter.dart';
import 'package:electric_client/migrators/bundle.dart';
import 'package:electric_client/migrators/migrators.dart';
import 'package:electric_client/notifiers/mock.dart';
import 'package:electric_client/notifiers/notifiers.dart';
import 'package:electric_client/satellite/client.dart';
import 'package:electric_client/satellite/config.dart';
import 'package:electric_client/satellite/mock.dart';
import 'package:electric_client/satellite/process.dart';
import 'package:electric_client/sockets/io.dart';
import 'package:electric_client/util/random.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import '../support/migrations.dart';
import 'server_ws_stub.dart';

// TODO: Revisar
// const opts = Object.assign({}, satelliteDefaults, {
//   minSnapshotWindow: 40,
//   pollingInterval: 200,
// })

final opts = kSatelliteDefaults;

final satelliteConfig = SatelliteConfig(
  app: 'test',
  env: 'default',
);

late Database db;
late DatabaseAdapter adapter;
late Migrator migrator;
late MockNotifier notifier;

void main() {
  setUp(() async {
    await Directory(".tmp").create(recursive: true);

    final dbName = '.tmp/test-${randomValue()}.db';
    db = sqlite3.open(dbName);
    adapter = SqliteAdapter(db);
    migrator = BundleMigrator(adapter: adapter, migrations: kTestMigrations);
    notifier = MockNotifier(dbName);
    final client = MockSatelliteClient();
    final console = MockConsoleClient();
    final satellite = SatelliteProcess(
      dbName: dbName,
      adapter: adapter,
      migrator: migrator,
      notifier: notifier,
      client: client,
      console: console,
      config: satelliteConfig,
      opts: opts,
    );
  });

//   tearDown(() async {
//     await client.close();
//     await server.close();
//   });
}
