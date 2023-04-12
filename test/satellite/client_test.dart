import 'package:electric_client/auth/auth.dart';
import 'package:electric_client/proto/satellite.pb.dart';
import 'package:electric_client/satellite/client.dart';
import 'package:electric_client/satellite/config.dart';
import 'package:electric_client/sockets/io.dart';
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
    server.close();
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

  test('authentication success', () async {
    await client.connect();

    final authResp = SatAuthResp(id: 'server_identity');
    server.nextResponses([authResp]);

    final res = await client.authenticate(createAuthState());
    expect(res.serverId, 'server_identity');
    expect(client.inbound.authenticated, isTrue);
  });
}

AuthState createAuthState() {
  return AuthState(app: app, env: env, token: token, clientId: clientId, refreshToken: null);
}
