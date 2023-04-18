import 'package:logging/logging.dart';

final Logger logger = _createLogger();

void setLogLevel(Level logLevel) {
  logger.level = logLevel;
}

Logger _createLogger() {
  final logger = Logger("electric");

  hierarchicalLoggingEnabled = true;

  // No logging by default
  logger.level = null;

  logger.onRecord.listen((event) {
    final error = event.error;

    String extra = "";
    if (error != null) {
      extra = "\n\t$error";
    }

    if (event.stackTrace != null) {
      extra += "\n\tStackTrace: ${event.stackTrace}";
    }

    print('${event.level.name}: ${event.time}: ${event.message} $extra');
  });

  return logger;
}
