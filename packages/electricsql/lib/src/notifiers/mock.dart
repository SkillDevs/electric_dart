import 'package:electricsql/src/notifiers/event.dart';
import 'package:electricsql/src/notifiers/notifiers.dart';
import 'package:electricsql/src/util/types.dart';

class MockNotifier extends EventNotifier {
  List<Notification> notifications = [];

  MockNotifier(DbName dbName, {super.eventEmitter}) : super(dbName: dbName);

  @override
  void emit(String eventName, Notification notification) {
    super.emit(eventName, notification);

    notifications.add(notification);
  }
}
