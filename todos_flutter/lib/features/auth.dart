import 'package:electricsql/util.dart';
import 'package:electricsql_flutter/electricsql_flutter.dart';

// This is just a demo. In a real app, the user ID would
// usually come from somewhere else :)
final dummyUserId = genUUID();

// Generate an insecure authentication JWT.
// See https://electric-sql.com/docs/usage/auth for more details.
String authToken() {
  final claims = {'sub': dummyUserId};

  return insecureAuthToken(claims);
}
