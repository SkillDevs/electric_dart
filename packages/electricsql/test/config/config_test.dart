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

    expect(hydrated.replication.host, 'localhost');
    expect(hydrated.replication.port, 5133);
    expect(hydrated.replication.ssl, false);
    expect(hydrated.replication.timeout, const Duration(milliseconds: 3000));

    expect(hydrated.auth.token, 'test-token');

    //expect(hydrated.debug, false);
  });

  test('hydrateConfig custom config', () {
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

  test('hydrateConfig port inference', () {
    final expectations = <String, ({int port, bool ssl})>{
      'http': (
        port: 80,
        ssl: false,
      ),
      'https': (
        port: 443,
        ssl: true,
      ),
      'electric': (
        port: 80,
        ssl: false,
      ),
      'ws': (
        port: 80,
        ssl: false,
      ),
      'wss': (
        port: 443,
        ssl: true,
      ),
    };

    for (final scheme in expectations.keys) {
      final expected = expectations[scheme]!;

      final config = hydrateConfig(
        ElectricConfig(
          auth: const AuthConfig(
            token: 'test-token-3',
          ),
          url: '$scheme://1.1.1.1',
        ),
      );
      expect(config.replication.port, expected.port);
      expect(config.replication.ssl, expected.ssl);
    }
  });

  test('hydrateConfig ssl', () {
    final httpsConfig = hydrateConfig(
      ElectricConfig(
        auth: const AuthConfig(
          token: 'test-token-3',
        ),
        url: 'http://1.1.1.1?ssl=true',
      ),
    );

    expect(httpsConfig.replication.ssl, true);
  });

  test('hydrateConfig checks for auth token', () {
    expect(
      () => hydrateConfig(
        ElectricConfig(
          auth: const AuthConfig(
            token: '',
          ),
        ),
      ),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'message',
          'Exception: Invalid configuration. Missing authentication token.',
        ),
      ),
    );
  });

  test('hydrateConfig checks for valid service url', () {
    final errorReasons = <String, String?>{
      'postgresql://somehost.com': 'Invalid url protocol.',
      'https://user@somehost.com': 'Username and password are not supported.',
      'https://user:pass@somehost.com':
          'Username and password are not supported.',
      // No reason, but it returns an invalid url error as well
      'https://somehost.com:wrongport': null,
    };

    for (final MapEntry(key: url, value: reason) in errorReasons.entries) {
      String expectedErrorMsg = "Invalid 'url' in the configuration.";
      if (reason != null) {
        expectedErrorMsg = '$expectedErrorMsg $reason';
      }

      expect(
        () => hydrateConfig(
          ElectricConfig(
            auth: const AuthConfig(
              token: 'test-token',
            ),
            url: url,
          ),
        ),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            'Exception: $expectedErrorMsg',
          ),
        ),
      );
    }
  });
}
