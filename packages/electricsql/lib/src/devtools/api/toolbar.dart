import 'dart:convert';

import 'package:electricsql/satellite.dart';
import 'package:electricsql/src/devtools/api/interface.dart';
import 'package:electricsql/src/devtools/api/statements.dart';
import 'package:electricsql/src/devtools/shared.dart';
import 'package:electricsql/util.dart';

class Toolbar implements ToolbarInterface {
  final Registry registry;

  /// By db name
  final Map<String, SqlDialect> _dialectMap = {};

  Toolbar(this.registry);

  Satellite _getSatellite(String dbName) {
    final sat = registry.satellites[dbName];
    if (sat == null) {
      throw Exception('Satellite for db $dbName not found.');
    }
    return sat;
  }

  @override
  List<String> getSatelliteNames() {
    return registry.satellites.keys.toList();
  }

  @override
  ConnectivityState? getSatelliteStatus(String dbName) {
    final sat = _getSatellite(dbName);
    return sat.connectivityState;
  }

  @override
  UnsubscribeFunction subscribeToSatelliteStatus(
    String name,
    void Function(ConnectivityState) callback,
  ) {
    final sat = _getSatellite(name);

    // call once immediately if connectivity state available
    if (sat.connectivityState != null) {
      callback(sat.connectivityState!);
    }
    // subscribe to subsequent changes
    return sat.notifier.subscribeToConnectivityStateChanges(
      (notification) => callback(notification.connectivityState),
    );
  }

  @override
  Future<void> toggleSatelliteStatus(String dbName) {
    final sat = _getSatellite(dbName);
    if (sat.connectivityState?.status == ConnectivityStatus.connected) {
      sat.clientDisconnect();
      return Future.value();
    }
    return sat.connectWithBackoff();
  }

  Future<SqlDialect> getDbDialect(String dbName) async {
    if (!_dialectMap.containsKey(dbName)) {
      _dialectMap[dbName] = await getSqlDialect(
        _getSatellite(dbName).adapter,
      );
    }
    return _dialectMap[dbName]!;
  }

  @override
  Future<List<DbTableInfo>> getDbTables(String dbName) async {
    final adapter = _getSatellite(dbName).adapter;
    final dialect = await getDbDialect(dbName);
    return genericGetDbTables(adapter, dialect);
  }

  @override
  Future<List<DbTableInfo>> getElectricTables(String dbName) async {
    final adapter = _getSatellite(dbName).adapter;
    final dialect = await getDbDialect(dbName);
    return genericGetElectricTables(adapter, dialect);
  }

  @override
  List<DebugShape> getSatelliteShapeSubscriptions(String dbName) {
    final sat = _getSatellite(dbName) as SatelliteProcess;
    final manager = sat.subscriptions;
    final shapes = jsonDecode(manager.serialize()) as Map<String, dynamic>;

    return shapes.entries
        .map((e) {
          final id = e.key;
          final shapes = (e.value as List<dynamic>)
              .map(
                (j) => Shape.fromMap(
                  (j as Map<String, dynamic>)['definition']
                      as Map<String, dynamic>,
                ),
              )
              .toList();
          return shapes.map(
            (s) => DebugShape(
              id: id,
              shape: s,
            ),
          );
        })
        .expand((e) => e)
        .toList();
  }
}
