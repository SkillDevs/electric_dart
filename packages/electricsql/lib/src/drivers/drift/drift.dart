import 'package:drift/drift.dart';
import 'package:electricsql/drivers/drift.dart';
import 'package:electricsql/electricsql.dart';
import 'package:electricsql/src/client/model/schema.dart';
import 'package:electricsql/src/electric/electric.dart' as electrify_lib;
import 'package:electricsql/src/electric/electric.dart';
import 'package:electricsql/src/notifiers/notifiers.dart';
import 'package:electricsql/src/satellite/satellite.dart';
import 'package:electricsql/src/sockets/sockets.dart';
import 'package:electricsql/src/util/debug/debug.dart';
import 'package:meta/meta.dart';

Future<DriftElectricClient<DB>> electrify<DB extends DatabaseConnectionUser>({
  required String dbName,
  required DB db,
  required List<Migration> migrations,
  required ElectricConfig config,
  ElectrifyOptions? opts,
}) async {
  final adapter = opts?.adapter ?? DriftAdapter(db);
  final socketFactory = opts?.socketFactory ?? getDefaultSocketFactory();

  final dbDescription = DBSchemaDrift(
    db: db,
    migrations: migrations,
  );

  final namespace = await electrify_lib.electrifyBase(
    dbName: dbName,
    dbDescription: dbDescription,
    config: config,
    adapter: adapter,
    socketFactory: socketFactory,
    opts: ElectrifyBaseOptions(
      migrator: opts?.migrator,
      notifier: opts?.notifier,
      registry: opts?.registry,
    ),
  );

  final driftClient = DriftElectricClient(namespace, db);
  driftClient.init();

  return driftClient;
}

class DriftElectricClient<DB extends DatabaseConnectionUser>
    implements ElectricClient {
  final DB db;

  final ElectricClient _baseClient;

  void Function()? _disposeHook;

  DriftElectricClient(this._baseClient, this.db);

  @visibleForTesting
  void init() {
    assert(_disposeHook == null, 'Already initialized');

    _disposeHook = _hookToNotifier();
  }

  @override
  Future<void> close() async {
    await _baseClient.close();

    _disposeHook?.call();
    _disposeHook = null;
  }

  void Function() _hookToNotifier() {
    final _unsubDataChanges = notifier.subscribeToDataChanges(
      (notification) {
        final tablesChanged = notification.changes.map((e) {
          final tableName = e.qualifiedTablename.tablename;
          return tableName;
        }).toSet();

        final Set<_TableUpdateFromElectric> tableUpdates =
            tablesChanged.map((e) => _TableUpdateFromElectric(e)).toSet();
        logger.info('Notifying table changes to drift: $tablesChanged');

        // Notify drift
        db.notifyUpdates(tableUpdates);
      },
    );

    final tableUpdateSub = db.tableUpdates().listen((updatedTables) {
      final tableNames = updatedTables
          .where((update) => update is! _TableUpdateFromElectric)
          .map((update) => update.table)
          .toSet();

      // Only notify Electric for the tables that were not triggered
      // by Electric itself in "notifier.subscribeToDataChanges"
      if (tableNames.isNotEmpty) {
        logger.info(
          'Drift tables have been updated $updatedTables. Notifying Electric.',
        );
        notifier.potentiallyChanged();
      }
    });

    return () {
      _unsubDataChanges();
      tableUpdateSub.cancel();
    };
  }

  @override
  DatabaseAdapter get adapter => _baseClient.adapter;

  @override
  DBSchema get dbDescription => _baseClient.dbDescription;

  @override
  bool get isConnected => _baseClient.isConnected;

  @override
  Notifier get notifier => _baseClient.notifier;

  @override
  String get dbName => _baseClient.dbName;

  @override
  Registry get registry => _baseClient.registry;

  @override
  void potentiallyChanged() {
    return _baseClient.potentiallyChanged();
  }

  @override
  Satellite get satellite => _baseClient.satellite;

  @override
  void setIsConnected(ConnectivityState connectivityState) {
    return _baseClient.setIsConnected(connectivityState);
  }

  @override
  Future<ShapeSubscription> syncTables(List<String> tables) {
    return _baseClient.syncTables(tables);
  }

  @override
  Future<void> connect([String? token]) {
    return _baseClient.connect(token);
  }

  @override
  void disconnect() {
    return _baseClient.disconnect();
  }
}

class _TableUpdateFromElectric extends TableUpdate {
  _TableUpdateFromElectric(super.table);
}
