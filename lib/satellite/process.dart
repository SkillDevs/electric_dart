import 'dart:async';
import 'dart:convert';

import 'package:electric_client/auth/auth.dart';
import 'package:electric_client/electric/adapter.dart';
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

    // Need to reload primary keys after schema migration
    // For now, we do it only at initialization
    relations = await _getLocalRelations();

// TODO:
    // _lastAckdRowId = int.parse(await _getMeta('lastAckdRowId'));
    // _lastSentRowId = int.parse(await _getMeta('lastSentRowId'));

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
    final opLogEntries = fromTransaction(transaction, relations);

    await _apply(opLogEntries, transaction.lsn);
    _notifyChanges(opLogEntries);
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
    print("ACK UNIMPLEMENTED LSN $lsn IS ACK $isAck");
    // if (lsn < this._lastAckdRowId || (lsn > this._lastSentRowId && isAck)) {
    //   throw new Error('Invalid position')
    // }

    // const meta = this.opts.metaTable.toString()

    // const sql = ` UPDATE ${meta} SET value = ? WHERE key = ?`
    // const args = [
    //   `${lsn.toString()}`,
    //   isAck ? 'lastAckdRowId' : 'lastSentRowId',
    // ]

    // if (isAck) {
    //   const oplog = this.opts.oplogTable.toString()
    //   const del = `DELETE FROM ${oplog} WHERE rowid <= ?`
    //   const delArgs = [lsn]

    //   this._lastAckdRowId = lsn
    //   await this.adapter.runInTransaction(
    //     { sql, args },
    //     { sql: del, args: delArgs }
    //   )
    // } else {
    //   this._lastSentRowId = lsn
    //   await this.adapter.runInTransaction({ sql, args })
    // }
  }

  // Apply a set of incoming transactions against pending local operations,
  // applying conflict resolution rules. Takes all changes per each key
  // before merging, for local and remote operations.
  Future<void> _apply(List<OplogEntry> incoming, LSN lsn) async {
    print("APPLY MOCKED $incoming LSN $lsn");
    // assign timestamp to pending operations before apply
    //
    // Log.info(`apply incoming changes for LSN: ${lsn}`)
    // await this._performSnapshot()

    // const local = await this._getEntries()
    // const merged = this._mergeEntries(local, incoming)

    // const stmts: Statement[] = []
    // // switches off on transaction commit/abort
    // stmts.push({ sql: 'PRAGMA defer_foreign_keys = ON' })
    // // update lsn.
    // this._lsn = lsn
    // const lsn_base64 = base64.fromBytes(lsn)
    // stmts.push({
    //   sql: `UPDATE ${this.opts.metaTable.tablename} set value = ? WHERE key = ?`,
    //   args: [lsn_base64, 'lsn'],
    // })

    // for (const [tablenameStr, mapping] of Object.entries(merged)) {
    //   for (const entryChanges of Object.values(mapping)) {
    //     switch (entryChanges.optype) {
    //       case OPTYPES.delete:
    //         stmts.push(_applyDeleteOperation(entryChanges, tablenameStr))
    //         break

    //       default:
    //         stmts.push(_applyNonDeleteOperation(entryChanges, tablenameStr))
    //     }
    //   }
    // }

    // const tablenames = Object.keys(merged)

    // await this.adapter.runInTransaction(
    //   ...this._disableTriggers(tablenames),
    //   ...stmts,
    //   ...this._enableTriggers(tablenames)
    // )
  }

  // Perform a snapshot and notify which data actually changed.
  Future<void> _performSnapshot() async {
    print("Perform snapshot");

    // const oplog = this.opts.oplogTable.toString()
    // const timestamp = new Date().toISOString()

    // const updateTimestamps = `
    //   UPDATE ${oplog} set timestamp = ?
    //     WHERE rowid in (
    //       SELECT rowid FROM ${oplog}
    //           WHERE timestamp is NULL
    //           AND rowid > ?
    //       ORDER BY rowid ASC
    //       )
    // `

    // const updateArgs = [timestamp, `${this._lastAckdRowId}`]
    // await this.adapter.run({ sql: updateTimestamps, args: updateArgs })

    // const selectChanges = `
    //   SELECT * FROM ${oplog}
    //   WHERE timestamp = ? ORDER BY rowid ASC
    // `

    // const rows = await this.adapter.query({
    //   sql: selectChanges,
    //   args: [timestamp],
    // })
    // const results = rows as unknown as OplogEntry[]

    // const promises: Promise<void | SatelliteError>[] = []

    // if (results.length !== 0) {
    //   promises.push(this._notifyChanges(results))
    // }

    // if (!this.client.isClosed()) {
    //   const { enqueued } = this.client.getOutboundLogPositions()
    //   const enqueuedLogPos = bytesToNumber(enqueued)

    //   // TODO: take next N transactions instead of all
    //   const promise = this._getEntries(enqueuedLogPos).then((missing) =>
    //     this._replicateSnapshotChanges(missing)
    //   )
    //   promises.push(promise)
    // }

    // await Promise.all(promises)
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
    return "";

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
}
