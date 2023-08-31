import 'package:ansicolor/ansicolor.dart';
import 'package:logging/logging.dart';

final Logger logger = _createLogger();

void setLogLevel(Level logLevel) {
  logger.level = logLevel;
}

Logger _createLogger() {
  final logger = Logger('electric');

  hierarchicalLoggingEnabled = true;

  // No logging by default
  logger.level = Level.OFF;

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
    if (level >= Level.SEVERE) {
      pen.red();
    } else if (level >= Level.WARNING) {
      pen.yellow();
    } else if (level <= Level.FINE) {
      pen.gray(level: 0.6);
    }

    // ignore: avoid_print
    print(pen('${event.level.name}: ${event.time}: ${event.message} $extra'));
  });

  return logger;
}
