import 'package:electricsql/drivers/drivers.dart';
import 'package:electricsql/electricsql.dart';
import 'package:electricsql/satellite.dart';
import 'package:electricsql/src/devtools/devtools.dart' as devtools;
import 'package:electricsql/src/notifiers/notifiers.dart';

class ElectricNamespace {
  final String dbName;
  final DatabaseAdapter adapter;
  final Notifier notifier;
  final Registry registry;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  late final UnsubscribeFunction _unsubscribeStateChanges;

  ElectricNamespace({
    required this.dbName,
    required this.adapter,
    required this.notifier,
    required this.registry,
  }) {
    _unsubscribeStateChanges =
        notifier.subscribeToConnectivityStateChanges((notification) {
      setIsConnected(notification.connectivityState);
    });
  }

  void setIsConnected(ConnectivityState connectivityState) {
    _isConnected = connectivityState.status == ConnectivityStatus.connected;
  }

  /// We lift this function a level so the user can call
  /// db.electric.potentiallyChanged() rather than the longer / more redundant
  /// db.electric.notifier.potentiallyChanged().
  void potentiallyChanged() {
    notifier.potentiallyChanged();
  }

  /// Cleans up the resources used by the `ElectricNamespace`.
  Future<void> close() async {
    _unsubscribeStateChanges();
    await registry.stop(dbName);

    devtools.handleElectricClientClosed(dbName);
  }
}
