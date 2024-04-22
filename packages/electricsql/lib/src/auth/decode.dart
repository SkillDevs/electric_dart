import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

/// Decodes a JWT token into a JWT payload.
///
/// @param token the JWT token to decode
/// @returns the decoded payload
Map<String, Object?> jwtDecode(String token) {
  try {
    final decoded = JWT.decode(token);

    final dynamic payloadDyn = decoded.payload;
    if (payloadDyn is! Map<String, Object?>) {
      throw InvalidTokenException('Token payload is not a JSON object');
    } else {
      return payloadDyn;
    }
  } on JWTException catch (e) {
    throw InvalidTokenException(e.toString());
  }
}

class InvalidTokenException implements Exception {
  final String message;

  InvalidTokenException(this.message);

  @override
  String toString() {
    return 'InvalidTokenException: $message';
  }
}
