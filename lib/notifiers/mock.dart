import 'package:electric_client/notifiers/event.dart';
import 'package:electric_client/notifiers/notifiers.dart';
import 'package:electric_client/util/types.dart';

class MockNotifier extends EventNotifier {
  List<Notification> notifications = [];

  MockNotifier(DbName dbName) : super(dbName: dbName);

  @override
  void emit(String eventName, Notification notification) {
    super.emit(eventName, notification);

    notifications.add(notification);
  }
}
