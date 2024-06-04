import 'package:electricsql_cli/src/util/util.dart';
import 'package:test/test.dart';

void main() {
  test('extractServiceURL decomposes electric URL', () async {
    expect(extractServiceURL('http://localhost:5133'), {
      'host': 'localhost',
      'port': 5133,
    });

    expect(extractServiceURL('https://www.my-website.com'), {
      'host': 'www.my-website.com',
      'port': null,
    });

    expect(extractServiceURL('https://www.my-website.com:8132'), {
      'host': 'www.my-website.com',
      'port': 8132,
    });
  });

  final postgresUrlExamples = {
    'postgresql://postgres:password@example.com:5432/app-db': {
      'user': 'postgres',
      'password': 'password',
      'host': 'example.com',
      'port': 5432,
      'dbName': 'app-db',
    },
    'postgresql://electric@192.168.111.33:81/__shadow': {
      'user': 'electric',
      'password': '',
      'host': '192.168.111.33',
      'port': 81,
      'dbName': '__shadow',
    },
    'postgresql://pg@[2001:db8::1234]:4321': {
      'user': 'pg',
      'password': '',
      'host': '2001:db8::1234', // Dart removes the square brackets for ipv6
      'port': 4321,
      'dbName': 'pg',
    },
    'postgresql://user@localhost:5433/': {
      'user': 'user',
      'password': '',
      'host': 'localhost',
      'port': 5433,
      'dbName': 'user',
    },
    'postgresql://user%2Btesting%40gmail.com:weird%2Fpassword@localhost:5433/my%2Bdb%2Bname':
        {
      'user': 'user+testing@gmail.com',
      'password': 'weird/password',
      'host': 'localhost',
      'port': 5433,
      'dbName': 'my+db+name',
    },
    'postgres://super_user@localhost:7801/postgres': {
      'user': 'super_user',
      'password': '',
      'host': 'localhost',
      'port': 7801,
      'dbName': 'postgres',
    },
  };

  test('extractDatabaseURL should parse valid URLs', () {
    for (final entry in postgresUrlExamples.entries) {
      final url = entry.key;
      final expected = entry.value;
      expect(extractDatabaseURL(url), expected);
    }
  });

  test('extractDatabaseURL throws for invalid URL scheme', () {
    const url = 'postgrex://localhost';
    expect(
      () => extractDatabaseURL(url),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'message',
          'Exception: Invalid database URL: $url',
        ),
      ),
    );
  });

  test('extractDatabaseURL throws for missing username', () {
    const url1 = 'postgresql://localhost';
    expect(
      () => extractDatabaseURL(url1),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'message',
          'Exception: Invalid or missing username: $url1',
        ),
      ),
    );

    const url2 = 'postgresql://:@localhost';
    expect(
      () => extractDatabaseURL(url2),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'message',
          'Exception: Invalid or missing username: $url2',
        ),
      ),
    );

    const url3 = 'postgresql://:password@localhost';
    expect(
      () => extractDatabaseURL(url3),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'message',
          'Exception: Invalid or missing username: $url3',
        ),
      ),
    );
  });

  test('extractDatabaseURL throws for missing host', () {
    const url = 'postgresql://user:password@';
    expect(
      () => extractDatabaseURL(url),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'message',
          'Exception: Invalid database URL: $url',
        ),
      ),
    );
  });

  test('parsePgProxyPort parses regular port number', () async {
    expect(
      parsePgProxyPort('5133'),
      (
        http: false,
        port: 5133,
      ),
    );

    expect(
      parsePgProxyPort('65432'),
      (
        http: false,
        port: 65432,
      ),
    );
  });

  test('parsePgProxyPort http proxy port', () async {
    expect(
      parsePgProxyPort('http:5133'),
      (
        http: true,
        port: 5133,
      ),
    );

    expect(
      parsePgProxyPort('random:5133'),
      (
        http: false,
        port: 5133,
      ),
    );
  });

  test('parsePgProxyPort http proxy with default port', () async {
    expect(
      parsePgProxyPort('http'),
      (
        http: true,
        port: 65432,
      ),
    );

    expect(
      () => parsePgProxyPort('test'),
      throwsA(
        isA<ConfigException>().having(
          (e) => e.message,
          'message',
          'Invalid port: test.',
        ),
      ),
    );
  });
}
