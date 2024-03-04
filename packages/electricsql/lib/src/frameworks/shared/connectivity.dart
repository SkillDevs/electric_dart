import 'package:electricsql/electricsql.dart';

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

ConnectivityState getElectricConnectivityState(ElectricClient? electric) {
  if (electric == null) {
    return _kStates.disconnected;
  }

  return electric.isConnected ? _kStates.connected : _kStates.disconnected;
}

ConnectivityState getValidConnectivityState(ConnectivityState candidateState) =>
    _kValidStatuses.contains(candidateState.status)
        ? candidateState
        : _kStates.disconnected;
