import 'package:electricsql_cli/src/config_options.dart';
import 'package:electricsql_cli/src/util/util.dart';
import 'package:test/test.dart';

const expectedEnvVars = <String>[
  'SERVICE',
  'PROXY',
  'CLIENT_PATH',
  'SERVICE_HOST',
  'PG_PROXY_HOST',
  'WITH_POSTGRES',
  'DATABASE_URL',
  'DATABASE_HOST',
  'DATABASE_PORT',
  'DATABASE_USER',
  'DATABASE_PASSWORD',
  'DATABASE_NAME',
  'DATABASE_REQUIRE_SSL',
  'DATABASE_USE_IPV6',
  'ELECTRIC_USE_IPV6',
  'LOGICAL_PUBLISHER_HOST',
  'LOGICAL_PUBLISHER_PORT',
  'HTTP_PORT',
  'PG_PROXY_PORT',
  'PG_PROXY_PASSWORD',
  'ELECTRIC_WRITE_TO_PG_MODE',
  'AUTH_MODE',
  'AUTH_JWT_ALG',
  'AUTH_JWT_KEY',
  'AUTH_JWT_NAMESPACE',
  'AUTH_JWT_ISS',
  'AUTH_JWT_AUD',
  'ELECTRIC_TELEMETRY',
  'POSTGRESQL_IMAGE',
  'ELECTRIC_IMAGE',
  'CONTAINER_NAME',
  'ELECTRIC_FEATURES',
];

void main() {
  setDebugMockParsedPubspecLockInfo();

  test('assert that all expected env vars are options for CLI', () {
    for (final varName in expectedEnvVars) {
      expect(
        configOptions[varName] != null,
        isTrue,
        reason: 'Environment variable $varName is missing from CLI',
      );
    }

    expect(
      configOptions.length,
      expectedEnvVars.length,
      reason: 'CLI options do not match expected environment variables',
    );
  });

  test('assert Electric is in logical_replication mode by default', () {
    expect(
      configOptions['ELECTRIC_WRITE_TO_PG_MODE']!.getDefaultValue({})!(),
      'logical_replication',
    );
  });

  test('assert IPv6 is enabled by default', () {
    expect(configOptions['DATABASE_USE_IPV6']!.getDefaultValue({})!(), true);
    expect(configOptions['ELECTRIC_USE_IPV6']!.getDefaultValue({})!(), true);
  });

  test('assert SSL is disabled by default', () {
    expect(
      configOptions['DATABASE_REQUIRE_SSL']!.getDefaultValue({})!(),
      false,
    );
  });

  test('assert authentication mode is insecure by default', () {
    expect(configOptions['AUTH_MODE']!.getDefaultValue({})!(), 'insecure');
  });

  test('assert database name is correctly inferred', () {
    // infer from db url
    expect(
      configOptions['DATABASE_NAME']!.inferVal!({
        'databaseUrl': 'postgres://db_user:db_password@db_host:123/db_name',
      }),
      'db_name',
    );

    // infer from proxy url if db url missing
    expect(
      configOptions['DATABASE_NAME']!.inferVal!({
        'proxy': 'postgres://db_user:db_password@db_host:123/db_name',
      }),
      'db_name',
    );

    // prefer db over proxy for name
    expect(
      configOptions['DATABASE_NAME']!.inferVal!({
        'databaseUrl': 'postgres://db_user:db_password@db_host:123/db_name',
        'proxy': 'postgres://db_user:db_password@db_host:123/proxy_db_name',
      }),
      'db_name',
    );

    // ignores query parameters in the URL
    expect(
      configOptions['DATABASE_NAME']!.inferVal!({
        'databaseUrl':
            'postgres://db_user:db_password@db_host:123/db_name?sslmode=disable',
      }),
      'db_name',
    );

    expect(
      configOptions['DATABASE_NAME']!.inferVal!({
        'proxy':
            'postgres://db_user:db_password@db_host:123/db_name?sslmode=require',
      }),
      'db_name',
    );

    // correctly decodes encoded characters
    expect(
      configOptions['DATABASE_NAME']!.inferVal!({
        'databaseUrl':
            'postgres://db_user:db_password@db_host:123/odd%3Adb%2Fname',
      }),
      'odd:db/name',
    );

    expect(
      configOptions['DATABASE_NAME']!.inferVal!({
        'proxy': 'postgres://db_user:db_password@db_host:123/odd%3Adb%2Fname',
      }),
      'odd:db/name',
    );
  });

  test('assert DATABASE_URL may contain percent-encoded characters', () {
    const dbUrl =
        'postgresql://test%2Bemail%40example.com:12%2B34@example.%63om/odd%3Adb%2Fname';

    expect(
      configOptions['DATABASE_HOST']!.inferVal!({'databaseUrl': dbUrl}),
      'example.com',
    );
    expect(
      configOptions['DATABASE_USER']!.inferVal!({'databaseUrl': dbUrl}),
      'test+email@example.com',
    );
    expect(
      configOptions['DATABASE_PASSWORD']!.inferVal!({'databaseUrl': dbUrl}),
      '12+34',
    );
  });

  test(
      'assert DATABASE_PORT is inferred to the default value when not present in the URL',
      () {
    const dbUrl = 'postgresql://user:@example.com/db';

    expect(
      configOptions['DATABASE_PORT']!.inferVal!({'databaseUrl': dbUrl}),
      5432,
    );
    expect(configOptions['DATABASE_PORT']!.inferVal!({'proxy': dbUrl}), 5432);
  });

  test(
      'assert PG_PROXY_PORT is inferred to the default value when not present in the URL',
      () {
    const proxyUrl = 'postgresql://user:@example.com/db';
    expect(
      configOptions['PG_PROXY_PORT']!.inferVal!({'proxy': proxyUrl}),
      '65432',
    );
  });
}
