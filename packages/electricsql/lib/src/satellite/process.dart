import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:electricsql/src/auth/auth.dart';
import 'package:electricsql/src/auth/secure.dart';
import 'package:electricsql/src/electric/adapter.dart';
import 'package:electricsql/src/migrators/migrators.dart';
import 'package:electricsql/src/migrators/triggers.dart';
import 'package:electricsql/src/notifiers/notifiers.dart';
import 'package:electricsql/src/proto/satellite.pbenum.dart';
import 'package:electricsql/src/satellite/config.dart';
import 'package:electricsql/src/satellite/error.dart';
import 'package:electricsql/src/satellite/merge.dart';
import 'package:electricsql/src/satellite/oplog.dart';
import 'package:electricsql/src/satellite/satellite.dart';
import 'package:electricsql/src/satellite/shapes/manager.dart';
import 'package:electricsql/src/satellite/shapes/shapes.dart';
import 'package:electricsql/src/satellite/shapes/types.dart';
import 'package:electricsql/src/util/arrays.dart';
import 'package:electricsql/src/util/common.dart';
import 'package:electricsql/src/util/converters/helpers.dart';
import 'package:electricsql/src/util/debug/debug.dart';
import 'package:electricsql/src/util/js_array_funs.dart';
import 'package:electricsql/src/util/random.dart';
import 'package:electricsql/src/util/relations.dart';
import 'package:electricsql/src/util/statements.dart';
import 'package:electricsql/src/util/tablename.dart';
import 'package:electricsql/src/util/types.dart' hide Change;
import 'package:meta/meta.dart';
import 'package:retry/retry.dart' as retry_lib;
import 'package:synchronized/synchronized.dart';

typedef Uuid = String;

typedef ChangeAccumulator = Map<String, Change>;

class ShapeSubscription {
  final Future<void> synced;

  ShapeSubscription({required this.synced});
}

typedef SubscriptionNotifier = ({
  void Function() success,
  void Function(Object error) failure
});

typedef ConnectRetryHandler = bool Function(Object error, int attempt);

// ignore: prefer_function_declarations_over_variables
final ConnectRetryHandler defaultConnectRetryHandler = (error, _attempts) {
  if (error is! SatelliteException || isThrowable(error) || isFatal(error)) {
    logger.debug('connectAndStartRetryHandler was cancelled: $error');
    return false;
  }
  return true;
};

class SatelliteProcess implements Satellite {
  @override
  final DbName dbName;

  @override
  DatabaseAdapter get adapter => _adapter;
  DatabaseAdapter _adapter;

  @override
  final Migrator migrator;
  @override
  final Notifier notifier;
  final Client client;

  final SatelliteOpts opts;

  @visibleForTesting
  AuthState? authState;
  UnsubscribeFunction? _unsubscribeFromAuthState;

  @override
  ConnectivityState? connectivityState;
  UnsubscribeFunction? _unsubscribeFromConnectivityChanges;

  Timer? _pollingInterval;
  UnsubscribeFunction? _unsubscribeFromPotentialDataChanges;
  late final Throttle<DateTime> throttledSnapshot;

  LSN? _lsn;

  @visibleForTesting
  LSN? get debugLsn => _lsn;

  RelationsCache relations = {};

  final List<ClientShapeDefinition> previousShapeSubscriptions = [];
  late SubscriptionsManager subscriptions;
  final Map<String, Completer<void>> subscriptionNotifiers = {};
  late String Function() subscriptionIdGenerator;
  late String Function() shapeRequestIdGenerator;

  /*
  To optimize inserting a lot of data when the subscription data comes, we need to do
  less `INSERT` queries, but SQLite supports only a limited amount of `?` positional
  arguments. Precisely, its either 999 for versions prior to 3.32.0 and 32766 for
  versions after.
  */
  int maxSqlParameters = 999; // : 999 | 32766
  final Lock _snapshotLock = Lock();
  bool _performingSnapshot = false;

  @visibleForTesting
  late ConnectRetryHandler connectRetryHandler;
  Waiter? initializing;

  SatelliteProcess({
    required this.dbName,
    required this.client,
    required this.opts,
    required DatabaseAdapter adapter,
    required this.migrator,
    required this.notifier,
  }) : _adapter = adapter {
    subscriptions = InMemorySubscriptionsManager(
      garbageCollectShapeHandler,
    );
    throttledSnapshot = Throttle(
      _mutexSnapshot,
      opts.minSnapshotWindow,
    );

    subscriptionIdGenerator = () => genUUID();
    shapeRequestIdGenerator = subscriptionIdGenerator;

    connectRetryHandler = defaultConnectRetryHandler;

    setClientListeners();
  }

  /// Perform a snapshot while taking out a mutex to avoid concurrent calls.
  Future<DateTime> _mutexSnapshot() async {
    return _snapshotLock.synchronized(() {
      return performSnapshot();
    });
  }

  @visibleForTesting
  void updateDatabaseAdapter(DatabaseAdapter newAdapter) {
    _adapter = newAdapter;
  }

  @override
  Future<void> start(AuthConfig? authConfig) async {
    if (opts.debug) {
      await _logSQLiteVersion();
    }

    await migrator.up();

    final isVerified = await _verifyTableStructure();
    if (!isVerified) {
      throw Exception('Invalid database schema.');
    }

    final configClientId = authConfig?.clientId;
    final clientId = configClientId != null && configClientId != ''
        ? configClientId
        : await _getClientId();
    setAuthState(AuthState(clientId: clientId));

    final notifierSubscriptions = {
      '_authStateSubscription': _unsubscribeFromAuthState,
      '_connectivityChangeSubscription': _unsubscribeFromConnectivityChanges,
      '_potentialDataChangeSubscription': _unsubscribeFromPotentialDataChanges,
    };
    notifierSubscriptions.forEach((name, value) {
      if (value != null) {
        throw Exception('''
Starting satellite process with an existing `$name`.
This means there is a notifier subscription leak.`''');
      }
    });

    // Monitor auth state changes.
    _unsubscribeFromAuthState =
        notifier.subscribeToAuthStateChanges(_updateAuthState);

    // Request a snapshot whenever the data in our database potentially changes.
    _unsubscribeFromPotentialDataChanges =
        notifier.subscribeToPotentialDataChanges((_) => throttledSnapshot());

    // Start polling to request a snapshot every `pollingInterval` ms.
    _pollingInterval = Timer.periodic(
      opts.pollingInterval,
      (_) => throttledSnapshot(),
    );

    // Starting now!
    unawaited(Future(() => throttledSnapshot()));

    // Need to reload primary keys after schema migration
    relations = await getLocalRelations();
    await checkMaxSqlParameters();

    final lsnBase64 = await getMeta<String?>('lsn');
    if (lsnBase64 != null && lsnBase64.isNotEmpty) {
      _lsn = base64.decode(lsnBase64);
      logger.info('retrieved lsn $_lsn');
    } else {
      logger.info('no lsn retrieved from store');
    }

    final subscriptionsState = await getMeta<String>('subscriptions');
    if (subscriptionsState.isNotEmpty) {
      subscriptions.setState(subscriptionsState);
    }
  }

  Future<void> _logSQLiteVersion() async {
    final sqliteVersionRow =
        await adapter.query(Statement('SELECT sqlite_version() AS version'));
    logger.info("Using SQLite version: ${sqliteVersionRow.first['version']}");
  }

  @visibleForTesting
  void setAuthState(AuthState newAuthState) {
    authState = newAuthState;
  }

  @visibleForTesting
  Future<void> garbageCollectShapeHandler(
    List<ShapeDefinition> shapeDefs,
  ) async {
    final stmts = <Statement>[];
    final tablenames = <String>[];
    // reverts to off on commit/abort
    stmts.add(Statement('PRAGMA defer_foreign_keys = ON'));
    shapeDefs.expand((ShapeDefinition def) => def.definition.selects).map(
      (ShapeSelect select) {
        tablenames.add('main.${select.tablename}');
        // We need "fully qualified" table names in the next calls
        return 'main.${select.tablename}';
      },
    ).fold(stmts, (List<Statement> stmts, String tablename) {
      stmts.addAll([
        Statement(
          'DELETE FROM $tablename',
        ),
      ]);
      return stmts;
      // does not delete shadow rows but we can do that
    });

    final stmtsWithTriggers = [
      ..._disableTriggers(tablenames),
      ...stmts,
      ..._enableTriggers(tablenames),
    ];

    await adapter.runInTransaction(stmtsWithTriggers);
  }

  void setClientListeners() {
    client.subscribeToError(_handleClientError);
    client.subscribeToRelations(updateRelations);
    client.subscribeToTransactions(applyTransaction);
    client.subscribeToOutboundStarted((_) => throttledSnapshot());

    client.subscribeToSubscriptionEvents(
      _handleSubscriptionData,
      _handleSubscriptionError,
    );
  }

  @override
  Future<void> stop({bool? shutdown}) async {
    await _stop(shutdown: shutdown);
  }

  Future<void> _stop({bool? shutdown}) async {
    // Stop snapshotting and polling for changes.
    throttledSnapshot.cancel();

    if (_pollingInterval != null) {
      _pollingInterval!.cancel();
      _pollingInterval = null;
    }

    if (_unsubscribeFromAuthState != null) {
      _unsubscribeFromAuthState?.call();
      _unsubscribeFromAuthState = null;
    }

    if (_unsubscribeFromConnectivityChanges != null) {
      _unsubscribeFromConnectivityChanges?.call();
      _unsubscribeFromConnectivityChanges = null;
    }

    if (_unsubscribeFromPotentialDataChanges != null) {
      _unsubscribeFromPotentialDataChanges?.call();
      _unsubscribeFromPotentialDataChanges = null;
    }

    disconnect(null);

    if (shutdown == true) {
      client.shutdown();
    }
  }

  @override
  Future<ShapeSubscription> subscribe(
    List<ClientShapeDefinition> shapeDefinitions,
  ) async {
    // Await for client to be ready before doing anything else
    await initializing?.waitOn();

    // First, we want to check if we already have either fulfilled or fulfilling subscriptions with exactly the same definitions
    final existingSubscription =
        subscriptions.getDuplicatingSubscription(shapeDefinitions);
    if (existingSubscription != null &&
        existingSubscription is DuplicatingSubInFlight) {
      return ShapeSubscription(
        synced: subscriptionNotifiers[existingSubscription.inFlight]!.future,
      );
    } else if (existingSubscription != null &&
        existingSubscription is DuplicatingSubFulfilled) {
      return ShapeSubscription(
        synced: Future.value(),
      );
    }

    // If no exact match found, we try to establish the subscription
    final List<ShapeRequest> shapeReqs = shapeDefinitions
        .map(
          (definition) => ShapeRequest(
            requestId: shapeRequestIdGenerator(),
            definition: definition,
          ),
        )
        .toList();

    final subId = subscriptionIdGenerator();
    subscriptions.subscriptionRequested(subId, shapeReqs);

    final completer = Completer<void>();
    // store the resolve and reject
    // such that we can resolve/reject
    // the promise later when the shape
    // is fulfilled or when an error arrives
    // we store it before making the actual request
    // to avoid that the answer would arrive too fast
    // and this resolver and rejecter would not yet be stored
    // this could especially happen in unit tests
    subscriptionNotifiers[subId] = completer;

    // store the promise because by the time the
    // `await this.client.subscribe(subId, shapeReqs)` call resolves
    // the `subId` entry in the `subscriptionNotifiers` may have been deleted
    // so we can no longer access it
    final subProm = subscriptionNotifiers[subId]!.future;

    // `clearSubAndThrow` deletes the listeners and cancels the subscription
    Never clearSubAndThrow(Object error) {
      subscriptionNotifiers.remove(subId);
      subscriptions.subscriptionCancelled(subId);
      throw error;
    }

    try {
      final SubscribeResponse(:subscriptionId, :error) =
          await client.subscribe(subId, shapeReqs);
      if (subId != subscriptionId) {
        clearSubAndThrow(
          Exception(
            'Expected SubscripeResponse for subscription id: $subId but got it for another id: $subscriptionId',
          ),
        );
      }

      if (error != null) {
        clearSubAndThrow(error);
      } else {
        return ShapeSubscription(
          synced: subProm,
        );
      }
    } catch (e) {
      clearSubAndThrow(e);
    }
  }

  @override
  Future<void> unsubscribe(String _subscriptionId) async {
    throw SatelliteException(
      SatelliteErrorCode.internal,
      'unsubscribe shape not supported',
    );
    // return this.subscriptions.unsubscribe(subscriptionId)
  }

  Future<void> _handleSubscriptionData(SubscriptionData subsData) async {
    subscriptions.subscriptionDelivered(subsData);

    // When data is empty, we will simply store the subscription and lsn state
    // Not storing this state means that a second open of the app will try to
    // re-insert rows which will possible trigger a UNIQUE constraint violation
    await _applySubscriptionData(subsData.data, subsData.lsn);

    // Call the `onSuccess` callback for this subscription
    final completer = subscriptionNotifiers[subsData.subscriptionId]!;
    // GC the notifiers for this subscription ID
    subscriptionNotifiers.remove(subsData.subscriptionId);
    completer.complete();
  }

  // Applies initial data for a shape subscription. Current implementation
  // assumes there are no conflicts INSERTing new rows and only expects
  // subscriptions for entire tables.
  Future<void> _applySubscriptionData(
    List<InitialDataChange> changes,
    LSN lsn,
  ) async {
    final stmts = <Statement>[];
    stmts.add(Statement('PRAGMA defer_foreign_keys = ON'));

    // It's much faster[1] to do less statements to insert the data instead of doing an insert statement for each row
    // so we're going to do just that, but with a caveat: SQLite has a max number of parameters in prepared statements,
    // so this is less of "insert all at once" and more of "insert in batches". This should be even more noticeable with
    // WASM builds, since we'll be crossing the JS-WASM boundary less.
    //
    // [1]: https://medium.com/@JasonWyatt/squeezing-performance-from-sqlite-insertions-971aff98eef2

    final groupedChanges = <String,
        ({
      Relation relation,
      List<InitialDataChange> dataChanges,
      QualifiedTablename tableName,
    })>{};

    final allArgsForShadowInsert = <Record>[];

    // Group all changes by table name to be able to insert them all together
    for (final op in changes) {
      final tableName = QualifiedTablename('main', op.relation.table);
      final tableNameString = tableName.toString();
      if (groupedChanges.containsKey(tableNameString)) {
        final changeGroup = groupedChanges[tableNameString]!;
        changeGroup.dataChanges.add(op);
      } else {
        groupedChanges[tableNameString] = (
          relation: op.relation,
          dataChanges: [op],
          tableName: tableName,
        );
      }

      // Since we're already iterating changes, we can also prepare data for shadow table
      final primaryKeyCols =
          op.relation.columns.fold(<String, Object>{}, (agg, col) {
        if (col.primaryKey != null && col.primaryKey!) {
          agg[col.name] = op.record[col.name]!;
        }
        return agg;
      });

      allArgsForShadowInsert.add({
        'namespace': 'main',
        'tablename': op.relation.table,
        'primaryKey': primaryKeyToStr(primaryKeyCols),
        'tags': encodeTags(op.tags),
      });
    }

    // Disable trigger for all affected tables
    stmts.addAll([..._disableTriggers(groupedChanges.keys.toList())]);

    // For each table, do a batched insert
    for (final entry in groupedChanges.entries) {
      final table = entry.key;
      final (:relation, :dataChanges, tableName: _) = entry.value;
      final records = dataChanges.map((change) => change.record).toList();
      final columnNames = relation.columns.map((col) => col.name).toList();
      final sqlBase = "INSERT INTO $table (${columnNames.join(', ')}) VALUES ";

      stmts.addAll([
        ...prepareInsertBatchedStatements(
          sqlBase,
          columnNames,
          records,
          maxSqlParameters,
        ),
      ]);
    }

    // And re-enable the triggers for all of them
    stmts.addAll([..._enableTriggers(groupedChanges.keys.toList())]);

    // Then do a batched insert for the shadow table
    final upsertShadowStmt =
        'INSERT or REPLACE INTO ${opts.shadowTable} (namespace, tablename, primaryKey, tags) VALUES ';
    stmts.addAll(
      prepareInsertBatchedStatements(
        upsertShadowStmt,
        ['namespace', 'tablename', 'primaryKey', 'tags'],
        allArgsForShadowInsert,
        maxSqlParameters,
      ),
    );

    // Then update subscription state and LSN
    stmts.add(_setMetaStatement('subscriptions', subscriptions.serialize()));
    stmts.add(updateLsnStmt(lsn));

    try {
      await adapter.runInTransaction(stmts);

      // We're explicitly not specifying rowids in these changes for now,
      // because nobody uses them and we don't have the machinery to to a
      // `RETURNING` clause in the middle of `runInTransaction`.
      final notificationChanges = <Change>[];
      for (final entry in groupedChanges.entries) {
        final (:relation, :dataChanges, :tableName) = entry.value;

        final primaryKeyColNames = relation.columns
            .where((col) => col.primaryKey == true)
            .map((col) => col.name)
            .toList();
        notificationChanges.add(
          Change(
            qualifiedTablename: tableName,
            rowids: [],
            recordChanges: dataChanges.map((change) {
              return RecordChange(
                primaryKey: Map.fromEntries(
                  primaryKeyColNames.map((colName) {
                    return MapEntry(colName, change.record[colName]);
                  }),
                ),
                type: RecordChangeType.initial,
              );
            }).toList(),
          ),
        );
      }
      notifier.actuallyChanged(
        dbName,
        notificationChanges,
        ChangeOrigin.initial,
      );
    } catch (e) {
      unawaited(
        _handleSubscriptionError(
          SubscriptionErrorData(
            error: SatelliteException(
              SatelliteErrorCode.internal,
              'Error applying subscription data: $e',
            ),
            subscriptionId: null,
          ),
        ),
      );
    }
  }

  Future<void> _resetClientState({
    bool keepSubscribedShapes = false,
  }) async {
    logger.warning('resetting client state');
    disconnect(null);
    final subscriptionIds = subscriptions.getFulfilledSubscriptions();

    if (keepSubscribedShapes) {
      final List<ClientShapeDefinition> shapeDefs = subscriptionIds
          .map((subId) => subscriptions.shapesForActiveSubscription(subId))
          .whereNotNull()
          .expand((List<ShapeDefinition> s) => s.map((i) => i.definition))
          .toList();

      previousShapeSubscriptions.addAll(shapeDefs);
    }

    _lsn = null;

    // TODO: this is obviously too conservative
    // we should also work on updating subscriptions
    // atomically on unsubscribe()
    await subscriptions.unsubscribeAll();

    await adapter.runInTransaction([
      _setMetaStatement('lsn', null),
      _setMetaStatement('subscriptions', subscriptions.serialize()),
    ]);
  }

  Future<void> _handleSubscriptionError(
    SubscriptionErrorData errorData,
  ) async {
    final subscriptionId = errorData.subscriptionId;
    final satelliteError = errorData.error;

    logger.error('encountered a subscription error: ${satelliteError.message}');

    await _resetClientState();

    // Call the `onFailure` callback for this subscription
    if (subscriptionId != null) {
      final completer = subscriptionNotifiers[subscriptionId]!;

      // GC the notifiers for this subscription ID
      subscriptionNotifiers.remove(subscriptionId);
      completer.completeError(satelliteError);
    }
  }

  // handles async client errors: can be a socket error or a server error message
  Future<void> _handleClientError(SatelliteException satelliteError) async {
    if (initializing != null && !initializing!.finished) {
      if (satelliteError.code == SatelliteErrorCode.socketError) {
        logger.warning(
          'a socket error occurred while connecting to server: ${satelliteError.message}',
        );
        return;
      }

      if (satelliteError.code == SatelliteErrorCode.authRequired) {
        // TODO: should stop retrying
        logger.warning(
          'an authentication error occurred while connecting to server: ${satelliteError.message}',
        );
        return;
      }

      // throw unhandled error
      throw satelliteError;
    }

    logger.warning(
      'an error occurred in satellite: ${satelliteError.message}',
    );

    unawaited(_handleOrThrowClientError(satelliteError));
  }

  Future<void> _handleOrThrowClientError(SatelliteException error) async {
    if (error.code == SatelliteErrorCode.authExpired) {
      logger.warning('Connection closed by Electric because the JWT expired.');
      return disconnect(
        SatelliteException(
          error.code,
          'Connection closed by Electric because the JWT expired.',
        ),
      );
    }

    disconnect(error);

    if (isThrowable(error)) {
      throw error;
    }
    if (isFatal(error)) {
      throw wrapFatalError(error);
    }

    logger.warning('Client disconnected with a non fatal error, reconnecting');
    return connectWithBackoff();
  }

  /// Sets the JWT token.
  /// @param token The JWT token.
  @override
  void setToken(String token) {
    final newUserId = decodeUserIdFromToken(token);
    final String? userId = authState?.userId;
    if (userId != null && newUserId != userId) {
      // We must check that the new token is still using the same user ID.
      // We can't accept a re-connection that changes the user ID because the Satellite process is statefull.
      // To change user ID the user must re-electrify the database.
      throw ArgumentError(
        "Can't change user ID when reconnecting. Previously connected with user ID '$userId' but trying to reconnect with user ID '$newUserId'",
      );
    }
    setAuthState(
      authState!.copyWith(
        userId: () => newUserId,
        token: () => token,
      ),
    );
  }

  /// @returns True if a JWT token has been set previously. False otherwise.
  @override
  bool hasToken() {
    return authState?.token != null;
  }

  @override
  Future<void> connectWithBackoff() async {
    if (client.isConnected()) {
      // we're already connected
      return;
    }

    if (initializing != null && !initializing!.finished) {
      // we're already trying to connect to Electric
      // return the promise that resolves when the connection is established
      return initializing!.waitOn();
    }

    final _initializing = initializing;
    if (_initializing == null || _initializing.finished) {
      initializing = Waiter();
    }

    final fut = initializing!.waitOn();

    // This is so that the future is not treated as unhandled
    fut.ignore();

    Future<void> _attemptBody() async {
      if (initializing?.finished == true) {
        return fut;
      }
      await _connect();
      await _startReplication();
      _subscribePreviousShapeRequests();

      _notifyConnectivityState(ConnectivityStatus.connected, null);
      initializing?.complete();
    }

    final backoffOpts = opts.connectionBackoffOptions;
    int retryAttempt = 0;
    try {
      await retry_lib.retry(
        () {
          retryAttempt++;
          return _attemptBody();
        },
        maxAttempts: backoffOpts.numOfAttempts,
        maxDelay: backoffOpts.maxDelay,
        delayFactor: backoffOpts.startingDelay,
        randomizationFactor: backoffOpts.randomizationFactor,
        retryIf: (e) {
          return connectRetryHandler(e, retryAttempt);
        },
      );
    } catch (e) {
      // We're very sure that no calls are going to modify `this.initializing` before this promise resolves
      // eslint-disable-next-line @typescript-eslint/no-non-null-assertion

      final error = !connectRetryHandler(e, 0)
          ? e
          : SatelliteException(
              SatelliteErrorCode.connectionFailedAfterRetry,
              'Failed to connect to server after exhausting retry policy. Last error thrown by server: $e',
            );

      disconnect(error is SatelliteException ? error : null);
      initializing?.completeError(error);
    }

    return fut;
  }

  void _subscribePreviousShapeRequests() {
    try {
      if (previousShapeSubscriptions.isNotEmpty) {
        logger.warning('Subscribing previous shape definitions');
        subscribe(
          previousShapeSubscriptions.splice(
            0,
            previousShapeSubscriptions.length,
          ),
        );
      }
    } catch (error) {
      final message =
          'Client was unable to subscribe previously subscribed shapes: $error';
      throw SatelliteException(SatelliteErrorCode.internal, message);
    }
  }

  // NO DIRECT CALLS TO CONNECT
  Future<void> _connect() async {
    logger.info('connecting to electric server');

    final _authState = authState;
    if (_authState == null || _authState.token == null) {
      throw Exception('trying to connect before authentication');
    }

    try {
      await client.connect();
      await authenticate(_authState.token!);
    } catch (error) {
      logger.debug(
        'server returned an error while establishing connection: $error',
      );
      rethrow;
    }
  }

  /// Authenticates with the Electric sync service using the provided token.
  /// @returns A promise that resolves to void if authentication succeeded. Otherwise, rejects with the reason for the error.
  @override
  Future<void> authenticate(String token) async {
    final authState = AuthState(
      clientId: this.authState!.clientId,
      token: token,
    );
    final authResp = await client.authenticate(authState);
    if (authResp.error != null) {
      throw authResp.error!;
    }
    setAuthState(authState);
  }

  void cancelConnectionWaiter(SatelliteException error) {
    if (initializing != null && !initializing!.finished) {
      initializing?.completeError(error);
    }
  }

  @override
  void disconnect(SatelliteException? error) {
    client.disconnect();
    _notifyConnectivityState(ConnectivityStatus.disconnected, error);
  }

  /// A disconnection issued by the client.
  @override
  void clientDisconnect() {
    final error = SatelliteException(
      SatelliteErrorCode.connectionCancelledByDisconnect,
      "Connection cancelled by 'disconnect'",
    );
    disconnect(error);
    cancelConnectionWaiter(error);
  }

  Future<void> _startReplication() async {
    try {
      final schemaVersion = await migrator.querySchemaVersion();

      // Fetch the subscription IDs that were fulfilled
      // such that we can resume and inform Electric
      // about fulfilled subscriptions
      final subscriptionIds = subscriptions.getFulfilledSubscriptions();

      final StartReplicationResponse(:error) = await client.startReplication(
        _lsn,
        schemaVersion,
        subscriptionIds.isNotEmpty ? subscriptionIds : null,
      );
      if (error != null) {
        throw error;
      }
    } catch (error) {
      logger.warning("Couldn't start replication: $error");

      if (error is! SatelliteException) {
        throw SatelliteException(SatelliteErrorCode.internal, error.toString());
      }

      if (isOutOfSyncError(error) && opts.clearOnBehindWindow) {
        await _resetClientState(keepSubscribedShapes: true);
        rethrow;
      }

      // Some errors could be fixed by dropping local database entirely
      // We propagate throwable and fatal errors for the app to decide
      if (isThrowable(error)) {
        rethrow;
      }

      if (isFatal(error)) {
        throw wrapFatalError(error);
      }
    }
  }

  void _notifyConnectivityState(
    ConnectivityStatus connectivityStatus,
    SatelliteException? error,
  ) {
    connectivityState = ConnectivityState(
      status: connectivityStatus,
      reason: error,
    );
    notifier.connectivityStateChanged(dbName, connectivityState!);
  }

  Future<bool> _verifyTableStructure() async {
    final meta = opts.metaTable.tablename;
    final oplog = opts.oplogTable.tablename;
    final shadow = opts.shadowTable.tablename;

    const tablesExist = '''
      SELECT count(name) as numTables FROM sqlite_master
        WHERE type='table'
        AND name IN (?, ?, ?)
    ''';

    final res = await adapter.query(
      Statement(
        tablesExist,
        [meta, oplog, shadow],
      ),
    );
    final numTables = res.first['numTables']! as int;
    return numTables == 3;
  }

  // Handle auth state changes.
  Future<void> _updateAuthState(AuthStateNotification notification) async {
    // XXX do whatever we need to stop/start or reconnect the replication
    // connection with the new auth state.

    // XXX Maybe we need to auto-start processing and/or replication
    // when we get the right authState?

    authState = notification.authState;
  }

  // Perform a snapshot and notify which data actually changed.
  // It is not safe to call concurrently. Use mutexSnapshot.
  @visibleForTesting
  Future<DateTime> performSnapshot() async {
    // assert a single call at a time
    if (_performingSnapshot) {
      throw SatelliteException(
        SatelliteErrorCode.internal,
        'already performing snapshot',
      );
    } else {
      _performingSnapshot = true;
    }

    try {
      final oplog = opts.oplogTable;
      final shadow = opts.shadowTable;
      final timestamp = DateTime.now();
      final newTag = _generateTag(timestamp);

      /*
     * IMPORTANT!
     *
     * The following queries make use of a documented but rare SQLite behaviour that allows selecting bare column
     * on aggregate queries: https://sqlite.org/lang_select.html#bare_columns_in_an_aggregate_query
     *
     * In short, when a query has a `GROUP BY` clause with a single `min()` or `max()` present in SELECT/HAVING,
     * then the "bare" columns (i.e. those not mentioned in a `GROUP BY` clause) are definitely the ones from the
     * row that satisfied that `min`/`max` function. We make use of it here to find first/last operations in the
     * oplog that touch a particular row.
     */

      // Update the timestamps on all "new" entries - they have been added but timestamp is still `NULL`
      final q1 = Statement(
        '''
      UPDATE $oplog SET timestamp = ?
      WHERE rowid in (
        SELECT rowid FROM $oplog
            WHERE timestamp is NULL
        ORDER BY rowid ASC
        )
      RETURNING *
    ''',
        [timestamp.toISOStringUTC()],
      );

      // We're adding new tag to the shadow tags for this row
      final q2 = Statement(
        '''
      UPDATE $oplog
      SET clearTags =
          CASE WHEN shadow.tags = '[]' OR shadow.tags = ''
               THEN '["' || ? || '"]'
               ELSE '["' || ? || '",' || substring(shadow.tags, 2)
          END
      FROM $shadow AS shadow
      WHERE $oplog.namespace = shadow.namespace
          AND $oplog.tablename = shadow.tablename
          AND $oplog.primaryKey = shadow.primaryKey AND $oplog.timestamp = ?
    ''',
        [
          newTag,
          newTag,
          timestamp.toISOStringUTC(),
        ],
      );

      // For each affected shadow row, set new tag array, unless the last oplog operation was a DELETE
      final q3 = Statement(
        '''
      INSERT OR REPLACE INTO $shadow (namespace, tablename, primaryKey, tags)
      SELECT namespace, tablename, primaryKey, ?
        FROM $oplog AS op
        WHERE timestamp = ?
        GROUP BY namespace, tablename, primaryKey
        HAVING rowid = max(rowid) AND optype != 'DELETE'
    ''',
        [
          encodeTags([newTag]),
          timestamp.toISOStringUTC(),
        ],
      );

      // And finally delete any shadow rows where the last oplog operation was a `DELETE`
      // We do an inner join in a CTE instead of a `WHERE EXISTS (...)` since this is not reliant on
      // re-executing a query per every row in shadow table, but uses a PK join instead.
      final q4 = Statement(
        '''
      WITH _to_be_deleted (rowid) AS (
        SELECT shadow.rowid
          FROM $oplog AS op
          INNER JOIN $shadow AS shadow
            ON shadow.namespace = op.namespace AND shadow.tablename = op.tablename AND shadow.primaryKey = op.primaryKey
          WHERE op.timestamp = ?
          GROUP BY op.namespace, op.tablename, op.primaryKey
          HAVING op.rowid = max(op.rowid) AND op.optype = 'DELETE'
      )

      DELETE FROM $shadow
      WHERE rowid IN _to_be_deleted
    ''',
        [timestamp.toISOStringUTC()],
      );

      // Execute the four queries above in a transaction, returning the results from the first query
      // We're dropping down to this transaction interface because `runInTransaction` doesn't allow queries
      final oplogEntries =
          await adapter.transaction<List<OplogEntry>>((tx, setResult) {
        tx.query(q1, (tx, res) {
          if (res.isNotEmpty) {
            tx.run(
              q2,
              (tx, _) => tx.run(
                q3,
                (tx, _) => tx.run(
                  q4,
                  (_, __) => setResult(res.map(opLogEntryFromRow).toList()),
                ),
              ),
            );
          } else {
            setResult([]);
          }
        });
      });

      if (oplogEntries.isNotEmpty) {
        unawaited(_notifyChanges(oplogEntries, ChangeOrigin.local));
      }

      if (client.getOutboundReplicationStatus() == ReplicationStatus.active) {
        final enqueued = client.getLastSentLsn();
        final enqueuedLogPos = bytesToNumber(enqueued);

        // TODO: handle case where pending oplog is large
        await getEntries(since: enqueuedLogPos).then(
          (missing) => _replicateSnapshotChanges(missing),
        );
      }
      return timestamp;
    } catch (e) {
      logger.error('error performing snapshot: $e');
      rethrow;
    } finally {
      _performingSnapshot = false;
    }
  }

  Future<void> _notifyChanges(
    List<OplogEntry> results,
    ChangeOrigin origin,
  ) async {
    logger.info('notify changes');
    final ChangeAccumulator acc = {};

    // Would it be quicker to do this using a second SQL query that
    // returns results in `Change` format?!
    ChangeAccumulator reduceFn(ChangeAccumulator acc, OplogEntry entry) {
      final qt = QualifiedTablename(entry.namespace, entry.tablename);
      final key = qt.toString();

      if (acc.containsKey(key)) {
        final Change change = acc[key]!;

        change.rowids ??= [];
        change.recordChanges ??= [];

        change.rowids!.add(entry.rowid);
        change.recordChanges!.add(
          RecordChange(
            primaryKey: json.decode(entry.primaryKey) as Map<String, Object?>,
            type: recordChangeTypeFromOpType(entry.optype),
          ),
        );
      } else {
        acc[key] = Change(
          qualifiedTablename: qt,
          rowids: [entry.rowid],
          recordChanges: [
            RecordChange(
              primaryKey: json.decode(entry.primaryKey) as Map<String, Object?>,
              type: recordChangeTypeFromOpType(entry.optype),
            ),
          ],
        );
      }

      return acc;
    }
    // final changes = Object.values(results.reduce(reduceFn, acc))

    final changes = results.fold(acc, reduceFn).values.toList();
    notifier.actuallyChanged(dbName, changes, origin);
  }

  Future<void> _replicateSnapshotChanges(
    List<OplogEntry> results,
  ) async {
    if (client.getOutboundReplicationStatus() != ReplicationStatus.active) {
      return;
    }

    final transactions = toTransactions(results, relations);
    for (final txn in transactions) {
      client.enqueueTransaction(txn);
    }

    return;
  }

  // Apply a set of incoming transactions against pending local operations,
  // applying conflict resolution rules. Takes all changes per each key before
  // merging, for local and remote operations.
  //
  // TODO: in case the subscriptions between the client and server become
  // out of sync, the server might send operations that do not belong to
  // any existing subscription. We need a way to detect and prevent that.
  @visibleForTesting
  Future<ApplyIncomingResult> apply(
    List<OplogEntry> incoming,
    String incomingOrigin,
  ) async {
    final local = await getEntries();
    final merged = mergeEntries(
      authState!.clientId,
      local,
      incomingOrigin,
      incoming,
      relations,
    );

    final List<Statement> stmts = [];

    for (final entry in merged.entries) {
      final tablenameStr = entry.key;
      final mapping = entry.value;
      for (final entryChanges in mapping.values) {
        final ShadowEntry shadowEntry = ShadowEntry(
          namespace: entryChanges.namespace,
          tablename: entryChanges.tablename,
          primaryKey: getShadowPrimaryKey(entryChanges),
          tags: encodeTags(entryChanges.tags),
        );
        switch (entryChanges.optype) {
          case ChangesOpType.delete:
            stmts.add(_applyDeleteOperation(entryChanges, tablenameStr));
            stmts.add(_deleteShadowTagsStatement(shadowEntry));

          default:
            stmts.add(_applyNonDeleteOperation(entryChanges, tablenameStr));
            stmts.add(_updateShadowTagsStatement(shadowEntry));
        }
      }
    }

    final tablenames = merged.keys.toList();

    return ApplyIncomingResult(
      tableNames: tablenames,
      statements: stmts,
    );
  }

  @visibleForTesting
  Future<List<OplogEntry>> getEntries({int? since}) async {
    // `rowid` is never below 0, so -1 means "everything"
    since ??= -1;
    final oplog = opts.oplogTable.toString();

    final selectEntries = '''
      SELECT * FROM $oplog
        WHERE timestamp IS NOT NULL
          AND rowid > ?
        ORDER BY rowid ASC
    ''';
    final rows = await adapter.query(Statement(selectEntries, [since]));
    return rows.map(opLogEntryFromRow).toList();
  }

  Statement _deleteShadowTagsStatement(ShadowEntry shadow) {
    final shadowTable = opts.shadowTable.toString();
    final deleteRow = '''
      DELETE FROM $shadowTable
      WHERE namespace = ? AND
            tablename = ? AND
            primaryKey = ?;
    ''';
    return Statement(
      deleteRow,
      [shadow.namespace, shadow.tablename, shadow.primaryKey],
    );
  }

  Statement _updateShadowTagsStatement(ShadowEntry shadow) {
    final shadowTable = opts.shadowTable.toString();
    final updateTags = '''
      INSERT or REPLACE INTO $shadowTable (namespace, tablename, primaryKey, tags) VALUES
      (?, ?, ?, ?);
    ''';
    return Statement(
      updateTags,
      <Object?>[
        shadow.namespace,
        shadow.tablename,
        shadow.primaryKey,
        shadow.tags,
      ],
    );
  }

  @visibleForTesting
  Future<void> updateRelations(Relation rel) async {
    if (rel.tableType == SatRelation_RelationType.TABLE) {
      // this relation may be for a newly created table
      // or for a column that was added to an existing table
      final tableName = rel.table;

      if (relations[tableName] == null) {
        int id = 0;
        // generate an id for the new relation as (the highest existing id) + 1
        // TODO: why not just use the relation.id coming from pg?
        for (final r in relations.values) {
          if (r.id > id) {
            id = r.id;
          }
        }
        final relation = rel.copyWith(
          id: id + 1,
        );
        relations[tableName] = relation;
      } else {
        // the relation is for an existing table
        // update the information but keep the same ID
        final id = relations[tableName]!.id;
        final relation = rel.copyWith(id: id);
        relations[tableName] = relation;
      }
    }
  }

  @visibleForTesting
  Future<void> applyTransaction(Transaction transaction) async {
    final origin = transaction.origin!;

    final commitTimestamp = DateTime.fromMillisecondsSinceEpoch(
      transaction.commitTimestamp.toInt(),
    );

    // Transactions coming from the replication stream
    // may contain DML operations manipulating data
    // but may also contain DDL operations migrating schemas.
    // DML operations are ran through conflict resolution logic.
    // DDL operations are applied as is against the local DB.

    // `stmts` will store all SQL statements
    // that need to be executed
    final stmts = <Statement>[];
    // `txStmts` will store the statements related to the transaction
    // including the creation of triggers
    // but not statements that disable/enable the triggers
    // neither statements that update meta tables or modify pragmas.
    // The `txStmts` is used to compute the hash of migration transactions
    final txStmts = <Statement>[];
    final tablenamesSet = <String>{};
    var newTables = <String>{};
    final opLogEntries = <OplogEntry>[];
    final lsn = transaction.lsn;
    bool firstDMLChunk = true;

    // switches off on transaction commit/abort
    stmts.add(Statement('PRAGMA defer_foreign_keys = ON'));
    // update lsn.
    stmts.add(updateLsnStmt(lsn));

    Future<void> processDML(List<DataChange> changes) async {
      final tx = DataTransaction(
        commitTimestamp: transaction.commitTimestamp,
        lsn: transaction.lsn,
        changes: changes,
      );
      final entries = fromTransaction(tx, relations);

      // Before applying DML statements we need to assign a timestamp to pending operations.
      // This only needs to be done once, even if there are several DML chunks
      // because all those chunks are part of the same transaction.
      if (firstDMLChunk) {
        logger.info('apply incoming changes for LSN: ${base64.encode(lsn)}');
        // assign timestamp to pending operations before apply
        await _mutexSnapshot();
        firstDMLChunk = false;
      }

      final applyRes = await apply(entries, origin);
      final statements = applyRes.statements;
      final tablenames = applyRes.tableNames;
      for (final e in entries) {
        opLogEntries.add(e);
      }
      for (final s in statements) {
        stmts.add(s);
      }
      for (final n in tablenames) {
        tablenamesSet.add(n);
      }
    }

    Future<void> processDDL(List<SchemaChange> changes) async {
      final createdTables = <String>{};
      final affectedTables = <String, MigrationTable>{};
      for (final change in changes) {
        stmts.add(Statement(change.sql));

        if (change.migrationType == SatOpMigrate_Type.CREATE_TABLE ||
            change.migrationType == SatOpMigrate_Type.ALTER_ADD_COLUMN) {
          // We will create/update triggers for this new/updated table
          // so store it in `tablenamesSet` such that those
          // triggers can be disabled while executing the transaction
          final affectedTable = change.table.name;
          // store the table information to generate the triggers after this `forEach`
          affectedTables[affectedTable] = change.table;
          tablenamesSet.add(affectedTable);

          if (change.migrationType == SatOpMigrate_Type.CREATE_TABLE) {
            createdTables.add(affectedTable);
          }
        }
      }

      // Also add statements to create the necessary triggers for the created/updated table
      for (final table in affectedTables.values) {
        final triggers = generateTriggersForTable(table);
        stmts.addAll(triggers);
        txStmts.addAll(triggers);
      }

      // Disable the newly created triggers
      // during the processing of this transaction
      stmts.addAll(_disableTriggers([...createdTables]));
      newTables = <String>{...newTables, ...createdTables};
    }

    // Start with garbage collection, because if this a transaction after round-trip, then we don't want it in conflict resolution
    await maybeGarbageCollect(origin, commitTimestamp);

    // Chunk incoming changes by their types, and process each chunk one by one
    for (final (dataChange, chunk) in chunkBy(
      transaction.changes,
      (c, _, __) => c is DataChange,
    )) {
      if (dataChange) {
        await processDML(chunk.cast<DataChange>());
      } else {
        await processDDL(chunk.cast<SchemaChange>());
      }
    }

    // Now run the DML and DDL statements in-order in a transaction
    final tablenames = tablenamesSet.toList();
    final notNewTableNames =
        tablenames.where((t) => !newTables.contains(t)).toList();

    final allStatements = [
      ..._disableTriggers(notNewTableNames),
      ...stmts,
      ..._enableTriggers(tablenames),
    ];

    if (transaction.migrationVersion != null) {
      // If a migration version is specified
      // then the transaction is a migration
      await migrator.applyIfNotAlready(
        StmtMigration(
          statements: allStatements,
          version: transaction.migrationVersion!,
        ),
      );
    } else {
      await adapter.runInTransaction(allStatements);
    }

    await _notifyChanges(opLogEntries, ChangeOrigin.remote);
  }

  Future<void> maybeGarbageCollect(
    String origin,
    DateTime commitTimestamp,
  ) async {
    if (origin == authState!.clientId) {
      /* Any outstanding transaction that originated on Satellite but haven't
       * been received back from the Electric is considered to be concurrent with
       * any other transaction coming from Electric.
       *
       * Thus we need to keep oplog entries in order to be able to do conflict
       * resolution with add-wins semantics.
       *
       * Once we receive transaction that was originated on the Satellite, oplog
       * entries that correspond to such transaction can be safely removed as
       * they are no longer necessary for conflict resolution.
       */
      await garbageCollectOplog(commitTimestamp);
    }
  }

  List<Statement> _disableTriggers(List<String> tablenames) {
    return _updateTriggerSettings(tablenames, false);
  }

  List<Statement> _enableTriggers(List<String> tablenames) {
    return _updateTriggerSettings(tablenames, true);
  }

  List<Statement> _updateTriggerSettings(List<String> tablenames, bool flag) {
    final triggers = opts.triggersTable.toString();
    if (tablenames.isNotEmpty) {
      final tablesOr = tablenames.map((_) => 'tablename = ?').join(' OR ');
      return [
        Statement(
          'UPDATE $triggers SET flag = ? WHERE $tablesOr',
          [if (flag) 1 else 0, ...tablenames],
        ),
      ];
    } else {
      return [];
    }
  }

  Statement _setMetaStatement(String key, Object? value) {
    final meta = opts.metaTable.toString();

    final sql = 'UPDATE $meta SET value = ? WHERE key = ?';
    final args = <Object?>[value, key];

    return Statement(sql, args);
  }

  @visibleForTesting
  Future<void> setMeta(String key, Object? value) async {
    final stmt = _setMetaStatement(key, value);
    await adapter.run(stmt);
  }

  @visibleForTesting
  Future<T> getMeta<T>(String key) async {
    final meta = opts.metaTable.toString();

    final sql = 'SELECT value from $meta WHERE key = ?';
    final args = [key];
    final rows = await adapter.query(Statement(sql, args));

    if (rows.length != 1) {
      throw 'Invalid metadata table: missing $key';
    }

    return rows.first['value'] as T;
  }

  Future<Uuid> _getClientId() async {
    const clientIdKey = 'clientId';

    String clientId = await getMeta<Uuid>(clientIdKey);

    if (clientId.isEmpty) {
      clientId = genUUID();
      await setMeta(clientIdKey, clientId);
    }
    return clientId;
  }

  @visibleForTesting
  Future<RelationsCache> getLocalRelations() async {
    return inferRelationsFromSQLite(adapter, opts);
  }

  String _generateTag(DateTime timestamp) {
    final instanceId = authState!.clientId;

    return generateTag(instanceId, timestamp);
  }

  @visibleForTesting
  Future<void> garbageCollectOplog(DateTime commitTimestamp) async {
    final isoString = commitTimestamp.toISOStringUTC();
    final String oplog = opts.oplogTable.tablename;

    await adapter.run(
      Statement(
        'DELETE FROM $oplog WHERE timestamp = ?',
        <Object?>[isoString],
      ),
    );
  }

  /// Update `this._lsn` to the new value and generate a statement to persist this change
  ///
  /// @param lsn new LSN value
  /// @returns statement to be executed to save the new LSN value in the database
  Statement updateLsnStmt(LSN lsn) {
    _lsn = lsn;
    final lsnBase64 = base64.encode(lsn);
    return Statement(
      'UPDATE ${opts.metaTable.tablename} set value = ? WHERE key = ?',
      [lsnBase64, 'lsn'],
    );
  }

  Future<void> checkMaxSqlParameters() async {
    final version = (await adapter.query(
      Statement(
        'SELECT sqlite_version() AS version',
      ),
    ))
        .first['version']! as String;
    final [major, minor, ...] =
        version.split('.').map((x) => int.parse(x)).toList();

    if (major == 3 && minor >= 32) {
      maxSqlParameters = 32766;
    } else {
      maxSqlParameters = 999;
    }
  }
}

Statement _applyDeleteOperation(
  ShadowEntryChanges entryChanges,
  String tablenameStr,
) {
  final pkEntries = entryChanges.primaryKeyCols.entries;
  if (pkEntries.isEmpty) {
    throw Exception(
      "Can't apply delete operation. None of the columns in changes are marked as PK.",
    );
  }
  final params = pkEntries.fold<_WhereAndValues>(
    _WhereAndValues([], []),
    (acc, entry) {
      final column = entry.key;
      final value = entry.value;
      acc.where.add('$column = ?');
      acc.values.add(value);
      return acc;
    },
  );

  return Statement(
    "DELETE FROM $tablenameStr WHERE ${params.where.join(' AND ')}",
    params.values,
  );
}

Statement _applyNonDeleteOperation(
  ShadowEntryChanges shadowEntryChanges,
  String tablenameStr,
) {
  final fullRow = shadowEntryChanges.fullRow;
  final primaryKeyCols = shadowEntryChanges.primaryKeyCols;

  final columnNames = fullRow.keys;
  final List<Object?> columnValues = fullRow.values.toList();
  String insertStmt =
      '''INTO $tablenameStr(${columnNames.join(', ')}) VALUES (${columnValues.map((_) => '?').join(',')})''';

  final updateColumnStmts =
      columnNames.where((c) => !primaryKeyCols.containsKey(c)).fold(
    _WhereAndValues([], []),
    (acc, c) {
      acc.where.add('$c = ?');
      acc.values.add(fullRow[c]);
      return acc;
    },
  );

  if (updateColumnStmts.values.isNotEmpty) {
    insertStmt = '''
                INSERT $insertStmt 
                ON CONFLICT DO UPDATE SET ${updateColumnStmts.where.join(', ')}
              ''';
    columnValues.addAll(updateColumnStmts.values);
  } else {
    // no changes, can ignore statement if exists
    insertStmt = 'INSERT OR IGNORE $insertStmt';
  }

  return Statement(insertStmt, columnValues);
}

List<Statement> generateTriggersForTable(MigrationTable tbl) {
  final table = Table(
    tableName: tbl.name,
    namespace: 'main',
    columns: tbl.columns.map((col) => col.name).toList(),
    primary: tbl.pks,
    foreignKeys: tbl.fks.map((fk) {
      if (fk.fkCols.length != 1 || fk.pkCols.length != 1) {
        throw Exception(
          'Satellite does not yet support compound foreign keys.',
        );
      }
      return ForeignKey(
        table: fk.pkTable,
        childKey: fk.fkCols[0],
        parentKey: fk.pkCols[0],
      );
    }).toList(),
    columnTypes: Map.fromEntries(
      tbl.columns.map(
        (col) {
          return MapEntry(
            col.name,
            (
              sqliteType: col.sqliteType.toUpperCase(),
              pgType: col.ensurePgType().name.toUpperCase(),
            ),
          );
        },
      ),
    ),
  );
  final fullTableName = '${table.namespace}.${table.tableName}';
  return generateTableTriggers(fullTableName, table);
}

class _WhereAndValues {
  final List<String> where;
  final List<SqlValue> values;

  _WhereAndValues(this.where, this.values);
}

class ShadowEntryLookup {
  final bool cached;
  final ShadowEntry entry;

  ShadowEntryLookup({required this.cached, required this.entry});
}

@visibleForTesting
OplogEntry opLogEntryFromRow(Map<String, Object?> row) {
  return OplogEntry(
    namespace: row['namespace']! as String,
    tablename: row['tablename']! as String,
    primaryKey: row['primaryKey']! as String,
    rowid: row['rowid']! as int,
    optype: opTypeStrToOpType(row['optype']! as String),
    timestamp: row['timestamp']! as String,
    newRow: row['newRow'] as String?,
    oldRow: row['oldRow'] as String?,
    clearTags: row['clearTags']! as String,
  );
}

class ApplyIncomingResult {
  final List<String> tableNames;
  final List<Statement> statements;

  ApplyIncomingResult({
    required this.tableNames,
    required this.statements,
  });
}
