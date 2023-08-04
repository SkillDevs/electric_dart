import 'package:electric_client/src/notifiers/event.dart';
import 'package:electric_client/src/notifiers/notifiers.dart';
import 'package:electric_client/src/util/types.dart';

class MockNotifier extends EventNotifier {
  List<Notification> notifications = [];

  MockNotifier(DbName dbName) : super(dbName: dbName);

  @override
  void emit(String eventName, Notification notification) {
    super.emit(eventName, notification);

    notifications.add(notification);
  }
}
