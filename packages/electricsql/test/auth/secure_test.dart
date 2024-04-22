import 'package:electricsql/src/auth/decode.dart';
import 'package:electricsql/src/auth/secure.dart';
import 'package:test/test.dart';

void main() {
  test('secureAuthToken generates expected JWT token', () async {
    final token = await secureAuthToken(
      claims: {'sub': 'test-user'},
      iss: 'test-issuer',
      key: 'test-key',
    );

    expect(token, matches(RegExp(r'^eyJh[\w-.]+$')));
    final decodedToken = jwtDecode(token);
    expect(decodedToken['sub'], 'test-user');
    expect(decodedToken['iss'], 'test-issuer');
  });
}
