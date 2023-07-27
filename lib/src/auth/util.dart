import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

Future<String> authToken({String? iss, String? key}) async {
  final mockIss = iss ?? 'dev.electric-sql.com';
  final mockKey = key ?? 'integration-tests-signing-key-example';

  final iat = DateTime.now().millisecondsSinceEpoch / 1000 - 1000;

  final jwt = JWT(
    {
      'type': 'access',
      'user_id': 'test-user',
      'iat': iat,
    },
    issuer: mockIss,
  );

  final signed = jwt.sign(
    SecretKey(mockKey),
    algorithm: JWTAlgorithm.HS256,
    expiresIn: const Duration(hours: 2),
  );

  return signed;
}
