import 'package:drift/drift.dart';
import 'package:electric_client/drivers/drift.dart';
import 'package:electric_client/electric_client.dart';
import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:todos_electrified/generated/electric_migrations.dart';

final Provider<ElectricClient> electricClientProvider =
    Provider((ref) => throw UnimplementedError());

final connectivityStateControllerProvider =
    ChangeNotifierProvider<ConnectivityStateController>(
        (ref) => throw UnimplementedError());

Future<ElectricClient> startElectricDrift(
  String dbName,
  DatabaseConnectionUser db,
) async {
  final namespace = await electrify(
    dbName: dbName,
    db: db,
    migrations: kElectricMigrations,
    config: ElectricConfig(
      auth: AuthConfig(
        //token:
        //    'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJsb2NhbC1kZXZlbG9wbWVudCIsInR5cGUiOiJhY2Nlc3MiLCJ1c2VyX2lkIjoidGVzdC11c2VyIiwiaWF0IjoxNjg3ODc3OTQ1LCJleHAiOjE2OTc4ODE1NDV9.L5Ui2sA9o5MeYDuy67u9lBV-2FzpOWL9dKcitRvgorg',
        token: await authToken(iss: 'local-development', key: 'local-development-key-minimum-32-symbols'),
      ),
      debug: true,
    ),
  );

  return namespace;
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

class ConnectivityStateController with ChangeNotifier {
  final ElectricClient electric;

  ConnectivityState _connectivityState = ConnectivityState.disconnected;
  ConnectivityState get connectivityState => _connectivityState;

  String? _connectivityChangeSubscriptionId;
  bool _shouldStop = false;

  ConnectivityStateController(this.electric);

  void init() {
    setConnectivityState(_getElectricState(electric));

    void handler(ConnectivityStateChangeNotification notification) {
      if (_shouldStop) return;

      final state = notification.connectivityState;

      setConnectivityState(getValidState(state));
    }

    _connectivityChangeSubscriptionId =
        electric.notifier.subscribeToConnectivityStateChanges(handler);
  }

  @override
  void dispose() {
    _shouldStop = true;
    if (_connectivityChangeSubscriptionId != null) {
      electric.notifier.unsubscribeFromConnectivityStateChanges(
        _connectivityChangeSubscriptionId!,
      );
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
