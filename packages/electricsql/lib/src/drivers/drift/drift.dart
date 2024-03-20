import 'package:drift/drift.dart';
import 'package:electricsql/drivers/drift.dart';
import 'package:electricsql/electricsql.dart';
import 'package:electricsql/src/client/model/schema.dart';
import 'package:electricsql/src/drivers/drift/sync_input.dart';
import 'package:electricsql/src/electric/electric.dart' as electrify_lib;
import 'package:electricsql/src/electric/electric.dart';
import 'package:electricsql/src/notifiers/notifiers.dart';
import 'package:electricsql/src/satellite/satellite.dart';
import 'package:electricsql/src/sockets/sockets.dart';
import 'package:electricsql/src/util/debug/debug.dart';
import 'package:meta/meta.dart';

Future<ElectricClient<DB>> electrify<DB extends GeneratedDatabase>({
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

abstract interface class ElectricClient<DB extends GeneratedDatabase>
    implements BaseElectricClient {
  DB get db;

  Future<ShapeSubscription> syncTable<T extends Table>(
    T table, {
    SyncIncludeBuilder<T>? include,
    SyncWhereBuilder<T>? where,
  });
}

class DriftElectricClient<DB extends GeneratedDatabase>
    implements ElectricClient<DB> {
  @override
  final DB db;

  final ElectricClientRaw _baseClient;

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

        final tableUpdates = tablesChanged.map((e) => TableUpdate(e)).toSet();
        logger.info('Notifying table changes to drift: $tablesChanged');
        db.notifyUpdates(tableUpdates);
      },
    );

    final tableUpdateSub = db.tableUpdates().listen((updatedTables) {
      logger.info(
        'Drift tables have been updated $updatedTables. Notifying Electric.',
      );
      notifier.potentiallyChanged();
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
  Future<void> connect([String? token]) {
    return _baseClient.connect(token);
  }

  @override
  void disconnect() {
    return _baseClient.disconnect();
  }

  @override
  Future<ShapeSubscription> syncTable<T extends Table>(
    T table, {
    SyncIncludeBuilder<T>? include,
    SyncWhereBuilder<T>? where,
  }) {
    final shape = computeShapeForDrift<T>(
      db,
      table,
      include: include,
      where: where,
    );

    // print("SHAPE ${shape.toMap()}");

    return _baseClient
        // ignore: invalid_use_of_protected_member
        .syncShapeInternal(shape);
  }
}
