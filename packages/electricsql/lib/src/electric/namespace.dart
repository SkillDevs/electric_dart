import 'package:electricsql/electricsql.dart';
import 'package:electricsql/src/notifiers/notifiers.dart';
import 'package:electricsql/util.dart';

class ElectricNamespace {
  final DatabaseAdapter adapter;
  final Notifier notifier;

  bool _isConnected = false;
  bool get isConnected => _isConnected;

  ElectricNamespace({
    required this.adapter,
    required this.notifier,
  }) {
    // XXX if you're implementing VAX-799, see the note below and maybe refactor
    // this out of here whilst cleaning up the subscription.

    // we need to set isConnected before the first event is emitted,
    // otherwise application might be out of sync with satellite state.
    notifier.subscribeToConnectivityStateChanges((notification) {
      setIsConnected(notification.connectivityState);
    });
  }

  // XXX this `isConnected` property is now only used via the ElectricClient.
  // Now ... because the connectivity state change subscription is wired up
  // here, we proxy this property from a dynamic `isConnected` getter on the
  // ElectricClient. All of which is a bit unecessary and something of a
  // code smell. As is the subscription above not being cleaned up.
  void setIsConnected(ConnectivityState connectivityState) {
    _isConnected = connectivityState == ConnectivityState.connected;
  }

  /// We lift this function a level so the user can call
  /// db.electric.potentiallyChanged() rather than the longer / more redundant
  /// db.electric.notifier.potentiallyChanged().
  void potentiallyChanged() {
    notifier.potentiallyChanged();
  }
}
