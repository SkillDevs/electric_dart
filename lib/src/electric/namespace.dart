import 'package:electric_client/electric_dart.dart';
import 'package:electric_client/src/notifiers/notifiers.dart';

class ElectricNamespace {
  final DatabaseAdapter adapter;
  final Notifier notifier;
  bool isConnected = false;

  ElectricNamespace({
    required this.adapter,
    required this.notifier,
  }) {
    notifier.subscribeToConnectivityStateChange((notification) {
      isConnected =
          notification.connectivityState == ConnectivityState.connected;
    });
  }

  /// We lift this function a level so the user can call
  /// db.electric.potentiallyChanged() rather than the longer / more redundant
  /// db.electric.notifier.potentiallyChanged().
  void potentiallyChanged() {
    notifier.potentiallyChanged();
  }
}
