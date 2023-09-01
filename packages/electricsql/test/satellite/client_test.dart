import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:electricsql/src/auth/auth.dart';
import 'package:electricsql/src/notifiers/mock.dart';
import 'package:electricsql/src/proto/satellite.pb.dart';
import 'package:electricsql/src/satellite/client.dart';
import 'package:electricsql/src/satellite/config.dart';
import 'package:electricsql/src/satellite/oplog.dart';
import 'package:electricsql/src/satellite/satellite.dart';
import 'package:electricsql/src/satellite/shapes/types.dart';
import 'package:electricsql/src/sockets/io.dart';
import 'package:electricsql/src/util/common.dart';
import 'package:electricsql/src/util/proto.dart';
import 'package:electricsql/src/util/types.dart';
import 'package:fixnum/fixnum.dart';
import 'package:test/test.dart';

import 'common.dart';
import 'server_ws_stub.dart';

late SatelliteWSServerStub server;
late SatelliteClient client;
late String clientId;
late String token;

void main() {
  setUp(() async {
    server = SatelliteWSServerStub();
    await server.start();

    const dbName = 'dbName';

    client = SatelliteClient(
      dbName: dbName,
      socketFactory: WebSocketIOFactory(),
      notifier: MockNotifier(dbName),
      opts: SatelliteClientOpts(
        host: '127.0.0.1',
        port: 30002,
        timeout: 10000,
        ssl: false,
        pushPeriod: 100,
      ),
    );
    clientId = '91eba0c8-28ba-4a86-a6e8-42731c2c6694';

    token = 'fake_token';
  });

  tearDown(() async {
    client.close();
    await server.close();
  });

  test('connect success', () async {
    await client.connect();
  });

  // TODO: handle connection errors scenarios

  Future<void> connectAndAuth() async {
    await client.connect();

    final authResp = SatAuthResp();
    server.nextResponses([authResp]);
    await client.authenticate(createAuthState());
  }

  test('replication start timeout', () async {
    client.opts.timeout = 10;
    await client.connect();

    // empty response will trigger client timeout
    server.nextResponses([]);
    try {
      await client.startReplication(null, null, null);
      fail('start replication should throw');
    } catch (error) {
      expect(
        error,
        isA<SatelliteException>()
            .having((e) => e.code, 'code', SatelliteErrorCode.timeout),
      );
    }
  });

  test('connect subscription error', () async {
    final startResp = SatInStartReplicationResp(
      err: SatInStartReplicationResp_ReplicationError(
        code: SatInStartReplicationResp_ReplicationError_Code.BEHIND_WINDOW,
        message: 'Test',
      ),
    );
    await client.connect();

    server.nextResponses([startResp]);

    try {
      final resp = await client.startReplication(null, null, null);
      expect(resp.error?.code, SatelliteErrorCode.behindWindow);
    } catch (e) {
      fail('Should not throw. Error: $e');
    }
  });

  test('authentication success', () async {
    await client.connect();

    final authResp = SatAuthResp(id: 'server_identity');
    server.nextResponses([authResp]);

    final res = await client.authenticate(createAuthState());
    expect(
      res.serverId,
      'server_identity',
    );
    expect(client.inbound.authenticated, isTrue);
  });

  test('replication start success', () async {
    await connectAndAuth();

    final startResp = SatInStartReplicationResp();
    server.nextResponses([startResp]);

    await client.startReplication(null, null, null);
  });

  test('replication start sends empty', () async {
    await connectAndAuth();
    final completer = Completer<void>();

    server.nextResponses([
      (Uint8List data) {
        final code = data[0];
        final msgType = getMsgFromCode(code);

        if (msgType == SatMsgType.inStartReplicationReq) {
          final decodedMsg = decode(data);
          expect(
            (decodedMsg.msg as SatInStartReplicationReq).lsn,
            isEmpty,
          );
          completer.complete();
        }
      },
    ]);
    unawaited(client.startReplication(null, null, null));
    await completer.future;
  });

  test('replication start sends schemaVersion', () async {
    await connectAndAuth();

    final completer = Completer<void>();
    server.nextResponses([
      (Uint8List data) {
        final decodedMsg = decode(data);
        expect(
          decodedMsg.msgType,
          SatMsgType.inStartReplicationReq,
        );

        expect(
          (decodedMsg.msg as SatInStartReplicationReq).schemaVersion,
          '20230711',
        );

        completer.complete();
      },
    ]);
    unawaited(client.startReplication([], '20230711', null));

    await completer.future;
  });

  test('replication start failure', () async {
    await connectAndAuth();

    final startResp = SatInStartReplicationResp();
    server.nextResponses([startResp]);

    try {
      await client.startReplication(null, null, null);
      await client.startReplication(null, null, null); // fails
    } catch (error) {
      expect(
        error,
        isA<SatelliteException>().having(
          (e) => e.code,
          'code',
          SatelliteErrorCode.replicationAlreadyStarted,
        ),
      );
    }
  });

  test('replication stop success', () async {
    await connectAndAuth();

    final start = SatInStartReplicationResp();
    final stop = SatInStopReplicationResp();
    server.nextResponses([start]);
    server.nextResponses([stop]);

    await client.startReplication(null, null, null);
    await client.stopReplication();
  });

  test('replication stop failure', () async {
    await connectAndAuth();

    final stop = SatInStopReplicationResp();
    server.nextResponses([stop]);

    try {
      await client.stopReplication();
      fail('stop replication should throw');
    } catch (error) {
      expect(
        error,
        isA<SatelliteException>().having(
          (e) => e.code,
          'code',
          SatelliteErrorCode.replicationNotStarted,
        ),
      );
    }
  });

  test('server pings client', () async {
    await connectAndAuth();

    final start = SatInStartReplicationResp();
    final ping = SatPingReq();
    final stop = SatInStopReplicationResp();
    final completer = Completer<void>();

    server.nextResponses([start, ping]);
    server.nextResponses([
      (_) {
        completer.complete();
      },
    ]);
    server.nextResponses([stop]);

    await client.startReplication(null, null, null);
    await client.stopReplication();

    await completer.future;
  });

  test('receive transaction over multiple messages', () async {
    await connectAndAuth();

    final start = SatInStartReplicationResp();
    final begin = SatOpBegin(commitTimestamp: Int64.ZERO);
    final commit = SatOpCommit();

    final Relation rel = Relation(
      id: 1,
      schema: 'schema',
      table: 'table',
      tableType: SatRelation_RelationType.TABLE,
      columns: [
        RelationColumn(name: 'name1', type: 'TEXT', isNullable: true),
        RelationColumn(name: 'name2', type: 'TEXT', isNullable: true),
      ],
    );

    final relation = SatRelation(
      relationId: 1,
      schemaName: 'schema',
      tableName: 'table',
      tableType: SatRelation_RelationType.TABLE,
      columns: [
        SatRelationColumn(name: 'name1', type: 'TEXT', isNullable: true),
        SatRelationColumn(name: 'name2', type: 'TEXT', isNullable: true),
      ],
    );

    final insertOp = SatOpInsert(
      relationId: 1,
      rowData: serializeRow({'name1': 'Foo', 'name2': 'Bar'}, rel),
    );

    final updateOp = SatOpUpdate(
      relationId: 1,
      rowData: serializeRow({'name1': 'Hello', 'name2': 'World!'}, rel),
      oldRowData: serializeRow({'name1': '', 'name2': ''}, rel),
    );
    final deleteOp = SatOpDelete(
      relationId: 1,
      oldRowData: serializeRow({'name1': 'Hello', 'name2': 'World!'}, rel),
    );

    final firstOpLogMessage = SatOpLog(
      ops: [
        SatTransOp(begin: begin),
        SatTransOp(insert: insertOp),
      ],
    );

    final secondOpLogMessage = SatOpLog(
      ops: [
        SatTransOp(update: updateOp),
        SatTransOp(delete: deleteOp),
        SatTransOp(commit: commit),
      ],
    );

    final stop = SatInStopReplicationResp();

    server.nextResponses(
      [start, relation, firstOpLogMessage, secondOpLogMessage],
    );
    server.nextResponses([stop]);

    final completer = Completer<void>();

    client.on('transaction', (TransactionEvent event) {
      expect(event.transaction.changes.length, 3);
      completer.complete();
    });

    await client.startReplication(null, null, null);
    await completer.future;
  });

  test('acknowledge lsn', () async {
    await connectAndAuth();

    final lsn = base64.decode('FAKE');

    final start = SatInStartReplicationResp();
    final begin = SatOpBegin(
      lsn: lsn,
      commitTimestamp: Int64.ZERO,
    );
    final commit = SatOpCommit();

    final opLog = SatOpLog(
      ops: [
        SatTransOp(begin: begin),
        SatTransOp(commit: commit),
      ],
    );

    final stop = SatInStopReplicationResp();

    server.nextResponses([start, opLog]);
    server.nextResponses([stop]);

    final completer = Completer<void>();
    client.on('transaction', (TransactionEvent event) {
      final ack = event.ackCb;
      final lsn0 = client.inbound.ackLsn;
      expect(lsn0, null);
      ack();
      final lsn1 = base64.encode(client.inbound.ackLsn!);
      expect(lsn1, 'FAKE');
      completer.complete();
    });

    await client.startReplication(null, null, null);
    await completer.future;
  });

  test('send transaction', () async {
    await connectAndAuth();

    final startResp = SatInStartReplicationResp();

    final List<OplogEntry> opLogEntries = [
      OplogEntry(
        namespace: 'main',
        tablename: 'parent',
        optype: OpType.insert,
        newRow: '{"id":0}',
        primaryKey: '{"id":0}',
        rowid: 0,
        timestamp: '1970-01-01T00:00:01.000Z',
        clearTags: '[]',
      ),
      OplogEntry(
        namespace: 'main',
        tablename: 'parent',
        optype: OpType.update,
        newRow: '{"id":1}',
        oldRow: '{"id":1}',
        primaryKey: '{"id":1}',
        rowid: 1,
        timestamp: '1970-01-01T00:00:01.000Z',
        clearTags: '["origin@1231232347"]',
      ),
      OplogEntry(
        namespace: 'main',
        tablename: 'parent',
        optype: OpType.update,
        newRow: '{"id":1}',
        oldRow: '{"id":1}',
        primaryKey: '{"id":1}',
        rowid: 2,
        timestamp: '1970-01-01T00:00:02.000Z',
        clearTags: '["origin@1231232347"]',
      ),
      OplogEntry(
        namespace: 'main',
        tablename: 'parent',
        optype: OpType.insert,
        newRow: '{"id":2}',
        oldRow: null,
        primaryKey: '{"id":2}',
        rowid: 3,
        timestamp: '1970-01-01T00:00:03.000Z',
        clearTags: '[]',
      ),
    ];

    final transaction = toTransactions(opLogEntries, kTestRelations);

    final completer = Completer<void>();
    server.nextResponses([startResp]);
    server.nextResponses([]);

    int expectedCount = 4;
    // first message is a relation
    server.nextResponses([
      (Uint8List data) {
        expectedCount -= 1;
        final code = data[0];
        final msgType = getMsgFromCode(code);

        if (msgType == SatMsgType.relation) {
          final decodedMsg = decode(data);
          expect((decodedMsg.msg as SatRelation).relationId, 1);
        }
      },
    ]);

    // second message is a transaction
    server.nextResponses([
      (Uint8List data) {
        expectedCount -= 1;
        final code = data[0];
        final msgType = getMsgFromCode(code);

        expect(msgType, SatMsgType.opLog);

        final satOpLog = (decode(data).msg as SatOpLog).ops;

        final lsn = satOpLog[0].begin.lsn;
        expect(bytesToNumber(lsn), 1);
        expect(satOpLog[0].begin.commitTimestamp, Int64(1000));
      },
    ]);

    // third message after new enqueue does not send relation
    server.nextResponses([
      (Uint8List data) {
        expectedCount -= 1;

        final code = data[0];
        final msgType = getMsgFromCode(code);
        expect(msgType, SatMsgType.opLog);

        final satOpLog = (decode(data).msg as SatOpLog).ops;

        final lsn = satOpLog[0].begin.lsn;
        expect(bytesToNumber(lsn), 2);
        expect(satOpLog[0].begin.commitTimestamp, Int64(2000));
      },
    ]);

    // fourth message is also an insert
    server.nextResponses([
      (Uint8List data) {
        expectedCount -= 1;

        final code = data[0];
        final msgType = getMsgFromCode(code);
        expect(msgType, SatMsgType.opLog);

        final satOpLog = (decode(data).msg as SatOpLog).ops;

        final lsn = satOpLog[0].begin.lsn;
        expect(bytesToNumber(lsn), 3);
        expect(satOpLog[0].begin.commitTimestamp, Int64(3000));
        completer.complete();
      },
    ]);

    final timeoutTimer = Timer(const Duration(milliseconds: 300), () {
      fail(
        'Timed out while waiting for server to get all expected requests. Missing $expectedCount',
      );
    });
    addTearDown(() => timeoutTimer.cancel());

    await client.startReplication(null, null, null);

    // wait a little for replication to start in the opposite direction
    await Future.delayed(
      const Duration(milliseconds: 100),
      () {
        client.enqueueTransaction(transaction[0]);
        client.enqueueTransaction(transaction[1]);
        client.enqueueTransaction(transaction[2]);
      },
    );

    await completer.future;
    expect(expectedCount, 0);
  });

  test('ack on send and pong', () async {
    await connectAndAuth();

    final lsn_1 = numberToBytes(1);

    final startResp = SatInStartReplicationResp();
    final pingResponse = SatPingResp(lsn: lsn_1);

    server.nextResponses([startResp]);
    server.nextResponses([]);
    server.nextResponses([pingResponse]);

    await client.startReplication(null, null, null);

    final transaction = DataTransaction(
      lsn: lsn_1,
      commitTimestamp: Int64.ZERO,
      changes: [
        DataChange(
          relation: kTestRelations['parent']!,
          type: DataChangeType.insert,
          record: {'id': 0},
          tags: [], // actual value is not relevent here
        ),
      ],
    );

    final completer = Completer<void>();

    var sent = false;
    client.subscribeToAck((event) {
      final lsn = event.lsn;
      final type = event.ackType;

      if (type == AckType.localSend) {
        expect(bytesToNumber(lsn), 1);
        sent = true;
      } else if (sent && type == AckType.remoteCommit) {
        expect(bytesToNumber(lsn), 1);
        expect(sent, true);
        completer.complete();
      }
    });

    await Future.delayed(const Duration(milliseconds: 100), () {
      client.enqueueTransaction(transaction);
    });

    await completer.future;
  });

  test('default and null test', () async {
    await connectAndAuth();

    final start = SatInStartReplicationResp();
    final begin = SatOpBegin(commitTimestamp: Int64.ZERO);
    final commit = SatOpCommit();
    final stop = SatInStopReplicationResp();

    final rel = Relation(
      id: 1,
      schema: 'schema',
      table: 'Items',
      tableType: SatRelation_RelationType.TABLE,
      columns: [
        RelationColumn(name: 'id', type: 'uuid', isNullable: false),
        RelationColumn(name: 'content', type: 'text', isNullable: false),
        RelationColumn(name: 'text_null', type: 'text', isNullable: true),
        RelationColumn(
          name: 'text_null_default',
          type: 'text',
          isNullable: true,
        ),
        RelationColumn(
          name: 'intvalue_null',
          type: 'integer',
          isNullable: true,
        ),
        RelationColumn(
          name: 'intvalue_null_default',
          type: 'integer',
          isNullable: true,
        ),
      ],
    );

    final relation = SatRelation(
      relationId: 1,
      schemaName: 'schema',
      tableName: 'table',
      tableType: SatRelation_RelationType.TABLE,
      columns: [
        SatRelationColumn(name: 'id', type: 'uuid'),
        SatRelationColumn(name: 'content', type: 'varchar'),
        SatRelationColumn(name: 'text_null', type: 'text'),
        SatRelationColumn(
          name: 'text_null_default',
          type: 'text',
        ),
        SatRelationColumn(
          name: 'intvalue_null',
          type: 'int4',
        ),
        SatRelationColumn(
          name: 'intvalue_null_default',
          type: 'int4',
        ),
      ],
    );

    final insertOp = SatOpInsert(
      relationId: 1,
      rowData: serializeRow(
        {
          'id': 'f989b58b-980d-4d3c-b178-adb6ae8222f1',
          'content': 'hello from pg_1',
          'text_null': null,
          'text_null_default': '',
          'intvalue_null': null,
          'intvalue_null_default': '10',
        },
        rel,
      ),
    );

    final serializedRow = SatOpRow(
      nullsBitmask: Uint8List.fromList([40]),
      values: [
        Uint8List.fromList([
          102,
          57,
          56,
          57,
          98,
          53,
          56,
          98,
          45,
          57,
          56,
          48,
          100,
          45,
          52,
          100,
          51,
          99,
          45,
          98,
          49,
          55,
          56,
          45,
          97,
          100,
          98,
          54,
          97,
          101,
          56,
          50,
          50,
          50,
          102,
          49,
        ]),
        Uint8List.fromList([
          104,
          101,
          108,
          108,
          111,
          32,
          102,
          114,
          111,
          109,
          32,
          112,
          103,
          95,
          49,
        ]),
        Uint8List.fromList([]),
        Uint8List.fromList([]),
        Uint8List.fromList([]),
        Uint8List.fromList([49, 48]),
      ],
    );

    final record = deserializeRow(serializedRow, rel);

    final firstOpLogMessage = SatOpLog(
      ops: [
        SatTransOp(begin: begin),
        SatTransOp(insert: insertOp),
        SatTransOp(commit: commit),
      ],
    );

    server.nextResponses([start, relation, firstOpLogMessage]);
    server.nextResponses([stop]);
    final completer = Completer<void>();

    client.on('transaction', (TransactionEvent transactionEvent) {
      final transaction = transactionEvent.transaction;
      final changes = transaction.changes.cast<DataChange>();
      expect(record!['id'], changes[0].record!['id']);
      expect(record['content'], changes[0].record!['content']);
      expect(record['text_null'], changes[0].record!['text_null']);
      completer.complete();
    });

    await client.startReplication(null, null, null);
  });

  test('subscription succesful', () async {
    await connectAndAuth();

    final startResp = SatInStartReplicationResp();
    server.nextResponses([startResp]);
    await client.startReplication(null, null, null);

    final shapeReq = ShapeRequest(
      requestId: 'fake',
      definition: ClientShapeDefinition(
        selects: [ShapeSelect(tablename: 'fake')],
      ),
    );

    const subscriptionId = 'THE_ID';
    final subsResp = SatSubsResp(subscriptionId: subscriptionId);
    server.nextResponses([subsResp]);

    final res = await client.subscribe(subscriptionId, [shapeReq]);
    expect(res.subscriptionId, subscriptionId);
  });

  test('RPC correctly handles interleaved subscribe responses', () async {
    await connectAndAuth();

    final startResp = SatInStartReplicationResp();
    server.nextResponses([startResp]);
    await client.startReplication(null, null, null);

    final shapeReq1 = ShapeRequest(
      requestId: 'fake1',
      definition: ClientShapeDefinition(
        selects: [ShapeSelect(tablename: 'fake1')],
      ),
    );

    final shapeReq2 = ShapeRequest(
      requestId: 'fake2',
      definition: ClientShapeDefinition(
        selects: [ShapeSelect(tablename: 'fake2')],
      ),
    );

    const subscriptionId1 = 'subscription id 1';
    const subscriptionId2 = 'subscription id 2';
    final subsResp1 = SatSubsResp(
      subscriptionId: subscriptionId1,
    );
    final subsResp2 = SatSubsResp(
      subscriptionId: subscriptionId2,
    );
    server.nextResponses([subsResp1, subsResp2]);

    final p1 = client.subscribe(subscriptionId1, [shapeReq1]);
    final p2 = client.subscribe(subscriptionId2, [shapeReq2]);
    final [resp1, resp2] = await Future.wait([p1, p2]);

    expect(resp1.subscriptionId, subscriptionId1);
    expect(resp2.subscriptionId, subscriptionId2);
  });

  test('listen to subscription events: error', () async {
    await connectAndAuth();

    final startResp = SatInStartReplicationResp();
    server.nextResponses([startResp]);
    await client.startReplication(null, null, null);

    final shapeReq = ShapeRequest(
      requestId: 'fake',
      definition: ClientShapeDefinition(
        selects: [ShapeSelect(tablename: 'fake')],
      ),
    );

    const subscriptionId = 'THE_ID';

    final subsResp = SatSubsResp(subscriptionId: subscriptionId);
    final subsData = SatSubsDataBegin(
      subscriptionId: subscriptionId,
    );
    final subsError = SatSubsDataError(
      code: SatSubsDataError_Code.SHAPE_DELIVERY_ERROR,
      message: 'FAKE ERROR',
      subscriptionId: subscriptionId,
    );
    server.nextResponses([subsResp, subsData, subsError]);

    void success(_) => fail('Should have failed');
    void error(_) {}

    client.subscribeToSubscriptionEvents(success, error);
    final res = await client.subscribe(subscriptionId, [shapeReq]);
    expect(res.subscriptionId, subscriptionId);
  });

  test('subscription incorrect protocol sequence', () async {
    await connectAndAuth();

    final startResp = SatInStartReplicationResp();
    server.nextResponses([startResp]);
    await client.startReplication(null, null, null);

    const requestId = 'THE_REQUEST_ID';
    const subscriptionId = 'THE_SUBS_ID';
    const shapeUuid = 'THE_SHAPE_ID';
    const tablename = 'THE_TABLE_ID';

    final shapeReq = ShapeRequest(
      requestId: requestId,
      definition: ClientShapeDefinition(
        selects: [ShapeSelect(tablename: tablename)],
      ),
    );

    final subsResp = SatSubsResp(subscriptionId: subscriptionId);
    final subsRespWithErr = SatSubsResp(
      subscriptionId: subscriptionId,
      err: SatSubsResp_SatSubsError(
        code: SatSubsResp_SatSubsError_Code.SHAPE_REQUEST_ERROR,
      ),
    );
    final beginSub = SatSubsDataBegin(subscriptionId: subscriptionId);
    final beginShape = SatShapeDataBegin(
      requestId: requestId,
      uuid: shapeUuid,
    );
    final endShape = SatShapeDataEnd();
    final endSub = SatSubsDataEnd();
    final satOpLog = SatOpLog();

    final begin = SatOpBegin(
      commitTimestamp: Int64.ZERO,
    );
    final commit = SatOpCommit();

    final insert = SatOpInsert();

    final satTransOpBegin = SatTransOp(begin: begin);
    final satTransOpInsert = SatTransOp(insert: insert);
    final satTransOpCommit = SatTransOp(commit: commit);

    final wrongSatOpLog1 = SatOpLog(
      ops: [satTransOpCommit],
    );

    final wrongSatOpLog2 = SatOpLog(
      ops: [satTransOpBegin],
    );

    final wrongSatOpLog3 = SatOpLog(
      ops: [satTransOpInsert, satTransOpBegin],
    );

    final wrongSatOpLog4 = SatOpLog(
      ops: [satTransOpInsert, satTransOpCommit],
    );

    final validSatOpLog = SatOpLog(
      ops: [satTransOpInsert, satTransOpInsert],
    );

    final testCases = [
      [subsResp, beginShape],
      [subsResp, endShape],
      [subsResp, endSub],
      [subsResp, beginSub, endShape],
      [subsResp, beginSub, beginShape, endSub],
      [subsResp, beginSub, endShape],
      [subsResp, beginSub, satOpLog],
      [subsResp, beginSub, beginShape, endShape, satOpLog],
      [subsResp, beginSub, beginShape, satOpLog, endSub],
      [subsResp, beginSub, beginShape, wrongSatOpLog1],
      [subsResp, beginSub, beginShape, wrongSatOpLog2],
      [subsResp, beginSub, beginShape, wrongSatOpLog3],
      [subsResp, beginSub, beginShape, wrongSatOpLog4],
      [subsResp, beginSub, beginShape, validSatOpLog, endShape, validSatOpLog],
      [subsRespWithErr, beginSub],
    ];

    while (testCases.isNotEmpty) {
      final next = testCases.removeAt(0);
      server.nextResponses(next);

      final completer = Completer<void>();
      void success(_) {
        completer.completeError(
          'expected the client to fail on an invalid message sequence',
        );
      }

      late SubscriptionEventListeners subListeners;
      void error(_) {
        // if (testCases.isEmpty) {
        //   t.pass()
        //   globalRes()
        // }
        client.unsubscribeToSubscriptionEvents(subListeners);
        completer.complete(null);
      }

      subListeners = client.subscribeToSubscriptionEvents(success, error);
      unawaited(client.subscribe(subscriptionId, [shapeReq, shapeReq]));

      await completer.future;
    }
  });

  test('subscription correct protocol sequence with data', () async {
    await connectAndAuth();

    final startResp = SatInStartReplicationResp();
    server.nextResponses([startResp]);
    await client.startReplication(null, null, null);

    final Relation rel = Relation(
      id: 0,
      schema: 'schema',
      table: 'table',
      tableType: SatRelation_RelationType.TABLE,
      columns: [
        RelationColumn(name: 'name1', type: 'TEXT', isNullable: true),
        RelationColumn(name: 'name2', type: 'TEXT', isNullable: true),
      ],
    );

    client.inbound.relations[0] = rel;

    const requestId1 = 'THE_REQUEST_ID_1';
    const requestId2 = 'THE_REQUEST_ID_2';
    const subscriptionId = 'THE_SUBS_ID';
    const uuid1 = 'THE_SHAPE_ID_1';
    const uuid2 = 'THE_SHAPE_ID_2';
    const tablename = 'THE_TABLE_ID';

    final shapeReq1 = ShapeRequest(
      requestId: requestId1,
      definition: ClientShapeDefinition(
        selects: [ShapeSelect(tablename: tablename)],
      ),
    );

    final shapeReq2 = ShapeRequest(
      requestId: requestId2,
      definition: ClientShapeDefinition(
        selects: [ShapeSelect(tablename: tablename)],
      ),
    );

    final subsResp = SatSubsResp(subscriptionId: subscriptionId);
    final beginSub = SatSubsDataBegin(subscriptionId: subscriptionId);
    final beginShape1 = SatShapeDataBegin(
      requestId: requestId1,
      uuid: uuid1,
    );
    final beginShape2 = SatShapeDataBegin(
      requestId: requestId2,
      uuid: uuid2,
    );
    final endShape = SatShapeDataEnd();
    final endSub = SatSubsDataEnd();

    final completer = Completer<void>();
    void success(_) {
      //t.pass()
      completer.complete(null);
    }

    void error(Object e) {
      completer.completeError((e as SatelliteException).message!);
    }

    client.subscribeToSubscriptionEvents(success, error);

    final insertOp = SatOpInsert(
      relationId: 0,
      rowData: serializeRow(
        {'name1': 'Foo', 'name2': 'Bar'},
        rel,
      ),
    );

    final satTransOpInsert = SatTransOp(insert: insertOp);

    final satOpLog1 = SatOpLog(
      ops: [satTransOpInsert],
    );

    server.nextResponses([
      subsResp,
      beginSub,
      beginShape1,
      satOpLog1,
      endShape,
      beginShape2,
      satOpLog1,
      endShape,
      endSub,
    ]);
    await client.subscribe(subscriptionId, [shapeReq1, shapeReq2]);

    await completer.future;
  });

  test(
    'unsubscribe successfull',
    () async {
      await connectAndAuth();

      final startResp = SatInStartReplicationResp();
      server.nextResponses([startResp]);
      await client.startReplication(null, null, null);

      const subscriptionId = 'THE_ID';

      final unsubResp = SatUnsubsResp();
      server.nextResponses([unsubResp]);
      final resp = await client.unsubscribe([subscriptionId]);
      expect(resp, UnsubscribeResponse());
    },
  );
}

AuthState createAuthState() {
  return AuthState(
    token: token,
    clientId: clientId,
  );
}

DecodedMessage decode(Uint8List data) {
  final code = data[0];
  final type = getMsgFromCode(code)!;
  return DecodedMessage(decodeMessage(data.sublist(1), type), type);
}
