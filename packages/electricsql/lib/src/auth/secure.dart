import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:electricsql/src/auth/auth.dart';
import 'package:electricsql/src/auth/decode.dart';

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
  final payload = jwtDecode(token);
  if (payload['sub'] == null && payload['user_id'] == null) {
    throw ArgumentError('Token does not contain a sub or user_id claim');
  }

  return DecodedJWT(
    payload,
    sub: payload['sub'] as String?,
    userId: payload['user_id'] as String?,
  );
}

/// Retrieves the user ID encoded in the JWT token
/// @param token the encoded JWT token
/// @returns {Uuid} the user ID found in the `sub` or `user_id` claim
String decodeUserIdFromToken(String token) {
  final decoded = decodeToken(token);

  // `sub` is the standard claim, but `user_id` is also used in the Electric service
  // We first check for sub, and if it's not present, we use user_id
  return decoded.sub ?? decoded.userId!;
}

class DecodedJWT {
  final Map<String, Object?> jwtPayload;

  final String? sub;
  final String? userId;

  DecodedJWT(
    this.jwtPayload, {
    required this.sub,
    required this.userId,
  });
}
