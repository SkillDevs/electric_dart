import 'dart:io';

import 'package:electricsql_cli/src/exit_signals.dart';
import 'package:mason_logger/mason_logger.dart';

const int kSigIntExitCode = 130;

bool notBlank(String? str) {
  return str != null && str.trim().isNotEmpty;
}

String removeTrailingSlash(String str) {
  if (str.endsWith('/')) {
    return str.substring(0, str.length - 1);
  }
  return str;
}

String prettyMap(Map<String, Object?> map) {
  Object? _getDistinctiveValue(Object? value) {
    if (value is String) {
      final quote = value.contains("'") ? '"' : "'";
      return '$quote$value$quote';
    } else {
      return value;
    }
  }

  final buffer = StringBuffer('{');
  buffer.writeln();
  for (final entry in map.entries) {
    buffer.writeln('  ${entry.key}: ${_getDistinctiveValue(entry.value)},');
  }
  buffer.write('}');
  return buffer.toString();
}

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

String buildDatabaseURL({
  required String user,
  required String password,
  required String host,
  required int port,
  required String dbName,
  bool? ssl,
}) {
  final url = StringBuffer('postgresql://$user');
  if (password.isNotEmpty) {
    url.write(':$password');
  }
  url.write('@$host:$port/$dbName');

  if (ssl == false) {
    url.write('?sslmode=disable');
  }

  return url.toString();
}

Map<String, Object?> extractDatabaseURL(String url) {
  final Uri parsed;
  try {
    parsed = Uri.parse(url);

    if (parsed.scheme != 'postgres' && parsed.scheme != 'postgresql') {
      throw Exception('Unexpected scheme: ${parsed.scheme}');
    }
  } catch (e) {
    throw Exception('Invalid database URL: $url');
  }

  String? user;
  String? password;
  if (parsed.userInfo.isNotEmpty) {
    final splitted = parsed.userInfo.split(':');
    user = splitted[0];
    password = splitted.length > 1 ? splitted.sublist(1).join(':') : '';
  }

  return {
    'user': user,
    'password': password,
    'host': parsed.host == '' ? null : parsed.host,
    'port': parsed.port == 0 ? null : parsed.port,
    'dbName': parsed.path == '' || parsed.path == '/'
        ? null
        // Remove leading slash
        : parsed.path.substring(1),
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

Future<int> waitForProcess(Process p) async {
  final disposeExitSignals = handleExitSignals(
    onExit: (_) async {
      // Don't exit, let the process handle it
      return false;
    },
  );

  try {
    final exitCode = await p.exitCode;
    return exitCode;
  } finally {
    await disposeExitSignals();
  }
}

Future<T> wrapWithProgress<T>(
  Logger logger,
  Future<T> Function() fun, {
  required String progressMsg,
  String? completeMsg,
}) async {
  final progress = logger.progress(progressMsg);
  try {
    final res = await fun();
    progress.complete(completeMsg);
    return res;
  } catch (e) {
    progress.fail();
    rethrow;
  }
}

int parsePort(String str) {
  final parsed = int.tryParse(str);
  if (parsed == null) {
    throw ConfigException('Invalid port: $str.');
  }
  return parsed;
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

class ConfigException implements Exception {
  ConfigException(this.message);

  final String message;

  @override
  String toString() => message;
}
