import 'package:electricsql/electricsql.dart';
import 'package:electricsql/notifiers.dart';
import 'package:electricsql_flutter/electricsql_flutter.dart';
import 'package:flutter/foundation.dart';

class ConnectivityStateController with ChangeNotifier {
  final ElectricClient electric;

  ConnectivityState _connectivityState = _kStates.disconnected;
  ConnectivityState get connectivityState => _connectivityState;

  void Function()? _unsubConnectivityChange;
  bool _shouldStop = false;

  ConnectivityStateController(this.electric);

  void init() {
    assert(_unsubConnectivityChange == null, 'Already initialized');

    _setConnectivityState(_getElectricState(electric));

    void handler(ConnectivityStateChangeNotification notification) {
      if (_shouldStop) return;

      final state = notification.connectivityState;

      _setConnectivityState(getValidState(state));
    }

    _unsubConnectivityChange =
        electric.notifier.subscribeToConnectivityStateChanges(handler);
  }

  @override
  void dispose() {
    _shouldStop = true;
    if (_unsubConnectivityChange != null) {
      _unsubConnectivityChange?.call();
      _unsubConnectivityChange = null;
    }
    super.dispose();
  }

  void _setConnectivityState(ConnectivityState state) {
    _connectivityState = state;
    notifyListeners();
  }
}

const ({
  ConnectivityState connected,
  ConnectivityState disconnected,
}) _kStates = (
  connected: ConnectivityState(status: ConnectivityStatus.connected),
  disconnected: ConnectivityState(status: ConnectivityStatus.disconnected),
);

const _kValidStatuses = <ConnectivityStatus>{
  ConnectivityStatus.connected,
  ConnectivityStatus.disconnected,
};

ConnectivityState _getElectricState(ElectricClient? electric) {
  if (electric == null) {
    return _kStates.disconnected;
  }

  return electric.isConnected ? _kStates.connected : _kStates.disconnected;
}

ConnectivityState getValidState(ConnectivityState candidateState) =>
    _kValidStatuses.contains(candidateState.status)
        ? candidateState
        : _kStates.disconnected;
