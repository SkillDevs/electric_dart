import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:electricsql/satellite.dart';
import 'package:electricsql/src/client/model/index.dart';
import 'package:electricsql/src/devtools/api/toolbar.dart';
import 'package:electricsql/src/devtools/devtools.dart';
import 'package:electricsql/src/devtools/platform/platform.dart';
import 'package:electricsql/src/devtools/shared.dart';
import 'package:electricsql/util.dart';
import 'package:meta/meta.dart';

class ElectricDevtoolsBinding {
  static final Map<String, BaseElectricClient> _clients = {};
  static final Map<String, Future<void> Function()> _dbResetCallbacks = {};
  static Registry? _customRegistry;

  /// The Electric Satellite registry used in the Electric Devtools.
  static Registry get registry => _customRegistry ?? globalRegistry;

  /// Set a custom Electric Satellite registry to use in the Electric Devtools.
  /// This would need to be called before electrifiying your database.
  static void setCustomRegistry(Registry registry) {
    if (_customRegistry != null) {
      throw StateError('Electric Registry already set. Can only be set once.');
    }
    _customRegistry = registry;
  }

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
  late final api = Toolbar(ElectricDevtoolsBinding.registry);

  // Random initial subscription id, so that it doesn't collide when restarting the app
  int _subscriptionId = Random().nextInt(9999999999);
  final Map<int, void Function()> _activeSubscriptions = {};

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
        return _createSubscription(
          (subId) => api.subscribeToSatelliteStatus(
            parameters['db']!,
            (ConnectivityState state) {
              postEvent(
                'satellite-status',
                {
                  'subscription': subId,
                  'status': state.toMap(),
                },
              );
            },
          ),
        );

      case 'unsubscribeFromSatelliteStatus':
        _unsubscribe(parameters);
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

        postDbWasReset(dbName);
        return null;
      case 'afterDbReset':
        // On web we reload the page
        await afterDbReset();
        return null;
      case 'getSatelliteShapeSubscriptions':
        final shapes = api.getSatelliteShapeSubscriptions(parameters['db']!);
        return shapes.map((s) => s.toMap()).toList();
      case 'subscribeToSatelliteShapeSubscriptions':
        return _createSubscription(
          (subId) => api.subscribeToSatelliteShapeSubscriptions(
            parameters['db']!,
            (List<DebugShape> shapes) {
              postEvent(
                'shape-subscriptions',
                {
                  'subscription': subId,
                  'shapes': shapes.map((e) => e.toMap()).toList(),
                },
              );
            },
          ),
        );
      case 'unsubscribeFromSatelliteShapeSubscriptions':
        _unsubscribe(parameters);
        return null;
      case 'getDbDialect':
        final dialect = await api.getDbDialect(parameters['db']!);
        return dialect.index;

      case 'queryDb':
        final query = parameters['query']!;
        final args = json.decode(parameters['args']!) as List<Object?>;
        final result = await api.queryDb(parameters['db']!, query, args);
        return result.toMap();

      case 'subscribeToDbTable':
        return _createSubscription(
          (subId) => api.subscribeToDbTable(
            parameters['db']!,
            parameters['table']!,
            () {
              postEvent(
                'db-table-data-changed',
                {
                  'subscription': subId,
                },
              );
            },
          ),
        );
      case 'unsubscribeFromDbTable':
        _unsubscribe(parameters);
        return null;
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

  int _createSubscription(void Function() Function(int subId) subscribeFun) {
    final id = _subscriptionId++;
    final unsubscribe = subscribeFun(id);
    _activeSubscriptions[id] = unsubscribe;
    return id;
  }

  void _unsubscribe(Map<String, String> parameters) {
    final subId = int.parse(parameters['id']!);
    _activeSubscriptions.remove(subId)?.call();
  }
}
