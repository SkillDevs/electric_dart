import 'dart:async';

import 'package:devtools_extensions/devtools_extensions.dart';
import 'package:electricsql/electricsql.dart';
// ignore: invalid_use_of_internal_member, implementation_imports
import 'package:electricsql/src/devtools/shared.dart';
import 'package:electricsql/util.dart';

final kRemoteToolbar = RemoteToolbarApi();

class RemoteToolbarApi {
  Future<List<String>> getSatelliteNames() async {
    final names = await electricSQLRequest('getSatelliteNames')
        .then((e) => (e! as List<dynamic>).cast<String>());
    return names;
  }

  Future<ConnectivityState?> getSatelliteStatus(String name) async {
    final statusJ = await electricSQLRequest(
      'getSatelliteStatus',
      payload: {
        'db': name,
      },
    );

    if (statusJ == null) {
      return null;
    }

    return ConnectivityState.fromMap(statusJ as Map<String, dynamic>);
  }

  Future<Future<void> Function()> subscribeToSatelliteStatus(
    String dbName,
    void Function(ConnectivityState) callback,
  ) async {
    return _genericRemoteSubscription(
      payload: {
        'db': dbName,
      },
      subscribeMethod: 'subscribeToSatelliteStatus',
      unsubscribeMethod: 'unsubscribeFromSatelliteStatus',
      getDataStream: _remoteConnectivityStateStream,
      callback: callback,
    );
  }

  Future<void> toggleSatelliteStatus(String name) async {
    await electricSQLRequest(
      'toggleSatelliteStatus',
      payload: {
        'db': name,
      },
    );
  }

  Future<List<DbTableInfo>> getDbTables(String dbName) async {
    return _getTables(dbName, 'getDbTables');
  }

  Future<List<DbTableInfo>> getElectricTables(String dbName) async {
    return _getTables(dbName, 'getElectricTables');
  }

  Future<List<DbTableInfo>> _getTables(String dbName, String method) async {
    final tables = await electricSQLRequest(
      method,
      payload: {
        'db': dbName,
      },
    ).then(
      (e) => (e! as List<dynamic>)
          .map((e) => DbTableInfo.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
    return tables;
  }

  Future<bool> canResetDb(String dbName) async {
    return electricSQLRequest(
      'canResetDb',
      payload: {
        'db': dbName,
      },
    ).then((e) => e! as bool);
  }

  Future<void> resetDb(String dbName) async {
    final dbHasResetCompleter = Completer<void>();

    StreamSubscription<void>? sub;
    sub = _remoteDbWasReset(dbName).listen((event) {
      dbHasResetCompleter.complete();
      sub?.cancel();
      sub = null;
    });

    await electricSQLRequest(
      'resetDb',
      payload: {
        'db': dbName,
      },
    );

    // Wait for the devtools plugin to actually be aware of the reset
    // Workaround for https://github.com/flutter/devtools/issues/7779
    await dbHasResetCompleter.future
        .timeout(const Duration(seconds: 2))
        .catchError((_) => null);
    await sub?.cancel();

    // Reload!

    // This reloads the page on web
    await electricSQLRequest('afterDbReset');

    // Hot restart
    await serviceManager.performHotRestart();
  }

  Stream<ConnectivityState> _remoteConnectivityStateStream(int subId) {
    return serviceManager.service!.onExtensionEvent.where((e) {
      return e.extensionKind == 'electricsql:satellite-status' &&
          e.extensionData?.data['subscription'] == subId;
    }).map((event) {
      final data = event.extensionData!.data;
      final statusJ = data['status']! as Map<String, dynamic>;
      final status = ConnectivityState.fromMap(statusJ);
      return status;
    });
  }

  Stream<void> _remoteDbWasReset(String dbName) {
    return serviceManager.service!.onExtensionEvent.where((e) {
      return e.extensionKind == 'electricsql:db-was-reset' &&
          e.extensionData?.data['db'] == dbName;
    });
  }

  Stream<List<DebugShape>> _remoteShapeSubscriptionsStream(int subId) {
    return serviceManager.service!.onExtensionEvent.where((e) {
      return e.extensionKind == 'electricsql:shape-subscriptions' &&
          e.extensionData?.data['subscription'] == subId;
    }).map((event) {
      final data = event.extensionData!.data;
      final shapesJ = data['shapes']! as List<dynamic>;
      final shapes = shapesJ
          .map((s) => DebugShape.fromMap(s as Map<String, dynamic>))
          .toList();
      return shapes;
    });
  }

  Future<List<DebugShape>> getSatelliteShapeSubscriptions(String dbName) async {
    final shapesJ = await electricSQLRequest(
      'getSatelliteShapeSubscriptions',
      payload: {
        'db': dbName,
      },
    ).then(
      (e) => (e! as List<dynamic>)
          .map((e) => DebugShape.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
    return shapesJ;
  }

  Future<Future<void> Function()> subscribeToSatelliteShapeSubscriptions(
    String dbName,
    void Function(List<DebugShape>) callback,
  ) {
    return _genericRemoteSubscription(
      payload: {
        'db': dbName,
      },
      subscribeMethod: 'subscribeToSatelliteShapeSubscriptions',
      unsubscribeMethod: 'unsubscribeFromSatelliteShapeSubscriptions',
      getDataStream: _remoteShapeSubscriptionsStream,
      callback: callback,
    );
  }

  /// Generic method to subscribe to some stream in the remote app
  /// Returns a function to unsubscribe
  Future<Future<void> Function()> _genericRemoteSubscription<T>({
    Map<String, String> payload = const {},
    required String subscribeMethod,
    required String unsubscribeMethod,
    required Stream<T> Function(int subId) getDataStream,
    required void Function(T) callback,
  }) async {
    final subId = (await electricSQLRequest(
      subscribeMethod,
      payload: payload,
    ))! as int;

    final sub = getDataStream(subId).listen((status) {
      callback(status);
    });

    return () async {
      await sub.cancel();
      await electricSQLRequest(
        unsubscribeMethod,
        payload: {
          'id': subId.toString(),
        },
      );
    };
  }
}

Future<Object?> electricSQLRequest(
  String method, {
  Map<String, String> payload = const {},
}) async {
  final response = await serviceManager.callServiceExtensionOnMainIsolate(
    'ext.electricsql.tools',
    args: {
      'action': method,
      ...payload,
    },
  );

  return response.json!['r'];
}
