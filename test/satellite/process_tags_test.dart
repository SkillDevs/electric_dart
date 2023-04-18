import 'dart:convert';
import 'dart:io';

import 'package:electric_client/auth/mock.dart';
import 'package:electric_client/electric/adapter.dart';
import 'package:electric_client/electric/sqlite3_adapter.dart';
import 'package:electric_client/migrators/bundle.dart';
import 'package:electric_client/migrators/migrators.dart';
import 'package:electric_client/notifiers/mock.dart';
import 'package:electric_client/satellite/config.dart';
import 'package:electric_client/satellite/mock.dart';
import 'package:electric_client/satellite/oplog.dart';
import 'package:electric_client/satellite/process.dart';
import 'package:electric_client/util/random.dart';
import 'package:electric_client/util/types.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import '../support/migrations.dart';
import '../support/satellite_helpers.dart';
import '../util/io.dart';

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

  test('TX1=INSERT, TX2=DELETE, TX3=INSERT, ack TX1', () async {
    await runMigrations();
    await satellite.setAuthState(null);

    final clientId = satellite.authState!.clientId;

    // Local INSERT
    final stmts1 = Statement(
      "INSERT INTO parent (id, value, other) VALUES (?, ?, ?)",
      <Object?>['1', 'local', null],
    );
    await adapter.runInTransaction([stmts1]);
    final txDate1 = await satellite.performSnapshot();

    final localEntries1 = await satellite.getEntries();
    final shadowEntry1 = await satellite.getOplogShadowEntry(oplog: localEntries1[0]);

    // shadow tag is time of snapshot
    final tag1 = genEncodedTags(clientId, [txDate1]);
    expect(tag1, shadowEntry1[0].tags);
    // clearTag is empty
    final localEntries10 = localEntries1[0];
    expect(localEntries10.clearTags, json.encode([]));
    expect(localEntries10.timestamp, txDate1.toIso8601String());

    // Local DELETE
    final stmts2 = Statement(
      "DELETE FROM parent WHERE id=?",
      ['1'],
    );
    await adapter.runInTransaction([stmts2]);
    final txDate2 = await satellite.performSnapshot();

    final localEntries2 = await satellite.getEntries();
    final shadowEntry2 = await satellite.getOplogShadowEntry(oplog: localEntries2[1]);

    // shadowTag is empty
    expect(0, shadowEntry2.length);
    // clearTags contains previous shadowTag
    final localEntry21 = localEntries2[1];

    expect(localEntry21.clearTags, tag1);
    expect(localEntry21.timestamp, txDate2.toIso8601String());

    // Local INSERT
    final stmts3 = Statement(
      "INSERT INTO parent (id, value, other) VALUES (?, ?, ?)",
      <Object?>['1', 'local', null],
    );
    await adapter.runInTransaction([stmts3]);
    final txDate3 = await satellite.performSnapshot();

    final localEntries3 = await satellite.getEntries();
    final shadowEntry3 = await satellite.getOplogShadowEntry(oplog: localEntries3[1]);

    final tag3 = genEncodedTags(clientId, [txDate3]);
    // shadow tag is tag3
    expect(tag3, shadowEntry3[0].tags);

    // clearTags is empty after a DELETE
    final localEntry32 = localEntries3[2];

    expect(localEntry32.clearTags, json.encode([]));
    expect(localEntry32.timestamp, txDate3.toIso8601String());

    // apply incomig operation (local operation ack)
    final ackEntry = generateRemoteOplogEntry(
      tableInfo,
      'main',
      'parent',
      OpType.insert,
      txDate1.millisecondsSinceEpoch,
      tag1,
      newValues: {
        "id": 1,
        "value": 'local',
        "other": null,
      },
      oldValues: {},
    );

    await satellite.applyTransactionInternal(
      clientId,
      txDate1,
      [ackEntry],
      [],
    );

    // validat that garbage collection have triggered
    expect(2, (await satellite.getEntries()).length);

    final shadow = await satellite.getOplogShadowEntry();
    expect(shadow[0].tags, genEncodedTags(clientId, [txDate3]),
        reason: 'error: tag1 was reintroduced after merging acked operation');
  });

  test('remote tx (INSERT) concurrently with local tx (INSERT -> DELETE)', () async {
    await runMigrations();
    await satellite.setAuthState(null);

    final List<Statement> stmts = [];

    // For this key we will choose remote Tx, such that: Local TM > Remote TX
    stmts.add(Statement(
      "INSERT INTO parent (id, value, other) VALUES (?, ?, ?);",
      ['1', 'local', null],
    ));
    stmts.add(Statement("DELETE FROM parent WHERE id = 1"));
    // For this key we will choose remote Tx, such that: Local TM < Remote TX
    stmts.add(Statement(
      "INSERT INTO parent (id, value, other) VALUES (?, ?, ?);",
      ['2', 'local', null],
    ));
    stmts.add(Statement("DELETE FROM parent WHERE id = 2"));
    await adapter.runInTransaction(stmts);

    final txDate1 = await satellite.performSnapshot();

    final prevTs = txDate1.millisecondsSinceEpoch - 1;
    final nextTs = txDate1.millisecondsSinceEpoch + 1;

    final prevEntry = generateRemoteOplogEntry(
      tableInfo,
      'main',
      'parent',
      OpType.insert,
      prevTs,
      genEncodedTags('remote', [DateTime.fromMillisecondsSinceEpoch(prevTs)]),
      newValues: {
        "id": 1,
        "value": 'remote',
        "other": 1,
      },
      oldValues: {},
    );
    final nextEntry = generateRemoteOplogEntry(
      tableInfo,
      'main',
      'parent',
      OpType.insert,
      nextTs,
      genEncodedTags('remote', [DateTime.fromMillisecondsSinceEpoch(nextTs)]),
      newValues: {
        "id": 2,
        "value": 'remote',
        "other": 2,
      },
      oldValues: {},
    );

    await satellite.apply([prevEntry], 'remote', []);
    await satellite.apply([nextEntry], 'remote', []);

    final shadow = await satellite.getOplogShadowEntry();
    final expectedShadow = [
      ShadowEntry(
        namespace: 'main',
        tablename: 'parent',
        primaryKey: "1",
        tags: genEncodedTags('remote', [DateTime.fromMillisecondsSinceEpoch(prevTs)]),
      ),
      ShadowEntry(
        namespace: 'main',
        tablename: 'parent',
        primaryKey: "2",
        tags: genEncodedTags('remote', [DateTime.fromMillisecondsSinceEpoch(nextTs)]),
      ),
    ];
    expect(shadow, expectedShadow);

    //let entries= await satellite._getEntries()
    //console.log(entries)
    final userTable = await adapter.query(Statement("SELECT * FROM parent;"));
    //console.log(table)

    // In both cases insert wins over delete, but
    // for id = 1 CR picks local data before delete, while
    // for id = 2 CR picks remote data
    final List<Map<String, Object?>> expectedUserTable = [
      {"id": 1, "value": 'local', "other": null},
      {"id": 2, "value": 'remote', "other": 2},
    ];

    expect(userTable, expectedUserTable);
  });
}
