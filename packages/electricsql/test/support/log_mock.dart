import 'package:electricsql/src/util/debug/debug.dart';
import 'package:logging/logging.dart' show LogRecord;
import 'package:test/test.dart';

typedef LoggedMsg = String;

void setupLoggerMock(List<LoggedMsg> Function() getLog) {
  // Clear the default listener, so that we can only use the one in the mock
  logger.clearListeners();

  logger.onRecord.listen((LogRecord record) {
    getLog().add(record.message);

    // ignore: dead_code
    if (false) {
      // We can call the logger for debug purposes
      final msg = convertLogEventToMessage(record);
      // ignore: avoid_print
      print(msg);
    }
  });

  configureElectricLogger(
    LoggerConfig(
      level: Level.debug,
    ),
  );

  setUp(() {
    getLog().clear();
  });
}
