import 'dart:async';
import 'dart:convert';

import 'package:electric_client/auth/auth.dart';
import 'package:electric_client/electric/adapter.dart' hide Transaction;
import 'package:electric_client/proto/satellite.pbenum.dart';
import 'package:electric_client/satellite/client.dart';
import 'package:electric_client/satellite/config.dart';
import 'package:electric_client/satellite/oplog.dart';
import 'package:electric_client/util/common.dart';
import 'package:electric_client/util/types.dart';

class Satellite {
  final ConsoleClient console;
  final Client client;
  final SatelliteConfig config;
  final DatabaseAdapter adapter;

  AuthState? _authState;
  LSN? _lsn;

  int _lastAckdRowId = 0;
  int _lastSentRowId = 0;

  RelationsCache relations = {};

  final SatelliteOpts opts;

  late void Function() _throttledSnapshot;

  Satellite({
    required this.console,
    required this.client,
    required this.config,
    required this.opts,
    required this.adapter,
  }) {
    _throttledSnapshot = throttle(
      _performSnapshot,
      Duration(milliseconds: opts.minSnapshotWindow),
    );
  }

  Future<void> start(AuthState? authState) async {
    await _setAuthState(authState);

    // Need to reload primary keys after schema migration
    // For now, we do it only at initialization
    relations = await _getLocalRelations();

    _lastAckdRowId = int.parse(await _getMeta('lastAckdRowId'));
    _lastSentRowId = int.parse(await _getMeta('lastSentRowId'));

    _lastAckdRowId = 0;
    _lastSentRowId = 0;

    setClientListeners();
    client.resetOutboundLogPositions(numberToBytes(_lastAckdRowId), numberToBytes(_lastSentRowId));

    final lsnBase64 = await _getMeta('lsn');
    if (lsnBase64.isNotEmpty) {
      print("retrieved lsn $_lsn");
      _lsn = base64.decode(lsnBase64);
    } else {
      print("no lsn retrieved from store");
    }

    await _connectAndStartReplication();
  }

  Future<void> _setAuthState(AuthState? authState) async {
    if (authState != null) {
      throw UnimplementedError();
      // this._authState = authState
    } else {
      final app = config.app;
      final env = config.env;
      final clientId = await _getClientId();
      final token = await _getMeta('token');
      final refreshToken = await _getMeta('refreshToken');

      _authState = AuthState(
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
      _applyTransaction(transaction);
    });
    // When a local transaction is sent, or an acknowledgement for
    // a remote transaction commit is received, we update lsn records.
    client.subscribeToAck((evt) async {
      final decoded = bytesToNumber(evt.lsn);
      await _ack(decoded, evt.ackType == AckType.remoteCommit);
    });
    client.subscribeToOutboundEvent(() => _throttledSnapshot());
  }

  Future<void> _applyTransaction(Transaction transaction) async {
    final origin = transaction.origin!;

    final opLogEntries = fromTransaction(transaction, relations);
    final commitTimestamp = DateTime.fromMicrosecondsSinceEpoch(transaction.commitTimestamp);
    await _applyTransactionInternal(origin, commitTimestamp, opLogEntries, transaction.lsn);
  }

  Future<void> _applyTransactionInternal(
      String origin, DateTime commitTimestamp, List<OplogEntry> opLogEntries, LSN lsn) async {
    await _apply(opLogEntries, origin, lsn);
    await _notifyChanges(opLogEntries);

    if (origin == _authState!.clientId) {
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

  // Apply a set of incoming transactions against pending local operations,
  // applying conflict resolution rules. Takes all changes per each key before
  // merging, for local and remote operations.
  Future<void> _apply(List<OplogEntry> incoming, String incoming_origin, LSN lsn) async {
    throw UnimplementedError();
  }

  Future<List<OplogEntry>> _getEntries({int? since}) async {
    since ??= _lastAckdRowId;
    final oplog = opts.oplogTable.toString();

    final selectEntries = '''
      SELECT * FROM $oplog
        WHERE timestamp IS NOT NULL
          AND rowid > ?
        ORDER BY rowid ASC
    ''';
    final rows = await adapter.query(Statement(selectEntries, [since]));
    return rows
        .map(
          (r) => OplogEntry(
            namespace: r['namespace'] as String,
            tablename: r['tablename'] as String,
            primaryKey: r['primaryKey'] as String,
            rowid: r['rowid'] as int,
            optype: opTypeStrToOpType(r['optype'] as String),
            timestamp: r['timestamp'] as String,
            newRow: r['newRow'] as String?,
            oldRow: r['oldRow'] as String?,
            clearTags: r['clearTags'] as String,
          ),
        )
        .toList();
  }

  // Perform a snapshot and notify which data actually changed.
  Future<void> _performSnapshot() async {
    print("Perform snapshot");
  }

  Future<void> _notifyChanges(List<OplogEntry> results) async {
    print('notify changes');
    // final ChangeAccumulator acc = {};

    // // Would it be quicker to do this using a second SQL query that
    // // returns results in `Change` format?!
    // const reduceFn = (acc: ChangeAccumulator, entry: OplogEntry) => {
    //   const qt = new QualifiedTablename(entry.namespace, entry.tablename)
    //   const key = qt.toString()

    //   if (key in acc) {
    //     const change: Change = acc[key]

    //     if (change.rowids === undefined) {
    //       change.rowids = []
    //     }

    //     change.rowids.push(entry.rowid)
    //   } else {
    //     acc[key] = {
    //       qualifiedTablename: qt,
    //       rowids: [entry.rowid],
    //     }
    //   }

    //   return acc
    // }

    // const changes = Object.values(results.reduce(reduceFn, acc))
    // this.notifier.actuallyChanged(this.dbName, changes)
  }

  Future<void> _connectAndStartReplication() async {
    print("connecting and starting replication");

    final authState = _authState;
    if (authState == null) {
      throw Exception("trying to connect before authentication");
    }

// TODO: Connect to client
    return client
        .connect()
        .then((_) => refreshAuthState(authState))
        .then((freshAuthState) => client.authenticate(freshAuthState))
        .then((_) => client.startReplication(_lsn))
        .then((_) => null)
        .onError(
      (error, st) {
        print("couldn't start replication: $error");
        return null;
      },
    );
  }

  FutureOr<AuthState> refreshAuthState(AuthState authState) async {
    try {
      final tokenResponse = await console.token(
        TokenRequest(
          app: authState.app,
          env: authState.env,
          clientId: authState.clientId,
        ),
      );
      await _setMeta('token', tokenResponse.token);
      // TODO: Bug
      await _setMeta('refreshToken', tokenResponse.token);

      return AuthState(
        app: authState.app,
        env: authState.env,
        clientId: authState.clientId,
        token: tokenResponse.token,
        refreshToken: tokenResponse.refreshToken,
      );
    } catch (error) {
      print("unable to refresh token: $error");
    }

    return authState;
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

  Future<void> _setMeta(String key, Object? value) async {
    final meta = opts.metaTable.toString();

    final sql = "UPDATE $meta SET value = ? WHERE key = ?";
    final args = <Object?>[value, key];

    await adapter.run(Statement(sql, args));
  }

  //   async _connectAndStartReplication(): Promise<void | SatelliteError> {
  //   Log.info(`connecting and starting replication`)

  //   if (!this._authState) {
  //     throw new Error(`trying to connect before authentication`)
  //   }
  //   const authState = this._authState

  //   return this.client
  //     .connect()
  //     .then(() => this.refreshAuthState(authState))
  //     .then((freshAuthState) => this.client.authenticate(freshAuthState))
  //     .then(() => this.client.startReplication(this._lsn))
  //     .catch((error) => {
  //       Log.warn(`couldn't start replication: ${error}`)
  //     })
  // }

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
