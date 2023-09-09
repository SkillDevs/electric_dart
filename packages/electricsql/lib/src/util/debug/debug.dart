import 'dart:developer' as developer;

import 'package:ansicolor/ansicolor.dart';
import 'package:logging/logging.dart' as loglib;

final Logger logger = _createLogger();

void _setLogLevel(Level logLevel) {
  logger.setLogLevel(logLevel);
}

void _setColoredLogger(bool value) {
  // Global variable from the ansicolor package
  ansiColorDisabled = !value;
}

void configureElectricLogger(LoggerConfig config) {
  if (config.level != null) {
    _setLogLevel(config.level!);
  }

  if (config.colored != null) {
    _setColoredLogger(config.colored!);
  }
}

class LoggerConfig {
  /// The minimum level of log messages to print.
  final Level? level;

  /// Whether to colorize the log messages.
  final bool? colored;

  LoggerConfig({
    this.level,
    this.colored,
  });
}

Logger _createLogger() {
  final logger = loglib.Logger('Electric');

  loglib.hierarchicalLoggingEnabled = true;

  // No logging by default
  logger.level = loglib.Level.OFF;

  logger.onRecord.listen((event) {
    final error = event.error;

    String extra = '';
    if (error != null) {
      extra = '\n\t$error';
    }

    if (event.stackTrace != null) {
      extra += '\n\tStackTrace: ${event.stackTrace}';
    }

    final pen = AnsiPen();

    final level = event.level;
    final String levelName;
    if (level >= loglib.Level.SEVERE) {
      pen.red();
      levelName = 'ERROR';
    } else if (level >= loglib.Level.WARNING) {
      pen.yellow();
      levelName = 'WARN';
    } else if (level <= loglib.Level.FINE) {
      pen.gray(level: 0.6);
      levelName = 'DEBUG';
    } else {
      levelName = 'INFO';
    }

    final paddedName = '$levelName:'.padRight(6);

    // ignore: avoid_print
    developer.log(
      pen('$paddedName ${_toIso8601StringOnlyDay(event.time)} ${event.message} $extra'),
      name: event.loggerName,
    );
  });

  // Wrapped simplified logger
  return Logger(logger);
}

enum Level {
  off,
  debug,
  info,
  warning,
  error,
}

extension LevelPublicExt on Level {
  int get value => loggingLibLevel.value;
}

class Logger {
  final loglib.Logger _logger;

  Logger(this._logger);

  int get levelImportance => _logger.level.value;

  void setLogLevel(Level logLevel) {
    _logger.level = logLevel.loggingLibLevel;
  }

  void debug(String message) {
    _logger.log(Level.debug.loggingLibLevel, message);
  }

  void info(String message) {
    _logger.log(Level.info.loggingLibLevel, message);
  }

  void warning(String message) {
    _logger.log(Level.warning.loggingLibLevel, message);
  }

  void error(String message) {
    _logger.log(Level.error.loggingLibLevel, message);
  }
}

extension _LevelExt on Level {
  loglib.Level get loggingLibLevel {
    switch (this) {
      case Level.off:
        return loglib.Level.OFF;
      case Level.debug:
        return loglib.Level.FINE;
      case Level.info:
        return loglib.Level.INFO;
      case Level.warning:
        return loglib.Level.WARNING;
      case Level.error:
        return loglib.Level.SEVERE;
    }
  }
}

String _toIso8601StringOnlyDay(DateTime date) {
  final String h = _twoDigits(date.hour);
  final String min = _twoDigits(date.minute);
  final String sec = _twoDigits(date.second);
  final String ms = _threeDigits(date.millisecond);
  return '$h:$min:$sec.$ms';
}

String _threeDigits(int n) {
  if (n >= 100) return '$n';
  if (n >= 10) return '0$n';
  return '00$n';
}

String _twoDigits(int n) {
  if (n >= 10) return '$n';
  return '0$n';
}
