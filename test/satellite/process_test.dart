import 'dart:io';

import 'package:electric_client/auth/mock.dart';
import 'package:electric_client/electric/adapter.dart';
import 'package:electric_client/electric/sqlite3_adapter.dart';
import 'package:electric_client/migrators/bundle.dart';
import 'package:electric_client/migrators/migrators.dart';
import 'package:electric_client/notifiers/mock.dart';
import 'package:electric_client/notifiers/notifiers.dart';
import 'package:electric_client/satellite/config.dart';
import 'package:electric_client/satellite/mock.dart';
import 'package:electric_client/satellite/oplog.dart';
import 'package:electric_client/satellite/process.dart';
import 'package:electric_client/util/random.dart';
import 'package:electric_client/util/tablename.dart';
import 'package:electric_client/util/types.dart' hide Change;
import 'package:sqlite3/sqlite3.dart';
import 'package:test/test.dart';

import '../support/migrations.dart';
import '../support/satellite_helpers.dart';
import '../util/io.dart';
import '../util/sqlite_errors.dart';

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

final opts = kSatelliteDefaults.copyWith(
  minSnapshotWindow: 40,
  pollingInterval: 200,
);

final satelliteConfig = SatelliteConfig(
  app: 'test',
  env: 'default',
);

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

  test('start creates system tables', () async {
    await satellite.start(null);

    const sql = "select name from sqlite_master where type = 'table'";
    final rows = await adapter.query(Statement(sql));
    final names = rows.map((row) => row['name']! as String).toList();

    expect(names, contains('_electric_oplog'));
  });

  test('load metadata', () async {
    await runMigrations();

    final meta = await loadSatelliteMetaTable(adapter);
    expect(meta, {
      "compensations": 0,
      "lastAckdRowId": '0',
      "lastSentRowId": '0',
      "lsn": '',
      "clientId": '',
      "token":
          'INITIAL_INVALID_TOKEN', // we need some value here for auth service
      "refreshToken": '',
    });
  });

  test('set persistent client id', () async {
    await satellite.start(null);
    final clientId1 = satellite.authState!.clientId;
    await satellite.stop();

    await satellite.start(null);

    final clientId2 = satellite.authState!.clientId;

    expect(clientId1, clientId2);
  });

  test('connect saves new token', () async {
    await runMigrations();

    final initToken = await satellite.getMeta('token');
    final connectionWrapper = await satellite.start(null);
    await connectionWrapper.connectionFuture;
    final receivedToken = await satellite.getMeta('token');

    expect(initToken, isNot(receivedToken));
  });

  test('cannot UPDATE primary key', () async {
    await runMigrations();

    await adapter.run(Statement("INSERT INTO parent(id) VALUES ('1'),('2')"));

    await expectLater(
      adapter.run(Statement("UPDATE parent SET id='3' WHERE id = '1'")),
      throwsA(
        isA<SqliteException>().having(
          (SqliteException e) => e.extendedResultCode,
          "code",
          SqliteErrors.SQLITE_CONSTRAINT_TRIGGER,
        ),
      ),
    );
  });

  test('snapshot works', () async {
    await runMigrations();
    await satellite.setAuthState(null);

    await adapter.run(Statement("INSERT INTO parent(id) VALUES ('1'),('2')"));

    final snapshotTimestamp = await satellite.performSnapshot();

    final clientId = satellite.authState!.clientId;
    final shadowTags = encodeTags([generateTag(clientId, snapshotTimestamp)]);

    final shadowRows = await adapter.query(
      Statement("SELECT tags FROM _electric_shadow"),
    );
    expect(shadowRows.length, 2);
    for (final row in shadowRows) {
      expect(row['tags'], shadowTags);
    }

    expect(notifier.notifications.length, 1);

    final changes = (notifier.notifications[0] as ChangeNotification).changes;
    final expectedChange = Change(
      qualifiedTablename: const QualifiedTablename('main', 'parent'),
      rowids: [1, 2],
    );

    expect(changes, [expectedChange]);
  });

  test('starting and stopping the process works', () async {
    await runMigrations();

    await adapter.run(Statement("INSERT INTO parent(id) VALUES ('1'),('2')"));

    await satellite.start(null);

    await Future<void>.delayed(Duration(milliseconds: opts.pollingInterval));

    expect(notifier.notifications.length, 1);

    await adapter.run(Statement("INSERT INTO parent(id) VALUES ('3'),('4')"));
    await Future<void>.delayed(Duration(milliseconds: opts.pollingInterval));

    expect(notifier.notifications.length, 2);

    await satellite.stop();
    await adapter.run(Statement("INSERT INTO parent(id) VALUES ('5'),('6')"));
    await Future<void>.delayed(Duration(milliseconds: opts.pollingInterval));

    expect(notifier.notifications.length, 2);

    await satellite.start(null);
    await Future<void>.delayed(Duration.zero);

    expect(notifier.notifications.length, 3);
  });

  test('snapshots on potential data change', () async {
    await runMigrations();

    await adapter.run(Statement("INSERT INTO parent(id) VALUES ('1'),('2')"));

    expect(notifier.notifications.length, 0);

    notifier.potentiallyChanged();

    expect(notifier.notifications.length, 1);
  });

  // INSERT after DELETE shall nullify all non explicitly set columns
// If last operation is a DELETE, concurrent INSERT shall resurrect deleted
// values as in 'INSERT wins over DELETE and restored deleted values'
  test('snapshot of INSERT after DELETE', () async {
    await runMigrations();

    await adapter.run(
      Statement(
        "INSERT INTO parent(id, value) VALUES (1,'val1')",
      ),
    );
    await adapter.run(Statement("DELETE FROM parent WHERE id=1"));
    await adapter.run(Statement("INSERT INTO parent(id) VALUES (1)"));

    await satellite.setAuthState(null);
    await satellite.performSnapshot();
    final entries = await satellite.getEntries();
    final clientId = satellite.authState!.clientId;

    final merged = localOperationsToTableChanges(entries, (DateTime timestamp) {
      return generateTag(clientId, timestamp);
    });
    final opLogTableChange = merged['main.parent']!['1']!;
    final keyChanges = opLogTableChange.oplogEntryChanges;
    final resultingValue = keyChanges.changes["value"]!.value;
    expect(resultingValue, null);
  });

  test('take snapshot and merge local wins', () async {
    await runMigrations();

    final incomingTs = DateTime.now().millisecondsSinceEpoch - 1;
    final incomingEntry = generateRemoteOplogEntry(
      tableInfo,
      'main',
      'parent',
      OpType.insert,
      incomingTs,
      encodeTags([
        generateTag('remote', DateTime.fromMillisecondsSinceEpoch(incomingTs))
      ]),
      newValues: {
        "id": 1,
        "value": 'incoming',
      },
      oldValues: {},
    );
    await adapter.run(
      Statement(
        "INSERT INTO parent(id, value, other) VALUES (1, 'local', 1)",
      ),
    );

    await satellite.setAuthState(null);
    final localTime = await satellite.performSnapshot();
    final clientId = satellite.authState!.clientId;

    final local = await satellite.getEntries();
    final localTimestamp =
        DateTime.parse(local[0].timestamp).millisecondsSinceEpoch;
    final merged = satellite.mergeEntries(clientId, local, 'remote', [
      incomingEntry,
    ]);
    final item = merged['main.parent']!['1'];

    expect(
      item,
      ShadowEntryChanges(
        namespace: 'main',
        tablename: 'parent',
        primaryKeyCols: {"id": 1},
        optype: ChangesOpType.upsert,
        changes: {
          "id": OplogColumnChange(1, localTimestamp),
          "value": OplogColumnChange('local', localTimestamp),
          "other": OplogColumnChange(1, localTimestamp),
        },
        tags: [
          generateTag(clientId, localTime),
          generateTag(
            'remote',
            DateTime.fromMillisecondsSinceEpoch(incomingTs),
          ),
        ],
      ),
    );
  });

  test('take snapshot and merge incoming wins', () async {
    await runMigrations();

    await adapter.run(Statement(
      "INSERT INTO parent(id, value, other) VALUES (1, 'local', 1)",
    ));

    await satellite.setAuthState();
    final clientId = satellite.authState!.clientId;
    await satellite.performSnapshot();

    final local = await satellite.getEntries();
    final localTimestamp = DateTime.parse(local[0].timestamp);

    final incomingTs = DateTime.fromMillisecondsSinceEpoch(
        localTimestamp.millisecondsSinceEpoch + 1);

    final incomingEntry = generateRemoteOplogEntry(
      tableInfo,
      'main',
      'parent',
      OpType.insert,
      incomingTs.millisecondsSinceEpoch,
      genEncodedTags("remote", [incomingTs]),
      newValues: {
        "id": 1,
        "value": 'incoming',
      },
      oldValues: {},
    );

    final merged = satellite.mergeEntries(clientId, local, 'remote', [
      incomingEntry,
    ]);
    final item = merged['main.parent']!['1'];

    expect(
      item,
      ShadowEntryChanges(
        namespace: 'main',
        tablename: 'parent',
        primaryKeyCols: {"id": 1},
        optype: ChangesOpType.upsert,
        changes: {
          "id": OplogColumnChange(1, incomingTs.millisecondsSinceEpoch),
          "value":
              OplogColumnChange('incoming', incomingTs.millisecondsSinceEpoch),
          "other": OplogColumnChange(1, localTimestamp.millisecondsSinceEpoch),
        },
        tags: [
          generateTag(clientId, localTimestamp),
          generateTag('remote', incomingTs),
        ],
      ),
    );
  });

  test('apply does not add anything to oplog', () async {
    await runMigrations();
    await adapter.run(
      Statement(
        "INSERT INTO parent(id, value, other) VALUES (1, 'local', null)",
      ),
    );

    await satellite.setAuthState();
    final clientId = satellite.authState!.clientId;

    final localTimestamp = await satellite.performSnapshot();

    final incomingTs = DateTime.now();
    final incomingEntry = generateRemoteOplogEntry(
      tableInfo,
      'main',
      'parent',
      OpType.insert,
      incomingTs.millisecondsSinceEpoch,
      genEncodedTags('remote', [incomingTs]),
      newValues: {
        "id": 1,
        "value": 'incoming',
        "other": 1,
      },
      oldValues: {},
    );

    await satellite.apply([incomingEntry], 'remote', []);
    await satellite.performSnapshot();

    const sql = 'SELECT * from parent WHERE id=1';
    final row = (await adapter.query(Statement(sql)))[0];
    expect(row['value']! as String, 'incoming');
    expect(row['other']! as int, 1);

    final localEntries = await satellite.getEntries();
    final shadowEntry =
        await satellite.getOplogShadowEntry(oplog: localEntries[0]);

    expect(
      encodeTags([
        generateTag(clientId, localTimestamp),
        generateTag('remote', incomingTs),
      ]),
      shadowEntry[0].tags,
    );

    //t.deepEqual(shadowEntries, shadowEntries2)
    expect(localEntries.length, 1);
  });
}
