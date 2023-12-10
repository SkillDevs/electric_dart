import 'package:electricsql/electricsql.dart';
import 'package:electricsql/notifiers.dart';
import 'package:flutter/foundation.dart';

class ConnectivityStateController with ChangeNotifier {
  final ElectricClient electric;

  ConnectivityState _connectivityState = ConnectivityState.disconnected;
  ConnectivityState get connectivityState => _connectivityState;

  void Function()? _unsubConnectivityChange;
  bool _shouldStop = false;

  ConnectivityStateController(this.electric);

  void init() {
    assert(_unsubConnectivityChange == null, 'Already initialized');

    setConnectivityState(_getElectricState(electric));

    void handler(ConnectivityStateChangeNotification notification) {
      if (_shouldStop) return;

      final state = notification.connectivityState;

      setConnectivityState(getValidState(state));
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

  void toggleConnectivityState() {
    final nextState = getNextState(connectivityState);
    final dbName = electric.notifier.dbName;
    electric.notifier.connectivityStateChanged(dbName, nextState);

    setConnectivityState(nextState);
  }

  void setConnectivityState(ConnectivityState state) {
    _connectivityState = state;
    notifyListeners();
  }
}

const ({
  ConnectivityState available,
  ConnectivityState connected,
  ConnectivityState disconnected,
}) _kStates = (
  available: ConnectivityState.available,
  connected: ConnectivityState.connected,
  disconnected: ConnectivityState.disconnected,
);

const _kValidStates = <ConnectivityState>{
  ConnectivityState.available,
  ConnectivityState.connected,
  ConnectivityState.disconnected,
};

ConnectivityState _getElectricState(ElectricClient? electric) {
  if (electric == null) {
    return _kStates.disconnected;
  }

  return electric.isConnected ? _kStates.connected : _kStates.disconnected;
}

ConnectivityState getNextState(ConnectivityState currentState) =>
    currentState == _kStates.connected
        ? _kStates.disconnected
        : _kStates.available;

ConnectivityState getValidState(ConnectivityState candidateState) =>
    _kValidStates.contains(candidateState)
        ? candidateState
        : _kStates.disconnected;
