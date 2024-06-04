import 'dart:io';

import 'package:electricsql_cli/src/util/util.dart';

/// Get the name of the current project.
String? getAppName() {
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    return null;
  }
  final pubspec = pubspecFile.readAsStringSync();
  final regexp = RegExp(r'^name:\s+(\S+)\s*$', multiLine: true);
  final match = regexp.firstMatch(pubspec);

  if (match != null) {
    return match[1];
  }
  return null;
}

int parsePort(String str) {
  final parsed = int.tryParse(str);
  if (parsed == null) {
    throw ConfigException('Invalid port: $str.');
  }
  return parsed;
}

Map<String, Object?> extractDatabaseURL(String url) {
  final Uri parsed;
  try {
    parsed = Uri.parse(url);

    if (parsed.scheme != 'postgres' && parsed.scheme != 'postgresql') {
      throw Exception('Unexpected scheme: ${parsed.scheme}');
    }

    if (parsed.host.isEmpty) {
      throw Exception('Invalid database URL: $url');
    }
  } catch (e) {
    throw Exception('Invalid database URL: $url');
  }

  String? user;
  String? password;
  if (parsed.userInfo.isNotEmpty) {
    final splitted = parsed.userInfo.split(':');
    user = Uri.decodeComponent(splitted[0]);
    password = splitted.length > 1
        ? Uri.decodeComponent(splitted.sublist(1).join(':'))
        : '';
  }

  if (user == null || user.isEmpty) {
    throw Exception('Invalid or missing username: $url');
  }

  return {
    'user': user,
    'password': password,
    'host': parsed.host == '' ? null : parsed.host,
    'port': parsed.port == 0 ? null : parsed.port,
    'dbName': parsed.path == '' || parsed.path == '/'
        ? user
        // Remove leading slash
        : Uri.decodeComponent(parsed.path.substring(1)),
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

({bool http, int port}) parsePgProxyPort(String str) {
  if (str.contains(':')) {
    final splitted = str.split(':');
    if (splitted.length != 2) {
      throw Exception("Unexpected proxy port value: '$str'");
    }
    final prefix = splitted[0];
    final port = splitted[1];
    return (
      http: prefix.toLowerCase() == 'http',
      port: parsePort(port),
    );
  } else if (str.toLowerCase() == 'http') {
    return (http: true, port: 65432);
  } else {
    return (http: false, port: parsePort(str));
  }
}
