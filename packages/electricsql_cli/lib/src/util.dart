bool notBlank(String? str) {
  return str != null && str.trim().isNotEmpty;
}

String? getAppName() {
  // const packageJsonPath = path.join(appRoot, 'package.json')
  // return JSON.parse(fs.readFileSync(packageJsonPath, 'utf8')).name
  // TODO(dart): getAppName
  return 'custom_cli_app';
}

String buildDatabaseURL({
  required String user,
  required String password,
  required String host,
  required int port,
  required String dbName,
}) {
  final url = StringBuffer('postgresql://$user');
  if (password.isNotEmpty) {
    url.write(':$password');
  }
  url.write('@$host:$port/$dbName');
  return url.toString();
}

Map<String, Object?> extractDatabaseURL(String url) {
  final regexp = RegExp(
    r'^postgres(ql)?:\/\/([^:]+)(?::([^@]+))?@([^:]+):(\d+)\/(.+)$',
  );
  final match = regexp.firstMatch(url);

  if (match == null) {
    throw Exception('Invalid database URL: $url');
  }
  return {
    'user': match[2],
    'password': match[3] ?? '',
    'host': match[4],
    'port': int.parse(match[5]!),
    'dbName': match[6],
  };
}


Map<String, Object?> extractServiceURL(String serviceUrl) {
  final parsed = Uri.parse(serviceUrl);
  if (parsed.host.isEmpty) {
    throw Exception('Invalid service URL: $serviceUrl');
  }
  return {
    'host': parsed.host,
    'port': parsed.hasPort ? parsed.port : null,
  };
}
