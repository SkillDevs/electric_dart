import 'package:ansicolor/ansicolor.dart';
import 'package:logging/logging.dart' as loglib;

final Logger logger = _createLogger();

void setLogLevel(Level logLevel) {
  logger.setLogLevel(logLevel);
}

Logger _createLogger() {
  final logger = loglib.Logger('electric');

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
    if (level >= loglib.Level.SEVERE) {
      pen.red();
    } else if (level >= loglib.Level.WARNING) {
      pen.yellow();
    } else if (level <= loglib.Level.FINE) {
      pen.gray(level: 0.6);
    }

    // ignore: avoid_print
    print(pen('${event.level.name}: ${event.time}: ${event.message} $extra'));
  });

  // Wrapped simplified logger
  return Logger(logger);
}

enum Level {
  trace,
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

  void trace(String message) {
    _logger.log(Level.trace.loggingLibLevel, message);
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
      case Level.trace:
        return loglib.Level.FINEST;
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
