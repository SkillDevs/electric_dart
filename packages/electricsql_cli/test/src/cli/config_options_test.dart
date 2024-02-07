import 'package:electricsql_cli/src/config_options.dart';
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
];

void main() {
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
}
