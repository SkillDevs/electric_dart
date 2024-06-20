import 'package:drift/drift.dart' hide Migrator;
import 'package:electricsql/drivers/drift.dart';
import 'package:electricsql/electricsql.dart';
import 'package:electricsql/migrators.dart';
import 'package:electricsql/src/client/model/client.dart';
import 'package:electricsql/src/client/model/relation.dart';
import 'package:electricsql/src/client/model/schema.dart';
import 'package:electricsql/src/client/model/transform.dart';
import 'package:electricsql/src/config/config.dart';
import 'package:electricsql/src/drivers/drift/sync_input.dart';
import 'package:electricsql/src/electric/electric.dart' as electrify_lib;
import 'package:electricsql/src/electric/electric.dart';
import 'package:electricsql/src/notifiers/notifiers.dart';
import 'package:electricsql/src/satellite/satellite.dart';
import 'package:electricsql/src/sockets/sockets.dart';
import 'package:electricsql/src/util/debug/debug.dart';
import 'package:electricsql/util.dart';
import 'package:meta/meta.dart';

Future<ElectricClient<DB>> electrify<DB extends GeneratedDatabase>({
  required String dbName,
  required DB db,
  required ElectricMigrations migrations,
  required ElectricConfig config,
  ElectrifyOptions? opts,
}) async {
  final adapter = opts?.adapter ?? DriftAdapter(db);
  final socketFactory = opts?.socketFactory ?? getDefaultSocketFactory();

  final sqliteMigrations = migrations.sqliteMigrations;
  final pgMigrations = migrations.pgMigrations;

  final dbDescription = DBSchemaDrift(
    db: db,
    migrations: sqliteMigrations,
    pgMigrations: pgMigrations,
  );

  final Dialect dialect = driftDialectToElectric(db);

  Migrator migrator;
  if (opts?.migrator != null) {
    migrator = opts!.migrator!;
  } else {
    migrator = dialect == Dialect.sqlite
        ? SqliteBundleMigrator(adapter: adapter, migrations: sqliteMigrations)
        : PgBundleMigrator(adapter: adapter, migrations: pgMigrations);
  }

  final namespace = await electrify_lib.electrifyBase(
    dbName: dbName,
    dbDescription: dbDescription,
    config: ElectricConfigWithDialect.from(
      config: config,
      dialect: dialect,
    ),
    adapter: adapter,
    socketFactory: socketFactory,
    opts: ElectrifyBaseOptions(
      migrator: migrator,
      notifier: opts?.notifier,
      registry: opts?.registry,
      // In postgres, we don't want to run the default prepare function
      // that enables FK constraints, as Postgres already has them enabled.
      prepare: dialect == Dialect.postgres ? (_) async {} : null,
    ),
  );

  final driftClient = DriftElectricClient(namespace as ElectricClientImpl, db);
  driftClient.init();

  return driftClient;
}

Dialect driftDialectToElectric(DatabaseConnectionUser db) {
  final driftDialect = db.typeMapping.dialect;

  return switch (driftDialect) {
    SqlDialect.sqlite => Dialect.sqlite,
    SqlDialect.postgres => Dialect.postgres,
    _ => throw ArgumentError('Unsupported dialect for Electric: $driftDialect'),
  };
}

abstract interface class ElectricClient<DB extends GeneratedDatabase>
    implements BaseElectricClient {
  DB get db;
  SyncManager get syncManager;

  /// Subscribes to the given shape, returnig a [ShapeSubscription] object which
  /// can be used to wait for the shape to sync initial data.
  ///
  /// https://electric-sql.com/docs/usage/data-access/shapes
  ///
  /// NOTE: If you establish a shape subscription that has already synced its initial data,
  /// awaiting `shape.synced` will always resolve immediately as shape subscriptions are persisted.
  /// i.e.: imagine that you re-sync the same shape during subsequent application loads.
  /// Awaiting `shape.synced` a second time will only ensure that the initial
  /// shape load is complete. It does not ensure that the replication stream
  /// has caught up to the central DB's more recent state.
  ///
  /// @param i - The shape to subscribe to
  /// @returns A shape subscription
  Future<ShapeSubscription> syncTable<T extends Table>(
    T table, {
    SyncIncludeBuilder<T>? include,
    SyncWhereBuilder<T>? where,
    String? key,
  });

  /// Same as [syncTable] but you would be providing table names, and foreign key
  /// relationships manually. This is more low-level and should be avoided if
  /// possible.
  Future<ShapeSubscription> syncTableRaw(SyncInputRaw syncInput);

  /// Puts transforms in place such that any data being replicated
  /// to or from this table is first handled appropriately while
  /// retaining type consistency.
  ///
  /// Can be used to encrypt sensitive fields before they are
  /// replicated outside of their secure local source.
  ///
  /// NOTE: usage is discouraged, but ensure transforms are
  /// set before replication is initiated using [syncTable]
  /// to avoid partially transformed tables.
  void setTableReplicationTransform<TableDsl extends Table, D>(
    TableInfo<TableDsl, D> table, {
    required D Function(D row) transformInbound,
    required D Function(D row) transformOutbound,
    Insertable<D> Function(D)? toInsertable,
  });

  /// Clears any replication transforms set using [setReplicationTransform]
  void clearTableReplicationTransform<TableDsl extends Table, D>(
    TableInfo<TableDsl, D> table,
  );
}

class DriftElectricClient<DB extends GeneratedDatabase>
    implements ElectricClient<DB> {
  @override
  final DB db;

  @override
  SyncManager get syncManager => _baseClient.syncManager;

  final ElectricClientImpl _baseClient;

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
    // Propagate change events from Electric to Drift
    final _unsubDataChanges = notifier.subscribeToDataChanges(
      (notification) {
        final origin = notification.origin;

        // Skip propagating changes coming from local. We assume
        // that the user is properly using Stream queries with drift,
        // so no need to notify twice (one from drift itself and other right here)
        if (origin == ChangeOrigin.local) {
          return;
        }

        final Set<String> tablesChanged = notification.changes.map((e) {
          final tableName = e.qualifiedTablename.tablename;
          return tableName;
        }).toSet();

        final Set<_TableUpdateFromElectric> tableUpdates =
            tablesChanged.map((e) => _TableUpdateFromElectric(e)).toSet();

        if (tableUpdates.isNotEmpty) {
          // Notify drift
          logger.debug(
            'notifying Drift of database changes: Changed tables: $tablesChanged. Origin: ${origin.name}',
          );
          db.notifyUpdates(tableUpdates);
        }
      },
    );

    // Propagate change events from Drift to Electric
    final tableUpdateSub = db.tableUpdates().listen((updatedTables) {
      final tableNames = updatedTables
          .where((update) => update is! _TableUpdateFromElectric)
          .map((update) => update.table)
          .toSet();

      // Only notify Electric for the tables that were not triggered
      // by Electric itself in "notifier.subscribeToDataChanges"
      if (tableNames.isNotEmpty) {
        logger.debug(
          'notifying Electric of database changes. Changed tables: $tableNames',
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
    String? key,
  }) {
    final shape = computeShapeForDrift<T>(
      db,
      table,
      include: include,
      where: where,
    );

    // print("SHAPE ${shape.toMap()}");

    return _baseClient.syncShapeInternal(shape, key);
  }

  @override
  Future<ShapeSubscription> syncTableRaw(SyncInputRaw syncInput) async {
    final shape = computeShape(syncInput);
    return _baseClient.syncShapeInternal(shape, syncInput.key);
  }

  @override
  void setTableReplicationTransform<TableDsl extends Table, D>(
    TableInfo<TableDsl, D> table, {
    required D Function(D row) transformInbound,
    required D Function(D row) transformOutbound,
    Insertable<D> Function(D)? toInsertable,
  }) {
    // forbid transforming relation keys to avoid breaking
    // referential integrity

    final tableRelations = getTableRelations(table)?.$relationsList ?? [];

    final outgoingRelations =
        tableRelations.where((r) => r.isOutgoingRelation());
    final incomingRelations =
        tableRelations.where((r) => r.isIncomingRelation());

    // the column could be the FK column when it is an outgoing FK
    // or it could be a PK column when it is an incoming FK
    final fkCols = outgoingRelations.map((r) => r.fromField);

    // Incoming relations don't have the `fromField` and `toField` filled in
    // so we need to fetch the `toField` from the opposite relation
    // which is effectively a column in this table to which the FK points
    final pkCols =
        incomingRelations.map((r) => r.getOppositeRelation(db).toField);

    // Merge all columns that are part of a FK relation.
    // Remove duplicate columns in case a column has both an outgoing FK and an incoming FK.
    final immutableFields = <String>{...fkCols, ...pkCols}.toList();

    final QualifiedTablename qualifiedTableName = _getQualifiedTableName(table);

    Insertable<D> _getInsertable(D d) {
      if (d is Insertable<D>) {
        return d;
      } else {
        if (toInsertable == null) {
          throw ArgumentError(
            'toInsertable is required for non-insertable data classes',
          );
        }
        return toInsertable(d);
      }
    }

    // ignore: invalid_use_of_protected_member
    _baseClient.replicationTransformManager.setTableTransform(
      qualifiedTableName,
      ReplicatedRowTransformer(
        transformInbound: (DbRecord record) {
          final dataClass = table.map(record) as D;
          final out = transformTableRecord<D>(
            dataClass,
            transformInbound,
            immutableFields,
            validateFun: (d) => validateDriftRecord(table, _getInsertable(d)),
            toRecord: (d) => driftInsertableToValues(_getInsertable(d)),
          );
          return driftInsertableToValues(_getInsertable(out));
        },
        transformOutbound: (DbRecord record) {
          final dataClass = table.map(record) as D;
          final out = transformTableRecord<D>(
            dataClass,
            transformOutbound,
            immutableFields,
            validateFun: (d) => validateDriftRecord(table, _getInsertable(d)),
            toRecord: (d) => driftInsertableToValues(_getInsertable(d)),
          );
          return driftInsertableToValues(_getInsertable(out));
        },
      ),
    );
  }

  @override
  void clearTableReplicationTransform<TableDsl extends Table, D>(
    TableInfo<TableDsl, D> table,
  ) {
    final qualifiedTableName = _getQualifiedTableName(table);
    // ignore: invalid_use_of_protected_member
    _baseClient.replicationTransformManager
        .clearTableTransform(qualifiedTableName);
  }

  QualifiedTablename _getQualifiedTableName<TableDsl extends Table, D>(
    TableInfo<TableDsl, D> table,
  ) {
    return QualifiedTablename('main', table.actualTableName);
  }
}

void validateDriftRecord<TableDsl extends Table, D>(
  TableInfo<TableDsl, D> table,
  Insertable<D> record,
) {
  table.validateIntegrity(record, isInserting: true).throwIfInvalid(record);
}

class _TableUpdateFromElectric extends TableUpdate {
  _TableUpdateFromElectric(super.table);
}

Map<String, Object?> driftInsertableToValues(Insertable<dynamic> insertable) {
  return insertable
      .toColumns(false)
      .map((key, val) => MapEntry(key, _expressionToValue(val)));
}

Object? _expressionToValue(Expression<Object?> expression) {
  if (expression is Variable) {
    return expression.value;
  } else if (expression is Constant) {
    return expression.value;
  } else {
    throw ArgumentError('Unsupported expression type: $expression');
  }
}
