String buildDatabaseURL({
  required String user,
  required String password,
  required String host,
  required int port,
  required String dbName,
  bool? ssl,
}) {
  final encodedUser = Uri.encodeComponent(user);
  final encodedPassword = password.replaceAll('@', '%40');
  final uri = Uri(
    scheme: 'postgresql',
    userInfo: password.isEmpty ? encodedUser : '$encodedUser:$encodedPassword',
    host: host,
    port: port,
    path: dbName,
    queryParameters: (ssl != null)
        ? {
            'sslmode': ssl ? 'require' : 'disable',
          }
        : null,
  );
  return uri.toString();
}
