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
import 'package:electric_client/satellite/oplog.dart';
import 'package:electric_client/satellite/process.dart';
import 'package:electric_client/sockets/io.dart';
import 'package:electric_client/util/random.dart';
import 'package:electric_client/util/types.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import '../support/migrations.dart';
import '../support/satellite_helpers.dart';
import '../util/io.dart';
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

  test('basic rules for setting tags', () async {
    await runMigrations();

    await satellite.setAuthState(null);
    final clientId = satellite.authState!.clientId;

    await adapter.run(Statement(
      "INSERT INTO parent(id, value, other) VALUES (1, 'local', null)",
    ));

    final txDate1 = await satellite.performSnapshot();
    var shadow = await satellite.getOplogShadowEntry();
    expect(shadow.length, 1);
    expect(shadow[0].tags, genEncodedTags(clientId, [txDate1]));

    await adapter.run(
      Statement("UPDATE parent SET value = 'local1', other = 'other1' WHERE id = 1"),
    );

    final txDate2 = await satellite.performSnapshot();
    shadow = await satellite.getOplogShadowEntry();
    expect(shadow.length, 1);
    expect(shadow[0].tags, genEncodedTags(clientId, [txDate2]));

    await adapter.run(Statement(
      "UPDATE parent SET value = 'local2', other = 'other2' WHERE id = 1",
    ));

    final txDate3 = await satellite.performSnapshot();
    shadow = await satellite.getOplogShadowEntry();
    expect(shadow.length, 1);
    expect(shadow[0].tags, genEncodedTags(clientId, [txDate3]));

    await adapter.run(Statement(
      "DELETE FROM parent WHERE id = 1",
    ));

    final txDate4 = await satellite.performSnapshot();
    shadow = await satellite.getOplogShadowEntry();
    expect(shadow.length, 0);

    final entries = await satellite.getEntries();
    //console.log(entries)
    expect(entries[0].clearTags, encodeTags([]));
    expect(entries[1].clearTags, genEncodedTags(clientId, [txDate1]));
    expect(entries[2].clearTags, genEncodedTags(clientId, [txDate2]));
    expect(entries[3].clearTags, genEncodedTags(clientId, [txDate3]));

    expect(txDate1, isNot(txDate2));
    expect(txDate2, isNot(txDate3));
    expect(txDate3, isNot(txDate4));
  });
}
