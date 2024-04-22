import 'package:electricsql/electricsql.dart';
import 'package:electricsql/frameworks_shared.dart';
import 'package:electricsql/util.dart';
import 'package:electricsql_flutter/electricsql_flutter.dart';
import 'package:flutter/foundation.dart';

class ConnectivityStateController with ChangeNotifier {
  final BaseElectricClient electric;

  late ConnectivityState _connectivityState =
      getElectricConnectivityState(electric);
  ConnectivityState get connectivityState => _connectivityState;

  void Function()? _unsubscribe;
  bool _disposed = false;

  ConnectivityStateController(this.electric);

  void init() {
    assert(_unsubscribe == null, 'Already initialized');

    _unsubscribe = createConnectivityStateSubscribeFunction(electric.notifier)(
      (ConnectivityState newState) {
        Future.microtask(
          () => _setConnectivityState(getValidConnectivityState(newState)),
        );
      },
    );

    _connectivityState = getElectricConnectivityState(electric);
  }

  @override
  void dispose() {
    _disposed = true;
    if (_unsubscribe != null) {
      _unsubscribe?.call();
      _unsubscribe = null;
    }
    super.dispose();
  }

  void _setConnectivityState(ConnectivityState state) {
    if (state == _connectivityState) return;
    _connectivityState = state;

    if (!_disposed) {
      notifyListeners();
    }
  }
}
