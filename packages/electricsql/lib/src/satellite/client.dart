import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:electricsql/src/auth/auth.dart';
import 'package:electricsql/src/notifiers/notifiers.dart' hide Change;
import 'package:electricsql/src/proto/satellite.pb.dart';
import 'package:electricsql/src/satellite/config.dart';
import 'package:electricsql/src/satellite/rpc.dart';
import 'package:electricsql/src/satellite/satellite.dart';
import 'package:electricsql/src/satellite/shapes/cache.dart';
import 'package:electricsql/src/satellite/shapes/types.dart';
import 'package:electricsql/src/sockets/sockets.dart';
import 'package:electricsql/src/util/bitmask_helpers.dart';
import 'package:electricsql/src/util/common.dart';
import 'package:electricsql/src/util/debug/debug.dart';
import 'package:electricsql/src/util/extension.dart';
import 'package:electricsql/src/util/proto.dart';
import 'package:electricsql/src/util/types.dart';
import 'package:events_emitter/events_emitter.dart';
import 'package:synchronized/synchronized.dart';

typedef IncomingHandler = void Function(Object?);

class DecodedMessage {
  final Object msg;
  final SatMsgType msgType;

  DecodedMessage(this.msg, this.msgType);
}

const subscriptionError = {
  SatelliteErrorCode.unexpectedSubscriptionState,
  SatelliteErrorCode.subscriptionError,
  SatelliteErrorCode.subscriptionAlreadyExists,
  SatelliteErrorCode.subscriptionIdAlreadyExists,
  SatelliteErrorCode.subscriptionNotFound,
  SatelliteErrorCode.shapeDeliveryError,
};

class SatelliteClient extends EventEmitter implements Client {
  final SocketFactory socketFactory;
  final SatelliteClientOpts opts;

  Socket? socket;

  late Replication<Transaction> inbound;
  late Replication<DataTransaction> outbound;

  // can only handle a single subscription at a time
  final SubscriptionsDataCache _subscriptionsDataCache =
      SubscriptionsDataCache();

  void Function(Uint8List bytes)? socketHandler;
  Throttle<void>? throttledPushTransaction;

  late RPC rpcClient;
  late RootApi _service;
  Lock _incomingLock = Lock();

  List<String> allowedMutexedRpcResponses = [];

  late final Map<String, Future<Object> Function(Object)>
      handlerForRpcRequests = {
    'startReplication': (o) => handleStartReq(o as SatInStartReplicationReq),
    'stopReplication': (o) => handleStopReq(o as SatInStopReplicationReq),
  };

  SatelliteClient({
    // ignore: avoid_unused_constructor_parameters
    required DbName dbName,
    required this.socketFactory,
    // ignore: avoid_unused_constructor_parameters
    required Notifier notifier,
    required this.opts,
  }) {
    inbound = resetReplication<Transaction>(null, null);
    outbound = resetReplication<DataTransaction>(null, null);

    rpcClient = RPC(
      sendMessage,
      opts.timeout,
      logger,
    );

    _service = withRpcRequestLogging(
      RootApi(rpcClient),
      logger,
    );
  }

  Replication<TransactionType> resetReplication<TransactionType>(
    LSN? lastLsn,
    ReplicationStatus? isReplicating,
  ) {
    return Replication<TransactionType>(
      authenticated: false,
      isReplicating: isReplicating ?? ReplicationStatus.stopped,
      relations: {},
      transactions: [],
      lastLsn: lastLsn,
    );
  }

  IncomingHandler getIncomingHandlerForMessage(SatMsgType msgType) {
    switch (msgType) {
      case SatMsgType.opLog:
        return (v) => handleTransaction(v! as SatOpLog);
      case SatMsgType.relation:
        return (msg) => handleRelation(msg! as SatRelation);
      case SatMsgType.errorResp:
        return (v) => handleErrorResp(v! as SatErrorResp);
      case SatMsgType.subsDataError:
        return (v) => handleSubscriptionError(v! as SatSubsDataError);
      case SatMsgType.subsDataBegin:
        return (v) => handleSubscriptionDataBegin(v! as SatSubsDataBegin);
      case SatMsgType.subsDataEnd:
        return (v) => handleSubscriptionDataEnd(v! as SatSubsDataEnd);
      case SatMsgType.shapeDataBegin:
        return (v) => handleShapeDataBegin(v! as SatShapeDataBegin);
      case SatMsgType.shapeDataEnd:
        return (v) => handleShapeDataEnd(v! as SatShapeDataEnd);
      case SatMsgType.rpcResponse:
        return (v) => rpcClient.handleResponse(v! as SatRpcResponse);
      case SatMsgType.rpcRequest:
        return (v) => handleRpcRequest(v! as SatRpcRequest);
    }
  }

  @override
  Future<void> connect() async {
    if (!isClosed()) {
      close();
    }

    final completer = Completer<void>();

    final socket = socketFactory.create(kProtocolVsn);
    this.socket = socket;

    void onceError(Object error) {
      close();
      completer.completeError(error);
    }

    void onceConnect() {
      if (this.socket == null) {
        throw SatelliteException(
          SatelliteErrorCode.unexpectedState,
          'socket got unassigned somehow',
        );
      }
      socket.removeErrorListener(onceError);
      socketHandler = (Uint8List message) => handleIncoming(message);
      socket.onMessage(socketHandler!);
      socket.onError((error) {
        if (listenerCount('error') == 0) {
          close();
          logger.error(
            'socket error but no listener is attached: $error',
          );
        }
        emit('error', error);
      });
      socket.onClose(() {
        close();
        if (listenerCount('error') == 0) {
          logger.error('socket closed but no listener is attached');
        }
        emit(
          'error',
          SatelliteException(SatelliteErrorCode.socketError, 'socket closed'),
        );
      });

      completer.complete();
    }

    socket.onceError(onceError);
    socket.onceConnect(onceConnect);

    final host = opts.host;
    final port = opts.port;
    final ssl = opts.ssl;
    final url = "${ssl ? 'wss' : 'ws'}://$host:$port/ws";
    socket.open(ConnectionOptions(url));

    return completer.future;
  }

  int listenerCount(String event) {
    return listeners.where((l) => l.type == event).length;
  }

  @override
  void close() {
    outbound = resetReplication(outbound.lastLsn, null);
    inbound = resetReplication(inbound.lastLsn, null);

    socketHandler = null;

    if (socket != null) {
      socket!.closeAndRemoveListeners();
      socket = null;
    }
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

  Future<T> delayIncomingMessages<T>(Future<T> Function() fn,
      {required List<String> allowedRpcResponses}) {
    return _incomingLock.synchronized(() async {
      allowedMutexedRpcResponses = allowedRpcResponses;
      try {
        return await fn();
      } finally {
        allowedMutexedRpcResponses = [];
      }
    });
  }

  Future<void> handleIncoming(Uint8List data) async {
    try {
      final messageInfo = toMessage(data);
      final message = messageInfo.msg;

      if (_incomingLock.inLock &&
          !(message is SatRpcResponse &&
              allowedMutexedRpcResponses.contains(message.method))) {
        // Wait for unlock
        await _incomingLock.synchronized(() {});
      }

      if (logger.levelImportance <= Level.debug.value) {
        logger.debug('[proto] recv: ${msgToString(messageInfo.msg)}');
      }

      print("incoming message type: ${messageInfo.msgType} $message");
      final handler = getIncomingHandlerForMessage(messageInfo.msgType);
      handler(message);
    } catch (error) {
      if (error is SatelliteException) {
        // subscription errors are emitted through specific event
        if (!subscriptionError.contains(error.code)) {
          emit('error', error);
        }
      } else {
        // This is an unexpected runtime error
        rethrow;
      }
    }
  }

  @override
  Future<AuthResponse> authenticate(
    AuthState authState,
  ) {
    final request = SatAuthReq(
      id: authState.clientId,
      token: authState.token,
      headers: [],
    );
    return _service.authenticate(null, request).then(handleAuthResp);
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
  void subscribeToRelations(
    void Function(Relation relation) callback,
  ) {
    on<Relation>('relation', callback);
  }

  @override
  void enqueueTransaction(
    DataTransaction transaction,
  ) {
    if (outbound.isReplicating != ReplicationStatus.active) {
      throw SatelliteException(
        SatelliteErrorCode.replicationNotStarted,
        'enqueuing a transaction while outbound replication has not started',
      );
    }

    outbound.transactions.add(transaction);
    outbound.lastLsn = transaction.lsn;

    throttledPushTransaction?.call();
  }

  @override
  Future<StartReplicationResponse> startReplication(
    LSN? lsn,
    String? schemaVersion,
    List<String>? subscriptionIds,
  ) async {
    if (inbound.isReplicating != ReplicationStatus.stopped) {
      throw SatelliteException(
        SatelliteErrorCode.replicationAlreadyStarted,
        'replication already started',
      );
    }

    // Perform validations and prepare the request

    late final SatInStartReplicationReq request;
    if (lsn == null || lsn.isEmpty) {
      logger.info('no previous LSN, start replication from scratch');

      if (subscriptionIds != null && subscriptionIds.isNotEmpty) {
        return Future.error(
          SatelliteException(
            SatelliteErrorCode.unexpectedSubscriptionState,
            'Cannot start replication with subscription IDs but without previous LSN.',
          ),
        );
      }
      request = SatInStartReplicationReq(schemaVersion: schemaVersion);
    } else {
      logger.info(
        'starting replication with lsn: ${base64.encode(lsn)} subscriptions: $subscriptionIds',
      );
      request = SatInStartReplicationReq(
        lsn: lsn,
        subscriptionIds: subscriptionIds,
      );
    }

    // Then set the replication state
    inbound = resetReplication(lsn, ReplicationStatus.starting);

    return delayIncomingMessages(
      () async {
        final resp = await _service.startReplication(null, request);
        return handleStartResp(resp);
      },
      allowedRpcResponses: ['startReplication'],
    );
  }

  @override
  Future<StopReplicationResponse> stopReplication() {
    if (inbound.isReplicating != ReplicationStatus.active) {
      return Future.error(
        SatelliteException(
          SatelliteErrorCode.replicationNotStarted,
          'replication not active',
        ),
      );
    }

    inbound.isReplicating = ReplicationStatus.stopping;
    final request = SatInStopReplicationReq();
    return _service.stopReplication(null, request).then(handleStopResp);
  }

  void sendMessage(Object request) {
    if (logger.levelImportance <= Level.debug.value) {
      logger.debug('[proto] send: ${msgToString(request)}');
    }
    final _socket = socket;
    if (_socket == null || isClosed()) {
      throw SatelliteException(
        SatelliteErrorCode.unexpectedState,
        'trying to send message, but client is closed',
      );
    }
    final msgType = getTypeFromSatObject(request);
    if (msgType == null) {
      throw SatelliteException(
        SatelliteErrorCode.unexpectedMessageType,
        '${request.runtimeType}',
      );
    }

    final buffer = encodeSocketMessage(msgType, request);
    _socket.write(buffer);
  }

  @override
  LSN getLastSentLsn() {
    return outbound.lastLsn ?? kDefaultLogPos;
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
        'An internal error occurred during authentication',
      );
    } else {
      throw StateError('Unexpected message $message');
    }

    return AuthResponse(serverId, error);
  }

  /// Server may issue RPC requests to the client, and we're handling them here.
  Future<void> handleRpcRequest(SatRpcRequest message) async {
    final responder = rpcRespond(sendMessage);

    if (message.method == 'startReplication') {
      final decoded = SatInStartReplicationReq.fromBuffer(message.message);
      responder(
        message,
        await handlerForRpcRequests[message.method]!(decoded),
      );
    } else if (message.method == 'stopReplication') {
      final decoded = SatInStopReplicationReq.fromBuffer(message.message);
      responder(
        message,
        await handlerForRpcRequests[message.method]!(decoded),
      );
    } else {
      logger.warning(
        'Server has sent an RPC request with a method that the client does not support: ${message.method}',
      );

      responder(
        message,
        SatErrorResp(
          errorType: SatErrorResp_ErrorCode.INVALID_REQUEST,
        ),
      );
    }
  }

  StartReplicationResponse handleStartResp(SatInStartReplicationResp resp) {
    if (inbound.isReplicating == ReplicationStatus.starting) {
      if (resp.hasErr()) {
        inbound.isReplicating = ReplicationStatus.stopped;
        return StartReplicationResponse(
          error: startReplicationErrorToSatelliteError(resp.err),
        );
      } else {
        inbound.isReplicating = ReplicationStatus.active;
      }
    } else {
      return StartReplicationResponse(
        error: SatelliteException(
          SatelliteErrorCode.unexpectedState,
          "unexpected state ${inbound.isReplicating} handling 'start' response",
        ),
      );
    }
    return StartReplicationResponse();
  }

  Future<Object> handleStartReq(
    SatInStartReplicationReq message,
  ) async {
    logger.info(
      'Server sent a replication request to start from ${bytesToNumber(message.lsn)}, and options ${message.options.map((e) => e.name)}',
    );
    if (outbound.isReplicating == ReplicationStatus.stopped) {
      // Use server-sent LSN as the starting point for replication
      outbound = resetReplication(
        message.lsn,
        ReplicationStatus.active,
      );

      throttledPushTransaction =
          Throttle(pushTransactions, Duration(milliseconds: opts.pushPeriod));

      emit('outbound_started', message.lsn);
      return SatInStartReplicationResp();
    } else {
      emit(
        'error',
        SatelliteException(
          SatelliteErrorCode.unexpectedState,
          "unexpected state ${outbound.isReplicating} handling 'start' request",
        ),
      );
      return SatErrorResp(
        errorType: SatErrorResp_ErrorCode.REPLICATION_FAILED,
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

      sendMessage(satOpLog);
    }
  }

  @override
  EventListener<SatelliteException> subscribeToError(ErrorCallback callback) {
    return on<SatelliteException>('error', callback);
  }

  @override
  void unsubscribeToError(EventListener<SatelliteException> eventListener) {
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

  @override
  SubscriptionEventListeners subscribeToSubscriptionEvents(
    SubscriptionDeliveredCallback successCallback,
    SubscriptionErrorCallback errorCallback,
  ) {
    final successListener =
        _subscriptionsDataCache.on(kSubscriptionDelivered, successCallback);
    final errorListener =
        _subscriptionsDataCache.on(kSubscriptionError, errorCallback);

    return SubscriptionEventListeners(
      successEventListener: successListener,
      errorEventListener: errorListener,
    );
  }

  @override
  void unsubscribeToSubscriptionEvents(
    SubscriptionEventListeners listeners,
  ) {
    _subscriptionsDataCache.removeEventListener(
      listeners.successEventListener,
    );
    _subscriptionsDataCache.removeEventListener(
      listeners.errorEventListener,
    );
  }

  @override
  Future<SubscribeResponse> subscribe(
    String subscriptionId,
    List<ShapeRequest> shapes,
  ) async {
    if (inbound.isReplicating != ReplicationStatus.active) {
      return Future.error(
        SatelliteException(
          SatelliteErrorCode.replicationNotStarted,
          'replication not active',
        ),
      );
    }

    final request = SatSubsReq(
      subscriptionId: subscriptionId,
      shapeRequests: shapeRequestToSatShapeReq(shapes),
    );

    _subscriptionsDataCache.subscriptionRequest(request);

    return _service.subscribe(null, request).then(handleSubscription);
  }

  @override
  Future<UnsubscribeResponse> unsubscribe(List<String> subscriptionIds) {
    if (inbound.isReplicating != ReplicationStatus.active) {
      return Future.error(
        SatelliteException(
          SatelliteErrorCode.replicationNotStarted,
          'replication not active',
        ),
      );
    }

    final request = SatUnsubsReq(
      subscriptionIds: subscriptionIds,
    );

    return _service.unsubscribe(null, request).then(handleUnsubscribeResponse);
  }

  void sendMissingRelations(
    DataTransaction transaction,
    Replication<DataTransaction> replication,
  ) {
    for (final change in transaction.changes) {
      final relation = change.relation;
      if (
          // this is a new relation
          !outbound.relations.containsKey(relation.id) ||
              // or, the relation has changed
              outbound.relations[relation.id] != relation) {
        replication.relations[relation.id] = relation;

        final satRelation = SatRelation(
          relationId: relation.id,
          schemaName: relation.schema, // TODO
          tableName: relation.table,
          tableType: relation.tableType,
          columns: relation.columns.map(
            (c) => SatRelationColumn(
              name: c.name,
              type: c.type,
              isNullable: c.isNullable,
            ),
          ),
        );

        sendMessage(satRelation);
      }
    }
  }

  Future<Object> handleStopReq(SatInStopReplicationReq value) async {
    if (outbound.isReplicating == ReplicationStatus.active) {
      outbound.isReplicating = ReplicationStatus.stopped;

      if (throttledPushTransaction != null) {
        throttledPushTransaction!.cancel();
        throttledPushTransaction = null;
      }

      return SatInStopReplicationResp();
    } else {
      emit(
        'error',
        SatelliteException(
          SatelliteErrorCode.unexpectedState,
          "unexpected state ${inbound.isReplicating} handling 'stop' request",
        ),
      );

      return SatErrorResp(
        errorType: SatErrorResp_ErrorCode.REPLICATION_FAILED,
      );
    }
  }

  StopReplicationResponse handleStopResp(SatInStopReplicationResp value) {
    if (inbound.isReplicating == ReplicationStatus.stopping) {
      inbound.isReplicating = ReplicationStatus.stopped;
      return StopReplicationResponse();
    } else {
      return StopReplicationResponse(
        error: SatelliteException(
          SatelliteErrorCode.unexpectedState,
          "unexpected state ${inbound.isReplicating} handling 'stop' response",
        ),
      );
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
          .map(
            (c) => RelationColumn(
              name: c.name,
              type: c.type,
              isNullable: c.isNullable,
              primaryKey: c.primaryKey,
            ),
          )
          .toList(),
    );

    inbound.relations[relation.id] = relation;
    emit('relation', relation);
  }

  void handleTransaction(SatOpLog message) {
    if (!_subscriptionsDataCache.isDelivering()) {
      processOpLogMessage(message);
    } else {
      try {
        _subscriptionsDataCache.transaction(message.ops);
      } catch (e) {
        logger.info('Error applying transaction message for subs $e');
      }
    }
  }

  void handleErrorResp(SatErrorResp error) {
    emit(
      'error',
      serverErrorToSatelliteError(error),
    );
  }

  SubscribeResponse handleSubscription(SatSubsResp msg) {
    if (msg.hasErr()) {
      final error = subsErrorToSatelliteError(msg.err);
      _subscriptionsDataCache.subscriptionError(msg.subscriptionId);
      return SubscribeResponse(
        subscriptionId: msg.subscriptionId,
        error: error,
      );
    } else {
      _subscriptionsDataCache.subscriptionResponse(msg);
      return SubscribeResponse(subscriptionId: msg.subscriptionId, error: null);
    }
  }

  void handleSubscriptionError(SatSubsDataError msg) {
    _subscriptionsDataCache.subscriptionDataError(msg.subscriptionId, msg);
  }

  void handleSubscriptionDataBegin(SatSubsDataBegin msg) {
    _subscriptionsDataCache.subscriptionDataBegin(msg);
  }

  void handleSubscriptionDataEnd(SatSubsDataEnd msg) {
    _subscriptionsDataCache.subscriptionDataEnd(inbound.relations);
  }

  void handleShapeDataBegin(SatShapeDataBegin msg) {
    _subscriptionsDataCache.shapeDataBegin(msg);
  }

  void handleShapeDataEnd(SatShapeDataEnd _msg) {
    _subscriptionsDataCache.shapeDataEnd();
  }

  // For now, unsubscribe responses doesn't send any information back
  // It might eventually confirm that the server processed it or was noop.
  UnsubscribeResponse handleUnsubscribeResponse(SatUnsubsResp msg) {
    return UnsubscribeResponse();
  }

  void processOpLogMessage(SatOpLog opLogMessage) {
    final replication = inbound;

    //print("PROCESS! ${opLogMessage.ops.length}");
    for (final op in opLogMessage.ops) {
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
        final transaction = Transaction(
          commitTimestamp: lastTx.commitTimestamp,
          lsn: lastTx.lsn,
          changes: lastTx.changes,
          origin: lastTx.origin,
        );
        emit<TransactionEvent>(
          'transaction',
          TransactionEvent(
            transaction,
            () => inbound.lastLsn = transaction.lsn,
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
            'missing relation ${op.insert.relationId} for incoming operation',
          );
        }

        final change = DataChange(
          relation: rel,
          type: DataChangeType.insert,
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

        final change = DataChange(
          relation: rel,
          type: DataChangeType.update,
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

        final change = DataChange(
          relation: rel,
          type: DataChangeType.delete,
          oldRecord: deserializeRow(oldRowData, rel),
          tags: op.delete.tags,
        );
        replication.transactions[lastTxnIdx].changes.add(change);
      }

      if (op.hasMigrate()) {
        // store the version of this migration transaction
        // (within 1 transaction, every SatOpMigrate message
        //  has the same version number)
        // TODO: in the protocol: move the `version` field to the SatOpBegin message
        //       or replace the `is_migration` field by an optional `version` field
        //       --> see issue VAX-718 on linear.
        final tx = replication.transactions[lastTxnIdx];
        tx.migrationVersion = op.migrate.version;

        final stmts = op.migrate.stmts;

        for (final stmt in stmts) {
          final change = SchemaChange(
            table: op.migrate.table,
            migrationType: stmt.type,
            sql: stmt.sql,
          );
          tx.changes.add(change);
        }
      }
    }
  }

  SatOpLog transactionToSatOpLog(DataTransaction transaction) {
    final List<SatTransOp> ops = [
      SatTransOp(
        begin: SatOpBegin(
          commitTimestamp: transaction.commitTimestamp,
          lsn: transaction.lsn,
        ),
      ),
    ];

    for (final change in transaction.changes) {
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
        case DataChangeType.delete:
          changeOp = SatTransOp(
            delete: SatOpDelete(
              oldRowData: oldRecord,
              relationId: relation.id,
              tags: tags,
            ),
          );
        case DataChangeType.insert:
          changeOp = SatTransOp(
            insert: SatOpInsert(
              rowData: record,
              relationId: relation.id,
              tags: tags,
            ),
          );
        case DataChangeType.update:
          changeOp = SatTransOp(
            update: SatOpUpdate(
              rowData: record,
              oldRowData: oldRecord,
              relationId: relation.id,
              tags: tags,
            ),
          );
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
      final Object? value = rec[c.name];
      if (value != null) {
        acc.add(serializeColumnData(value, c.type));
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
    case 'DATE':
    case 'TEXT':
    case 'TIME':
    case 'TIMESTAMP':
    case 'TIMESTAMPTZ':
    case 'UUID':
    case 'VARCHAR':
      return TypeDecoder.text(column);
    case 'BOOL':
      return TypeDecoder.boolean(column);
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
List<int> serializeColumnData(Object columnValue, String colType) {
  switch (colType.toUpperCase()) {
    case 'BOOL':
      return TypeEncoder.boolean(columnValue as int);
    default:
      return TypeEncoder.text(columnValue.toString());
  }
}

List<int> serializeNullData() {
  return TypeEncoder.text('');
}

Uint8List encodeSocketMessage(SatMsgType msgType, Object msg) {
  final typeEncoded = getBufWithMsgTag(msgType);
  final msgEncoded = encodeMessage(msg);
  final totalBufLen = typeEncoded.length + msgEncoded.length;

  final buffer = Uint8List(totalBufLen);
  buffer.setRange(0, 1, typeEncoded);
  buffer.setRange(1, totalBufLen, msgEncoded);

  return buffer;
}

DecodedMessage toMessage(Uint8List data) {
  final code = data[0];
  final type = getMsgFromCode(code);

  if (type == null) {
    throw SatelliteException(
      SatelliteErrorCode.unexpectedMessageType,
      '$code',
    );
  }

  return DecodedMessage(decodeMessage(data.sublist(1), type), type);
}
