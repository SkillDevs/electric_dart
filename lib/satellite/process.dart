import 'dart:async';
import 'dart:convert';

import 'package:electric_client/auth/auth.dart';
import 'package:electric_client/electric/adapter.dart' hide Transaction;
import 'package:electric_client/migrators/migrators.dart';
import 'package:electric_client/notifiers/notifiers.dart';
import 'package:electric_client/proto/satellite.pbenum.dart';
import 'package:electric_client/satellite/config.dart';
import 'package:electric_client/satellite/merge.dart';
import 'package:electric_client/satellite/oplog.dart';
import 'package:electric_client/satellite/satellite.dart';
import 'package:electric_client/util/common.dart';
import 'package:electric_client/util/debug/debug.dart';
import 'package:electric_client/util/sets.dart';
import 'package:electric_client/util/tablename.dart';
import 'package:electric_client/util/types.dart' hide Change;
import 'package:fpdart/fpdart.dart';
import 'package:meta/meta.dart';

typedef ChangeAccumulator = Map<String, Change>;

class SatelliteProcess implements Satellite {
  @override
  final DbName dbName;
  @override
  final DatabaseAdapter adapter;
  @override
  final Migrator migrator;
  @override
  final Notifier notifier;
  final Client client;
  final ConsoleClient console;

  final SatelliteConfig config;
  final SatelliteOpts opts;

  @visibleForTesting
  AuthState? authState;

  // TODO: Unused in typescript
  //DateTime? _lastSnapshotTimestamp;

  Timer? _pollingInterval;
  String? _potentialDataChangeSubscription;
  String? _connectivityChangeSubscription;

  late void Function() _throttledSnapshot;

  int _lastAckdRowId = 0;
  int _lastSentRowId = 0;
  LSN? _lsn;

  RelationsCache relations = {};

  SatelliteProcess({
    required this.dbName,
    required this.console,
    required this.client,
    required this.config,
    required this.opts,
    required this.adapter,
    required this.migrator,
    required this.notifier,
  }) {
    // Create a throttled function that performs a snapshot at most every
    // `minSnapshotWindow` ms. This function runs immediately when you
    // first call it and then every `minSnapshotWindow` ms as long as
    // you keep calling it within the window. If you don't call it within
    // the window, it will then run immediately the next time you call it.
    _throttledSnapshot = throttle(
      performSnapshot,
      Duration(milliseconds: opts.minSnapshotWindow),
    );
  }

  @override
  Future<Either<Exception, void>> start(AuthState? authStateParam) async {
    await migrator.up();

    final isVerified = await _verifyTableStructure();
    if (!isVerified) {
      throw Exception('Invalid database schema.');
    }

    await setAuthState(authStateParam);

    // XXX establish replication connection,
    // validate auth state, etc here.

    // Request a snapshot whenever the data in our database potentially changes.
    _potentialDataChangeSubscription = notifier.subscribeToPotentialDataChanges((_) => _throttledSnapshot());

    void connectivityChangeCallback(
      ConnectivityStateChangeNotification notification,
    ) {
      _connectivityStateChange(notification.connectivityState);
    }

    _connectivityChangeSubscription = notifier.subscribeToConnectivityStateChange(connectivityChangeCallback);

    // Start polling to request a snapshot every `pollingInterval` ms.
    _pollingInterval = Timer.periodic(
      Duration(milliseconds: opts.pollingInterval),
      (_) => _throttledSnapshot(),
    );

    // Starting now!
    unawaited(Future(() => _throttledSnapshot()));

    // Need to reload primary keys after schema migration
    // For now, we do it only at initialization
    relations = await _getLocalRelations();

    _lastAckdRowId = int.parse(await _getMeta('lastAckdRowId'));
    _lastSentRowId = int.parse(await _getMeta('lastSentRowId'));

    setClientListeners();
    client.resetOutboundLogPositions(numberToBytes(_lastAckdRowId), numberToBytes(_lastSentRowId));

    final lsnBase64 = await _getMeta('lsn');
    if (lsnBase64.isNotEmpty) {
      logger.info("retrieved lsn $_lsn");
      _lsn = base64.decode(lsnBase64);
    } else {
      logger.info("no lsn retrieved from store");
    }

    return await _connectAndStartReplication();
  }

  @visibleForTesting
  Future<void> setAuthState(AuthState? newAuthState) async {
    if (newAuthState != null) {
      throw UnimplementedError();
      // this._authState = authState
    } else {
      final app = config.app;
      final env = config.env;
      final clientId = await _getClientId();
      final token = await _getMeta('token');
      final refreshToken = await _getMeta('refreshToken');

      authState = AuthState(
        app: app,
        env: env,
        clientId: clientId,
        token: token,
        refreshToken: refreshToken,
      );
    }
  }

  void setClientListeners() {
    client.subscribeToTransactions((Transaction transaction) async {
      unawaited(_applyTransaction(transaction));
    });
    // When a local transaction is sent, or an acknowledgement for
    // a remote transaction commit is received, we update lsn records.
    client.subscribeToAck((evt) async {
      final decoded = bytesToNumber(evt.lsn);
      await _ack(decoded, evt.ackType == AckType.remoteCommit);
    });
    client.subscribeToOutboundEvent(() => _throttledSnapshot());
  }

  @override
  Future<void> stop() async {
    logger.info('stop polling');
    if (_pollingInterval != null) {
      _pollingInterval!.cancel();
      _pollingInterval = null;
    }

    if (_potentialDataChangeSubscription != null) {
      notifier.unsubscribeFromPotentialDataChanges(_potentialDataChangeSubscription!);
      _potentialDataChangeSubscription = null;
    }

    // TODO: Missing in typescript client
    if (_connectivityChangeSubscription != null) {
      notifier.unsubscribeFromConnectivityStateChange(_connectivityChangeSubscription!);
      _connectivityChangeSubscription = null;
    }

    await client.close();
  }

  Future<Either<SatelliteException, void>> _connectivityStateChange(
    ConnectivityState status,
  ) async {
    // TODO: no op if state is the same
    switch (status) {
      case ConnectivityState.available:
        {
          setClientListeners();
          return _connectAndStartReplication();
        }
      case ConnectivityState.error:
      case ConnectivityState.disconnected:
        {
          return client.close();
        }
      case ConnectivityState.connected:
        {
          return Right(null);
        }
      default:
        {
          throw Exception("unexpected connectivity state: $status");
        }
    }
  }

  Future<Either<SatelliteException, void>> _connectAndStartReplication() async {
    logger.info("connecting and starting replication");

    final localAuthState = authState;
    if (localAuthState == null) {
      throw Exception("trying to connect before authentication");
    }

    // TODO: Connect to client
    return client
        .connect()
        .then((_) => refreshAuthState(localAuthState))
        .then((freshAuthState) => client.authenticate(freshAuthState))
        .then((_) => client.startReplication(_lsn))
        .onError(
      (error, st) {
        logger.warning("couldn't start replication: $error");
        return Right(null);
      },
    );
  }

  FutureOr<AuthState> refreshAuthState(AuthState authStateParam) async {
    try {
      final tokenResponse = await console.token(
        TokenRequest(
          app: authStateParam.app,
          env: authStateParam.env,
          clientId: authStateParam.clientId,
        ),
      );
      await _setMeta('token', tokenResponse.token);
      // TODO: Bug
      await _setMeta('refreshToken', tokenResponse.token);

      return AuthState(
        app: authStateParam.app,
        env: authStateParam.env,
        clientId: authStateParam.clientId,
        token: tokenResponse.token,
        refreshToken: tokenResponse.refreshToken,
      );
    } catch (error) {
      logger.warning("unable to refresh token: $error");
    }

    return authStateParam;
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

    final res = await adapter.query(Statement(
      tablesExist,
      [meta, oplog, shadow],
    ));
    final numTables = res.first["numTables"]! as int;
    return numTables == 3;
  }

// TODO: Migrate
/*
    // Handle auth state changes.
  async _updateAuthState({ authState }: AuthStateNotification): Promise<void> {
    // XXX do whatever we need to stop/start or reconnect the replication
    // connection with the new auth state.

    // XXX Maybe we need to auto-start processing and/or replication
    // when we get the right authState?

    this._authState = authState
  }
  */

  // Perform a snapshot and notify which data actually changed.
  @visibleForTesting
  Future<DateTime> performSnapshot() async {
    final timestamp = DateTime.now();

    await _updateOplogTimestamp(timestamp);
    final oplogEntries = await _getUpdatedEntries(timestamp);

    final List<Future> promises = [];

    if (oplogEntries.isNotEmpty) {
      promises.add(_notifyChanges(oplogEntries));

      final shadowEntries = <String, ShadowEntry>{};

      for (final oplogEntry in oplogEntries) {
        final shadowEntryLookup = await _lookupCachedShadowEntry(oplogEntry, shadowEntries);
        final cached = shadowEntryLookup.cached;
        final shadowEntry = shadowEntryLookup.entry;

        // Clear should not contain the tag for this timestamp, so if
        // the entry was previously in cache - it means, that we already
        // read it within the same snapshot
        if (cached) {
          oplogEntry.clearTags = encodeTags(difference(decodeTags(shadowEntry.tags), [
            _generateTag(timestamp),
          ]));
        } else {
          oplogEntry.clearTags = shadowEntry.tags;
        }

        if (oplogEntry.optype == OpType.delete) {
          shadowEntry.tags = shadowTagsDefault;
        } else {
          final newTag = _generateTag(timestamp);
          shadowEntry.tags = encodeTags([newTag]);
        }

        promises.add(_updateOplogEntryTags(oplogEntry));
        _updateCachedShadowEntry(oplogEntry, shadowEntry, shadowEntries);
      }

      shadowEntries.forEach((String _key, ShadowEntry value) {
        if (value.tags == shadowTagsDefault) {
          promises.add(adapter.run(_deleteShadowTagsQuery(value)));
        } else {
          promises.add(_updateShadowTags(value));
        }
      });
    }
    await Future.wait(promises);

    if (!client.isClosed()) {
      final enqueued = client.getOutboundLogPositions().enqueued;
      final enqueuedLogPos = bytesToNumber(enqueued);

      // TODO: take next N transactions instead of all
      await getEntries(since: enqueuedLogPos).then((missing) => _replicateSnapshotChanges(missing));
    }
    return timestamp;
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
      OplogEntry oplogEntry, Map<String, ShadowEntry> shadowEntries) async {
    final pk = getShadowPrimaryKey(oplogEntry);
    final String key = [oplogEntry.namespace, oplogEntry.tablename, pk].join('.');

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
    reduceFn(ChangeAccumulator acc, OplogEntry entry) {
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

  Future<Either<SatelliteException, void>> _replicateSnapshotChanges(
    List<OplogEntry> results,
  ) async {
    // TODO: Don't try replicating when outbound is inactive
    if (client.isClosed()) {
      return Right(null);
    }

    final transactions = toTransactions(results, relations);
    for (final txn in transactions) {
      return client.enqueueTransaction(txn);
    }

    return Right(null);
  }

  // Apply a set of incoming transactions against pending local operations,
  // applying conflict resolution rules. Takes all changes per each key before
  // merging, for local and remote operations.
  @visibleForTesting
  Future<void> apply(List<OplogEntry> incoming, String incoming_origin, LSN lsn) async {
    logger.info("apply incoming changes for LSN: $lsn");
    // assign timestamp to pending operations before apply
    await performSnapshot();

    final local = await getEntries();
    final merged = _mergeEntries(authState!.clientId, local, incoming_origin, incoming);

    final List<Statement> stmts = [];
    // switches off on transaction commit/abort
    stmts.add(Statement('PRAGMA defer_foreign_keys = ON'));
    // update lsn.
    _lsn = lsn;
    final lsn_base64 = base64.encode(lsn);
    stmts
        .add(Statement("UPDATE ${opts.metaTable.tablename} set value = ? WHERE key = ?", <Object?>[lsn_base64, 'lsn']));

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
            stmts.add(_deleteShadowTagsQuery(shadowEntry));
            break;

          default:
            stmts.add(_applyNonDeleteOperation(entryChanges, tablenameStr));
            stmts.add(_updateShadowTagsQuery(shadowEntry));
        }
      }
    }

    final tablenames = merged.keys;

    await adapter.runInTransaction([
      ..._disableTriggers(tablenames.toList()),
      ...stmts,
      ..._enableTriggers(tablenames.toList()),
    ]);
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
// TODO:

  Future<List<OplogEntry>> _getUpdatedEntries(DateTime timestamp, {int? since}) async {
    since ??= _lastAckdRowId;
    final oplog = opts.oplogTable.toString();

    final selectChanges = '''
      SELECT * FROM $oplog
      WHERE timestamp = ? AND
            rowid > ?
      ORDER BY rowid ASC
    ''';

    final rows = await adapter.query(Statement(
      selectChanges,
      [timestamp.toIso8601String(), since],
    ));
    return rows.map(_opLogEntryFromRow).toList();
  }

  @visibleForTesting
  Future<List<ShadowEntry>> getOplogShadowEntry({OplogEntry? oplog}) async {
    final shadow = opts.shadowTable.toString();
    Statement query;
    var selectTags = "SELECT * FROM $shadow";
    if (oplog != null) {
      selectTags = '''$selectTags WHERE
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

    final shadowTags = await adapter.query(query);
    return shadowTags.map((e) {
      return ShadowEntry(
        namespace: e['namespace'] as String,
        tablename: e['tablename'] as String,
        primaryKey: e['primaryKey'] as String,
        tags: e['tags'] as String,
      );
    }).toList();
  }

  Future<RunResult> _updateShadowTags(ShadowEntry shadow) async {
    return await adapter.run(_updateShadowTagsQuery(shadow));
  }

  Statement _deleteShadowTagsQuery(ShadowEntry shadow) {
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

  Statement _updateShadowTagsQuery(ShadowEntry shadow) {
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

  Future<RunResult> _updateOplogEntryTags(OplogEntry oplog) async {
    final oplogTable = opts.oplogTable.toString();
    final updateTags = '''
      UPDATE $oplogTable set clearTags = ?
        WHERE rowid = ?
    ''';
    return await adapter.run(Statement(
      updateTags,
      <Object?>[oplog.clearTags, oplog.rowid],
    ));
  }

  Future<void> _updateOplogTimestamp(DateTime timestamp) async {
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

    final updateArgs = <Object?>[timestamp.toIso8601String(), _lastAckdRowId.toString()];
    await adapter.run(Statement(updateTimestamps, updateArgs));
  }

  // Merge changes, with last-write-wins and add-wins semantics.
  // clearTags field is used by the calling code to determine new value of
  // the shadowTags
  ShadowTableChanges _mergeEntries(
    String local_origin,
    List<OplogEntry> local,
    String incoming_origin,
    List<OplogEntry> incoming,
  ) {
    final localTableChanges = localOperationsToTableChanges(local, (DateTime timestamp) {
      return generateTag(local_origin, timestamp);
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

        final changes =
            mergeChangesLastWriteWins(local_origin, localChanges.changes, incoming_origin, incomingChanges.changes);
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

  Future<void> _applyTransaction(Transaction transaction) async {
    final origin = transaction.origin!;

    final opLogEntries = fromTransaction(transaction, relations);
    final commitTimestamp = DateTime.fromMicrosecondsSinceEpoch(transaction.commitTimestamp.toInt());
    await applyTransactionInternal(origin, commitTimestamp, opLogEntries, transaction.lsn);
  }

  @visibleForTesting
  Future<void> applyTransactionInternal(
      String origin, DateTime commitTimestamp, List<OplogEntry> opLogEntries, LSN lsn) async {
    await apply(opLogEntries, origin, lsn);
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
      await _garbageCollectOplog(commitTimestamp);
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
    final stmts = tablenames
        .map((tablenameStr) => (Statement(
              "UPDATE $triggers SET flag = ? WHERE tablename = ?",
              [flag ? 1 : 0, tablenameStr],
            )))
        .toList();
    return stmts;
  }

  Future<void> _ack(int lsn, bool isAck) async {
    if (lsn < _lastAckdRowId || (lsn > _lastSentRowId && isAck)) {
      throw Exception('Invalid position');
    }

    final meta = opts.metaTable.toString();

    final sql = " UPDATE $meta SET value = ? WHERE key = ?";
    final args = <Object?>[
      lsn.toString(),
      isAck ? 'lastAckdRowId' : 'lastSentRowId',
    ];

    if (isAck) {
      final oplog = opts.oplogTable.toString();
      final del = "DELETE FROM $oplog WHERE rowid <= ?";
      final delArgs = <Object?>[lsn];

      _lastAckdRowId = lsn;
      await adapter.runInTransaction([
        Statement(sql, args),
        Statement(del, delArgs),
      ]);
    } else {
      _lastSentRowId = lsn;
      await adapter.runInTransaction([Statement(sql, args)]);
    }
  }

  Future<void> _setMeta(String key, Object? value) async {
    final meta = opts.metaTable.toString();

    final sql = "UPDATE $meta SET value = ? WHERE key = ?";
    final args = <Object?>[value, key];

    await adapter.run(Statement(sql, args));
  }

  Future<String> _getMeta(String key) async {
    final meta = opts.metaTable.toString();

    final sql = "SELECT value from $meta WHERE key = ?";
    final args = [key];
    final rows = await adapter.query(Statement(sql, args));

    if (rows.length != 1) {
      throw "Invalid metadata table: missing $key";
    }

    return rows.first["value"]! as String;
  }

  Future<String> _getClientId() async {
    const clientIdKey = 'clientId';

    String clientId = await _getMeta(clientIdKey);

    if (clientId.isEmpty) {
      clientId = uuid();
      await _setMeta(clientIdKey, clientId);
    }
    return clientId;
  }

  // Fetch primary keys from local store and use them to identify incoming ops.
  // TODO: Improve this code once with Migrator and consider simplifying oplog.
  Future<RelationsCache> _getLocalRelations() async {
    final notIn = [
      opts.metaTable.tablename.toString(),
      opts.migrationsTable.tablename.toString(),
      opts.oplogTable.tablename.toString(),
      opts.triggersTable.tablename.toString(),
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
        relation.columns.add(RelationColumn(
          name: c["name"]! as String,
          type: c["type"]! as String,
          primaryKey: (c["pk"]! as int) > 0,
        ));
      }
      relations[tableName] = relation;
    }

    return relations;
  }

  String _generateTag(DateTime timestamp) {
    final instanceId = authState!.clientId;

    return generateTag(instanceId, timestamp);
  }

  Future<void> _garbageCollectOplog(DateTime commitTimestamp) async {
    final isoString = commitTimestamp.toIso8601String();
    final oplog = opts.oplogTable.tablename.toString();
    final stmt = '''
      DELETE FROM $oplog
      WHERE timestamp = ?;
    ''';
    await adapter.run(Statement(stmt, <Object?>[isoString]));
  }
}

Statement _applyDeleteOperation(ShadowEntryChanges entryChanges, String tablenameStr) {
  final pkEntries = entryChanges.primaryKeyCols.entries;
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

Statement _applyNonDeleteOperation(ShadowEntryChanges shadowEntryChanges, String tablenameStr) {
  final changes = shadowEntryChanges.changes;
  final primaryKeyCols = shadowEntryChanges.primaryKeyCols;

  final columnNames = changes.keys;
  final List<Object?> columnValues = changes.values.map((c) => c.value).toList();
  String insertStmt =
      '''INTO $tablenameStr(${columnNames.join(', ')}) VALUES (${columnValues.map((_) => '?').join(',')})''';

  final updateColumnStmts = columnNames.where((c) => !(primaryKeyCols.containsKey(c))).fold(
    _WhereAndValues([], []),
    (acc, c) {
      acc.where.add("$c = ?");
      acc.values.add(changes[c]!.value);
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
    namespace: row['namespace'] as String,
    tablename: row['tablename'] as String,
    primaryKey: row['primaryKey'] as String,
    rowid: row['rowid'] as int,
    optype: opTypeStrToOpType(row['optype'] as String),
    timestamp: row['timestamp'] as String,
    newRow: row['newRow'] as String?,
    oldRow: row['oldRow'] as String?,
    clearTags: row['clearTags'] as String,
  );
}
