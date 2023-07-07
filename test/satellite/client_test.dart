import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:electric_client/src/auth/auth.dart';
import 'package:electric_client/src/notifiers/mock.dart';
import 'package:electric_client/src/proto/satellite.pb.dart';
import 'package:electric_client/src/satellite/client.dart';
import 'package:electric_client/src/satellite/config.dart';
import 'package:electric_client/src/satellite/oplog.dart';
import 'package:electric_client/src/sockets/io.dart';
import 'package:electric_client/src/util/common.dart';
import 'package:electric_client/src/util/proto.dart';
import 'package:electric_client/src/util/types.dart';
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
      ),
    );
    clientId = '91eba0c8-28ba-4a86-a6e8-42731c2c6694';

    token = 'fake_token';
  });

  tearDown(() async {
    await client.close();
    await server.close();
  });

  test('connect success', () async {
    await client.connect();
  });

  test('connection backoff success', () async {
    await server.close();

    bool passed = false;

    bool retry(Object _e, int a) {
      if (a > 0) {
        passed = true;
        return false;
      }
      return true;
    }

    try {
      await client.connect(retryHandler: retry);
    } catch (e) {
      //
    }

    expect(passed, isTrue);
  });

  test('connection backoff failure', () async {
    await server.close();

    bool retry(Object _e, int a) {
      if (a > 0) {
        return false;
      }
      return true;
    }

    try {
      await client.connect(retryHandler: retry);
      fail("Should have failed");
    } catch (e) {
      // Should pass
    }
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
      await client.startReplication(null, null);
      fail("start replication should throw");
    } catch (error) {
      expect(
        error,
        isA<SatelliteException>()
            .having((e) => e.code, "code", SatelliteErrorCode.timeout),
      );
    }
  });

  test('authentication success', () async {
    await client.connect();

    final authResp = SatAuthResp(id: 'server_identity');
    server.nextResponses([authResp]);

    final res = await client.authenticate(createAuthState());
    expect(
      res.getOrElse((l) => throw StateError("auth error")).serverId,
      'server_identity',
    );
    expect(client.inbound.authenticated, isTrue);
  });

  test('replication start success', () async {
    await connectAndAuth();

    final startResp = SatInStartReplicationResp();
    server.nextResponses([startResp]);

    await client.startReplication(null, null);
  });

  test('replication start sends FIRST_LSN', () async {
    await connectAndAuth();
    final completer = Completer<void>();

    server.nextResponses([
      (Uint8List data) {
        final code = data[0];
        final msgType = getMsgFromCode(code);

        if (msgType == SatMsgType.inStartReplicationReq) {
          final decodedMsg = decode(data);
          expect(
            (decodedMsg.msg as SatInStartReplicationReq).options[0],
            SatInStartReplicationReq_Option.FIRST_LSN,
          );
          completer.complete();
        }
      },
    ]);
    unawaited(client.startReplication(null, null));
    await completer.future;
  });

  test('replication start failure', () async {
    await connectAndAuth();

    final startResp = SatInStartReplicationResp();
    server.nextResponses([startResp]);

    try {
      await client.startReplication(null, null);
      await client.startReplication(null, null); // fails
    } catch (error) {
      expect(
        error,
        isA<SatelliteException>().having(
          (e) => e.code,
          "code",
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

    await client.startReplication(null, null);
    await client.stopReplication();
  });

  test('replication stop failure', () async {
    await connectAndAuth();

    final stop = SatInStopReplicationResp();
    server.nextResponses([stop]);

    try {
      await client.stopReplication();
      fail("stop replication should throw");
    } catch (error) {
      expect(
        error,
        isA<SatelliteException>().having(
          (e) => e.code,
          "code",
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

    await client.startReplication(null, null);
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
        RelationColumn(name: 'name1', type: 'TEXT'),
        RelationColumn(name: 'name2', type: 'TEXT'),
      ],
    );

    final relation = SatRelation(
      relationId: 1,
      schemaName: 'schema',
      tableName: 'table',
      tableType: SatRelation_RelationType.TABLE,
      columns: [
        SatRelationColumn(name: 'name1', type: 'TEXT'),
        SatRelationColumn(name: 'name2', type: 'TEXT'),
      ],
    );

    final insertOp = SatOpInsert(
      relationId: 1,
      rowData: serializeRow({"name1": 'Foo', "name2": 'Bar'}, rel),
    );

    final updateOp = SatOpUpdate(
      relationId: 1,
      rowData: serializeRow({"name1": 'Hello', "name2": 'World!'}, rel),
      oldRowData: serializeRow({"name1": '', "name2": ''}, rel),
    );
    final deleteOp = SatOpDelete(
      relationId: 1,
      oldRowData: serializeRow({"name1": 'Hello', "name2": 'World!'}, rel),
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

    await client.startReplication(null, null);
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

    await client.startReplication(null, null);
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
    ];

    final transaction = toTransactions(opLogEntries, kTestRelations);

    final completer = Completer<void>();
    server.nextResponses([startResp]);
    server.nextResponses([]);

    // first message is a relation
    server.nextResponses([
      (Uint8List data) {
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
        final code = data[0];
        final msgType = getMsgFromCode(code);

        if (msgType == SatMsgType.opLog) {
          final satOpLog = (decode(data).msg as SatOpLog).ops;

          final lsn = satOpLog[0].begin.lsn;
          expect(bytesToNumber(lsn), 1);
          expect(satOpLog[0].begin.commitTimestamp, Int64(1000));
          // TODO: check values
        }
      },
    ]);

    // third message after new enqueue does not send relation
    server.nextResponses([
      (Uint8List data) {
        final code = data[0];
        final msgType = getMsgFromCode(code);

        if (msgType == SatMsgType.opLog) {
          final satOpLog = (decode(data).msg as SatOpLog).ops;

          final lsn = satOpLog[0].begin.lsn;
          expect(bytesToNumber(lsn), 2);
          expect(satOpLog[0].begin.commitTimestamp, Int64(2000));
          // TODO: check values
        }
        completer.complete();
      },
    ]);

    await client.startReplication(null, null);

    // wait a little for replication to start in the opposite direction
    await Future.delayed(
      const Duration(milliseconds: 100),
      () {
        client.enqueueTransaction(transaction[0]);
        client.enqueueTransaction(transaction[1]);
      },
    );
  });

  test('ack on send and pong', () async {
    await connectAndAuth();

    final lsn_1 = numberToBytes(1);

    final startResp = SatInStartReplicationResp();
    final pingResponse = SatPingResp(lsn: lsn_1);

    server.nextResponses([startResp]);
    server.nextResponses([]);
    server.nextResponses([pingResponse]);

    await client.startReplication(null, null);

    final transaction = DataTransaction(
      lsn: lsn_1,
      commitTimestamp: Int64.ZERO,
      changes: [
        DataChange(
          relation: kTestRelations["parent"]!,
          type: DataChangeType.insert,
          record: {"id": 0},
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
        RelationColumn(name: 'id', type: 'uuid'),
        RelationColumn(name: 'content', type: 'text'),
        RelationColumn(name: 'text_null', type: 'text'),
        RelationColumn(name: 'text_null_default', type: 'text'),
        RelationColumn(name: 'intvalue_null', type: 'integer'),
        RelationColumn(name: 'intvalue_null_default', type: 'integer'),
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
          "id": 'f989b58b-980d-4d3c-b178-adb6ae8222f1',
          "content": 'hello from pg_1',
          "text_null": null,
          "text_null_default": '',
          "intvalue_null": null,
          "intvalue_null_default": '10',
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

    await client.startReplication(null, null);
  });
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
