import 'dart:convert';

import 'package:electricsql/src/auth/auth.dart';

String insecureAuthToken(TokenClaims claims) {
  final header = {
    'alg': 'none',
  };

  return '${encode(header)}.${encode(claims)}.';
}

String encode(Map<String, Object?> data) {
  final str = json.encode(data);
  final encoded = base64Url.encode(utf8.encode(str));
  return encoded;
}
