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

  final int iat = DateTime.now().millisecondsSinceEpoch ~/ 1000;

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
  Duration? exp,
  String? iss,
  String? key,
}) {
  final mockIss = iss ?? 'dev.electric-sql.com';
  final mockKey = key ?? 'integration-tests-signing-key-example';

  return secureAuthToken(
    claims: {'sub': 'test-user'},
    iss: mockIss,
    key: mockKey,
    exp: exp,
  );
}

DecodedJWT decodeToken(String token) {
  final decoded = JWT.decode(token);
  final dynamic payload = decoded.payload;
  if (payload is! Map<String, dynamic> ||
      payload['sub'] == null ||
      payload['sub'] is! String) {
    throw ArgumentError('Token does not contain a sub claim');
  }

  return DecodedJWT(decoded, sub: payload['sub'] as String);
}

class DecodedJWT {
  final JWT jwt;

  final String sub;

  DecodedJWT(this.jwt, {required this.sub});
}
