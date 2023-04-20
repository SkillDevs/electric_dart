import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:electric_client/auth/auth.dart';
import 'package:electric_client/notifiers/notifiers.dart' hide Change;
import 'package:electric_client/proto/satellite.pb.dart';
import 'package:electric_client/satellite/config.dart';
import 'package:electric_client/satellite/satellite.dart';
import 'package:electric_client/sockets/sockets.dart';
import 'package:electric_client/util/common.dart';
import 'package:electric_client/util/debug/debug.dart';
import 'package:electric_client/util/extension.dart';
import 'package:electric_client/util/proto.dart';
import 'package:electric_client/util/types.dart';
import 'package:events_emitter/events_emitter.dart';
import 'package:fpdart/fpdart.dart';
import 'package:retry/retry.dart' as retry_lib;

class IncomingHandler {
  final Object? Function(Object?) handle;
  final bool isRpc;

  IncomingHandler({required this.handle, required this.isRpc});
}

class DecodedMessage {
  final Object msg;
  final SatMsgType msgType;

  DecodedMessage(this.msg, this.msgType);
}

class SatelliteClient extends EventEmitter implements Client {
  final String dbName;
  final SocketFactory socketFactory;
  final SatelliteClientOpts opts;
  final Notifier notifier;

  Socket? socket;

  late Replication inbound;
  late Replication outbound;

  Throttle<void>? throttledPushTransaction;
  void Function(Uint8List bytes)? socketHandler;

  SatelliteClient({
    required this.dbName,
    required this.socketFactory,
    required this.notifier,
    required this.opts,
  }) {
    inbound = resetReplication(null, null, null);
    outbound = resetReplication(null, null, null);
  }

  Replication resetReplication(
    LSN? enqueued,
    LSN? ack,
    ReplicationStatus? isReplicating,
  ) {
    return Replication(
      authenticated: false,
      isReplicating: isReplicating ?? ReplicationStatus.stopped,
      relations: {},
      transactions: [],
      ackLsn: ack,
      enqueuedLsn: enqueued,
    );
  }

  DecodedMessage toMessage(Uint8List data) {
    final code = data[0];
    final type = getMsgFromCode(code);

    if (type == null) {
      throw SatelliteException(
        SatelliteErrorCode.unexpectedMessageType,
        "$code",
      );
    }

    return DecodedMessage(decodeMessage(data.sublist(1), type), type);
  }

  IncomingHandler getIncomingHandlerForMessage(SatMsgType msgType) {
    switch (msgType) {
      case SatMsgType.authResp:
        return IncomingHandler(
          handle: (v) => handleAuthResp(v),
          isRpc: true,
        );

      case SatMsgType.inStartReplicationReq:
        return IncomingHandler(
          handle: (v) =>
              handleInStartReplicationReq(v! as SatInStartReplicationReq),
          isRpc: false,
        );
      case SatMsgType.inStartReplicationResp:
        return IncomingHandler(
          handle: (v) => handleStartResp(v! as SatInStartReplicationResp),
          isRpc: true,
        );

      case SatMsgType.inStopReplicationReq:
        return IncomingHandler(
          handle: (v) => handleStopReq(v! as SatInStopReplicationReq),
          isRpc: false,
        );

      case SatMsgType.inStopReplicationResp:
        return IncomingHandler(
          handle: (v) => handleStopResp(v! as SatInStopReplicationResp),
          isRpc: true,
        );

      case SatMsgType.pingReq:
        return IncomingHandler(
          handle: (v) => handlePingReq(),
          isRpc: true,
        );

      case SatMsgType.pingResp:
        return IncomingHandler(
          handle: (v) => handlePingResp(v),
          isRpc: false,
        );

      case SatMsgType.opLog:
        return IncomingHandler(
          handle: (v) => handleTransaction(v! as SatOpLog),
          isRpc: false,
        );

      case SatMsgType.relation:
        return IncomingHandler(
          handle: (v) => handleRelation(v! as SatRelation),
          isRpc: false,
        );

      case SatMsgType.errorResp:
        return IncomingHandler(
          handle: (v) => handleErrorResp(v! as SatErrorResp),
          isRpc: false,
        );

      case SatMsgType.authReq:
      case SatMsgType.migrationNotification:
        throw UnimplementedError();
    }
  }

  @override
  Future<Either<SatelliteException, void>> connect({
    bool Function(Object error, int attempt)? retryHandler,
  }) async {
    Future<void> _attemptBody() {
      final Completer<void> connectCompleter = Completer();

      // TODO: ensure any previous socket is closed, or reject
      if (this.socket != null) {
        throw SatelliteException(
          SatelliteErrorCode.unexpectedState,
          'a socket already exist. ensure it is closed before reconnecting.',
        );
      }
      final socket = socketFactory.create();
      this.socket = socket;

      socket.onceConnect(() {
        if (this.socket == null) {
          throw SatelliteException(
            SatelliteErrorCode.unexpectedState,
            'socket got unassigned somehow',
          );
        }
        socketHandler = (Uint8List message) => handleIncoming(message);
        notifier.connectivityStateChange(dbName, ConnectivityState.connected);
        socket.onMessage(socketHandler!);
        socket.onError((error) {
          notifier.connectivityStateChange(dbName, ConnectivityState.error);
        });
        socket.onClose(() {
          notifier.connectivityStateChange(
            dbName,
            ConnectivityState.disconnected,
          );
        });
        connectCompleter.complete();
      });

      socket.onceError((error) {
        // print("Once Error $error");
        this.socket = null;
        notifier.connectivityStateChange(
          dbName,
          ConnectivityState.disconnected,
        );
        if (!connectCompleter.isCompleted) {
          connectCompleter.completeError(error);
        }
      });

      final host = opts.host;
      final port = opts.port;
      final ssl = opts.ssl;
      final url = "${ssl ? 'wss' : 'ws'}://$host:$port/ws";
      socket.open(ConnectionOptions(url));

      return connectCompleter.future;
    }

    int retryAttempt = 0;
    await retry_lib.retry(
      () {
        retryAttempt++;
        return _attemptBody();
      },
      maxAttempts: 10,
      maxDelay: const Duration(milliseconds: 100),
      delayFactor: const Duration(milliseconds: 100),
      retryIf: (e) {
        if (retryHandler != null) {
          return retryHandler(e, retryAttempt);
        }
        return true;
      },
    );

    return const Right(null);
  }

  @override
  Future<Either<SatelliteException, void>> close() async {
    logger.info('closing client');

    outbound = resetReplication(outbound.enqueuedLsn, outbound.ackLsn, null);
    inbound = resetReplication(
      inbound.enqueuedLsn,
      inbound.ackLsn,
      null,
    );

    socketHandler = null;
    removeAllListeners();

    if (socket != null) {
      socket!.closeAndRemoveListeners();
      socket = null;
    }

    return const Right(null);
  }

  @override
  bool isClosed() {
    return socketHandler == null;
  }

  void removeAllListeners() {
    // Prevent concurrent modification
    for (final listener in [...listeners]) {
      removeEventListener(listener);
    }
  }

  void handleIncoming(Uint8List data) {
    late final DecodedMessage messageInfo;
    try {
      // TODO(dart): Use union instead of throwing
      messageInfo = toMessage(data);
    } catch (e) {
      // this.emit('error', messageOrError)
      emit("error", messageInfo);
      return;
    }

    logger.info("Received message ${messageInfo.msg.runtimeType}");
    final handler = getIncomingHandlerForMessage(messageInfo.msgType);
    final response = handler.handle(messageInfo.msg);

    if (handler.isRpc) {
      emit("rpc_response", response);
    }
  }

  @override
  Future<Either<SatelliteException, AuthResponse>> authenticate(
    AuthState authState,
  ) async {
    final headers = [
      SatAuthHeaderPair(
        key: SatAuthHeader.PROTO_VERSION,
        value: getProtocolVersion(),
      ),
    ];
    final request = SatAuthReq(
      id: authState.clientId,
      token: authState.token,
      headers: headers,
    );
    return Right(await rpc<AuthResponse>(request));
  }

  @override
  void subscribeToTransactions(
    Future<void> Function(Transaction transaction) callback,
  ) {
    on<TransactionEvent>('transaction', (txnEvent) async {
      // move callback execution outside the message handling path
      await callback(txnEvent.transaction);
      txnEvent.ackCb();
    });
  }

  @override
  Either<SatelliteException, void> enqueueTransaction(Transaction transaction) {
    if (outbound.isReplicating != ReplicationStatus.active) {
      throw SatelliteException(
        SatelliteErrorCode.replicationNotStarted,
        'enqueuing a transaction while outbound replication has not started',
      );
    }

    outbound.transactions.add(transaction);
    outbound.enqueuedLsn = transaction.lsn;

    if (throttledPushTransaction != null) {
      throttledPushTransaction!.call();
    }

    return const Right(null);
  }

  @override
  Future<Either<SatelliteException, void>> startReplication(LSN? lsn) async {
    if (inbound.isReplicating != ReplicationStatus.stopped) {
      throw SatelliteException(
        SatelliteErrorCode.replicationAlreadyStarted,
        "replication already started",
      );
    }

    inbound = resetReplication(lsn, lsn, ReplicationStatus.starting);

    late final SatInStartReplicationReq request;
    if (lsn == null || lsn.isEmpty) {
      logger.info("no previous LSN, start replication with option FIRST_LSN");

      request = SatInStartReplicationReq(
        options: [SatInStartReplicationReq_Option.FIRST_LSN],
      );
    } else {
      logger.info("starting replication with lsn: ${base64.encode(lsn)}");
      request = SatInStartReplicationReq(lsn: lsn);
    }

    await rpc<void>(request);

    return const Right(null);
  }

  @override
  Future<Either<SatelliteException, void>> stopReplication() async {
    if (inbound.isReplicating != ReplicationStatus.active) {
      return Future.error(
        SatelliteException(
          SatelliteErrorCode.replicationNotStarted,
          "replication not active",
        ),
      );
    }

    inbound.isReplicating = ReplicationStatus.stopping;
    final request = SatInStopReplicationReq();
    await rpc<void>(request);

    return const Right(null);
  }

  void sendMessage(Object request) {
    logger.info("Sending message $request");
    final _socket = socket;
    if (_socket == null) {
      throw SatelliteException(
        SatelliteErrorCode.unexpectedState,
        'trying to send message, but no socket exists',
      );
    }
    final msgType = getTypeFromSatObject(request);
    if (msgType == null) {
      throw SatelliteException(
        SatelliteErrorCode.unexpectedMessageType,
        "${request.runtimeType}",
      );
    }

    final buffer = encodeSocketMessage(msgType, request);
    _socket.write(buffer);
  }

  Future<T> rpc<T>(Object request) async {
    Timer? timer;
    EventListener? rpcRespListener;
    EventListener? errorListener;
    final Completer<T> completer = Completer();

    try {
      timer = Timer(Duration(milliseconds: opts.timeout), () {
        final error = SatelliteException(
          SatelliteErrorCode.timeout,
          "${request.runtimeType}",
        );
        completer.completeError(error);
      });

      // reject on any error
      errorListener = on('error', (error) {
        errorListener?.cancel();
        errorListener = null;
        completer.completeError(error as Object);
      });

      rpcRespListener = on('rpc_response', (resp) {
        rpcRespListener?.cancel();
        rpcRespListener = null;
        completer.complete(resp as T);
      });

      sendMessage(request);

      return await completer.future;
    } finally {
      timer?.cancel();
      errorListener?.cancel();
      rpcRespListener?.cancel();
    }
  }

  @override
  void resetOutboundLogPositions(LSN sent, LSN ack) {
    outbound = resetReplication(sent, ack, null);
  }

  @override
  LogPositions getOutboundLogPositions() {
    return LogPositions(
      ack: outbound.ackLsn ?? kDefaultLogPos,
      enqueued: outbound.enqueuedLsn ?? kDefaultLogPos,
    );
  }

  AuthResponse handleAuthResp(Object? message) {
    Object? error;
    String? serverId;
    if (message is SatAuthResp) {
      serverId = message.id;
      inbound.authenticated = true;
    } else if (message is SatErrorResp) {
      error = SatelliteException(
        SatelliteErrorCode.authError,
        "${message.errorType}",
      );
    } else {
      throw StateError("Unexpected message $message");
    }

    return AuthResponse(serverId, error);
  }

  void handleStartResp(SatInStartReplicationResp value) {
    if (inbound.isReplicating == ReplicationStatus.starting) {
      inbound.isReplicating = ReplicationStatus.active;
    } else {
      emit(
        "error",
        SatelliteException(
          SatelliteErrorCode.unexpectedState,
          "unexpected state ${inbound.isReplicating} handling 'start' response",
        ),
      );
    }
  }

  void handleInStartReplicationReq(SatInStartReplicationReq message) {
    logger.info("received replication request $message");
    if (outbound.isReplicating == ReplicationStatus.stopped) {
      final replication = outbound.clone();
      if (message.options.firstWhereOrNull(
            (o) => o == SatInStartReplicationReq_Option.LAST_ACKNOWLEDGED,
          ) ==
          null) {
        final lsnList = Uint8List.fromList(message.lsn);
        replication.ackLsn = lsnList;
        replication.enqueuedLsn = lsnList;
      }
      if (message.options.firstWhereOrNull(
            (o) => o == SatInStartReplicationReq_Option.FIRST_LSN,
          ) ==
          null) {
        replication.ackLsn = kDefaultLogPos;
        replication.enqueuedLsn = kDefaultLogPos;
      }

      outbound = resetReplication(
        replication.enqueuedLsn,
        replication.ackLsn,
        ReplicationStatus.active,
      );

      throttledPushTransaction =
          Throttle(pushTransactions, Duration(milliseconds: opts.pushPeriod));

      final response = SatInStartReplicationResp();
      sendMessage(response);
      emit('outbound_started', replication.enqueuedLsn);
    } else {
      final response = SatErrorResp(
        errorType: SatErrorResp_ErrorCode.REPLICATION_FAILED,
      );
      sendMessage(response);

      emit(
        'error',
        SatelliteException(
          SatelliteErrorCode.unexpectedState,
          "unexpected state ${outbound.isReplicating} handling 'start' request",
        ),
      );
    }
  }

  void pushTransactions() {
    if (outbound.isReplicating != ReplicationStatus.active) {
      throw SatelliteException(
        SatelliteErrorCode.replicationNotStarted,
        'sending a transaction while outbound replication has not started',
      );
    }

    while (outbound.transactions.isNotEmpty) {
      final next = outbound.transactions.removeAt(0);

      // TODO: divide into SatOpLog array with max size
      sendMissingRelations(next, outbound);
      final SatOpLog satOpLog = transactionToSatOpLog(next);

      // console.log(`sending message with lsn ${JSON.stringify(next.lsn)}`)
      sendMessage(satOpLog);
      emit<AckLsnEvent>('ack_lsn', AckLsnEvent(next.lsn, AckType.localSend));
    }
  }

  @override
  EventListener<AckLsnEvent> subscribeToAck(AckCallback callback) {
    return on<AckLsnEvent>('ack_lsn', callback);
  }

  @override
  void unsubscribeToAck(EventListener<AckLsnEvent> eventListener) {
    removeEventListener(eventListener);
  }

  @override
  EventListener<void> subscribeToOutboundEvent(void Function() callback) {
    return on<void>('outbound_started', (_) => callback());
  }

  @override
  void unsubscribeToOutboundEvent(EventListener<void> eventListener) {
    removeEventListener(eventListener);
  }

  void sendMissingRelations(Transaction transaction, Replication replication) {
    for (var change in transaction.changes) {
      final relation = change.relation;
      if (!outbound.relations.containsKey(relation.id)) {
        replication.relations[relation.id] = relation;

        final satRelation = SatRelation(
          relationId: relation.id,
          schemaName: relation.schema, // TODO
          tableName: relation.table,
          tableType: relation.tableType,
          columns: relation.columns
              .map((c) => SatRelationColumn(name: c.name, type: c.type)),
        );

        sendMessage(satRelation);
      }
    }
  }

  void handleStopReq(SatInStopReplicationReq value) {
    if (outbound.isReplicating == ReplicationStatus.active) {
      outbound.isReplicating = ReplicationStatus.stopped;

      if (throttledPushTransaction != null) {
        throttledPushTransaction!.cancel();
        throttledPushTransaction = null;
      }

      final response = SatInStopReplicationResp();
      sendMessage(response);
    } else {
      final response = SatErrorResp(
        errorType: SatErrorResp_ErrorCode.REPLICATION_FAILED,
      );
      sendMessage(response);

      emit(
        'error',
        SatelliteException(
          SatelliteErrorCode.unexpectedState,
          "unexpected state ${inbound.isReplicating} handling 'stop' request",
        ),
      );
    }
  }

  void handleStopResp(SatInStopReplicationResp value) {
    if (inbound.isReplicating == ReplicationStatus.stopping) {
      inbound.isReplicating = ReplicationStatus.stopped;
    } else {
      emit(
        'error',
        SatelliteException(
          SatelliteErrorCode.unexpectedState,
          "unexpected state ${inbound.isReplicating} handling 'stop' response",
        ),
      );
    }
  }

  void handlePingReq() {
    logger.info("respond to ping with last ack ${inbound.ackLsn}");
    final pong = SatPingResp(lsn: inbound.ackLsn);
    sendMessage(pong);
  }

  void handlePingResp(Object? message) {
    if (message is SatPingResp) {
      if (message.lsn.isNotEmpty) {
        outbound.ackLsn = Uint8List.fromList(message.lsn);
        emit('ack_lsn', AckLsnEvent(message.lsn, AckType.remoteCommit));
      }
    } else {
      throw StateError("Unexpected ping resp message");
    }
  }

  void handleRelation(SatRelation message) {
    if (inbound.isReplicating != ReplicationStatus.active) {
      emit(
        'error',
        SatelliteException(
          SatelliteErrorCode.unexpectedState,
          "unexpected state ${inbound.isReplicating} handling 'relation' message",
        ),
      );
      return;
    }

    final relation = Relation(
      id: message.relationId,
      schema: message.schemaName,
      table: message.tableName,
      tableType: message.tableType,
      columns: message.columns
          .map((c) => RelationColumn(name: c.name, type: c.type))
          .toList(),
    );

    inbound.relations[relation.id] = relation;
  }

  void handleTransaction(SatOpLog message) {
    processOpLogMessage(message, inbound);
  }

  void handleErrorResp(SatErrorResp error) {
    emit(
      'error',
      Exception("server replied with error code: ${error.errorType}"),
    );
  }

  void processOpLogMessage(
    SatOpLog opLogMessage,
    Replication replication,
  ) {
    //print("PROCESS! ${opLogMessage.ops.length}");
    for (var op in opLogMessage.ops) {
      if (op.hasBegin()) {
        final transaction = Transaction(
          commitTimestamp: op.begin.commitTimestamp,
          lsn: op.begin.lsn,
          changes: [],
          origin: op.begin.origin,
        );
        replication.transactions.add(transaction);
      }

      final lastTxnIdx = replication.transactions.length - 1;
      if (op.hasCommit()) {
        final lastTx = replication.transactions[lastTxnIdx];
        final Transaction transaction = Transaction(
          commitTimestamp: lastTx.commitTimestamp,
          lsn: lastTx.lsn,
          changes: lastTx.changes,
          origin: lastTx.origin,
        );
        // in the future, emitting this event can be decoupled
        emit<TransactionEvent>(
          'transaction',
          TransactionEvent(
            transaction,
            () => inbound.ackLsn = transaction.lsn,
          ),
        );
        replication.transactions.removeAt(lastTxnIdx);
      }
      if (op.hasInsert()) {
        final rid = op.insert.relationId;
        final rel = replication.relations[rid];

        if (rel == null) {
          throw SatelliteException(
            SatelliteErrorCode.protocolViolation,
            "missing relation ${op.insert.relationId} for incoming operation",
          );
        }

        final change = Change(
          relation: rel,
          type: ChangeType.insert,
          record: deserializeRow(op.insert.getNullableRowData(), rel),
          tags: op.insert.tags,
        );

        replication.transactions[lastTxnIdx].changes.add(change);
      }

      if (op.hasUpdate()) {
        final rid = op.update.relationId;
        final rel = replication.relations[rid];
        final rowData = op.update.getNullableRowData();
        final oldRowData = op.update.getNullableOldRowData();

        if (rel == null) {
          throw SatelliteException(
            SatelliteErrorCode.protocolViolation,
            'missing relation for incoming operation',
          );
        }

        final change = Change(
          relation: rel,
          type: ChangeType.update,
          record: deserializeRow(rowData, rel),
          oldRecord: deserializeRow(oldRowData, rel),
          tags: op.update.tags,
        );

        replication.transactions[lastTxnIdx].changes.add(change);
      }

      if (op.hasDelete()) {
        final rid = op.delete.relationId;
        final rel = replication.relations[rid];
        if (rel == null) {
          throw SatelliteException(
            SatelliteErrorCode.protocolViolation,
            'missing relation for incoming operation',
          );
        }

        final oldRowData = op.delete.getNullableOldRowData();

        final change = Change(
          relation: rel,
          type: ChangeType.delete,
          oldRecord: deserializeRow(oldRowData, rel),
          tags: op.delete.tags,
        );
        replication.transactions[lastTxnIdx].changes.add(change);
      }
    }
  }

  SatOpLog transactionToSatOpLog(Transaction transaction) {
    final List<SatTransOp> ops = [
      SatTransOp(
        begin: SatOpBegin(
          commitTimestamp: transaction.commitTimestamp,
          lsn: transaction.lsn,
        ),
      ),
    ];

    for (var change in transaction.changes) {
      //let txOp, oldRecord, record;
      final relation = outbound.relations[change.relation.id]!;
      final tags = change.tags;

      SatOpRow? oldRecord;
      SatOpRow? record;

      if (change.oldRecord != null && change.oldRecord!.isNotEmpty) {
        oldRecord = serializeRow(change.oldRecord!, relation);
      }
      if (change.record != null && change.record!.isNotEmpty) {
        record = serializeRow(change.record!, relation);
      }

      late final SatTransOp changeOp;
      switch (change.type) {
        case ChangeType.delete:
          changeOp = SatTransOp(
            delete: SatOpDelete(
              oldRowData: oldRecord,
              relationId: relation.id,
              tags: tags,
            ),
          );
          break;
        case ChangeType.insert:
          changeOp = SatTransOp(
            insert: SatOpInsert(
              rowData: record,
              relationId: relation.id,
              tags: tags,
            ),
          );
          break;
        case ChangeType.update:
          changeOp = SatTransOp(
            update: SatOpUpdate(
              rowData: record,
              oldRowData: oldRecord,
              relationId: relation.id,
              tags: tags,
            ),
          );
          break;
      }
      ops.add(changeOp);
    }

    ops.add(SatTransOp(commit: SatOpCommit()));
    return SatOpLog(ops: ops);
  }
}

SatOpRow serializeRow(Record rec, Relation relation) {
  int recordNumColumn = 0;
  final recordNullBitMask =
      Uint8List(calculateNumBytes(relation.columns.length));
  final recordValues = relation.columns.fold<List<List<int>>>(
    [],
    (List<List<int>> acc, RelationColumn c) {
      if (rec[c.name] != null) {
        // TODO(dart): Review this. This can be a number and it's treated as a string
        acc.add(serializeColumnData(rec[c.name]!.toString()));
      } else {
        acc.add(serializeNullData());
        setMaskBit(recordNullBitMask, recordNumColumn);
      }
      recordNumColumn = recordNumColumn + 1;
      return acc;
    },
  );
  return SatOpRow(
    nullsBitmask: recordNullBitMask,
    values: recordValues,
  );
}

Record? deserializeRow(
  SatOpRow? row,
  Relation relation,
) {
  final _row = row;
  if (_row == null) {
    return null;
  }
  return Map.fromEntries(
    relation.columns.mapIndexed((i, c) {
      Object? value;
      if (getMaskBit(_row.nullsBitmask, i) == 1) {
        value = null;
      } else {
        value = deserializeColumnData(_row.values[i], c);
      }
      return MapEntry(c.name, value);
    }),
  );
}

void setMaskBit(List<int> array, int indexFromStart) {
  final byteIndex = (indexFromStart / 8).floor();
  final bitIndex = 7 - (indexFromStart % 8);

  final mask = 0x01 << bitIndex;
  array[byteIndex] = array[byteIndex] | mask;
}

int getMaskBit(List<int> array, int indexFromStart) {
  if (array.isEmpty) return 0;
  final byteIndex = (indexFromStart / 8).floor();
  final bitIndex = 7 - (indexFromStart % 8);

  return (array[byteIndex] >>> bitIndex) & 0x01;
}

int calculateNumBytes(int columnNum) {
  final rem = columnNum % 8;
  if (rem == 0) {
    return (columnNum / 8).floor();
  } else {
    return (1 + (columnNum - rem) / 8).floor();
  }
}

Object deserializeColumnData(
  List<int> column,
  RelationColumn columnInfo,
) {
  final columnType = columnInfo.type.toUpperCase();
  switch (columnType) {
    case 'CHAR':
    case 'TEXT':
    case 'UUID':
    case 'VARCHAR':
      return TypeDecoder.text(column);
    case 'FLOAT4':
    case 'FLOAT8':
    case 'INT':
    case 'INT2':
    case 'INT4':
    case 'INT8':
    case 'INTEGER':
      return num.parse(TypeDecoder.text(column));
  }
  throw SatelliteException(
    SatelliteErrorCode.unknownDataType,
    "can't deserialize ${columnInfo.type}",
  );
}

// All values serialized as textual representation
List<int> serializeColumnData(String column) {
  return TypeEncoder.text(column);
}

List<int> serializeNullData() {
  return TypeEncoder.text('');
}

Uint8List encodeSocketMessage(SatMsgType msgType, Object msg) {
  final typeEncoded = getSizeBuf(msgType);
  final msgEncoded = encodeMessage(msg);
  final totalBufLen = typeEncoded.length + msgEncoded.length;

  final buffer = Uint8List(totalBufLen);
  buffer.setRange(0, 1, typeEncoded);
  buffer.setRange(1, totalBufLen, msgEncoded);

  return buffer;
}
