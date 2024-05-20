import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:electricsql/src/client/model/index.dart';
import 'package:electricsql/src/devtools/api/toolbar.dart';
import 'package:electricsql/src/devtools/devtools.dart';
import 'package:electricsql/src/devtools/platform/platform.dart';
import 'package:electricsql/src/satellite/registry.dart';
import 'package:electricsql/util.dart';
import 'package:meta/meta.dart';

class ElectricDevtoolsBinding {
  static final Map<String, BaseElectricClient> _clients = {};
  static final Map<String, Future<void> Function()> _dbResetCallbacks = {};

  /// Let the Electric Devtools know how to reset the database.
  /// Usually this would be a `db.close()` followed by a delete of the local database file.
  static void registerDbResetCallback(
    BaseElectricClient electric,
    Future<void> Function() dbReset,
  ) {
    if (!enableDevtools) return;

    registerElectricClient(electric);

    final dbName = electric.dbName;
    _dbResetCallbacks[dbName] = dbReset;

    postDbResetChanged(dbName);
  }

  @internal
  static void registerElectricClient(BaseElectricClient electric) {
    if (!enableDevtools) return;

    _clients[electric.dbName] = electric;
  }

  @internal
  static void unregisterElectricClient(String dbName) {
    if (!enableDevtools) return;

    _dbResetCallbacks.remove(dbName);
    _clients.remove(dbName);
  }
}

/// A service extension to interact with Electric
class ElectricServiceExtension {
  // TODO(dart): Configure the registry to use
  late final api = Toolbar(globalRegistry);

  // Random initial subscription id, so that it doesn't collide when restarting the app
  int _subscriptionId = Random().nextInt(100000);
  final Map<int, void Function()> _activeStatusSubscriptions = {};

  Future<Object?> _handle(Map<String, String> parameters) async {
    final action = parameters['action']!;

    switch (action) {
      case 'getSatelliteNames':
        return api.getSatelliteNames();
      case 'getDbTables':
        final tables = await api.getDbTables(parameters['db']!);
        return tables.map((t) => t.toMap()).toList();
      case 'getElectricTables':
        final tables = await api.getElectricTables(parameters['db']!);
        return tables.map((t) => t.toMap()).toList();
      case 'getSatelliteStatus':
        final state = api.getSatelliteStatus(parameters['db']!);
        return state?.toMap();
      case 'subscribeToSatelliteStatus':
        final id = _subscriptionId++;
        final unsubscribe = api.subscribeToSatelliteStatus(
          parameters['db']!,
          (ConnectivityState state) {
            postEvent(
              'satellite-status',
              {
                'subscription': id,
                'status': state.toMap(),
              },
            );
          },
        );

        _activeStatusSubscriptions[id] = unsubscribe;
        return id;
      case 'unsubscribeFromSatelliteStatus':
        final subId = int.parse(parameters['id']!);
        _activeStatusSubscriptions.remove(subId)?.call();
        return null;
      case 'toggleSatelliteStatus':
        await api.toggleSatelliteStatus(parameters['db']!);
        return null;
      case 'canResetDb':
        return ElectricDevtoolsBinding._dbResetCallbacks
            .containsKey(parameters['db']);
      case 'resetDb':
        final dbName = parameters['db']!;
        final client = ElectricDevtoolsBinding._clients[dbName]!;
        final resetDbFun = ElectricDevtoolsBinding._dbResetCallbacks[dbName]!;

        await client.close();
        await resetDbFun();

        // On web we reload the page
        await afterDbReset();
        return null;

      case 'getSatelliteShapeSubscriptions':
        final shapes = api.getSatelliteShapeSubscriptions(parameters['db']!);
        return shapes.map((s) => s.toMap()).toList();
    }

    throw UnsupportedError('Method $action unknown');
  }

  static bool _registered = false;

  /// Registers the `ext.electricsql.tools` extension if it has not yet been
  /// registered on this isolate.
  static void registerIfNeeded() {
    if (!_registered) {
      _registered = true;

      final extension = ElectricServiceExtension();
      registerExtension('ext.electricsql.tools', (method, parameters) {
        return Future(() => extension._handle(parameters))
            .then(
          (value) => ServiceExtensionResponse.result(
            json.encode({
              'r': value,
            }),
          ),
        )
            .onError((error, stackTrace) {
          return ServiceExtensionResponse.error(
            ServiceExtensionResponse.extensionErrorMin,
            json.encode(
              {
                'e': error.toString(),
                'trace': stackTrace.toString(),
              },
            ),
          );
        });
      });
    }
  }
}
