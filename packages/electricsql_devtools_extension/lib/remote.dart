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
    final subId = (await electricSQLRequest(
      'subscribeToSatelliteStatus',
      payload: {
        'db': dbName,
      },
    ))! as int;
    // print("NEW SUB: $subId");

    final sub = _remoteConnectivityStateStream(subId).listen((status) {
      // print("SUB CHANGED: $status");
      callback(status);
    });

    return () async {
      // print("UNSUB $subId");
      await sub.cancel();
      await electricSQLRequest(
        'unsubscribeFromSatelliteStatus',
        payload: {
          'id': subId.toString(),
        },
      );
    };
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
    await electricSQLRequest(
      'resetDb',
      payload: {
        'db': dbName,
      },
    );

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
