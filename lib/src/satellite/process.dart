import 'dart:async';
import 'dart:convert';

import 'package:electric_client/src/auth/auth.dart';
import 'package:electric_client/src/electric/adapter.dart' hide Transaction;
import 'package:electric_client/src/migrators/migrators.dart';
import 'package:electric_client/src/migrators/triggers.dart';
import 'package:electric_client/src/notifiers/notifiers.dart';
import 'package:electric_client/src/proto/satellite.pbenum.dart';
import 'package:electric_client/src/satellite/config.dart';
import 'package:electric_client/src/satellite/merge.dart';
import 'package:electric_client/src/satellite/oplog.dart';
import 'package:electric_client/src/satellite/satellite.dart';
import 'package:electric_client/src/satellite/shapes/manager.dart';
import 'package:electric_client/src/satellite/shapes/shapes.dart';
import 'package:electric_client/src/satellite/shapes/types.dart';
import 'package:electric_client/src/util/common.dart';
import 'package:electric_client/src/util/debug/debug.dart';
import 'package:electric_client/src/util/sets.dart';
import 'package:electric_client/src/util/statements.dart';
import 'package:electric_client/src/util/tablename.dart';
import 'package:electric_client/src/util/types.dart' hide Change;
import 'package:electric_client/src/util/types.dart' as types;
import 'package:meta/meta.dart';
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

const throwErrors = [
  SatelliteErrorCode.invalidPosition,
  SatelliteErrorCode.behindWindow,
];

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
  String? _authStateSubscription;

  Timer? _pollingInterval;
  String? _potentialDataChangeSubscription;
  String? _connectivityChangeSubscription;

  late Throttle<DateTime> throttledSnapshot;

  int _lastAckdRowId = 0;
  @visibleForTesting
  int lastSentRowId = 0;
  LSN? _lsn;

  @visibleForTesting
  LSN? get debugLsn => _lsn;

  RelationsCache relations = {};

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

    subscriptionIdGenerator = () => uuid();
    shapeRequestIdGenerator = subscriptionIdGenerator;
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
  Future<ConnectionWrapper> start(
    AuthConfig authConfig, {
    SatelliteReplicationOptions? opts,
  }) async {
    // TODO(dart): Explicitly enable foreign keys, which is used by Electric
    await adapter.run(Statement("PRAGMA foreign_keys = ON"));

    await migrator.up();

    final isVerified = await _verifyTableStructure();
    if (!isVerified) {
      throw Exception('Invalid database schema.');
    }

    final configClientId = authConfig.clientId;
    final clientId = configClientId != null && configClientId != ''
        ? configClientId
        : await _getClientId();
    await setAuthState(AuthState(clientId: clientId, token: authConfig.token));

    final notifierSubscriptions = {
      "_authStateSubscription": _authStateSubscription,
      "_connectivityChangeSubscription": _connectivityChangeSubscription,
      "_potentialDataChangeSubscription": _potentialDataChangeSubscription,
    };
    notifierSubscriptions.forEach((name, value) {
      if (value != null) {
        throw Exception('''
Starting satellite process with an existing `$name`.
This means there is a notifier subscription leak.`''');
      }
    });

    // Monitor auth state changes.
    _authStateSubscription =
        notifier.subscribeToAuthStateChanges(_updateAuthState);

    // Monitor connectivity state changes.
    _connectivityChangeSubscription =
        notifier.subscribeToConnectivityStateChanges(
      (ConnectivityStateChangeNotification notification) async {
        // Wait for the next event loop to ensure that other listeners get a
        // chance to handle the change before actually handling it internally in the process
        await Future<void>.delayed(Duration.zero);

        await connectivityStateChanged(notification.connectivityState);
      },
    );

    // Request a snapshot whenever the data in our database potentially changes.
    _potentialDataChangeSubscription =
        notifier.subscribeToPotentialDataChanges((_) => throttledSnapshot());

    // Start polling to request a snapshot every `pollingInterval` ms.
    _pollingInterval = Timer.periodic(
      this.opts.pollingInterval,
      (_) => throttledSnapshot(),
    );

    // Starting now!
    unawaited(Future(() => throttledSnapshot()));

    // Need to reload primary keys after schema migration
    relations = await getLocalRelations();
    await checkMaxSqlParameters();

    _lastAckdRowId = int.parse((await getMeta('lastAckdRowId'))!);
    lastSentRowId = int.parse((await getMeta('lastSentRowId'))!);

    setClientListeners();
    client.resetOutboundLogPositions(
      numberToBytes(_lastAckdRowId),
      numberToBytes(lastSentRowId),
    );

    final lsnBase64 = await getMeta<String?>('lsn');
    if (lsnBase64 != null && lsnBase64.isNotEmpty) {
      _lsn = base64.decode(lsnBase64);
      logger.info("retrieved lsn $_lsn");
    } else {
      logger.info("no lsn retrieved from store");
    }

    final subscriptionsState = await getMeta<String>('subscriptions');
    if (subscriptionsState.isNotEmpty) {
      subscriptions.setState(subscriptionsState);
    }

    final connectionFuture = _connectAndStartReplication(opts);
    return ConnectionWrapper(
      connectionFuture: connectionFuture,
    );
  }

  @visibleForTesting
  Future<void> setAuthState(AuthState newAuthState) async {
    authState = newAuthState;
  }

  @visibleForTesting
  Future<void> garbageCollectShapeHandler(
    List<ShapeDefinition> shapeDefs,
  ) async {
    final stmts = <Statement>[];
    // reverts to off on commit/abort
    stmts.add(Statement('PRAGMA defer_foreign_keys = ON'));
    shapeDefs
        .expand((ShapeDefinition def) => def.definition.selects)
        .map(
          (ShapeSelect select) =>
              // We need "fully qualified" table names in the next calls
              "main." + select.tablename,
        )
        .fold(stmts, (List<Statement> stmts, String tablename) {
      stmts.addAll([
        ..._disableTriggers([tablename]),
        Statement(
          "DELETE FROM $tablename",
        ),
        ..._enableTriggers([tablename])
      ]);
      return stmts;
      // does not delete shadow rows but we can do that
    });

    await adapter.runInTransaction(stmts);
  }

  void setClientListeners() {
    client.subscribeToRelations(updateRelations);
    client.subscribeToTransactions(applyTransaction);
    // When a local transaction is sent, or an acknowledgement for
    // a remote transaction commit is received, we update lsn records.
    client.subscribeToAck((evt) async {
      final decoded = bytesToNumber(evt.lsn);
      await ack(decoded, evt.ackType == AckType.remoteCommit);
    });
    client.subscribeToOutboundEvent(() => throttledSnapshot());

    client.subscribeToSubscriptionEvents(
      _handleSubscriptionData,
      _handleSubscriptionError,
    );
  }

  @override
  Future<void> stop() async {
    // Stop snapshotting and polling for changes.
    throttledSnapshot.cancel();

    if (_pollingInterval != null) {
      _pollingInterval!.cancel();
      _pollingInterval = null;
    }

    if (_authStateSubscription != null) {
      notifier.unsubscribeFromAuthStateChanges(_authStateSubscription!);
      _authStateSubscription = null;
    }

    if (_connectivityChangeSubscription != null) {
      notifier.unsubscribeFromConnectivityStateChanges(
        _connectivityChangeSubscription!,
      );
      _connectivityChangeSubscription = null;
    }

    if (_potentialDataChangeSubscription != null) {
      notifier.unsubscribeFromPotentialDataChanges(
        _potentialDataChangeSubscription!,
      );
      _potentialDataChangeSubscription = null;
    }

    await client.close();
  }

  @override
  Future<ShapeSubscription> subscribe(
    List<ClientShapeDefinition> shapeDefinitions,
  ) async {
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

    final SubscribeResponse(:subscriptionId, :error) =
        await client.subscribe(subId, shapeReqs);
    if (subId != subscriptionId) {
      subscriptionNotifiers.remove(subId);
      subscriptions.subscriptionCancelled(subId);
      throw Exception(
        "Expected SubscripeResponse for subscription id: $subId but got it for another id: $subscriptionId",
      );
    }

    if (error != null) {
      subscriptionNotifiers.remove(subId);
      subscriptions.subscriptionCancelled(subscriptionId);
      throw error;
    } else {
      return ShapeSubscription(
        synced: subscriptionNotifiers[subId]!.future,
      );
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
    if (subsData.data.isNotEmpty) {
      await _applySubscriptionData(subsData.data, subsData.lsn);
    }

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

    final groupedChanges =
        <String, ({List<String> columns, List<Record> records})>{};

    final allArgsForShadowInsert = <Record>[];

    // Group all changes by table name to be able to insert them all together
    for (final op in changes) {
      final tableName = QualifiedTablename('main', op.relation.table);
      if (groupedChanges.containsKey(tableName.toString())) {
        groupedChanges[tableName.toString()]?.records.add(op.record);
      } else {
        groupedChanges[tableName.toString()] = (
          columns: op.relation.columns.map((x) => x.name).toList(),
          records: [op.record]
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
        "namespace": 'main',
        "tablename": op.relation.table,
        "primaryKey": primaryKeyToStr(primaryKeyCols),
        "tags": encodeTags(op.tags),
      });
    }

    // Disable trigger for all affected tables
    stmts.addAll([..._disableTriggers(groupedChanges.keys.toList())]);

    // For each table, do a batched insert
    for (final entry in groupedChanges.entries) {
      final table = entry.key;
      final (:columns, :records) = entry.value;
      final sqlBase = "INSERT INTO $table (${columns.join(', ')}) VALUES ";

      stmts.addAll([
        ...prepareBatchedStatements(sqlBase, columns, records, maxSqlParameters)
      ]);
    }

    // And re-enable the triggers for all of them
    stmts.addAll([..._enableTriggers(groupedChanges.keys.toList())]);

    // Then do a batched insert for the shadow table
    final upsertShadowStmt =
        "INSERT or REPLACE INTO ${opts.shadowTable} (namespace, tablename, primaryKey, tags) VALUES ";
    stmts.addAll(
      prepareBatchedStatements(
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
      final notificationChanges = changes
          .map(
            (x) => Change(
              qualifiedTablename: QualifiedTablename('main', x.relation.table),
              rowids: [],
            ),
          )
          .toList();
      notifier.actuallyChanged(dbName, notificationChanges);
    } catch (e) {
      unawaited(
        _handleSubscriptionError(
          SubscriptionErrorData(
            error: SatelliteException(
              SatelliteErrorCode.internal,
              "Error applying subscription data: $e",
            ),
            subscriptionId: null,
          ),
        ),
      );
    }
  }

  Future<void> _handleSubscriptionError(
    SubscriptionErrorData errorData,
  ) async {
    final subscriptionId = errorData.subscriptionId;
    final satelliteError = errorData.error;

    // this is obviously too conservative and note
    // that it does not update meta transactionally
    final ids = await subscriptions.unsubscribeAll();

    logger
        .severe('Encountered a subscription error: ${satelliteError.message}');

    _lsn = null;
    await adapter.runInTransaction([
      _setMetaStatement('lsn', null),
      _setMetaStatement('subscriptions', subscriptions.serialize())
    ]);

    await client.unsubscribe(ids);

    // Call the `onSuccess` callback for this subscription
    if (subscriptionId != null) {
      final completer = subscriptionNotifiers[subscriptionId]!;

      // GC the notifiers for this subscription ID
      subscriptionNotifiers.remove(subscriptionId);
      completer.completeError(satelliteError);
    }
  }

  @visibleForTesting
  Future<void> connectivityStateChanged(
    ConnectivityState status,
  ) async {
    // TODO: no op if state is the same
    switch (status) {
      case ConnectivityState.available:
        {
          setClientListeners();
          return _connectAndStartReplication(null);
        }
      case ConnectivityState.error:
      case ConnectivityState.disconnected:
        {
          return client.close();
        }
      case ConnectivityState.connected:
        {
          return;
        }
      default:
        {
          throw Exception("unexpected connectivity state: $status");
        }
    }
  }

  Future<void> _connectAndStartReplication(
    SatelliteReplicationOptions? opts,
  ) async {
    logger.info("connecting and starting replication");

    final _authState = authState;
    if (_authState == null) {
      throw Exception("trying to connect before authentication");
    }

    try {
      await client.connect();
      await client.authenticate(_authState);

      final schemaVersion = await migrator.querySchemaVersion();

      // Fetch the subscription IDs that were fulfilled
      // such that we can resume and inform Electric
      // about fulfilled subscriptions
      final subscriptionIds = subscriptions.getFulfilledSubscriptions();

      await client.startReplication(_lsn, schemaVersion, subscriptionIds);
    } catch (error) {
      if (error is SatelliteException) {
        if (error.code == SatelliteErrorCode.behindWindow &&
            opts?.clearOnBehindWindow == true) {
          return _handleSubscriptionError(
            SubscriptionErrorData(
              error: error,
              subscriptionId: null,
            ),
          ).then(
            (_) => _connectAndStartReplication(opts),
          );
        }

        if (throwErrors.contains(error.code)) {
          rethrow;
        }
      }
      logger.warning("couldn't start replication: $error");
      return;
    }
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
    final numTables = res.first["numTables"]! as int;
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
  // It is not safe to call this function concurrently. Consider
  // using a wrapped version
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

    final timestamp = DateTime.now();

    await _updateOplogTimestamp(timestamp);
    final oplogEntries = await _getUpdatedEntries(timestamp);

    if (oplogEntries.isNotEmpty) {
      final stmts = await _handleShadowOperations(timestamp, oplogEntries);
      await adapter.runInTransaction(stmts);
      unawaited(_notifyChanges(oplogEntries));
    }

    if (!client.isClosed()) {
      final LogPositions(:enqueued) = client.getOutboundLogPositions();
      final enqueuedLogPos = bytesToNumber(enqueued);

      // TODO: handle case where pending oplog is large
      await getEntries(since: enqueuedLogPos).then(
        (missing) => _replicateSnapshotChanges(missing),
      );
    }
    _performingSnapshot = false;
    return timestamp;
  }

  Future<List<Statement>> _handleShadowOperations(
    DateTime timestamp,
    List<OplogEntry> oplogEntries,
  ) async {
    final stmts = <Statement>[];
    final shadowEntries = <String, ShadowEntry>{};

    for (final oplogEntry in oplogEntries) {
      // should get shadow entries at once to prevent querying in a loop
      final shadowEntryLookup =
          await _lookupCachedShadowEntry(oplogEntry, shadowEntries);
      final cached = shadowEntryLookup.cached;
      final shadowEntry = shadowEntryLookup.entry;

      // Clear should not contain the tag for this timestamp, so if
      // the entry was previously in cache - it means, that we already
      // read it within the same snapshot
      if (cached) {
        oplogEntry.clearTags = encodeTags(
          difference(decodeTags(shadowEntry.tags), [
            _generateTag(timestamp),
          ]),
        );
      } else {
        oplogEntry.clearTags = shadowEntry.tags;
      }

      if (oplogEntry.optype == OpType.delete) {
        shadowEntry.tags = shadowTagsDefault;
      } else {
        final newTag = _generateTag(timestamp);
        shadowEntry.tags = encodeTags([newTag]);
      }

      stmts.add(_updateOplogEntryTagsStatement(oplogEntry));
      _updateCachedShadowEntry(oplogEntry, shadowEntry, shadowEntries);
    }

    shadowEntries.forEach((String _key, ShadowEntry value) {
      if (value.tags == shadowTagsDefault) {
        stmts.add(_deleteShadowTagsStatement(value));
      } else {
        stmts.add(_updateShadowTagsStatement(value));
      }
    });
    return stmts;
  }

  void _updateCachedShadowEntry(
    OplogEntry oplogEntry,
    ShadowEntry shadowEntry,
    Map<String, ShadowEntry> shadowEntries,
  ) {
    final pk = getShadowPrimaryKey(oplogEntry);
    final key = [oplogEntry.namespace, oplogEntry.tablename, pk].join('.');

    shadowEntries[key] = shadowEntry;
  }

  // Promise<[boolean, ShadowEntry]
  Future<ShadowEntryLookup> _lookupCachedShadowEntry(
    OplogEntry oplogEntry,
    Map<String, ShadowEntry> shadowEntries,
  ) async {
    final pk = getShadowPrimaryKey(oplogEntry);
    final String key =
        [oplogEntry.namespace, oplogEntry.tablename, pk].join('.');

    if (shadowEntries.containsKey(key)) {
      return ShadowEntryLookup(cached: true, entry: shadowEntries[key]!);
    } else {
      late final ShadowEntry shadowEntry;
      final shadowEntriesList = await getOplogShadowEntry(oplog: oplogEntry);
      if (shadowEntriesList.isEmpty) {
        shadowEntry = newShadowEntry(oplogEntry);
      } else {
        shadowEntry = shadowEntriesList[0];
      }
      shadowEntries[key] = shadowEntry;
      return ShadowEntryLookup(cached: false, entry: shadowEntry);
    }
  }

  Future<void> _notifyChanges(List<OplogEntry> results) async {
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

        change.rowids!.add(entry.rowid);
      } else {
        acc[key] = Change(
          qualifiedTablename: qt,
          rowids: [entry.rowid],
        );
      }

      return acc;
    }
    // final changes = Object.values(results.reduce(reduceFn, acc))

    final changes = results.fold(acc, reduceFn).values.toList();
    notifier.actuallyChanged(dbName, changes);
  }

  Future<void> _replicateSnapshotChanges(
    List<OplogEntry> results,
  ) async {
    // TODO: Don't try replicating when outbound is inactive
    if (client.isClosed()) {
      return;
    }

    final transactions = toTransactions(results, relations);
    for (final txn in transactions) {
      return client.enqueueTransaction(txn);
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
    final merged =
        mergeEntries(authState!.clientId, local, incomingOrigin, incoming);

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
    since ??= _lastAckdRowId;
    final oplog = opts.oplogTable.toString();

    final selectEntries = '''
      SELECT * FROM $oplog
        WHERE timestamp IS NOT NULL
          AND rowid > ?
        ORDER BY rowid ASC
    ''';
    final rows = await adapter.query(Statement(selectEntries, [since]));
    return rows.map(_opLogEntryFromRow).toList();
  }

  Future<List<OplogEntry>> _getUpdatedEntries(
    DateTime timestamp, {
    int? since,
  }) async {
    since ??= _lastAckdRowId;
    final oplog = opts.oplogTable.toString();

    final selectChanges = '''
      SELECT * FROM $oplog
      WHERE timestamp = ? AND
            rowid > ?
      ORDER BY rowid ASC
    ''';

    final rows = await adapter.query(
      Statement(
        selectChanges,
        [timestamp.toISOStringUTC(), since],
      ),
    );
    return rows.map(_opLogEntryFromRow).toList();
  }

  @visibleForTesting
  Statement getOplogShadowEntryStatement({OplogEntry? oplog}) {
    final shadow = opts.shadowTable.toString();
    Statement query;
    var selectTags = "SELECT * FROM $shadow";
    if (oplog != null) {
      selectTags = '''
        $selectTags WHERE
         namespace = ? AND
         tablename = ? AND
         primaryKey = ?
      ''';
      final args = [
        oplog.namespace,
        oplog.tablename,
        getShadowPrimaryKey(oplog),
      ];
      query = Statement(selectTags, args);
    } else {
      query = Statement(selectTags);
    }

    return query;
  }

  @visibleForTesting
  Future<List<ShadowEntry>> getOplogShadowEntry({OplogEntry? oplog}) async {
    final stmt = getOplogShadowEntryStatement(oplog: oplog);

    final shadowTags = await adapter.query(stmt);
    return shadowTags.map((e) {
      return ShadowEntry(
        namespace: e['namespace']! as String,
        tablename: e['tablename']! as String,
        primaryKey: e['primaryKey']! as String,
        tags: e['tags']! as String,
      );
    }).toList();
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

  Statement _updateOplogEntryTagsStatement(OplogEntry oplog) {
    final oplogTable = opts.oplogTable.toString();
    final updateTags = '''
      UPDATE $oplogTable set clearTags = ?
        WHERE rowid = ?
    ''';
    return Statement(
      updateTags,
      <Object?>[oplog.clearTags, oplog.rowid],
    );
  }

  Future<RunResult> _updateOplogTimestamp(DateTime timestamp) async {
    final oplog = opts.oplogTable.toString();

    final updateTimestamps = '''
      UPDATE $oplog set timestamp = ?
        WHERE rowid in (
          SELECT rowid FROM $oplog
              WHERE timestamp is NULL
              AND rowid > ?
          ORDER BY rowid ASC
          )
    ''';

    final updateArgs = <Object?>[
      timestamp.toISOStringUTC(),
      _lastAckdRowId.toString()
    ];
    return await adapter.run(Statement(updateTimestamps, updateArgs));
  }

  // Merge changes, with last-write-wins and add-wins semantics.
  // clearTags field is used by the calling code to determine new value of
  // the shadowTags
  ShadowTableChanges mergeEntries(
    String localOrigin,
    List<OplogEntry> local,
    String incomingOrigin,
    List<OplogEntry> incoming,
  ) {
    final localTableChanges =
        localOperationsToTableChanges(local, (DateTime timestamp) {
      return generateTag(localOrigin, timestamp);
    });
    final incomingTableChanges = remoteOperationsToTableChanges(incoming);

    for (final incomingTableChangeEntry in incomingTableChanges.entries) {
      final tablename = incomingTableChangeEntry.key;
      final incomingMapping = incomingTableChangeEntry.value;
      final localMapping = localTableChanges[tablename];

      if (localMapping == null) {
        continue;
      }

      for (final incomingMappingEntry in incomingMapping.entries) {
        final primaryKey = incomingMappingEntry.key;
        final incomingChanges = incomingMappingEntry.value;
        final localInfo = localMapping[primaryKey];
        if (localInfo == null) {
          continue;
        }
        final localChanges = localInfo.oplogEntryChanges;

        final changes = mergeChangesLastWriteWins(
          localOrigin,
          localChanges.changes,
          incomingOrigin,
          incomingChanges.changes,
          incomingChanges.fullRow,
        );
        late final ChangesOpType optype;

        final tags = mergeOpTags(localChanges, incomingChanges);
        if (tags.isEmpty) {
          optype = ChangesOpType.delete;
        } else {
          optype = ChangesOpType.upsert;
        }

        incomingChanges.changes = changes;
        incomingChanges.optype = optype;
        incomingChanges.tags = tags;
      }
    }

    return incomingTableChanges;
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

    final processDML = (List<DataChange> changes) async {
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
        logger.info("apply incoming changes for LSN: ${base64.encode(lsn)}");
        // assign timestamp to pending operations before apply
        await _mutexSnapshot();
        firstDMLChunk = false;
      }

      final applyRes = await apply(entries, origin);
      final statements = applyRes.statements;
      final tablenames = applyRes.tableNames;
      entries.forEach((e) => opLogEntries.add(e));
      statements.forEach((s) => stmts.add(s));
      tablenames.forEach((n) => tablenamesSet.add(n));
    };

    final processDDL = (List<SchemaChange> changes) async {
      final createdTables = <String>{};
      final affectedTables = <String, MigrationTable>{};
      changes.forEach((change) {
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
      });

      // Also add statements to create the necessary triggers for the created/updated table
      affectedTables.values.forEach((table) {
        final triggers = generateTriggersForTable(table);
        stmts.addAll(triggers);
        txStmts.addAll(triggers);
      });

      // Disable the newly created triggers
      // during the processing of this transaction
      stmts.addAll(_disableTriggers([...createdTables]));
      newTables = <String>{...newTables, ...createdTables};
    };

    // Now process all changes per chunk.
    // We basically take a prefix of changes of the same type
    // which we call a `dmlChunk` or `ddlChunk` if the changes
    // are DML statements, respectively, DDL statements.
    // We process chunk per chunk in-order.
    var dmlChunk = <DataChange>[];
    var ddlChunk = <SchemaChange>[];

    final changes = transaction.changes;
    for (int idx = 0; idx < changes.length; idx++) {
      final change = changes[idx];
      ChangeType getChangeType(types.Change change) {
        return change is DataChange ? ChangeType.dml : ChangeType.ddl;
      }

      bool sameChangeTypeAsPrevious() {
        return idx == 0 ||
            getChangeType(changes[idx]) == getChangeType(changes[idx - 1]);
      }

      final addToChunk = (types.Change change) {
        if (change is DataChange) {
          dmlChunk.add(change);
        } else {
          ddlChunk.add(change as SchemaChange);
        }
      };
      Future<void> processChunk(ChangeType type) async {
        if (type == ChangeType.dml) {
          await processDML(dmlChunk);
          dmlChunk = [];
        } else {
          await processDDL(ddlChunk);
          ddlChunk = [];
        }
      }

      addToChunk(change); // add the change in the right chunk
      if (!sameChangeTypeAsPrevious()) {
        // We're starting a new chunk
        // process the previous chunk and clear it
        final previousChange = changes[idx - 1];
        await processChunk(getChangeType(previousChange));
      }

      if (idx == changes.length - 1) {
        // we're at the last change
        // process this chunk
        final thisChange = changes[idx];
        await processChunk(getChangeType(thisChange));
      }
    }

    // Now run the DML and DDL statements in-order in a transaction
    final tablenames = tablenamesSet.toList();
    final notNewTableNames =
        tablenames.where((t) => !newTables.contains(t)).toList();

    final allStatements = [
      ..._disableTriggers(notNewTableNames),
      ...stmts,
      ..._enableTriggers(tablenames)
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

    await notifyChangesAndGCopLog(opLogEntries, origin, commitTimestamp);
  }

  @visibleForTesting
  Future<void> notifyChangesAndGCopLog(
    List<OplogEntry> opLogEntries,
    String origin,
    DateTime commitTimestamp,
  ) async {
    await _notifyChanges(opLogEntries);

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
          "UPDATE $triggers SET flag = ? WHERE $tablesOr",
          [if (flag) 1 else 0, ...tablenames],
        )
      ];
    } else {
      return [];
    }
  }

  @visibleForTesting
  Future<void> ack(int lsn, bool isAck) async {
    if (lsn < _lastAckdRowId || (lsn > lastSentRowId && isAck)) {
      throw Exception('Invalid position');
    }

    final meta = opts.metaTable.toString();

    final sql = " UPDATE $meta SET value = ? WHERE key = ?";
    final args = <Object?>[
      lsn.toString(),
      if (isAck) 'lastAckdRowId' else 'lastSentRowId',
    ];

    if (isAck) {
      _lastAckdRowId = lsn;
      await adapter.runInTransaction([
        Statement(sql, args),
      ]);
    } else {
      lastSentRowId = lsn;
      await adapter.run(Statement(sql, args));
    }
  }

  Statement _setMetaStatement(String key, Object? value) {
    final meta = opts.metaTable.toString();

    final sql = "UPDATE $meta SET value = ? WHERE key = ?";
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

    final sql = "SELECT value from $meta WHERE key = ?";
    final args = [key];
    final rows = await adapter.query(Statement(sql, args));

    if (rows.length != 1) {
      throw "Invalid metadata table: missing $key";
    }

    return rows.first["value"] as T;
  }

  Future<Uuid> _getClientId() async {
    const clientIdKey = 'clientId';

    String clientId = await getMeta<Uuid>(clientIdKey);

    if (clientId.isEmpty) {
      clientId = uuid();
      await setMeta(clientIdKey, clientId);
    }
    return clientId;
  }

  Future<List<Row>> _getLocalTableNames() async {
    final notIn = <String>[
      opts.metaTable.tablename,
      opts.migrationsTable.tablename,
      opts.oplogTable.tablename,
      opts.triggersTable.tablename,
      opts.shadowTable.tablename,
      'sqlite_schema',
      'sqlite_sequence',
      'sqlite_temp_schema',
    ];

    final tables = '''
      SELECT name FROM sqlite_master
        WHERE type = 'table'
          AND name NOT IN (${notIn.map((_) => '?').join(',')})
    ''';
    final tableNames = await adapter.query(Statement(tables, notIn));
    return tableNames;
  }

  // Fetch primary keys from local store and use them to identify incoming ops.
  // TODO: Improve this code once with Migrator and consider simplifying oplog.
  @visibleForTesting
  Future<RelationsCache> getLocalRelations() async {
    final tableNames = await _getLocalTableNames();
    final RelationsCache relations = {};

    int id = 0;
    const schema = 'public'; // TODO
    for (final table in tableNames) {
      final tableName = table["name"]! as String;
      const sql = 'SELECT * FROM pragma_table_info(?)';
      final args = [tableName];
      final columnsForTable = await adapter.query(Statement(sql, args));
      if (columnsForTable.isEmpty) {
        continue;
      }
      final Relation relation = Relation(
        id: id++,
        schema: schema,
        table: tableName,
        tableType: SatRelation_RelationType.TABLE,
        columns: [],
      );
      for (final c in columnsForTable) {
        relation.columns.add(
          RelationColumn(
            name: c["name"]! as String,
            type: c["type"]! as String,
            primaryKey: (c["pk"]! as int) > 0,
          ),
        );
      }
      relations[tableName] = relation;
    }

    return relations;
  }

  String _generateTag(DateTime timestamp) {
    final instanceId = authState!.clientId;

    return generateTag(instanceId, timestamp);
  }

  @visibleForTesting
  Future<void> garbageCollectOplog(DateTime commitTimestamp) async {
    final isoString = commitTimestamp.toISOStringUTC();
    final String oplog = opts.oplogTable.tablename;
    final stmt = '''
      DELETE FROM $oplog
      WHERE timestamp = ?;
    ''';
    await adapter.run(Statement(stmt, <Object?>[isoString]));
  }

  /// Update `this._lsn` to the new value and generate a statement to persist this change
  ///
  /// @param lsn new LSN value
  /// @returns statement to be executed to save the new LSN value in the database
  Statement updateLsnStmt(LSN lsn) {
    _lsn = lsn;
    final lsn_base64 = base64.encode(lsn);
    return Statement(
      "UPDATE ${opts.metaTable.tablename} set value = ? WHERE key = ?",
      [lsn_base64, 'lsn'],
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
      acc.where.add("$column = ?");
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
      acc.where.add("$c = ?");
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
    insertStmt = "INSERT OR IGNORE $insertStmt";
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
  );
  final fullTableName = table.namespace + '.' + table.tableName;
  return generateOplogTriggers(fullTableName, table);
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

OplogEntry _opLogEntryFromRow(Map<String, Object?> row) {
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
