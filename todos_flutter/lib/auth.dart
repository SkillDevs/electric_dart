import 'package:electricsql_flutter/electricsql_flutter.dart';

// Generate an insecure authentication JWT.
// See https://electric-sql.com/docs/usage/auth for more details.
String authToken(String userId) {
  final claims = {'user_id': userId};

  return insecureAuthToken(claims);
}
