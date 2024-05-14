// ignore_for_file: unreachable_from_main

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:electricsql/electricsql.dart';
import 'package:electricsql/src/migrators/migrators.dart';
import 'package:electricsql/src/migrators/query_builder/query_builder.dart';
import 'package:electricsql/src/notifiers/mock.dart';
import 'package:electricsql/src/notifiers/notifiers.dart';
import 'package:electricsql/src/satellite/config.dart';
import 'package:electricsql/src/satellite/merge.dart';
import 'package:electricsql/src/satellite/mock.dart';
import 'package:electricsql/src/satellite/oplog.dart';
import 'package:electricsql/src/satellite/process.dart';
import 'package:electricsql/src/satellite/shapes/manager.dart';
import 'package:electricsql/src/satellite/shapes/types.dart';
import 'package:electricsql/src/util/common.dart';
import 'package:electricsql/src/util/encoders/encoders.dart';
import 'package:electricsql/src/util/tablename.dart';
import 'package:electricsql/src/util/types.dart' hide Change;
import 'package:electricsql/src/util/types.dart' as t;
import 'package:fixnum/fixnum.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart';

import '../support/matchers.dart';
import '../support/satellite_helpers.dart';
import '../util/db_errors.dart';
import 'common.dart';

late SatelliteTestContext context;

Future<void> runMigrations() async {
  await context.runMigrations();
}

DatabaseAdapter get adapter => context.adapter;
Migrator get migrator => context.migrator;
MockNotifier get notifier => context.notifier;
TableInfo get tableInfo => context.tableInfo;
DateTime get timestamp => context.timestamp;
SatelliteProcess get satellite => context.satellite;
MockSatelliteClient get client => context.client;
String get dbName => context.dbName;
AuthState get authState => context.authState;
AuthConfig get authConfig => context.authConfig;
String get token => context.token;
SatelliteOpts get opts => context.opts;

late QueryBuilder _globalBuilder;

const parentRecord = <String, Object?>{
  'id': 1,
  'value': 'incoming',
  'other': 1,
};

const childRecord = <String, Object?>{
  'id': 1,
  'parent': 1,
};

Future<({Future<void> connectionFuture})> startSatellite(
  SatelliteProcess satellite,
  AuthConfig authConfig,
  String token,
) async {
  await satellite.start(authConfig);
  satellite.setToken(token);
  final connectionFuture = satellite.connectWithBackoff();
  return (connectionFuture: connectionFuture);
}

Object? dialectValue(
  Object? sqliteValue,
  Object? pgValue,
) {
  if (_globalBuilder.dialect == Dialect.sqlite) {
    return sqliteValue;
  }
  return pgValue;
}

@isTestGroup
void processTests({
  required SatelliteTestContext Function() getContext,
  required String namespace,
  required QueryBuilder builder,
  required String qualifiedParentTableName,
  required GetMatchingShadowEntries getMatchingShadowEntries,
}) {
  setUp(() {
    context = getContext();
    _globalBuilder = builder;
  });

  test('start creates system tables', () async {
    await satellite.start(authConfig);

    final rows = await adapter.query(builder.getLocalTableNames());
    final names = rows.map((row) => row['name']! as String).toList();

    expect(names, contains('_electric_oplog'));
  });

  test('load metadata', () async {
    await runMigrations();

    final meta = await loadSatelliteMetaTable(adapter, namespace);
    expect(meta, {
      'compensations': dialectValue(1, '1'),
      'lsn': '',
      'clientId': '',
      'subscriptions': '',
      'seenAdditionalData': '',
    });
  });

  test('set persistent client id', () async {
    final conn = await startSatellite(satellite, authConfig, token);
    final clientId1 = satellite.authState!.clientId;
    await conn.connectionFuture;
    await satellite.stop();

    final conn2 = await startSatellite(satellite, authConfig, token);
    await conn2.connectionFuture;

    final clientId2 = satellite.authState!.clientId;

    expect(clientId1, clientId2);
    // Give time for the starting performSnapshot to finish
    // Otherwise the database might not exist because the test ended
    await Future<void>.delayed(const Duration(milliseconds: 100));
  });

  test('can use user_id in JWT', () async {
    // Doesn't throw
    final conn = await startSatellite(
      satellite,
      authConfig,
      insecureAuthToken({'user_id': 'test-userA'}),
    );
    await conn.connectionFuture;
  });

  test('can use sub in JWT', () async {
    // Doesn't throw
    final conn = await startSatellite(
      satellite,
      authConfig,
      insecureAuthToken({'sub': 'test-userB'}),
    );
    await conn.connectionFuture;
  });

  test('require user_id or sub in JWT', () async {
    expect(
      () => startSatellite(
        satellite,
        authConfig,
        insecureAuthToken({'custom_user_claim': 'test-userC'}),
      ),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          'Token does not contain a sub or user_id claim',
        ),
      ),
    );
  });

  test('cannot update user id', () async {
    final conn = await startSatellite(satellite, authConfig, token);
    expect(
      () => satellite.setToken(insecureAuthToken({'sub': 'test-user2'})),
      throwsA(
        isA<ArgumentError>().having(
          (e) => e.message,
          'message',
          "Can't change user ID when reconnecting. Previously connected with user ID 'test-user' but trying to reconnect with user ID 'test-user2'",
        ),
      ),
    );
    await conn.connectionFuture;
  });

  test('cannot UPDATE primary key', () async {
    await runMigrations();

    await adapter.run(Statement("INSERT INTO parent(id) VALUES ('1'),('2')"));

    await expectLater(
      adapter.run(Statement("UPDATE parent SET id='3' WHERE id = '1'")),
      throwsA(
        isADbExceptionWithCode(
          builder.dialect,
          SqliteErrors.SQLITE_CONSTRAINT_TRIGGER,
          PostgresErrors.PG_CONSTRAINT_TRIGGER,
        ),
      ),
    );
  });

  test('snapshot works', () async {
    await runMigrations();
    satellite.setAuthState(authState);

    await adapter.run(Statement("INSERT INTO parent(id) VALUES ('1'),('2')"));

    final snapshotTimestamp = await satellite.performSnapshot();

    final clientId = satellite.authState!.clientId;
    final shadowTags = encodeTags([generateTag(clientId, snapshotTimestamp)]);

    final shadowRows = await adapter.query(
      Statement('SELECT tags FROM _electric_shadow'),
    );
    expect(shadowRows.length, 2);
    for (final row in shadowRows) {
      expect(row['tags'], shadowTags);
    }

    expect(notifier.notifications.length, 1);

    final changes = (notifier.notifications[0] as ChangeNotification).changes;
    final expectedChange = Change(
      qualifiedTablename: QualifiedTablename(namespace, 'parent'),
      rowids: [1, 2],
      recordChanges: [
        RecordChange(
          primaryKey: {'id': 1},
          type: RecordChangeType.insert,
        ),
        RecordChange(
          primaryKey: {'id': 2},
          type: RecordChangeType.insert,
        ),
      ],
    );

    expect(changes, [expectedChange]);
  });

  test('(regression) performSnapshot cant be called concurrently', () async {
    await runMigrations();
    satellite.setAuthState(authState);

    satellite.updateDatabaseAdapter(
      SlowDatabaseAdapter(satellite.adapter),
    );

    await expectLater(
      () async {
        final p1 = satellite.performSnapshot();
        final p2 = satellite.performSnapshot();
        await Future.wait([p1, p2]);
      }(),
      throwsA(
        isA<SatelliteException>()
            .having(
              (e) => e.code,
              'code',
              SatelliteErrorCode.internal,
            )
            .having((e) => e.message, 'message', 'already performing snapshot'),
      ),
    );
  });

  test('(regression) throttle with mutex prevents race when snapshot is slow',
      () async {
    await runMigrations();
    satellite.setAuthState(authState);

    // delay termination of _performSnapshot
    satellite.updateDatabaseAdapter(
      SlowDatabaseAdapter(satellite.adapter),
    );

    final p1 = satellite.throttledSnapshot();

    final completer = Completer<void>();
    Timer(const Duration(milliseconds: 50), () async {
      // call snapshot after throttle time has expired
      await satellite.throttledSnapshot();
      completer.complete();
    });
    final p2 = completer.future;

    // They don't throw
    await p1;
    await p2;
  });

  test('starting and stopping the process works', () async {
    await runMigrations();

    await adapter.run(Statement("INSERT INTO parent(id) VALUES ('1'),('2')"));

    final conn = await startSatellite(satellite, authConfig, token);
    await conn.connectionFuture;

    await Future<void>.delayed(opts.pollingInterval);

    // connect, 1st txn
    expect(notifier.notifications.length, 2);

    await adapter.run(Statement("INSERT INTO parent(id) VALUES ('3'),('4')"));
    await Future<void>.delayed(opts.pollingInterval);

    // 2nd txm
    expect(notifier.notifications.length, 3);

    await satellite.stop();
    await adapter.run(Statement("INSERT INTO parent(id) VALUES ('5'),('6')"));
    await Future<void>.delayed(opts.pollingInterval);

    // no txn notified
    expect(notifier.notifications.length, 4);

    final conn1 = await startSatellite(satellite, authConfig, token);
    await conn1.connectionFuture;
    await Future<void>.delayed(opts.pollingInterval);

    // connect, 4th txn
    expect(notifier.notifications.length, 6);
  });

  test('snapshots on potential data change', () async {
    await runMigrations();

    await adapter.run(Statement("INSERT INTO parent(id) VALUES ('1'),('2')"));

    expect(notifier.notifications.length, 0);

    notifier.potentiallyChanged();

    expect(notifier.notifications.length, 1);
  });

  test('snapshot of INSERT with blob/Uint8Array', () async {
    await runMigrations();

    final blob = Uint8List.fromList([1, 2, 255, 244, 160, 1]);

    await adapter.run(
      Statement(
        'INSERT INTO "blobTable"(value) VALUES (${builder.makePositionalParam(1)})',
        [blob],
      ),
    );

    satellite.setAuthState(authState);
    await satellite.performSnapshot();
    final entries = await satellite.getEntries();
    final clientId = satellite.authState!.clientId;

    final merged = localOperationsToTableChanges(
      entries,
      (timestamp) {
        return generateTag(clientId, timestamp);
      },
      kTestRelations,
    );
    final qualifiedTableName =
        QualifiedTablename(namespace, 'blobTable').toString();

    final opLogTableChange =
        merged[qualifiedTableName]!['{"value":"${blobToHexString(blob)}"}']!;
    final keyChanges = opLogTableChange.oplogEntryChanges;
    final resultingValue = keyChanges.changes['value']!.value;
    expect(resultingValue, blob);
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
    await adapter.run(Statement('DELETE FROM parent WHERE id=1'));
    await adapter.run(Statement('INSERT INTO parent(id) VALUES (1)'));

    satellite.setAuthState(authState);
    await satellite.performSnapshot();
    final entries = await satellite.getEntries();
    final clientId = satellite.authState!.clientId;

    final merged = localOperationsToTableChanges(
      entries,
      (DateTime timestamp) {
        return generateTag(clientId, timestamp);
      },
      kTestRelations,
    );
    final opLogTableChange = merged[qualifiedParentTableName]!['{"id":1}']!;
    final keyChanges = opLogTableChange.oplogEntryChanges;
    final resultingValue = keyChanges.changes['value']!.value;
    expect(resultingValue, null);
  });

  test('snapshot of INSERT with bigint', () async {
    await runMigrations();

    await adapter.run(
      Statement(
        'INSERT INTO "bigIntTable"(value) VALUES (1)',
      ),
    );

    satellite.setAuthState(authState);
    await satellite.performSnapshot();
    final entries = await satellite.getEntries();
    final clientId = satellite.authState!.clientId;

    final merged = localOperationsToTableChanges(
      entries,
      (timestamp) {
        return generateTag(clientId, timestamp);
      },
      kTestRelations,
    );
    final qualifiedTableName =
        QualifiedTablename(namespace, 'bigIntTable').toString();
    final opLogTableChange = merged[qualifiedTableName]!['{"value":"1"}']!;
    final keyChanges = opLogTableChange.oplogEntryChanges;
    final resultingValue = keyChanges.changes['value']!.value;
    expect(resultingValue, BigInt.from(1));
  });

  test('take snapshot and merge local wins', () async {
    await runMigrations();

    final incomingTs = DateTime.now().millisecondsSinceEpoch - 1;
    final incomingEntry = generateRemoteOplogEntry(
      tableInfo,
      namespace,
      'parent',
      OpType.insert,
      incomingTs,
      encodeTags([
        generateTag('remote', DateTime.fromMillisecondsSinceEpoch(incomingTs)),
      ]),
      newValues: {
        'id': 1,
        'value': 'incoming',
      },
      oldValues: {},
    );
    await adapter.run(
      Statement(
        "INSERT INTO parent(id, value, other) VALUES (1, 'local', 1)",
      ),
    );

    satellite.setAuthState(authState);
    final localTime = await satellite.performSnapshot();
    final clientId = satellite.authState!.clientId;

    final local = await satellite.getEntries();
    final localTimestamp =
        DateTime.parse(local[0].timestamp).millisecondsSinceEpoch;
    final merged = mergeEntries(
      clientId,
      local,
      'remote',
      [incomingEntry],
      kTestRelations,
    );
    final item = merged[qualifiedParentTableName]!['{"id":1}'];

    expect(
      item,
      ShadowEntryChanges(
        namespace: namespace,
        tablename: 'parent',
        primaryKeyCols: {'id': 1},
        optype: ChangesOpType.upsert,
        changes: {
          'id': OplogColumnChange(1, localTimestamp),
          'value': OplogColumnChange('local', localTimestamp),
          'other': OplogColumnChange(1, localTimestamp),
        },
        fullRow: {
          'id': 1,
          'value': 'local',
          'other': 1,
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

    await adapter.run(
      Statement(
        "INSERT INTO parent(id, value, other) VALUES (1, 'local', 1)",
      ),
    );

    satellite.setAuthState(authState);
    final clientId = satellite.authState!.clientId;
    await satellite.performSnapshot();

    final local = await satellite.getEntries();
    final localTimestamp = DateTime.parse(local[0].timestamp);

    final incomingTs = DateTime.fromMillisecondsSinceEpoch(
      localTimestamp.millisecondsSinceEpoch + 1,
    );

    final incomingEntry = generateRemoteOplogEntry(
      tableInfo,
      namespace,
      'parent',
      OpType.insert,
      incomingTs.millisecondsSinceEpoch,
      genEncodedTags('remote', [incomingTs]),
      newValues: {
        'id': 1,
        'value': 'incoming',
      },
      oldValues: {},
    );

    final merged = mergeEntries(
      clientId,
      local,
      'remote',
      [incomingEntry],
      kTestRelations,
    );
    final item = merged[qualifiedParentTableName]!['{"id":1}'];

    expect(
      item,
      ShadowEntryChanges(
        namespace: namespace,
        tablename: 'parent',
        primaryKeyCols: {'id': 1},
        optype: ChangesOpType.upsert,
        changes: {
          'id': OplogColumnChange(1, incomingTs.millisecondsSinceEpoch),
          'value':
              OplogColumnChange('incoming', incomingTs.millisecondsSinceEpoch),
          'other': OplogColumnChange(1, localTimestamp.millisecondsSinceEpoch),
        },
        fullRow: {
          'id': 1,
          'value': 'incoming',
          'other': 1,
        },
        tags: [
          generateTag(clientId, localTimestamp),
          generateTag('remote', incomingTs),
        ],
      ),
    );
  });

  test('merge incoming wins on persisted ops', () async {
    await runMigrations();
    satellite.setAuthState(authState);
    satellite.relations = kTestRelations;

    // This operation is persisted
    await adapter.run(
      Statement(
        "INSERT INTO parent(id, value, other) VALUES (1, 'local', 1)",
      ),
    );
    await satellite.performSnapshot();
    final [originalInsert] = await satellite.getEntries();
    final [tx] = toTransactions([originalInsert], satellite.relations);
    tx.origin = authState.clientId;
    await satellite.applyTransaction(tx);

    // Verify that GC worked as intended and the oplog entry was deleted
    expect(await satellite.getEntries(), isEmpty);

    // This operation is done offline
    await adapter.run(
      Statement("UPDATE parent SET value = 'new local' WHERE id = 1"),
    );
    await satellite.performSnapshot();
    final [offlineInsert] = await satellite.getEntries();
    final offlineTimestamp = DateTime.parse(offlineInsert.timestamp);

    // This operation is done concurrently with offline but at a later point in time. It's sent immediately on connection
    final incomingTs = offlineTimestamp.add(const Duration(milliseconds: 1));
    final firstIncomingEntry = generateRemoteOplogEntry(
      tableInfo,
      namespace,
      'parent',
      OpType.update,
      incomingTs.millisecondsSinceEpoch,
      genEncodedTags('remote', [incomingTs]),
      newValues: {'id': 1, 'value': 'incoming'},
      oldValues: {'id': 1, 'value': 'local'},
    );

    final firstIncomingTx = Transaction(
      origin: 'remote',
      commitTimestamp: Int64(incomingTs.millisecondsSinceEpoch),
      changes: [opLogEntryToChange(firstIncomingEntry, satellite.relations)],
      lsn: [],
    );
    await satellite.applyTransaction(firstIncomingTx);

    var [row] = await adapter.query(
      Statement('SELECT value FROM parent WHERE id = 1'),
    );
    final value1 = row['value']!;
    expect(
      value1,
      'incoming',
      reason:
          'LWW conflict merge of the incoming transaction should lead to incoming operation winning',
    );

    // And after the offline transaction was sent, the resolved no-op transaction comes in
    final secondIncomingEntry = generateRemoteOplogEntry(
      tableInfo,
      namespace,
      'parent',
      OpType.update,
      offlineTimestamp.millisecondsSinceEpoch,
      encodeTags([
        generateTag('remote', incomingTs),
        generateTag(authState.clientId, offlineTimestamp),
      ]),
      newValues: {'id': 1, 'value': 'incoming'},
      oldValues: {'id': 1, 'value': 'incoming'},
    );

    final secondIncomingTx = Transaction(
      origin: authState.clientId,
      commitTimestamp: Int64(offlineTimestamp.millisecondsSinceEpoch),
      changes: [opLogEntryToChange(secondIncomingEntry, satellite.relations)],
      lsn: [],
    );
    await satellite.applyTransaction(secondIncomingTx);

    [row] = await adapter.query(
      Statement('SELECT value FROM parent WHERE id = 1'),
    );
    final value2 = row['value']!;
    expect(
      value2,
      'incoming',
      reason:
          'Applying the resolved write from the round trip should be a no-op',
    );
  });

  test('apply does not add anything to oplog', () async {
    await runMigrations();
    await adapter.run(
      Statement(
        "INSERT INTO parent(id, value, other) VALUES (1, 'local', null)",
      ),
    );

    satellite.setAuthState(authState);
    final clientId = satellite.authState!.clientId;

    final localTimestamp = await satellite.performSnapshot();

    final incomingTs = DateTime.now();
    final incomingEntry = generateRemoteOplogEntry(
      tableInfo,
      namespace,
      'parent',
      OpType.insert,
      incomingTs.millisecondsSinceEpoch,
      genEncodedTags('remote', [incomingTs]),
      newValues: {
        'id': 1,
        'value': 'incoming',
        'other': 1,
      },
      oldValues: {},
    );

    satellite.relations =
        kTestRelations; // satellite must be aware of the relations in order to turn `DataChange`s into `OpLogEntry`s

    final incomingChange = opLogEntryToChange(incomingEntry, kTestRelations);
    final incomingTx = Transaction(
      origin: 'remote',
      commitTimestamp: Int64(incomingTs.millisecondsSinceEpoch),
      changes: [incomingChange],
      lsn: [],
    );

    await satellite.applyTransaction(incomingTx);

    await satellite.performSnapshot();

    const sql = 'SELECT * from parent WHERE id=1';
    final row = (await adapter.query(Statement(sql)))[0];
    expect(row['value']! as String, 'incoming');
    expect(row['other']! as int, 1);

    final localEntries = await satellite.getEntries();
    final shadowEntry =
        await getMatchingShadowEntries(adapter, oplog: localEntries[0]);

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

  test('apply incoming with no local', () async {
    await runMigrations();

    final incomingTs = DateTime.now();
    final incomingEntry = generateRemoteOplogEntry(
      tableInfo,
      namespace,
      'parent',
      OpType.delete,
      incomingTs.millisecondsSinceEpoch,
      genEncodedTags('remote', []),
      newValues: {
        'id': 1,
        'value': 'incoming',
        'otherValue': 1,
      },
      oldValues: {},
    );

    // satellite must be aware of the relations in order to deserialise oplog entries
    satellite.relations = kTestRelations;

    satellite.setAuthState(authState);
    await satellite.apply([incomingEntry], 'remote');

    const sql = 'SELECT * from parent WHERE id=1';
    final rows = await adapter.query(Statement(sql));
    final shadowEntries = await getMatchingShadowEntries(adapter);

    expect(shadowEntries, isEmpty);
    expect(rows, isEmpty);
  });

  test('apply empty incoming', () async {
    await runMigrations();

    satellite.setAuthState(authState);

    await satellite.apply([], 'external');
  });

  test('apply incoming with null on column with default', () async {
    await runMigrations();

    final incomingTs = DateTime.now();
    final incomingEntry = generateRemoteOplogEntry(
      tableInfo,
      namespace,
      'parent',
      OpType.insert,
      incomingTs.millisecondsSinceEpoch,
      genEncodedTags('remote', [incomingTs]),
      newValues: {
        'id': 1234,
        'value': 'incoming',
        'other': null,
      },
      oldValues: {},
    );

    satellite.setAuthState(authState);

    satellite.relations =
        kTestRelations; // satellite must be aware of the relations in order to turn `DataChange`s into `OpLogEntry`s

    final incomingChange = opLogEntryToChange(incomingEntry, kTestRelations);
    final incomingTx = Transaction(
      origin: 'remote',
      commitTimestamp: Int64(incomingTs.millisecondsSinceEpoch),
      changes: [incomingChange],
      lsn: [],
    );
    await satellite.applyTransaction(incomingTx);

    const sql = "SELECT * from parent WHERE value='incoming'";
    final rows = await adapter.query(Statement(sql));

    expect(rows[0]['other'], null);
  });

  test('apply incoming with undefined on column with default', () async {
    await runMigrations();

    final incomingTs = DateTime.now();
    final incomingEntry = generateRemoteOplogEntry(
      tableInfo,
      namespace,
      'parent',
      OpType.insert,
      incomingTs.millisecondsSinceEpoch,
      genEncodedTags('remote', [incomingTs]),
      newValues: {
        'id': 1234,
        'value': 'incoming',
      },
      oldValues: {},
    );

    satellite.setAuthState(authState);

    satellite.relations =
        kTestRelations; // satellite must be aware of the relations in order to turn `DataChange`s into `OpLogEntry`s

    final incomingChange = opLogEntryToChange(incomingEntry, kTestRelations);
    final incomingTx = Transaction(
      origin: 'remote',
      commitTimestamp: Int64(incomingTs.millisecondsSinceEpoch),
      changes: [incomingChange],
      lsn: [],
    );
    await satellite.applyTransaction(incomingTx);

    const sql = "SELECT * from parent WHERE value='incoming'";
    final rows = await adapter.query(Statement(sql));

    expect(rows[0]['other'], 0);
  });

  test('INSERT wins over DELETE and restored deleted values', () async {
    await runMigrations();
    satellite.setAuthState(authState);
    final clientId = satellite.authState!.clientId;

    final localTs = DateTime.now();
    final incomingTs = localTs.add(const Duration(milliseconds: 1));

    final incoming = [
      generateRemoteOplogEntry(
        tableInfo,
        namespace,
        'parent',
        OpType.insert,
        incomingTs.millisecondsSinceEpoch,
        genEncodedTags('remote', [incomingTs]),
        newValues: {
          'id': 1,
          'other': 1,
        },
        oldValues: {},
      ),
      generateRemoteOplogEntry(
        tableInfo,
        namespace,
        'parent',
        OpType.delete,
        incomingTs.millisecondsSinceEpoch,
        genEncodedTags('remote', []),
        newValues: {
          'id': 1,
        },
        oldValues: {},
      ),
    ];

    final local = [
      generateLocalOplogEntry(
        tableInfo,
        namespace,
        'parent',
        OpType.insert,
        localTs.millisecondsSinceEpoch,
        genEncodedTags(clientId, [localTs]),
        newValues: {
          'id': 1,
          'value': 'local',
          'other': null,
        },
      ),
    ];

    final merged =
        mergeEntries(clientId, local, 'remote', incoming, kTestRelations);
    final item = merged[qualifiedParentTableName]!['{"id":1}'];

    expect(
      item,
      ShadowEntryChanges(
        namespace: namespace,
        tablename: 'parent',
        primaryKeyCols: {'id': 1},
        optype: ChangesOpType.upsert,
        changes: {
          'id': OplogColumnChange(1, incomingTs.millisecondsSinceEpoch),
          'value': OplogColumnChange('local', localTs.millisecondsSinceEpoch),
          'other': OplogColumnChange(1, incomingTs.millisecondsSinceEpoch),
        },
        fullRow: {
          'id': 1,
          'value': 'local',
          'other': 1,
        },
        tags: [
          generateTag(clientId, localTs),
          generateTag('remote', incomingTs),
        ],
      ),
    );
  });

  test('concurrent updates take all changed values', () async {
    await runMigrations();
    satellite.setAuthState(authState);
    final clientId = satellite.authState!.clientId;

    final localTs = DateTime.now().millisecondsSinceEpoch;
    final incomingTs = localTs + 1;

    final incoming = [
      generateRemoteOplogEntry(
        tableInfo,
        namespace,
        'parent',
        OpType.update,
        incomingTs,
        genEncodedTags(
          'remote',
          [DateTime.fromMillisecondsSinceEpoch(incomingTs)],
        ),
        newValues: {
          'id': 1,
          'value': 'remote', // the only modified column
          'other': 0,
        },
        oldValues: {
          'id': 1,
          'value': 'local',
          'other': 0,
        },
      ),
    ];

    final local = [
      generateLocalOplogEntry(
        tableInfo,
        namespace,
        'parent',
        OpType.update,
        localTs,
        genEncodedTags(
          clientId,
          [DateTime.fromMillisecondsSinceEpoch(localTs)],
        ),
        newValues: {
          'id': 1,
          'value': 'local',
          'other': 1, // the only modified column
        },
        oldValues: {
          'id': 1,
          'value': 'local',
          'other': 0,
        },
      ),
    ];

    final merged =
        mergeEntries(clientId, local, 'remote', incoming, kTestRelations);
    final item = merged[qualifiedParentTableName]!['{"id":1}']!;

    // The incoming entry modified the value of the `value` column to `'remote'`
    // The local entry concurrently modified the value of the `other` column to 1.
    // The merged entries should have `value = 'remote'` and `other = 1`.
    expect(
      item,
      ShadowEntryChanges(
        namespace: namespace,
        tablename: 'parent',
        primaryKeyCols: {'id': 1},
        optype: ChangesOpType.upsert,
        changes: {
          'value': OplogColumnChange('remote', incomingTs),
          'other': OplogColumnChange(1, localTs),
        },
        fullRow: {
          'id': 1,
          'value': 'remote',
          'other': 1,
        },
        tags: [
          generateTag(clientId, DateTime.fromMillisecondsSinceEpoch(localTs)),
          generateTag(
            'remote',
            DateTime.fromMillisecondsSinceEpoch(incomingTs),
          ),
        ],
      ),
    );
  });

  test('merge incoming with empty local', () async {
    await runMigrations();
    satellite.setAuthState(authState);
    final clientId = satellite.authState!.clientId;

    final localTs = DateTime.now();
    final incomingTs = localTs.add(const Duration(milliseconds: 1));

    final incoming = [
      generateRemoteOplogEntry(
        tableInfo,
        namespace,
        'parent',
        OpType.insert,
        incomingTs.millisecondsSinceEpoch,
        genEncodedTags('remote', [incomingTs]),
        newValues: {
          'id': 1,
        },
        oldValues: {},
      ),
    ];

    final local = <OplogEntry>[];
    final merged =
        mergeEntries(clientId, local, 'remote', incoming, kTestRelations);
    final item = merged[qualifiedParentTableName]!['{"id":1}'];

    expect(
      item,
      ShadowEntryChanges(
        namespace: namespace,
        tablename: 'parent',
        primaryKeyCols: {'id': 1},
        optype: ChangesOpType.upsert,
        changes: {
          'id': OplogColumnChange(1, incomingTs.millisecondsSinceEpoch),
        },
        fullRow: {
          'id': 1,
        },
        tags: [generateTag('remote', incomingTs)],
      ),
    );
  });

  test('compensations: referential integrity is enforced', () async {
    await runMigrations();

    if (builder.dialect == Dialect.sqlite) {
      await adapter.run(Statement('PRAGMA foreign_keys = ON'));
    }
    await satellite.setMeta('compensations', 0);
    await adapter.run(
      Statement(
        "INSERT INTO parent(id, value) VALUES (1, '1')",
      ),
    );

    await expectLater(
      adapter.run(Statement('INSERT INTO child(id, parent) VALUES (1, 2)')),
      throwsA(
        isADbExceptionWithCode(
          builder.dialect,
          SqliteErrors.SQLITE_CONSTRAINT_FOREIGNKEY,
          PostgresErrors.PG_CONSTRAINT_FOREIGNKEY,
        ),
      ),
    );
  });

  test('compensations: incoming operation breaks referential integrity',
      () async {
    if (builder.dialect == Dialect.postgres) {
      // Ignore this unit test for Postgres
      // because we don't defer FK checks
      // but completely disable them for incoming transactions
      return;
    }

    await runMigrations();

    await adapter.run(Statement('PRAGMA foreign_keys = ON;'));
    await satellite.setMeta('compensations', 0);
    satellite.setAuthState(authState);

    final incoming = generateLocalOplogEntry(
      tableInfo,
      namespace,
      'child',
      OpType.insert,
      timestamp.millisecondsSinceEpoch,
      genEncodedTags('remote', [timestamp]),
      newValues: {
        'id': 1,
        'parent': 1,
      },
    );

    // satellite.setAuthState(authState);

    satellite.relations =
        kTestRelations; // satellite must be aware of the relations in order to turn `DataChange`s into `OpLogEntry`s

    final incomingChange = opLogEntryToChange(incoming, kTestRelations);
    final incomingTx = Transaction(
      origin: 'remote',
      commitTimestamp: Int64(timestamp.millisecondsSinceEpoch),
      changes: [incomingChange],
      lsn: [],
    );

    await expectLater(
      satellite.applyTransaction(incomingTx),
      throwsA(
        isADbExceptionWithCode(
          builder.dialect,
          SqliteErrors.SQLITE_CONSTRAINT_FOREIGNKEY,
          PostgresErrors.PG_CONSTRAINT_FOREIGNKEY,
        ),
      ),
    );
  });

  test(
      'compensations: incoming operations accepted if restore referential integrity',
      () async {
    await runMigrations();

    if (builder.dialect == Dialect.sqlite) {
      await adapter.run(Statement('PRAGMA foreign_keys = ON;'));
    }
    await satellite.setMeta('compensations', 0);
    satellite.setAuthState(authState);
    final clientId = satellite.authState!.clientId;

    final childInsertEntry = generateRemoteOplogEntry(
      tableInfo,
      namespace,
      'child',
      OpType.insert,
      timestamp.millisecondsSinceEpoch,
      genEncodedTags(clientId, [timestamp]),
      newValues: {
        'id': 1,
        'parent': 1,
      },
    );

    final parentInsertEntry = generateRemoteOplogEntry(
      tableInfo,
      namespace,
      'parent',
      OpType.insert,
      timestamp.millisecondsSinceEpoch,
      genEncodedTags(clientId, [timestamp]),
      newValues: {
        'id': 1,
      },
    );

    await adapter.run(
      Statement(
        "INSERT INTO parent(id, value) VALUES (1, '1')",
      ),
    );
    await adapter.run(Statement('DELETE FROM parent WHERE id=1'));

    await satellite.performSnapshot();

    satellite.relations =
        kTestRelations; // satellite must be aware of the relations in order to turn `DataChange`s into `OpLogEntry`s

    final childInsertChange =
        opLogEntryToChange(childInsertEntry, kTestRelations);
    final parentInsertChange =
        opLogEntryToChange(parentInsertEntry, kTestRelations);
    final insertChildAndParentTx = Transaction(
      origin: 'remote',
      commitTimestamp: Int64(
        DateTime.now().millisecondsSinceEpoch,
      ), // timestamp is not important for this test, it is only used to GC the oplog
      changes: [childInsertChange, parentInsertChange],
      lsn: [],
    );
    await satellite.applyTransaction(insertChildAndParentTx);

    final rows = await adapter.query(
      Statement(
        'SELECT * from parent WHERE id=1',
      ),
    );

    // Not only does the parent exist.
    expect(rows.length, 1);

    // But it's also recreated with deleted values.
    expect(rows[0]['value'], '1');
  });

  test('compensations: using triggers with flag 0', () async {
    // since this test disables compensations
    // by putting the flag on 0
    // it is expecting a FK violation
    if (builder.dialect == Dialect.postgres) {
      // if we're running Postgres
      // we are not deferring FK checks
      // but completely disabling them for incoming transactions
      // so the FK violation will not occur
      return;
    }

    await runMigrations();

    if (builder.dialect == Dialect.sqlite) {
      await adapter.run(Statement('PRAGMA foreign_keys = ON'));
    }
    await satellite.setMeta('compensations', 0);

    await adapter.run(
      Statement("INSERT INTO parent(id, value) VALUES (1, '1')"),
    );
    satellite.setAuthState(authState);
    final ts = await satellite.performSnapshot();
    await satellite.garbageCollectOplog(ts);

    await adapter.run(Statement('INSERT INTO child(id, parent) VALUES (1, 1)'));
    await satellite.performSnapshot();

    final timestamp = DateTime.now();
    final incoming = generateRemoteOplogEntry(
      tableInfo,
      namespace,
      'parent',
      OpType.delete,
      timestamp.millisecondsSinceEpoch,
      genEncodedTags('remote', []),
      newValues: {
        'id': 1,
      },
    );

    satellite.relations =
        kTestRelations; // satellite must be aware of the relations in order to turn `DataChange`s into `OpLogEntry`s

    final incomingChange = opLogEntryToChange(incoming, kTestRelations);
    final incomingTx = Transaction(
      origin: 'remote',
      commitTimestamp: Int64(timestamp.millisecondsSinceEpoch),
      changes: [incomingChange],
      lsn: [],
    );

    await expectLater(
      satellite.applyTransaction(incomingTx),
      throwsA(
        isADbExceptionWithCode(
          builder.dialect,
          SqliteErrors.SQLITE_CONSTRAINT_FOREIGNKEY,
          PostgresErrors.PG_CONSTRAINT_FOREIGNKEY,
        ),
      ),
    );
  });

  test('compensations: using triggers with flag 1', () async {
    await runMigrations();

    if (builder.dialect == Dialect.sqlite) {
      await adapter.run(Statement('PRAGMA foreign_keys = ON'));
    }
    await satellite.setMeta('compensations', 1);

    await adapter.run(
      Statement("INSERT INTO parent(id, value) VALUES (1, '1')"),
    );
    satellite.setAuthState(authState);
    final ts = await satellite.performSnapshot();
    await satellite.garbageCollectOplog(ts);

    await adapter.run(Statement('INSERT INTO child(id, parent) VALUES (1, 1)'));
    await satellite.performSnapshot();

    final timestamp = DateTime.now();
    final incoming = [
      generateRemoteOplogEntry(
        tableInfo,
        namespace,
        'parent',
        OpType.delete,
        timestamp.millisecondsSinceEpoch,
        genEncodedTags('remote', []),
        newValues: {
          'id': 1,
        },
      ),
    ];

    // satellite must be aware of the relations in order to deserialise oplog entries
    satellite.relations = kTestRelations;

    // Should not throw
    await satellite.apply(incoming, 'remote');
  });

  test('get oplogEntries from transaction', () async {
    await runMigrations();

    final relations = await satellite.getLocalRelations();

    final transaction = DataTransaction(
      lsn: kDefaultLogPos,
      commitTimestamp: Int64.ZERO,
      changes: [
        t.DataChange(
          relation: relations['parent']!,
          type: DataChangeType.insert,
          record: {'id': 0},
          tags: [], // proper values are not relevent here
        ),
      ],
    );

    final expected = OplogEntry(
      namespace: namespace,
      tablename: 'parent',
      optype: OpType.insert,
      newRow: '{"id":0}',
      oldRow: null,
      primaryKey: '{"id":0}',
      rowid: -1,
      timestamp: '1970-01-01T00:00:00.000Z',
      clearTags: encodeTags([]),
    );

    final opLog = fromTransaction(transaction, relations, namespace);
    expect(opLog[0], expected);
  });

  test('get transactions from opLogEntries', () async {
    await runMigrations();

    final opLogEntries = <OplogEntry>[
      OplogEntry(
        namespace: 'public',
        tablename: 'parent',
        optype: OpType.insert,
        newRow: '{"id":0}',
        oldRow: null,
        primaryKey: '{"id":0}',
        rowid: 1,
        timestamp: '1970-01-01T00:00:00.000Z',
        clearTags: encodeTags([]),
      ),
      OplogEntry(
        namespace: 'public',
        tablename: 'parent',
        optype: OpType.update,
        newRow: '{"id":1}',
        oldRow: '{"id":1}',
        primaryKey: '{"id":1}',
        rowid: 2,
        timestamp: '1970-01-01T00:00:00.000Z',
        clearTags: encodeTags([]),
      ),
      OplogEntry(
        namespace: 'public',
        tablename: 'parent',
        optype: OpType.insert,
        newRow: '{"id":2}',
        oldRow: null,
        primaryKey: '{"id":0}',
        rowid: 3,
        timestamp: '1970-01-01T00:00:01.000Z',
        clearTags: encodeTags([]),
      ),
    ];

    final expected = <DataTransaction>[
      DataTransaction(
        lsn: numberToBytes(2),
        commitTimestamp: Int64.ZERO,
        changes: [
          t.DataChange(
            relation: kTestRelations['parent']!,
            type: DataChangeType.insert,
            record: {'id': 0},
            oldRecord: null,
            tags: [],
          ),
          t.DataChange(
            relation: kTestRelations['parent']!,
            type: DataChangeType.update,
            record: {'id': 1},
            oldRecord: {'id': 1},
            tags: [],
          ),
        ],
      ),
      DataTransaction(
        lsn: numberToBytes(3),
        commitTimestamp: Int64(1000),
        changes: [
          t.DataChange(
            relation: kTestRelations['parent']!,
            type: DataChangeType.insert,
            record: {'id': 2},
            oldRecord: null,
            tags: [],
          ),
        ],
      ),
    ];

    final opLog = toTransactions(opLogEntries, kTestRelations);
    expect(opLog, expected);
  });

  test('disconnect stops queueing operations', () async {
    await runMigrations();
    final conn = await startSatellite(satellite, authConfig, token);

    await adapter.run(
      Statement(
        "INSERT INTO parent(id, value, other) VALUES (1, 'local', 1)",
      ),
    );
    await conn.connectionFuture;

    await satellite.performSnapshot();

    // We should have sent (or at least enqueued to send) one row
    final sentLsn = satellite.client.getLastSentLsn();
    expect(sentLsn, numberToBytes(1));

    satellite.disconnect(null);

    await adapter.run(
      Statement(
        "INSERT INTO parent(id, value, other) VALUES (2, 'local', 1)",
      ),
    );

    await satellite.performSnapshot();

    // Since connectivity is down, that row isn't yet sent
    final lsn1 = satellite.client.getLastSentLsn();
    expect(lsn1, sentLsn);

    // Once connectivity is restored, we will immediately run a snapshot to send pending rows
    await satellite.connectWithBackoff();

    // Wait for snapshot to run
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final lsn2 = satellite.client.getLastSentLsn();
    expect(lsn2, numberToBytes(2));
  });

  test('notifies about JWT expiration', () async {
    await runMigrations();
    await startSatellite(satellite, authConfig, token);

    // give some time for Satellite to start
    // (needed because connecting and starting replication are async)
    await Future<void>.delayed(const Duration(milliseconds: 100));

    bool hasListened = false;
    final unsubConnectivityChanges =
        notifier.subscribeToConnectivityStateChanges((notification) {
      if (hasListened) {
        return;
      }

      expect(notification.dbName, dbName);
      expect(
        notification.connectivityState.status,
        ConnectivityStatus.disconnected,
      );
      expect(
        notification.connectivityState.reason?.code,
        SatelliteErrorCode.authExpired,
      );

      hasListened = true;
    });
    addTearDown(() => unsubConnectivityChanges());

    // mock JWT expiration
    client.emitSocketClosedError(SocketCloseReason.authExpired);

    // give the notifier some time to fire
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(hasListened, true);

    // check that the client is disconnected
    expect(client.isConnected(), false);
  });

  test(
      'garbage collection is triggered when transaction from the same origin is replicated',
      () async {
    await runMigrations();
    final conn = await startSatellite(satellite, authConfig, token);
    await conn.connectionFuture;

    await adapter.run(
      Statement(
        "INSERT INTO parent(id, value, other) VALUES (1, 'local', 1);",
      ),
    );
    await adapter.run(
      Statement(
        "UPDATE parent SET value = 'local', other = 2 WHERE id = 1;",
      ),
    );

    // Before snapshot, we didn't send anything
    final lsn1 = satellite.client.getLastSentLsn();
    expect(lsn1, numberToBytes(0));

    // Snapshot sends these oplog entries
    await satellite.performSnapshot();
    final lsn2 = satellite.client.getLastSentLsn();
    expect(lsn2, numberToBytes(2));

    final oldOplog = await satellite.getEntries();
    final transactions = toTransactions(oldOplog, kTestRelations);

    final clientId = satellite.authState!.clientId;
    transactions[0].origin = clientId;

    // Transaction containing these oplogs is applies, which means we delete them
    await satellite.applyTransaction(transactions[0]);
    final newOplog = await satellite.getEntries();
    expect(newOplog, isEmpty);
  });

  // stub client and make satellite throw the error with option off/succeed with option on
  test('clear database on BEHIND_WINDOW', () async {
    await runMigrations();

    final base64lsn = base64.encode(numberToBytes(kMockBehindWindowLsn));
    await satellite.setMeta('lsn', base64lsn);
    try {
      final conn = await startSatellite(satellite, authConfig, token);
      await conn.connectionFuture;
      final lsnAfter = await satellite.getMeta<String?>('lsn');
      expect(lsnAfter, isNot(base64lsn));
    } catch (e) {
      fail('start should not throw');
    }

    // TODO: test clear subscriptions
  });

  test('throw other replication errors', () async {
    await runMigrations();

    final base64lsn = base64.encode(numberToBytes(kMockInternalError));
    await satellite.setMeta('lsn', base64lsn);

    int numExpects = 0;

    final conn = await startSatellite(satellite, authConfig, token);
    await Future.wait<dynamic>(
      [
        satellite.initializing!.waitOn(),
        conn.connectionFuture,
      ].map(
        (f) => f.onError<SatelliteException>((e, st) {
          numExpects++;
          expect(e.code, SatelliteErrorCode.internal);
        }),
      ),
    );

    expect(numExpects, 2);
  });

  test('apply shape data and persist subscription', () async {
    await runMigrations();

    const tablename = 'parent';
    final qualifiedTableName = QualifiedTablename(namespace, tablename);

    // relations must be present at subscription delivery
    client.setRelations(kTestRelations);
    client.setRelationData(tablename, parentRecord);

    final conn = await startSatellite(satellite, authConfig, token);
    await conn.connectionFuture;

    final shapeDef = Shape(tablename: tablename);
    satellite.relations = kTestRelations;

    final ShapeSubscription(synced: synced) =
        await satellite.subscribe([shapeDef]);
    await synced;

    // first notification is 'connected'
    expect(notifier.notifications.length, 2);
    final changeNotification = notifier.notifications[1] as ChangeNotification;
    expect(changeNotification.changes.length, 1);
    expect(
      changeNotification.changes[0],
      Change(
        qualifiedTablename: qualifiedTableName,
        rowids: [],
        recordChanges: [
          RecordChange(
            primaryKey: {'id': 1},
            type: RecordChangeType.initial,
          ),
        ],
      ),
    );

    // wait for process to apply shape data
    try {
      final row = await adapter.query(
        Statement(
          'SELECT id FROM $qualifiedTableName',
        ),
      );
      expect(row.length, 1);

      final shadowRows = await adapter.query(
        Statement(
          'SELECT tags FROM _electric_shadow',
        ),
      );
      expect(shadowRows.length, 1);

      final subsMeta = await satellite.getMeta<String>('subscriptions');
      final subsObj = json.decode(subsMeta) as Map<String, Object?>;
      expect(subsObj.length, 1);

      // Check that we save the LSN sent by the mock
      expect(satellite.debugLsn, base64.decode('MTIz'));
    } catch (e, st) {
      fail('Reason: $e\n$st');
    }
  });

  test(
      '(regression) shape subscription succeeds even if subscription data is delivered before the SatSubsReq RPC call receives its SatSubsResp answer',
      () async {
    await runMigrations();

    const tablename = 'parent';

    // relations must be present at subscription delivery
    client.setRelations(kTestRelations);
    client.setRelationData(tablename, parentRecord);

    final conn = await startSatellite(satellite, authConfig, token);
    await conn.connectionFuture;

    final shapeDef = Shape(tablename: tablename);

    satellite.relations = kTestRelations;

    // Enable the deliver first flag in the mock client
    // such that the subscription data is delivered before the
    // subscription promise is resolved
    final mockClient = satellite.client as MockSatelliteClient;
    mockClient.enableDeliverFirst();

    final ShapeSubscription(:synced) = await satellite.subscribe([shapeDef]);
    await synced;

    // doesn't throw
  });

  test('multiple subscriptions for the same shape are deduplicated', () async {
    await runMigrations();

    const tablename = 'parent';

    // relations must be present at subscription delivery
    client.setRelations(kTestRelations);
    client.setRelationData(tablename, parentRecord);

    final conn = await startSatellite(satellite, authConfig, token);
    await conn.connectionFuture;

    final shapeDef = Shape(tablename: tablename);

    satellite.relations = kTestRelations;

    // None of the following cases should throw

    // We should dedupe subscriptions that are done at the same time
    final [sub1, sub2] = await Future.wait([
      satellite.subscribe([shapeDef]),
      satellite.subscribe([shapeDef]),
    ]);
    // That are done after first await but before the data
    final sub3 = await satellite.subscribe([shapeDef]);
    // And that are done after previous data is resolved
    await Future.wait([sub1.synced, sub2.synced, sub3.synced]);
    final sub4 = await satellite.subscribe([shapeDef]);

    await sub4.synced;

    // And be "merged" into one subscription
    expect(satellite.subscriptions.getFulfilledSubscriptions().length, 1);
  });

  test('applied shape data will be acted upon correctly', () async {
    await runMigrations();

    const tablename = 'parent';
    final qualified = QualifiedTablename(namespace, tablename);

    // relations must be present at subscription delivery
    client.setRelations(kTestRelations);
    client.setRelationData(tablename, parentRecord);

    final conn = await startSatellite(satellite, authConfig, token);
    await conn.connectionFuture;

    final shapeDef = Shape(tablename: tablename);

    satellite.relations = kTestRelations;
    final ShapeSubscription(:synced) = await satellite.subscribe([shapeDef]);
    await synced;

    // wait for process to apply shape data
    try {
      final row = await adapter.query(
        Statement(
          'SELECT id FROM $qualified',
        ),
      );
      expect(row.length, 1);

      final shadowRows = await adapter.query(
        Statement(
          'SELECT * FROM _electric_shadow',
        ),
      );
      expect(shadowRows.length, 1);
      expect(shadowRows[0]['namespace'], namespace);
      expect(shadowRows[0]['tablename'], 'parent');

      await adapter.run(Statement('DELETE FROM $qualified WHERE id = 1'));
      await satellite.performSnapshot();

      final oplogs =
          await adapter.query(Statement('SELECT * FROM _electric_oplog'));
      expect(oplogs[0]['clearTags'], isNot('[]'));
    } catch (e, st) {
      fail('Reason: $e\n$st');
    }
  });

  test('additional data will be stored properly', () async {
    await runMigrations();
    const tablename = 'parent';

    // relations must be present at subscription delivery
    client.setRelations(kTestRelations);
    client.setRelationData(tablename, parentRecord);

    await startSatellite(satellite, authConfig, token);

    final shapeDef = Shape(tablename: tablename);

    satellite.relations = kTestRelations;
    final ShapeSubscription(:synced) = await satellite.subscribe([shapeDef]);
    await synced;
    await satellite.performSnapshot();

    // Send additional data
    await client.additionalDataCb!(
      AdditionalData(
        ref: Int64(10),
        changes: [
          DataChange(
            relation: kTestRelations['parent']!,
            tags: ['server@${DateTime.now().millisecondsSinceEpoch}'],
            type: DataChangeType.insert,
            record: {'id': 100, 'value': 'new_value'},
          ),
        ],
      ),
    );

    final [result] = await adapter.query(
      Statement(
        'SELECT * FROM parent WHERE id = 100',
      ),
    );
    expect(result, {'id': 100, 'value': 'new_value', 'other': null});
  });

  test('GONE messages are applied as DELETEs', () async {
    await runMigrations();
    const tablename = 'parent';

    // relations must be present at subscription delivery
    client.setRelations(kTestRelations);
    client.setRelationData(tablename, parentRecord);

    await startSatellite(satellite, authConfig, token);

    final shapeDef = Shape(tablename: tablename);

    satellite.relations = kTestRelations;
    final ShapeSubscription(:synced) = await satellite.subscribe([shapeDef]);
    await synced;
    await satellite.performSnapshot();

    // Send additional data
    await client.transactionsCb!(
      ServerTransaction(
        commitTimestamp: Int64(DateTime.now().millisecondsSinceEpoch),
        id: Int64(10),
        lsn: [],
        origin: 'remote',
        changes: [
          DataChange(
            relation: kTestRelations['parent']!,
            tags: [],
            type: DataChangeType.gone,
            record: {'id': 1},
          ),
        ],
      ),
    );

    final results = await adapter.query(
      Statement(
        'SELECT * FROM parent',
      ),
    );
    expect(results, <dynamic>[]);
  });

  test(
      'a subscription that failed to apply because of FK constraint triggers GC',
      () async {
    if (builder.dialect == Dialect.postgres) {
      // Ignore this unit test for Postgres
      // because we don't defer FK checks
      // but completely disable them for incoming transactions
      return;
    }

    await runMigrations();

    const tablename = 'child';

    // relations must be present at subscription delivery
    client.setRelations(kTestRelations);
    client.setRelationData(tablename, childRecord);

    final conn = await startSatellite(satellite, authConfig, token);
    await conn.connectionFuture;

    final shapeDef1 = Shape(tablename: tablename);

    satellite.relations = kTestRelations;
    final ShapeSubscription(synced: dataReceived) =
        await satellite.subscribe([shapeDef1]);
    await dataReceived; // wait for subscription to be fulfilled

    try {
      final row = await adapter.query(
        Statement(
          'SELECT id FROM "$namespace"."$tablename"',
        ),
      );

      expect(row.length, 0);
    } catch (e, st) {
      fail('Reason: $e\n$st');
    }
  });

  test('a second successful subscription', () async {
    await runMigrations();

    const tablename = 'child';

    // relations must be present at subscription delivery
    client.setRelations(kTestRelations);
    client.setRelationData('parent', parentRecord);
    client.setRelationData(tablename, childRecord);

    final conn = await startSatellite(satellite, authConfig, token);
    await conn.connectionFuture;

    final shapeDef1 = Shape(tablename: 'parent');
    final shapeDef2 = Shape(tablename: tablename);

    satellite.relations = kTestRelations;
    await satellite.subscribe([shapeDef1]);
    final ShapeSubscription(synced: synced) =
        await satellite.subscribe([shapeDef2]);
    await synced;

    try {
      final row = await adapter.query(
        Statement(
          'SELECT id FROM "$namespace"."$tablename"',
        ),
      );
      expect(row.length, 1);

      final shadowRows = await adapter.query(
        Statement(
          'SELECT tags FROM _electric_shadow',
        ),
      );
      expect(shadowRows.length, 2);

      final subsMeta = await satellite.getMeta<String>('subscriptions');
      final subsObj = json.decode(subsMeta) as Map<String, Object?>;
      expect(subsObj.length, 2);
    } catch (e, st) {
      fail('Reason: $e\n$st');
    }
  });

  test('a single subscribe with multiple tables with FKs', () async {
    await runMigrations();

    // relations must be present at subscription delivery
    client.setRelations(kTestRelations);
    client.setRelationData('parent', parentRecord);
    client.setRelationData('child', childRecord);

    final conn = await startSatellite(satellite, authConfig, token);
    await conn.connectionFuture;

    final shapeDef1 = Shape(tablename: 'child');
    final shapeDef2 = Shape(tablename: 'parent');

    satellite.relations = kTestRelations;

    final completer = Completer<void>();
    client.subscribeToSubscriptionEvents(
      (data) async {
        // child is applied first
        expect(data.data[0].relation.table, 'child');
        expect(data.data[1].relation.table, 'parent');

        Timer(const Duration(milliseconds: 10), () async {
          try {
            final row = await adapter.query(
              Statement(
                'SELECT id FROM "$namespace"."child"',
              ),
            );
            expect(row.length, 1);

            completer.complete();
          } catch (e) {
            completer.completeError(e);
          }
        });
      },
      (_) {},
    );

    await satellite.subscribe([shapeDef1, shapeDef2]);

    await completer.future;
  });

  test('a shape delivery that triggers garbage collection', () async {
    await runMigrations();

    // relations must be present at subscription delivery
    client.setRelations(kTestRelations);
    client.setRelationData('parent', parentRecord);
    client.setRelationData('child', childRecord);
    client.setRelationData('another', {});

    final conn = await startSatellite(satellite, authConfig, token);
    await conn.connectionFuture;

    final shapeDef1 = Shape(
      tablename: 'parent',
      include: [
        Rel(foreignKey: ['parent'], select: Shape(tablename: 'child')),
      ],
    );
    final shapeDef2 = Shape(tablename: 'another');

    satellite.relations = kTestRelations;

    final ShapeSubscription(synced: synced1) =
        await satellite.subscribe([shapeDef1]);
    await synced1;
    final row = await adapter.query(Statement('SELECT id FROM parent'));
    expect(row.length, 1);
    final row1 = await adapter.query(Statement('SELECT id FROM child'));
    expect(row1.length, 1);
    final ShapeSubscription(synced: synced) =
        await satellite.subscribe([shapeDef2]);

    try {
      await synced;
      fail('Expected a subscription error');
    } catch (expected) {
      expect(expected, isA<SatelliteException>());

      try {
        final row = await adapter.query(
          Statement('SELECT id FROM parent'),
        );
        expect(row.length, 0);
        final row1 = await adapter.query(
          Statement('SELECT id FROM child'),
        );
        expect(row1.length, 0);

        final shadowRows = await adapter.query(
          Statement('SELECT tags FROM _electric_shadow'),
        );
        expect(shadowRows.length, 2);

        final subsMeta = await satellite.getMeta<String>('subscriptions');
        final subsObj = json.decode(subsMeta) as Map<String, Object?>;
        expect(subsObj, <String, Object?>{});
        expect(
          (expected as SatelliteException).message!.indexOf("table 'another'"),
          greaterThanOrEqualTo(0),
        );
      } catch (e, st) {
        fail('Reason: $e\n$st');
      }
    }
  });

  test('a subscription request failure does not clear the manager state',
      () async {
    await runMigrations();

    // relations must be present at subscription delivery
    const tablename = 'parent';
    client.setRelations(kTestRelations);
    client.setRelationData(tablename, parentRecord);

    final conn = await startSatellite(satellite, authConfig, token);
    await conn.connectionFuture;

    final shapeDef1 = Shape(tablename: tablename);

    final shapeDef2 = Shape(tablename: 'failure');

    satellite.relations = kTestRelations;
    final ShapeSubscription(synced: dataReceived) =
        await satellite.subscribe([shapeDef1]);
    await dataReceived;

    try {
      final row = await adapter.query(
        Statement(
          'SELECT id FROM "$namespace"."$tablename"',
        ),
      );
      expect(row.length, 1);
    } catch (e, st) {
      fail('Reason: $e\n$st');
    }

    try {
      await satellite.subscribe([shapeDef2]);
    } catch (error) {
      expect(
        (error as SatelliteException).code,
        SatelliteErrorCode.tableNotFound,
      );
    }
  });

  test("snapshot while not fully connected doesn't throw", () async {
    client.setStartReplicationDelay(const Duration(milliseconds: 100));

    await runMigrations();

    // Add log entry while offline
    await adapter.run(Statement("INSERT INTO parent(id) VALUES ('1'),('2')"));

    final conn = await startSatellite(satellite, authConfig, token);

    // Performing a snapshot while the replication connection has not been stablished
    // should not throw
    await satellite.performSnapshot();

    await conn.connectionFuture;

    await satellite.performSnapshot();
  });

  test('unsubscribing all subscriptions does not trigger FK violations',
      () async {
    await runMigrations(); // because the meta tables need to exist for shape GC

    unawaited(
      satellite.garbageCollectShapeHandler(
        [ShapeDefinition(uuid: '', definition: Shape(tablename: 'parent'))],
      ),
    );

    final subsManager = MockSubscriptionsManager(
      satellite.garbageCollectShapeHandler,
    );

    // Create the 'users' and 'posts' tables expected by sqlite
    // populate it with foreign keys and check that the subscription
    // manager does not violate the FKs when unsubscribing from all subscriptions
    await satellite.adapter.runInTransaction([
      Statement('CREATE TABLE users (id TEXT PRIMARY KEY, name TEXT)'),
      Statement(
        'CREATE TABLE posts (id TEXT PRIMARY KEY, title TEXT, author_id TEXT, FOREIGN KEY(author_id) REFERENCES users(id) ${builder.pgOnly('DEFERRABLE INITIALLY IMMEDIATE')})',
      ),
      Statement("INSERT INTO users (id, name) VALUES ('u1', 'user1')"),
      Statement(
        "INSERT INTO posts (id, title, author_id) VALUES ('p1', 'My first post', 'u1')",
      ),
    ]);

    await subsManager.unsubscribeAll();
    // if we reach here, the FKs were not violated

    // Check that everything was deleted
    final users =
        await satellite.adapter.query(Statement('SELECT * FROM users'));
    expect(users, isEmpty);

    final posts =
        await satellite.adapter.query(Statement('SELECT * FROM posts'));
    expect(posts, isEmpty);
  });

  test("Garbage collecting the subscription doesn't generate oplog entries",
      () async {
    await startSatellite(satellite, authConfig, token);
    await runMigrations();
    await adapter.run(Statement("INSERT INTO parent(id) VALUES ('1'),('2')"));
    final ts = await satellite.performSnapshot();
    await satellite.garbageCollectOplog(ts);
    expect((await satellite.getEntries(since: 0)).length, 0);

    unawaited(
      satellite.garbageCollectShapeHandler([
        ShapeDefinition(
          uuid: '',
          definition: Shape(tablename: 'parent'),
        ),
      ]),
    );

    await satellite.performSnapshot();
    expect(await satellite.getEntries(since: 0), <OplogEntry>[]);
  });

  test('snapshots: generated oplog entries have the correct tags', () async {
    await runMigrations();

    const tablename = 'parent';
    final qualified = QualifiedTablename(namespace, tablename);

    // relations must be present at subscription delivery
    client.setRelations(kTestRelations);
    client.setRelationData(tablename, parentRecord);

    final conn = await startSatellite(satellite, authConfig, token);
    await conn.connectionFuture;

    final shapeDef = Shape(tablename: tablename);

    satellite.relations = kTestRelations;
    final ShapeSubscription(:synced) = await satellite.subscribe([shapeDef]);
    await synced;

    final expectedTs = DateTime.now();
    final incoming = generateRemoteOplogEntry(
      tableInfo,
      namespace,
      'parent',
      OpType.insert,
      expectedTs.millisecondsSinceEpoch,
      genEncodedTags('remote', [expectedTs]),
      newValues: {
        'id': 2,
      },
      oldValues: {},
    );
    final incomingChange = opLogEntryToChange(incoming, kTestRelations);

    await satellite.applyTransaction(
      Transaction(
        origin: 'remote',
        commitTimestamp: Int64(expectedTs.millisecondsSinceEpoch),
        changes: [incomingChange],
        lsn: [],
      ),
    );

    final row = await adapter.query(
      Statement(
        'SELECT id FROM $qualified',
      ),
    );
    expect(row.length, 2);

    final shadowRows = await adapter.query(
      Statement(
        'SELECT * FROM _electric_shadow',
      ),
    );
    expect(shadowRows.length, 2);

    expect(shadowRows[0]['namespace'], namespace);
    expect(shadowRows[0]['tablename'], 'parent');

    await adapter.run(Statement('DELETE FROM $qualified WHERE id = 2'));
    final deleteTx = await satellite.performSnapshot();

    final oplogs = await adapter.query(
      Statement(
        'SELECT * FROM _electric_oplog',
      ),
    );
    expect(
      oplogs[0]['clearTags'],
      encodeTags([
        generateTag(satellite.authState!.clientId, deleteTx),
        generateTag('remote', expectedTs),
      ]),
    );
  });

  test('DELETE after DELETE sends clearTags', () async {
    await runMigrations();

    satellite.setAuthState(authState);

    await adapter
        .run(Statement("INSERT INTO parent(id, value) VALUES (1,'val1')"));
    await adapter
        .run(Statement("INSERT INTO parent(id, value) VALUES (2,'val2')"));

    await adapter.run(Statement('DELETE FROM parent WHERE id=1'));

    await satellite.performSnapshot();

    await adapter.run(Statement('DELETE FROM parent WHERE id=2'));

    await satellite.performSnapshot();

    final entries = await satellite.getEntries();

    expect(entries.length, 4);

    final delete1 = entries[2];
    final delete2 = entries[3];

    expect(delete1.primaryKey, '{"id":1}');
    expect(delete1.optype, OpType.delete);
    // No tags for first delete
    expect(delete1.clearTags, '[]');

    expect(delete2.primaryKey, '{"id":2}');
    expect(delete2.optype, OpType.delete);
    // The second should have clearTags
    expect(delete2.clearTags, isNot('[]'));
  });

  test('connection backoff success', () async {
    client.shutdown();

    int numExpects = 0;

    bool retry(Object _e, int a) {
      if (a > 0) {
        numExpects++;
        return false;
      }
      return true;
    }

    satellite.connectRetryHandler = retry;

    await Future.wait<dynamic>(
      [satellite.connectWithBackoff(), satellite.initializing!.waitOn()].map(
        (f) => f.catchError((e) => numExpects++),
      ),
    );

    expect(numExpects, 3);
  });

  test('connection cancelled on disconnect', () async {
    // such that satellite can't connect to Electric and will keep retrying
    client.shutdown();
    final conn = await startSatellite(satellite, authConfig, token);

    // We expect the connection to be cancelled
    final fut = expectLater(
      conn.connectionFuture,
      throwsA(
        isA<SatelliteException>().having(
          (e) => e.code,
          'code',
          SatelliteErrorCode.connectionCancelledByDisconnect,
        ),
      ),
    );

    // Disconnect Satellite
    satellite.clientDisconnect();

    // Await until the connection promise is rejected
    await fut;
  });

  // check that performing snapshot doesn't throw without resetting the performing snapshot assertions
  test('(regression) performSnapshot handles exceptions gracefully', () async {
    await runMigrations();
    satellite.setAuthState(authState);

    satellite.updateDatabaseAdapter(
      ReplaceTxDatabaseAdapter(satellite.adapter),
    );

    const error = 'FAKE TRANSACTION';

    final customAdapter = satellite.adapter as ReplaceTxDatabaseAdapter;

    customAdapter.customTxFun = (_) {
      throw Exception(error);
    };

    try {
      await satellite.performSnapshot();
      fail('Should throw');
    } on Exception catch (e) {
      expect(e.toString(), 'Exception: $error');

      // Restore default tx behavior
      customAdapter.customTxFun = null;
    }

    await satellite.performSnapshot();

    // Doesn't throw
  });

  test("don't leave a snapshot running when stopping", () async {
    await runMigrations();
    satellite.setAuthState(authState);

    // Make the adapter slower, to interleave stopping the process and closing the db with a snapshot
    // delay termination of _performSnapshot
    satellite.updateDatabaseAdapter(
      SlowDatabaseAdapter(
        satellite.adapter,
        delay: const Duration(milliseconds: 500),
      ),
    );

    // Add something to the oplog
    await adapter
        .run(Statement("INSERT INTO parent(id, value) VALUES (1,'val1')"));

    // // Perform snapshot with the mutex, to emulate a real scenario
    final snapshotFuture = satellite.mutexSnapshot();
    // Give some time to start the "slow" snapshot
    await Future<void>.delayed(const Duration(milliseconds: 100));

    // Stop the process while the snapshot is being performed
    await satellite.stop();

    // Remove/close the database connection
    await context.cleanAndStopDb();

    // Wait for the snapshot to finish to consider the test successful
    await snapshotFuture;
  });

  test("don't snapshot after closing satellite process", () async {
    // open and then immediately close
    // check that no snapshot is called after close
    final conn = await startSatellite(satellite, authConfig, token);
    await conn.connectionFuture;

    await satellite.stop();

    satellite.debugSetPerformSnapshot(() async {
      fail('Snapshot was called');
    });

    // wait some time to see that mutexSnapshot is not called
    await Future<void>.delayed(const Duration(milliseconds: 50));
  });

  test(
      "don't schedule snapshots from polling interval when closing satellite process",
      () async {
    await runMigrations();

    // Replace the snapshot function to simulate a slow snapshot
    // that access the database after closing
    satellite.debugSetPerformSnapshot(() async {
      try {
        await Future<void>.delayed(const Duration(milliseconds: 500));
        await adapter.query(builder.getLocalTableNames());
        return DateTime.now();
      } catch (e) {
        fail('should not fail');
      }
    });

    final conn = await startSatellite(satellite, authConfig, token);
    await conn.connectionFuture;

    // Let the process schedule a snapshot
    await Future<void>.delayed(opts.pollingInterval * 2);

    await satellite.stop();

    // Remove/close the database connection
    await context.cleanAndStopDb();

    // Wait for the snapshot to finish to consider the test successful
    await Future<void>.delayed(const Duration(milliseconds: 1000));
  });
}

class SlowDatabaseAdapter extends DatabaseAdapter {
  final DatabaseAdapter delegate;

  SlowDatabaseAdapter(
    this.delegate, {
    this.delay = const Duration(milliseconds: 100),
  });

  final Duration delay;

  @override
  Future<RunResult> run(Statement statement) async {
    await Future<void>.delayed(delay);
    return delegate.run(statement);
  }

  @override
  Future<T> transaction<T>(
    void Function(DbTransaction tx, void Function(T res) setResult) f,
  ) async {
    await Future<void>.delayed(delay);
    return delegate.transaction<T>(f);
  }

  @override
  Future<List<Row>> query(Statement statement) async {
    await Future<void>.delayed(delay);
    return delegate.query(statement);
  }

  @override
  Future<RunResult> runInTransaction(List<Statement> statements) async {
    await Future<void>.delayed(delay);
    return delegate.runInTransaction(statements);
  }
}

typedef _TxFun<T> = Future<T> Function(
  void Function(DbTransaction tx, void Function(T res) setResult) f,
);

class ReplaceTxDatabaseAdapter extends DatabaseAdapter {
  final DatabaseAdapter delegate;

  ReplaceTxDatabaseAdapter(this.delegate);

  _TxFun<dynamic>? customTxFun;

  @override
  Future<RunResult> run(Statement statement) async {
    return delegate.run(statement);
  }

  @override
  Future<T> transaction<T>(
    void Function(DbTransaction tx, void Function(T res) setResult) f,
  ) {
    return customTxFun != null
        ? (customTxFun! as _TxFun<T>).call(f)
        : delegate.transaction(f);
  }

  @override
  Future<List<Row>> query(Statement statement) async {
    return delegate.query(statement);
  }

  @override
  Future<RunResult> runInTransaction(List<Statement> statements) async {
    return delegate.runInTransaction(statements);
  }
}
