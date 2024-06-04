import 'dart:io';

import 'package:electricsql_cli/src/logger.dart';
import 'package:electricsql_cli/src/util/exit_signals.dart';

export 'exit_signals.dart';
export 'get_port.dart';
export 'parse.dart';
export 'paths.dart';
export 'string.dart';
export 'version.dart';

class ConfigException implements Exception {
  ConfigException(this.message);

  final String message;

  @override
  String toString() => message;
}

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
