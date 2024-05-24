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
    final manager = sat.subscriptionManager;
    final subscriptions = manager.listAllSubscriptions();
    return subscriptions
        .expand(
          (subscription) => subscription.shapes.map(
            (Shape shape) => DebugShape(
              key: subscription.key,
              shape: shape,
              status: subscription.status.statusType,
            ),
          ),
        )
        .toList();
  }

  @override
  UnsubscribeFunction subscribeToSatelliteShapeSubscriptions(
    String dbName,
    void Function(List<DebugShape> shapes) callback,
  ) {
    final sat = _getSatellite(dbName);

    // subscribe to subsequent changes
    return sat.notifier.subscribeToShapeSubscriptionSyncStatusChanges(
      (_) => callback(getSatelliteShapeSubscriptions(dbName)),
    );
  }

  @override
  Future<RemoteQueryRes> queryDb(
    String dbName,
    String sql,
    List<Object?> args,
  ) async {
    final sat = _getSatellite(dbName);
    try {
      final rows = await sat.adapter.query(Statement(sql, args));

      final encodableRows = rows.map((row) {
        return row.map((key, value) {
          if (value == null ||
              value is num ||
              value is bool ||
              value is String) {
            return MapEntry(key, value);
          } else if (value is DateTime) {
            return MapEntry(key, value.toIso8601String());
          } else {
            return MapEntry(key, value.toString());
          }
        });
      }).toList();

      return RemoteQueryRes(rows: encodableRows, error: null);
    } catch (e) {
      return RemoteQueryRes(rows: [], error: e.toString());
    }
  }

  @override
  UnsubscribeFunction subscribeToDbTable(
    String dbName,
    String tableName,
    void Function() callback,
  ) {
    final sat = _getSatellite(dbName);

    // subscribe to subsequent changes
    return sat.notifier.subscribeToDataChanges((notification) {
      if (notification.dbName != dbName) return;
      for (final change in notification.changes) {
        if (change.qualifiedTablename.tablename == tableName ||
            // always trigger an update if subscribing to internal tables
            tableName.startsWith('_electric')) {
          callback();
          return;
        }
      }
    });
  }
}
