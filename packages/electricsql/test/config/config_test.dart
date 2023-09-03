import 'package:electricsql/src/auth/auth.dart';
import 'package:electricsql/src/config/config.dart';
import 'package:test/test.dart';

void main() {
  test('hydrateConfig adds expected defaults', () {
    final hydrated = hydrateConfig(
      ElectricConfig(
        auth: const AuthConfig(
          token: 'test-token',
        ),
      ),
    );

    expect(hydrated.replication.host, '127.0.0.1');
    expect(hydrated.replication.port, 5133);
    expect(hydrated.replication.ssl, false);

    expect(hydrated.auth.token, 'test-token');

    //expect(hydrated.debug, false);
  });

  test('custom config', () {
    final hydrated = hydrateConfig(
      ElectricConfig(
        auth: const AuthConfig(
          token: 'test-token-2',
        ),
        url: 'https://192.169.2.10',
        //debug: true,
      ),
    );

    expect(hydrated.replication.host, '192.169.2.10');
    expect(hydrated.replication.port, 443);
    expect(hydrated.replication.ssl, true);

    expect(hydrated.auth.token, 'test-token-2');

    //expect(hydrated.debug, true);
  });

  test('port inference', () {
    final httpConfig = hydrateConfig(
      ElectricConfig(
        auth: const AuthConfig(
          token: 'test-token-3',
        ),
        url: 'http://1.1.1.1',
      ),
    );

    expect(httpConfig.replication.port, 80);
    expect(httpConfig.replication.ssl, false);

    final httpsConfig = hydrateConfig(
      ElectricConfig(
        auth: const AuthConfig(
          token: 'test-token-3',
        ),
        url: 'https://1.1.1.1',
      ),
    );

    expect(httpsConfig.replication.port, 443);
    expect(httpsConfig.replication.ssl, true);
  });

  test('ssl', () {
    final httpsConfig = hydrateConfig(
      ElectricConfig(
        auth: const AuthConfig(
          token: 'test-token-3',
        ),
        url: '1.1.1.1?ssl=true',
      ),
    );

    expect(httpsConfig.replication.ssl, true);
  });
}
