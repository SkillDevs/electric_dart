import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:electricsql/src/auth/auth.dart';
import 'package:electricsql/src/auth/secure.dart';
import 'package:electricsql/src/electric/adapter.dart';
import 'package:electricsql/src/migrators/migrators.dart';
import 'package:electricsql/src/migrators/query_builder/query_builder.dart';
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
import 'package:electricsql/src/util/encoders/encoders.dart';
import 'package:electricsql/src/util/exceptions.dart';
import 'package:electricsql/src/util/js_array_funs.dart';
import 'package:electricsql/src/util/random.dart';
import 'package:electricsql/src/util/relations.dart';
import 'package:electricsql/src/util/statements.dart';
import 'package:electricsql/src/util/tablename.dart';
import 'package:electricsql/src/util/types.dart' hide Change;
import 'package:fixnum/fixnum.dart';
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
  final QueryBuilder builder;

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

  final List<Shape> previousShapeSubscriptions = [];
  late SubscriptionsManager subscriptions;
  final Map<String, Completer<void>> subscriptionNotifiers = {};
  late String Function() subscriptionIdGenerator;
  late String Function() shapeRequestIdGenerator;

  /// To optimize inserting a lot of data when the subscription data comes, we need to do
  /// less `INSERT` queries, but SQLite/Postgres support only a limited amount of `?`/`$i` positional
  /// arguments. Precisely, its either 999 for SQLite versions prior to 3.32.0 and 32766 for
  /// versions after, and 65535 for Postgres.
  int maxSqlParameters = 999; // 999 | 32766 | 65535
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
  })  : _adapter = adapter,
        builder = migrator.queryBuilder {
    subscriptions = InMemorySubscriptionsManager(
      garbageCollectShapeHandler,
    );
    throttledSnapshot = Throttle(
      mutexSnapshot,
      opts.minSnapshotWindow,
    );

    subscriptionIdGenerator = () => genUUID();
    shapeRequestIdGenerator = subscriptionIdGenerator;

    connectRetryHandler = defaultConnectRetryHandler;

    setClientListeners();
  }

  /// Perform a snapshot while taking out a mutex to avoid concurrent calls.
  @visibleForTesting
  Future<DateTime> mutexSnapshot() async {
    return _snapshotLock.synchronized(() {
      return performSnapshot();
    });
  }

  Future<DateTime> Function()? _debugPerformSnapshotFun;

  /// Override the snapshot function for testing.
  @visibleForTesting
  void debugSetPerformSnapshot(Future<DateTime> Function()? fun) {
    _debugPerformSnapshotFun = fun;
  }

  @visibleForTesting
  void updateDatabaseAdapter(DatabaseAdapter newAdapter) {
    _adapter = newAdapter;
  }

  @override
  Future<void> start(AuthConfig? authConfig) async {
    if (opts.debug) {
      await _logDatabaseVersion();
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
    await throttledSnapshot();

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

  Future<void> _logDatabaseVersion() async {
    final versionRow = await adapter.query(
      Statement(
        builder.getVersion,
      ),
    );
    logger.info(
      'Using ${builder.dialect.name} version: ${versionRow[0]['version']}',
    );
  }

  @visibleForTesting
  void setAuthState(AuthState newAuthState) {
    authState = newAuthState;
  }

  @visibleForTesting
  Future<void> garbageCollectShapeHandler(
    List<ShapeDefinition> shapeDefs,
  ) async {
    final namespace = builder.defaultNamespace;
    final allTables = shapeDefs
        .map((ShapeDefinition def) => def.definition)
        .expand((x) => getAllTablesForShape(x, namespace));
    final tables = allTables.toSet().toList();

    // TODO: table and schema warrant escaping here too, but they aren't in the triggers table.

    final deleteStmts = tables.map(
      (x) => Statement(
        'DELETE FROM "${x.namespace}"."${x.tablename}"',
      ),
    );

    final stmtsWithTriggers = [
      // reverts to off on commit/abort
      Statement(builder.deferForeignKeys),
      ..._disableTriggers(tables),
      ...deleteStmts,
      ..._enableTriggers(tables),
    ];

    await adapter.runInTransaction(stmtsWithTriggers);
  }

  void setClientListeners() {
    client.subscribeToError(_handleClientError);
    client.subscribeToRelations(updateRelations);
    client.subscribeToTransactions(applyTransaction);
    client.subscribeToAdditionalData(_applyAdditionalData);
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

    // Ensure that no snapshot is left running in the background
    // by acquiring the mutex and releasing it immediately.
    await _snapshotLock.synchronized(() => null);

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
    List<Shape> shapeDefinitions,
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
    LSN lsn, {
    List<Statement> additionalStatements = const [],
  }) async {
    final namespace = builder.defaultNamespace;
    final stmts = <Statement>[];

    if (builder.dialect == Dialect.postgres) {
      // disable FK checks because order of inserts
      // may not respect referential integrity
      // and Postgres doesn't let us defer FKs
      // that were not originally defined as deferrable
      stmts.add(Statement(builder.disableForeignKeys));
    } else {
      // Defer FKs on SQLite
      stmts.add(Statement(builder.deferForeignKeys));
    }

    // It's much faster[1] to do less statements to insert the data instead of doing an insert statement for each row
    // so we're going to do just that, but with a caveat: SQLite has a max number of parameters in prepared statements,
    // so this is less of "insert all at once" and more of "insert in batches". This should be even more noticeable with
    // WASM builds, since we'll be crossing the JS-WASM boundary less.
    //
    // [1]: https://medium.com/@JasonWyatt/squeezing-performance-from-sqlite-insertions-971aff98eef2

    final groupedChanges = <String,
        ({
      Relation relation,
      List<DbRecord> records,
      QualifiedTablename table,
    })>{};

    final allArgsForShadowInsert = <DbRecord>[];

    // Group all changes by table name to be able to insert them all together
    for (final op in changes) {
      final tableName = QualifiedTablename(namespace, op.relation.table);
      final tableNameString = tableName.toString();
      if (groupedChanges.containsKey(tableNameString)) {
        final changeGroup = groupedChanges[tableNameString]!;
        changeGroup.records.add(op.record);
      } else {
        groupedChanges[tableNameString] = (
          relation: op.relation,
          records: [op.record],
          table: tableName,
        );
      }

      // Since we're already iterating changes, we can also prepare data for shadow table
      final primaryKeyCols =
          op.relation.columns.fold(<String, Object>{}, (agg, col) {
        if (col.primaryKey != null && col.primaryKey != 0) {
          agg[col.name] = op.record[col.name]!;
        }
        return agg;
      });

      allArgsForShadowInsert.add({
        'namespace': namespace,
        'tablename': op.relation.table,
        'primaryKey': primaryKeyToStr(primaryKeyCols),
        'tags': encodeTags(op.tags),
      });
    }

    final List<QualifiedTablename> qualifiedTableNames = [
      ...groupedChanges.values.map((chg) => chg.table),
    ];

    // Disable trigger for all affected tables
    stmts.addAll([..._disableTriggers(qualifiedTableNames)]);

    // For each table, do a batched insert
    for (final entry in groupedChanges.entries) {
      // final _table = entry.key;
      final (:relation, :records, table: table) = entry.value;
      final columnNames = relation.columns.map((col) => col.name).toList();
      final qualifiedTableName = '"${table.namespace}"."${table.tablename}"';
      final orIgnore = builder.sqliteOnly('OR IGNORE');
      final onConflictDoNothing = builder.pgOnly('ON CONFLICT DO NOTHING');
      final sqlBase = '''
INSERT $orIgnore INTO $qualifiedTableName (${columnNames.join(', ')}) VALUES ''';
      // Must be an insert or ignore into

      stmts.addAll([
        ...builder.prepareInsertBatchedStatements(
          sqlBase,
          columnNames,
          records,
          maxSqlParameters,
          onConflictDoNothing,
        ),
      ]);
    }

    // And re-enable the triggers for all of them
    stmts.addAll([..._enableTriggers(qualifiedTableNames)]);

    // Then do a batched insert for the shadow table
    final batchedShadowInserts = builder.batchedInsertOrReplace(
      opts.shadowTable.tablename,
      ['namespace', 'tablename', 'primaryKey', 'tags'],
      allArgsForShadowInsert,
      ['namespace', 'tablename', 'primaryKey'],
      ['namespace', 'tablename', 'tags'],
      maxSqlParameters,
      opts.shadowTable.namespace,
    );
    stmts.addAll(batchedShadowInserts);

    // Then update subscription state and LSN
    stmts.add(_setMetaStatement('subscriptions', subscriptions.serialize()));
    stmts.add(updateLsnStmt(lsn));
    stmts.addAll(additionalStatements);

    try {
      await adapter.runInTransaction(stmts);

      // We're explicitly not specifying rowids in these changes for now,
      // because nobody uses them and we don't have the machinery to to a
      // `RETURNING` clause in the middle of `runInTransaction`.
      final notificationChanges = <Change>[];
      for (final entry in groupedChanges.entries) {
        final (:relation, :records, :table) = entry.value;

        final primaryKeyColNames = relation.columns
            .where((col) => col.primaryKey != null)
            .map((col) => col.name)
            .toList();
        notificationChanges.add(
          Change(
            qualifiedTablename: table,
            rowids: [],
            recordChanges: records.map((change) {
              return RecordChange(
                primaryKey: Map.fromEntries(
                  primaryKeyColNames.map((colName) {
                    return MapEntry(colName, change[colName]);
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
    } catch (e, st) {
      unawaited(
        _handleSubscriptionError(
          SubscriptionErrorData(
            error: SatelliteException(
              SatelliteErrorCode.internal,
              'Error applying subscription data: $e',
            ),
            subscriptionId: null,
            stackTrace: st,
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
      final List<Shape> shapeDefs = subscriptionIds
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
    final satelliteStackTrace = errorData.stackTrace;
    Object? resettingError;
    StackTrace? resettingStackTrace;

    logger.error('encountered a subscription error: ${satelliteError.message}');

    try {
      await _resetClientState();
    } catch (error, st) {
      // If we encounter an error here, we want to float it to the client so that the bug is visible
      // instead of just a broken state.
      resettingError = NestedException(
        error,
        reasonContext: 'Encountered when handling a subscription error',
        innerException: satelliteError,
        innerStackTrace: satelliteStackTrace,
      );
      resettingStackTrace = st;
    }

    // Call the `onFailure` callback for this subscription
    if (subscriptionId != null) {
      final completer = subscriptionNotifiers[subscriptionId]!;

      // GC the notifiers for this subscription ID
      subscriptionNotifiers.remove(subscriptionId);
      completer.completeError(
        resettingError ?? satelliteError,
        resettingStackTrace ?? satelliteStackTrace,
      );
    }
  }

  // handles async client errors: can be a socket error or a server error message
  Future<void> _handleClientError(
    (SatelliteException satelliteError, StackTrace stackTrace) errorInfo,
  ) async {
    final satelliteError = errorInfo.$1;
    final stackTrace = errorInfo.$2;

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
      Error.throwWithStackTrace(satelliteError, stackTrace);
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
    } catch (e, st) {
      // We're very sure that no calls are going to modify `this.initializing` before this promise resolves
      // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
      final Object error;
      final StackTrace stackTrace;

      if (!connectRetryHandler(e, 0)) {
        error = e;
        stackTrace = st;
      } else {
        error = SatelliteException(
          SatelliteErrorCode.connectionFailedAfterRetry,
          'Failed to connect to server after exhausting retry policy. Last error thrown by server: $e\n$st',
        );
        stackTrace = StackTrace.current;
      }

      disconnect(error is SatelliteException ? error : null);
      initializing?.completeError(error, stackTrace);
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
      Error.throwWithStackTrace(authResp.error!, authResp.stackTrace!);
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
      final observedTransactionData =
          await getMeta<String>('seenAdditionalData');

      final StartReplicationResponse(:error, :stackTrace) =
          await client.startReplication(
        _lsn,
        schemaVersion,
        subscriptionIds.isNotEmpty ? subscriptionIds : null,
        observedTransactionData
            .split(',')
            .where((x) => x != '')
            .map((x) => Int64.parseInt(x))
            .toList(),
      );
      if (error != null) {
        Error.throwWithStackTrace(error, stackTrace!);
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

    final res = await adapter.query(
      builder.countTablesIn('numTables', [meta, oplog, shadow]),
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
    if (_debugPerformSnapshotFun != null) {
      return _debugPerformSnapshotFun!();
    }

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
      final oplog =
          '"${opts.oplogTable.namespace}"."${opts.oplogTable.tablename}"';
      final shadow =
          '"${opts.shadowTable.namespace}"."${opts.shadowTable.tablename}"';
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
      UPDATE $oplog SET timestamp = ${builder.makePositionalParam(1)}
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
      SET "clearTags" =
          CASE WHEN shadow.tags = '[]' OR shadow.tags = ''
               THEN '["' || ${builder.makePositionalParam(1)} || '"]'
               ELSE '["' || ${builder.makePositionalParam(2)} || '",' || substring(shadow.tags, 2)
          END
      FROM $shadow AS shadow
      WHERE $oplog.namespace = shadow.namespace
          AND $oplog.tablename = shadow.tablename
          AND $oplog."primaryKey" = shadow."primaryKey" AND $oplog.timestamp = ${builder.makePositionalParam(3)}
    ''',
        [
          newTag,
          newTag,
          timestamp.toISOStringUTC(),
        ],
      );

      // For each affected shadow row, set new tag array, unless the last oplog operation was a DELETE
      final q3 = Statement(
        builder.setTagsForShadowRows(opts.oplogTable, opts.shadowTable),
        [
          encodeTags([newTag]),
          timestamp.toISOStringUTC(),
        ],
      );

      // And finally delete any shadow rows where the last oplog operation was a `DELETE`
      final q4 = Statement(
        builder.removeDeletedShadowRows(opts.oplogTable, opts.shadowTable),
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
        final qualifiedTableName = QualifiedTablename.parse(tablenameStr);
        switch (entryChanges.optype) {
          case ChangesOpType.gone:
          case ChangesOpType.delete:
            stmts.add(_applyDeleteOperation(entryChanges, qualifiedTableName));
            stmts.add(_deleteShadowTagsStatement(shadowEntry));

          default:
            stmts.add(
                _applyNonDeleteOperation(entryChanges, qualifiedTableName));
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
    final oplog =
        '"${opts.oplogTable.namespace}"."${opts.oplogTable.tablename}"';

    final selectEntries = '''
      SELECT * FROM $oplog
        WHERE timestamp IS NOT NULL
          AND rowid > ${builder.makePositionalParam(1)}
        ORDER BY rowid ASC
    ''';
    final rows = await adapter.query(Statement(selectEntries, [since]));
    return rows.map(opLogEntryFromRow).toList();
  }

  Statement _deleteShadowTagsStatement(ShadowEntry shadow) {
    final shadowTable =
        '"${opts.shadowTable.namespace}"."${opts.shadowTable.tablename}"';
    String pos(int i) => builder.makePositionalParam(i);

    final deleteRow = '''
      DELETE FROM $shadowTable
      WHERE namespace = ${pos(1)} AND
            tablename = ${pos(2)} AND
            primaryKey = ${pos(3)};
    ''';
    return Statement(
      deleteRow,
      [shadow.namespace, shadow.tablename, shadow.primaryKey],
    );
  }

  Statement _updateShadowTagsStatement(ShadowEntry shadow) {
    return builder.insertOrReplace(
      opts.shadowTable.tablename,
      ['namespace', 'tablename', 'primaryKey', 'tags'],
      [shadow.namespace, shadow.tablename, shadow.primaryKey, shadow.tags],
      ['namespace', 'tablename', 'primaryKey'],
      ['tags'],
      opts.shadowTable.namespace,
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
    final namespace = builder.defaultNamespace;
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

    if (builder.dialect == Dialect.postgres) {
      // Temporarily disable FK checks because order of inserts
      // may not respect referential integrity
      // and Postgres doesn't let us defer FKs
      // that were not originally defined as deferrable
      stmts.add(Statement(builder.disableForeignKeys));
    } else {
      // Defer FKs on SQLite
      stmts.add(Statement(builder.deferForeignKeys));
    }

    // update lsn.
    stmts.add(updateLsnStmt(lsn));
    stmts.add(_resetSeenAdditionalDataStmt());

    Future<void> processDML(List<DataChange> changes) async {
      final tx = DataTransaction(
        commitTimestamp: transaction.commitTimestamp,
        lsn: transaction.lsn,
        changes: changes,
      );
      final entries = fromTransaction(tx, relations, namespace);

      // Before applying DML statements we need to assign a timestamp to pending operations.
      // This only needs to be done once, even if there are several DML chunks
      // because all those chunks are part of the same transaction.
      if (firstDMLChunk) {
        logger.info('apply incoming changes for LSN: ${base64.encode(lsn)}');
        // assign timestamp to pending operations before apply
        await mutexSnapshot();
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
          final affectedTable =
              QualifiedTablename(namespace, change.table.name).toString();

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
        final triggers = generateTriggersForTable(table, builder);
        stmts.addAll(triggers);
        txStmts.addAll(triggers);
      }

      // Disable the newly created triggers
      // during the processing of this transaction
      final createdQualifiedTables =
          createdTables.map(QualifiedTablename.parse).toList();
      stmts.addAll(_disableTriggers(createdQualifiedTables));
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
    final qualifiedTables = tablenames.map(QualifiedTablename.parse).toList();
    final notNewTableNames =
        tablenames.where((t) => !newTables.contains(t)).toList();
    final notNewQualifiedTables =
        tablenames.map(QualifiedTablename.parse).toList();

    final allStatements = [
      ..._disableTriggers(notNewQualifiedTables),
      ...stmts,
      ..._enableTriggers(qualifiedTables),
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

  Future<void> _applyAdditionalData(AdditionalData data) {
    // Server sends additional data on move-ins and tries to send only data
    // the client has never seen from its perspective. Because of this, we're writing this
    // data directly, like subscription data
    return _applySubscriptionData(
      data.changes
          .map(
            (e) => InitialDataChange(
              relation: e.relation,
              record: e.record!,
              tags: e.tags,
            ),
          )
          .toList(),
      _lsn!,
      additionalStatements: [
        _addSeenAdditionalDataStmt(data.ref.toString()),
      ],
    );
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

  List<Statement> _disableTriggers(List<QualifiedTablename> tables) {
    return _updateTriggerSettings(tables, false);
  }

  List<Statement> _enableTriggers(List<QualifiedTablename> tables) {
    return _updateTriggerSettings(tables, true);
  }

  List<Statement> _updateTriggerSettings(
    List<QualifiedTablename> tables,
    bool flag,
  ) {
    if (tables.isEmpty) return [];

    final triggers =
        '"${opts.triggersTable.namespace}"."${opts.triggersTable.tablename}"';
    final namespacesAndTableNames = tables.expand(
      (tbl) => [
        tbl.namespace,
        tbl.tablename,
      ],
    );
    String pos(int i) => builder.makePositionalParam(i);
    int i = 1;
    final tablesOr = tables
        .map((_) => '(namespace = ${pos(i++)} AND tablename = ${pos(i++)})')
        .join(' OR ');
    return [
      Statement(
        'UPDATE $triggers SET flag = ${pos(i++)} WHERE $tablesOr',
        [if (flag) 1 else 0, ...namespacesAndTableNames],
      ),
    ];
  }

  Statement _addSeenAdditionalDataStmt(String ref) {
    final meta = '"${opts.metaTable.namespace}"."${opts.metaTable.tablename}"';

    final sql = '''
      INSERT INTO $meta (key, value) VALUES ('seenAdditionalData', ${builder.makePositionalParam(1)})
        ON CONFLICT (key) DO
          UPDATE SET value = $meta.value || ',' || excluded.value
    ''';
    final args = <Object?>[ref];
    return Statement(sql, args);
  }

  Statement _resetSeenAdditionalDataStmt() {
    return _setMetaStatement('seenAdditionalData', '');
  }

  Statement _setMetaStatement(String key, Object? value) {
    final meta = '"${opts.metaTable.namespace}"."${opts.metaTable.tablename}"';
    String pos(int i) => builder.makePositionalParam(i);

    final sql = 'UPDATE $meta SET value = ${pos(1)} WHERE key = ${pos(2)}';
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
    final meta = '"${opts.metaTable.namespace}"."${opts.metaTable.tablename}"';
    String pos(int i) => builder.makePositionalParam(i);

    final sql = 'SELECT value from $meta WHERE key = ${pos(1)}';
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
    return inferRelationsFromDb(adapter, opts, builder);
  }

  String _generateTag(DateTime timestamp) {
    final instanceId = authState!.clientId;

    return generateTag(instanceId, timestamp);
  }

  @visibleForTesting
  Future<void> garbageCollectOplog(DateTime commitTimestamp) async {
    final isoString = commitTimestamp.toISOStringUTC();
    final String oplog =
        '"${opts.oplogTable.namespace}"."${opts.oplogTable.tablename}"';
    String pos(int i) => builder.makePositionalParam(i);

    await adapter.run(
      Statement(
        'DELETE FROM $oplog WHERE timestamp = ${pos(1)}',
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
    return _setMetaStatement('lsn', base64.encode(lsn));
  }

  @override
  void setReplicationTransform(
    QualifiedTablename tableName,
    ReplicatedRowTransformer<DbRecord> transform,
  ) {
    client.setReplicationTransform(tableName, transform);
  }

  @override
  void clearReplicationTransform(QualifiedTablename tableName) {
    client.clearReplicationTransform(tableName);
  }

  Statement _applyDeleteOperation(
    ShadowEntryChanges entryChanges,
    QualifiedTablename qualifiedTableName,
  ) {
    final pkEntries = entryChanges.primaryKeyCols.entries;
    if (pkEntries.isEmpty) {
      throw Exception(
        "Can't apply delete operation. None of the columns in changes are marked as PK.",
      );
    }
    int i = 1;
    String pos(int i) => builder.makePositionalParam(i);
    final params = pkEntries.fold<_WhereAndValues>(
      _WhereAndValues([], []),
      (acc, entry) {
        final column = entry.key;
        final value = entry.value;
        acc.where.add('$column = ${pos(i++)}');
        acc.values.add(value);
        return acc;
      },
    );

    return Statement(
      '''DELETE FROM "${qualifiedTableName.namespace}"."${qualifiedTableName.tablename}" WHERE ${params.where.join(' AND ')}''',
      params.values,
    );
  }

  Statement _applyNonDeleteOperation(
    ShadowEntryChanges shadowEntryChanges,
    QualifiedTablename qualifiedTableName,
  ) {
    final fullRow = shadowEntryChanges.fullRow;
    final primaryKeyCols = shadowEntryChanges.primaryKeyCols;

    final columnNames = fullRow.keys.toList();
    final columnValues = fullRow.values.toList();
    final updateColumnStmts =
        columnNames.where((c) => !primaryKeyCols.containsKey(c)).toList();

    if (updateColumnStmts.isNotEmpty) {
      return builder.insertOrReplaceWith(
        qualifiedTableName.tablename,
        columnNames,
        columnValues,
        ['id'],
        updateColumnStmts,
        updateColumnStmts.map((col) => fullRow[col]).toList(),
        qualifiedTableName.namespace,
      );
    }

    // no changes, can ignore statement if exists
    return builder.insertOrIgnore(
      qualifiedTableName.tablename,
      columnNames,
      columnValues,
      qualifiedTableName.namespace,
    );
  }

  Future<void> checkMaxSqlParameters() async {
    if (builder.dialect == Dialect.sqlite) {
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
    } else {
      // Postgres allows a maximum of 65535 query parameters
      maxSqlParameters = 65535;
    }
  }
}

List<Statement> generateTriggersForTable(
  MigrationTable tbl,
  QueryBuilder builder,
) {
  final table = Table(
    tableName: tbl.name,
    namespace: builder.defaultNamespace,
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
            col.ensurePgType().name.toUpperCase(),
          );
        },
      ),
    ),
  );
  return generateTableTriggers(table, builder);
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
