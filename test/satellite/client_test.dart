import 'dart:async';
import 'dart:typed_data';

import 'package:electric_client/auth/auth.dart';
import 'package:electric_client/proto/satellite.pb.dart';
import 'package:electric_client/satellite/client.dart';
import 'package:electric_client/satellite/config.dart';
import 'package:electric_client/sockets/io.dart';
import 'package:electric_client/util/proto.dart';
import 'package:electric_client/util/types.dart';
import 'package:electric_client/util/types.dart';
import 'package:test/test.dart';

import 'server_ws_stub.dart';

late SatelliteWSServerStub server;
// TODO: Client interface
late SatelliteClient client;
late String clientId;
late String app;
late String env;
late String token;

void main() {
  setUp(() async {
    server = SatelliteWSServerStub();
    await server.start();

    const dbName = 'dbName';

    client = SatelliteClient(
      dbName: dbName,
      socketFactory: WebSocketIOFactory(),
      //MockNotifier(dbName),
      opts: SatelliteClientOpts(
        host: '127.0.0.1',
        port: 30002,
        timeout: 10000,
        ssl: false,
      ),
    );
    clientId = '91eba0c8-28ba-4a86-a6e8-42731c2c6694';

    app = 'fake_id';
    env = 'default';
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
    server.close();

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
    server.close();

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
      await client.startReplication(null);
      fail("start replication should throw");
    } catch (error) {
      print("HEYE");
      expect(error, isA<SatelliteException>().having((e) => e.code, "code", SatelliteErrorCode.timeout));
    }
  });

  test('authentication success', () async {
    await client.connect();

    final authResp = SatAuthResp(id: 'server_identity');
    server.nextResponses([authResp]);

    final res = await client.authenticate(createAuthState());
    expect(res.serverId, 'server_identity');
    expect(client.inbound.authenticated, isTrue);
  });

  test('replication start success', () async {
    await connectAndAuth();

    final startResp = SatInStartReplicationResp();
    server.nextResponses([startResp]);

    await client.startReplication(null);
  });

  test('replication start sends FIRST_LSN', () async {
    await connectAndAuth();
    final completer = Completer();

    server.nextResponses([
      (Uint8List data) {
        final code = data[0];
        final msgType = getMsgFromCode(code);

        if (msgType == SatMsgType.inStartReplicationReq) {
          final decodedMsg = client.toMessage(data);
          expect((decodedMsg.msg as SatInStartReplicationReq).options[0], SatInStartReplicationReq_Option.FIRST_LSN);
          completer.complete();
        }
      },
    ]);
    client.startReplication(null);
    await completer.future;
  });

  test('replication start failure', () async {
    await connectAndAuth();

    final startResp = SatInStartReplicationResp();
    server.nextResponses([startResp]);

    try {
      await client.startReplication(null);
      await client.startReplication(null); // fails
    } catch (error) {
      expect(
        error,
        isA<SatelliteException>().having((e) => e.code, "code", SatelliteErrorCode.replicationAlreadyStarted),
      );
    }
  });

  test('replication stop success', () async {
    await connectAndAuth();

    final start = SatInStartReplicationResp();
    final stop = SatInStopReplicationResp();
    server.nextResponses([start]);
    server.nextResponses([stop]);

    await client.startReplication(null);
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
        isA<SatelliteException>().having((e) => e.code, "code", SatelliteErrorCode.replicationNotStarted),
      );
    }
  });
}

AuthState createAuthState() {
  return AuthState(app: app, env: env, token: token, clientId: clientId, refreshToken: null);
}
