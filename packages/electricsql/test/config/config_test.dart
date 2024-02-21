import 'package:electricsql/src/auth/auth.dart';
import 'package:electricsql/src/config/config.dart';
import 'package:test/test.dart';

import '../support/log_mock.dart';

final log = <String>[];

void main() {
  setupLoggerMock(() => log);

  test('hydrateConfig adds expected defaults', () {
    final hydrated = hydrateConfig(
      ElectricConfig(),
    );

    expect(hydrated.replication.host, 'localhost');
    expect(hydrated.replication.port, 5133);
    expect(hydrated.replication.ssl, false);
    expect(hydrated.replication.timeout, const Duration(milliseconds: 3000));

    expect(hydrated.auth, const AuthConfig());

    //expect(hydrated.debug, false);
  });

  test('hydrateConfig custom config', () {
    final hydrated = hydrateConfig(
      ElectricConfig(
        auth: const AuthConfig(
          clientId: 'some-id',
        ),
        url: 'https://192.169.2.10',
        //debug: true,
      ),
    );

    expect(hydrated.replication.host, '192.169.2.10');
    expect(hydrated.replication.port, 443);
    expect(hydrated.replication.ssl, true);

    expect(hydrated.auth.clientId, 'some-id');

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
        url: 'http://1.1.1.1?ssl=true',
      ),
    );

    expect(httpsConfig.replication.ssl, true);
  });

  test('throws for invalid service url', () {
    const urls = ['', 'https://somehost.com:wrongport', 'abc'];

    for (final url in urls) {
      const expectedErrorMsg = "Invalid 'url' in the configuration.";

      expect(
        () => hydrateConfig(
          ElectricConfig(
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
        reason: "url '$url' didn't throw an exception",
      );
    }
  });

  test('hydrateConfig warns unexpected service urls', () {
    const warnReasons = {
      'postgresql://somehost.com': ['Unsupported URL protocol.'],
      // For now don't check other parts of the URLs
      // Curently a draft PR: https://github.com/electric-sql/electric/pull/826
      /* 'https://user@somehost.com': ['Username and password are not supported.'],
      'custom://user:pass@somehost.com': [
        'Unsupported URL protocol.',
        'Username and password are not supported.',
      ],
      'http://somehost.com:1234/some/path': ['An URL path is not supported.'], */
    };

    for (final MapEntry(key: url, value: reasons) in warnReasons.entries) {
      // Cleanup logs between urls
      log.clear();

      String expectedWarningMsg = "Unexpected 'url' in the configuration.";
      if (reasons.isNotEmpty) {
        expectedWarningMsg += ' ${reasons.join(' ')}';
      }
      expectedWarningMsg +=
          " An URL like 'http(s)://<host>:<port>' is expected.";

      hydrateConfig(
        ElectricConfig(
          url: url,
        ),
      );

      expect(log, [expectedWarningMsg]);
    }
  });
}
