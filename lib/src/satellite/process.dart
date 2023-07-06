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
import 'package:electric_client/src/util/common.dart';
import 'package:electric_client/src/util/debug/debug.dart';
import 'package:electric_client/src/util/sets.dart';
import 'package:electric_client/src/util/tablename.dart';
import 'package:electric_client/src/util/types.dart' hide Change;
import 'package:electric_client/src/util/types.dart' as types;
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

  final SatelliteOpts opts;

  @visibleForTesting
  AuthState? authState;
  String? _authStateSubscription;

  // TODO(dart): Unused in typescript
  //DateTime? _lastSnapshotTimestamp;

  Timer? _pollingInterval;
  String? _potentialDataChangeSubscription;
  String? _connectivityChangeSubscription;

  late Throttle<DateTime> throttledSnapshot;

  int _lastAckdRowId = 0;
  @visibleForTesting
  int lastSentRowId = 0;
  LSN? _lsn;

  RelationsCache relations = {};

  SatelliteProcess({
    required this.dbName,
    required this.client,
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

    // TODO(dart): Maybe it would better to instantiate the throttle in the start function and cancel it in stop
    // Instead of creating it in the constructor and never cancelling it
    throttledSnapshot = Throttle(
      performSnapshot,
      opts.minSnapshotWindow,
    );
  }

  @override
  Future<ConnectionWrapper> start(AuthConfig authConfig) async {
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

    _authStateSubscription ??=
        notifier.subscribeToAuthStateChanges(_updateAuthState);

    // XXX establish replication connection,
    // validate auth state, etc here.

    // Request a snapshot whenever the data in our database potentially changes.
    _potentialDataChangeSubscription =
        notifier.subscribeToPotentialDataChanges((_) => throttledSnapshot());

    void connectivityChangeCallback(
      ConnectivityStateChangeNotification notification,
    ) {
      connectivityStateChange(notification.connectivityState);
    }

    // TODO(dart): Should the subscription be removed here, before assigning a new one?

    _connectivityChangeSubscription =
        notifier.subscribeToConnectivityStateChange(connectivityChangeCallback);

    // Start polling to request a snapshot every `pollingInterval` ms.
    _pollingInterval = Timer.periodic(
      opts.pollingInterval,
      (_) => throttledSnapshot(),
    );

    // Starting now!
    unawaited(Future(() => throttledSnapshot()));

    // Need to reload primary keys after schema migration
    relations = await getLocalRelations();

    _lastAckdRowId = int.parse(await getMeta('lastAckdRowId'));
    lastSentRowId = int.parse(await getMeta('lastSentRowId'));

    setClientListeners();
    client.resetOutboundLogPositions(
      numberToBytes(_lastAckdRowId),
      numberToBytes(lastSentRowId),
    );

    final lsnBase64 = await getMeta('lsn');
    if (lsnBase64.isNotEmpty) {
      logger.info("retrieved lsn $_lsn");
      _lsn = base64.decode(lsnBase64);
    } else {
      logger.info("no lsn retrieved from store");
    }

    final connectionFuture = _connectAndStartReplication();
    return ConnectionWrapper(
      connectionFuture: connectionFuture,
    );
  }

  @visibleForTesting
  Future<void> setAuthState(AuthState newAuthState) async {
    authState = newAuthState;
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
  }

  @override
  Future<void> stop() async {
    logger.info('stop polling');
    if (_pollingInterval != null) {
      _pollingInterval!.cancel();
      _pollingInterval = null;
    }

    if (_potentialDataChangeSubscription != null) {
      notifier.unsubscribeFromPotentialDataChanges(
        _potentialDataChangeSubscription!,
      );
      _potentialDataChangeSubscription = null;
    }

    await client.close();
  }

  @visibleForTesting
  Future<Either<SatelliteException, void>> connectivityStateChange(
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
          return const Right(null);
        }
      default:
        {
          throw Exception("unexpected connectivity state: $status");
        }
    }
  }

  Future<Either<SatelliteException, void>> _connectAndStartReplication() async {
    logger.info("connecting and starting replication");

    final _authState = authState;
    if (_authState == null) {
      throw Exception("trying to connect before authentication");
    }

    return client
        .connect()
        .then((_) => client.authenticate(_authState))
        .then((_) => client.startReplication(_lsn))
        .onError(
      (error, st) {
        logger.warning("couldn't start replication: $error");
        return const Right(null);
      },
    );
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
      await getEntries(since: enqueuedLogPos)
          .then((missing) => _replicateSnapshotChanges(missing));
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

  Future<Either<SatelliteException, void>> _replicateSnapshotChanges(
    List<OplogEntry> results,
  ) async {
    // TODO: Don't try replicating when outbound is inactive
    if (client.isClosed()) {
      return const Right(null);
    }

    final transactions = toTransactions(results, relations);
    for (final txn in transactions) {
      return client.enqueueTransaction(txn);
    }

    return const Right(null);
  }

  // Apply a set of incoming transactions against pending local operations,
  // applying conflict resolution rules. Takes all changes per each key before
  // merging, for local and remote operations.
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
            stmts.add(_deleteShadowTagsQuery(shadowEntry));

          default:
            stmts.add(_applyNonDeleteOperation(entryChanges, tablenameStr));
            stmts.add(_updateShadowTagsQuery(shadowEntry));
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
  Future<List<ShadowEntry>> getOplogShadowEntry({OplogEntry? oplog}) async {
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

    final shadowTags = await adapter.query(query);
    return shadowTags.map((e) {
      return ShadowEntry(
        namespace: e['namespace']! as String,
        tablename: e['tablename']! as String,
        primaryKey: e['primaryKey']! as String,
        tags: e['tags']! as String,
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
    return await adapter.run(
      Statement(
        updateTags,
        <Object?>[oplog.clearTags, oplog.rowid],
      ),
    );
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

    final updateArgs = <Object?>[
      timestamp.toISOStringUTC(),
      _lastAckdRowId.toString()
    ];
    await adapter.run(Statement(updateTimestamps, updateArgs));
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
    _lsn = lsn;
    final lsn_base64 = base64.encode(lsn);
    stmts.add(
      Statement(
        "UPDATE ${opts.metaTable.tablename} set value = ? WHERE key = ?",
        [lsn_base64, 'lsn'],
      ),
    );

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
        logger.info("apply incoming changes for LSN: $lsn");
        // assign timestamp to pending operations before apply
        await performSnapshot();
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
        tablenames.filter((t) => !newTables.contains(t)).toList();

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
        .map(
          (tablenameStr) => Statement(
            "UPDATE $triggers SET flag = ? WHERE tablename = ?",
            [if (flag) 1 else 0, tablenameStr],
          ),
        )
        .toList();
    return stmts;
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

  @visibleForTesting
  Future<void> setMeta(String key, Object? value) async {
    final meta = opts.metaTable.toString();

    final sql = "UPDATE $meta SET value = ? WHERE key = ?";
    final args = <Object?>[value, key];

    await adapter.run(Statement(sql, args));
  }

  @visibleForTesting
  Future<String> getMeta(String key) async {
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

    String clientId = await getMeta(clientIdKey);

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

  Future<void> _garbageCollectOplog(DateTime commitTimestamp) async {
    final isoString = commitTimestamp.toISOStringUTC();
    final String oplog = opts.oplogTable.tablename;
    final stmt = '''
      DELETE FROM $oplog
      WHERE timestamp = ?;
    ''';
    await adapter.run(Statement(stmt, <Object?>[isoString]));
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
