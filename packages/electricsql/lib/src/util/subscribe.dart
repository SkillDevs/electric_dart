import 'package:electricsql/electricsql.dart';
import 'package:electricsql/notifiers.dart';

typedef ConnectivityStateSubscribeFunction = void Function() Function(
  void Function(ConnectivityState) handler,
);

ConnectivityStateSubscribeFunction createConnectivityStateSubscribeFunction(
  Notifier notifier,
) {
  return (handler) {
    bool cancelled = false;
    void update(
      ConnectivityStateChangeNotification notification,
    ) {
      if (cancelled) return;
      handler(notification.connectivityState);
    }

    final unsubscribe = notifier.subscribeToConnectivityStateChanges(update);

    return () {
      cancelled = true;
      unsubscribe();
    };
  };
}
