import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:electricsql/src/auth/auth.dart';

export 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart' show JWTAlgorithm;

Future<String> secureAuthToken({
  required TokenClaims claims,
  required String iss,
  required String key,
  JWTAlgorithm? alg,
  Duration? exp,
}) async {
  final algorithm = alg ?? JWTAlgorithm.HS256;
  final expiration = exp ?? const Duration(hours: 2);

  // final mockIss = iss ?? 'dev.electric-sql.com';
  // final mockKey = key ?? 'integration-tests-signing-key-example';

  final int nowInSecs = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  // Subtract 1 second to account for clock precision when validating the token
  final iat = nowInSecs - 1;

  final jwt = JWT(
    {
      ...claims,
      'iat': iat,
      'type': 'access',
    },
    issuer: iss,
  );

  final signed = jwt.sign(
    SecretKey(key),
    algorithm: algorithm,
    expiresIn: expiration,
    // We are providing a custom iat, so don't let it automatically
    // generate one.
    noIssueAt: true,
  );

  return signed;
}

Future<String> mockSecureAuthToken({
  String? iss,
  String? key,
}) {
  final mockIss = iss ?? 'dev.electric-sql.com';
  final mockKey = key ?? 'integration-tests-signing-key-example';

  return secureAuthToken(
    claims: {'sub': 'test-user'},
    iss: mockIss,
    key: mockKey,
  );
}
