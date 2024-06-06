import 'package:electricsql_cli/src/config.dart';
import 'package:electricsql_cli/src/util/util.dart';
import 'package:test/test.dart';

void main() {
  setDebugMockParsedPubspecLockInfo();

  test('getConfigValue can capture `ELECTRIC_` prefixed CLI opitons', () {
    final image =
        getConfigValue<String>('ELECTRIC_IMAGE', {'image': 'electric:test'});
    final writeToPgMode = getConfigValue<String>('ELECTRIC_WRITE_TO_PG_MODE', {
      'writeToPgMode': 'test',
    });

    expect(image, 'electric:test');
    expect(writeToPgMode, 'test');
  });

  test('redactConfigValue redacts value in all of the config', () {
    final config = Config({
      'ELECTRIC_IMAGE': 'electric:test',
      'PROXY':
          'postgresql://postgres:proxy_password@localhost:65432/test?sslmode=disable',
      'PG_PROXY_PASSWORD': 'proxy_password',
      'ELECTRIC_WRITE_TO_PG_MODE': 'test',
      'DATABASE_URL': 'postgresql://postgres:db_password@postgres:5432/test',
      'DATABASE_PASSWORD': 'db_password',
      'RANDOM_KEY_NOT_IN_CONFIG': 'foo',
    });
    expect(redactConfigSecrets(config).map, {
      ...config.map,
      'DATABASE_URL': 'postgresql://postgres:******@postgres:5432/test',
      'DATABASE_PASSWORD': '******',
      'PROXY':
          'postgresql://postgres:******@localhost:65432/test?sslmode=disable',
      'PG_PROXY_PASSWORD': '******',

      // should still include value outside of the config
      'RANDOM_KEY_NOT_IN_CONFIG': 'foo',
    });
  });
}
