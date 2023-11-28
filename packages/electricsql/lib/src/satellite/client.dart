import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:electricsql/src/auth/auth.dart';
import 'package:electricsql/src/client/conversions/types.dart';
import 'package:electricsql/src/client/model/schema.dart';
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
import 'package:meta/meta.dart';
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

abstract interface class SafeEventEmitter {
  EventListener<SatelliteException> onError(ErrorCallback callback);
  EventListener<Relation> onRelation(RelationCallback callback);
  EventListener<TransactionEvent> onTransaction(
    IncomingTransactionCallback callback,
  );
  EventListener<LSN> onOutboundStarted(OutboundStartedCallback callback);

  bool emitError(SatelliteException error);
  bool emitRelation(Relation relation);
  bool emitTransaction(TransactionEvent transactionEvent);
  bool emitOutboundStarted(LSN lsn);

  void removeListener<T>(EventListener<T> eventListener);

  void removeAllListeners();

  int listenerCount(String event);
}

class SatelliteClient implements Client {
  final SocketFactory socketFactory;
  final SatelliteClientOpts opts;
  late final SafeEventEmitter _emitter;

  @visibleForTesting
  SafeEventEmitter get emitter => _emitter;

  Socket? socket;

  late Replication<Transaction> inbound;
  late Replication<DataTransaction> outbound;

  // can only handle a single subscription at a time
  late final SubscriptionsDataCache _subscriptionsDataCache;

  void Function(Uint8List bytes)? socketHandler;
  Throttle<void>? throttledPushTransaction;

  late RPC rpcClient;
  late RootApi _service;
  final Lock _incomingLock = Lock();

  List<String> allowedMutexedRpcResponses = [];

  DBSchema _dbDescription;
  bool _isDown = false;

  @visibleForTesting
  void debugSetDbDescription(DBSchema value) {
    _dbDescription = value;
    _subscriptionsDataCache.dbDescription = value;
  }

  late final Map<String, Future<Object> Function(Object)>
      handlerForRpcRequests = {
    'startReplication': (o) => handleStartReq(o as SatInStartReplicationReq),
    'stopReplication': (o) => handleStopReq(o as SatInStopReplicationReq),
  };

  SatelliteClient({
    required DBSchema dbDescription,
    required this.socketFactory,
    required this.opts,
  }) : _dbDescription = dbDescription {
    // This cannot be lazyly instantiated in the 'late final' property, otherwise
    // it won't be properly ready to emit events at the right time
    _subscriptionsDataCache = SubscriptionsDataCache(_dbDescription);

    _emitter = SatelliteClientEventEmitter();

    inbound = resetReplication<Transaction>(null, null);
    outbound = resetReplication<DataTransaction>(null, null);

    rpcClient = RPC(
      sendMessage,
      opts.timeout,
      logger,
    );

    // Configure the RPC client to also log each request/response
    rpcClient = withRpcRequestLogging(
      rpcClient,
      logger,
    );

    _service = RootApi(rpcClient);
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
    if (_isDown) {
      throw SatelliteException(
        SatelliteErrorCode.unexpectedState,
        'client has already shutdown',
      );
    }

    if (isConnected()) {
      disconnect();
    }

    final completer = Completer<void>();

    final socket = socketFactory.create(kProtocolVsn);
    this.socket = socket;

    void onceError(Object error) {
      disconnect();
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
        if (_emitter.listenerCount('error') == 0) {
          disconnect();
          logger.error(
            'socket error but no listener is attached: $error',
          );
        }
        _emitter.emitError(error);
      });
      socket.onClose(() {
        disconnect();
        if (_emitter.listenerCount('error') == 0) {
          logger.error('socket closed but no listener is attached');
        }
        _emitter.emitError(
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

  @override
  void disconnect() {
    outbound = resetReplication(outbound.lastLsn, null);
    inbound = resetReplication(inbound.lastLsn, null);

    socketHandler = null;

    if (socket != null) {
      socket!.closeAndRemoveListeners();
      socket = null;
    }
  }

  @override
  bool isConnected() {
    return socketHandler != null;
  }

  @override
  void shutdown() {
    disconnect();
    _emitter.removeAllListeners();
    _isDown = true;
  }

  Future<T> delayIncomingMessages<T>(
    Future<T> Function() fn, {
    required List<String> allowedRpcResponses,
  }) async {
    final res = await _incomingLock.synchronized(() async {
      allowedMutexedRpcResponses = allowedRpcResponses;
      try {
        return await fn();
      } finally {
        allowedMutexedRpcResponses = [];
      }
    });

    // Drain the event loop to execute what was waiting for the lock
    await Future<void>.delayed(Duration.zero);

    return res;
  }

  Future<void> handleIncoming(Uint8List data) async {
    try {
      final messageInfo = toMessage(data);
      final message = messageInfo.msg;

      if (_incomingLock.inLock &&
          !(message is SatRpcResponse &&
              allowedMutexedRpcResponses.contains(message.method))) {
        // Wait for unlock
        await _incomingLock.synchronized(() {
          // Needs to be async to preserve the order of locks
          return Future<void>.value();
        });
      }

      if (logger.levelImportance <= Level.debug.value) {
        logger.debug('[proto] recv: ${msgToString(messageInfo.msg)}');
      }

      final handler = getIncomingHandlerForMessage(messageInfo.msgType);
      handler(message);
    } catch (error) {
      if (error is SatelliteException) {
        // subscription errors are emitted through specific event
        if (!subscriptionError.contains(error.code)) {
          _emitter.emitError(error);
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
    TransactionCallback callback,
  ) {
    _emitter.onTransaction((txnEvent) async {
      await callback(txnEvent.transaction);
      txnEvent.ackCb();
    });
  }

  @override
  void unsubscribeToTransactions(
    EventListener<TransactionEvent> eventListener,
  ) {
    _emitter.removeListener(eventListener);
  }

  @override
  void subscribeToRelations(
    RelationCallback callback,
  ) {
    _emitter.onRelation(callback);
  }

  @override
  void unsubscribeToRelations(
    EventListener<Relation> eventListener,
  ) {
    _emitter.removeListener(eventListener);
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
    if (_socket == null || !isConnected()) {
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

      _emitter.emitOutboundStarted(message.lsn);
      return SatInStartReplicationResp();
    } else {
      _emitter.emitError(
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
    return _emitter.onError(callback);
  }

  @override
  void unsubscribeToError(EventListener<SatelliteException> eventListener) {
    _emitter.removeListener(eventListener);
  }

  @override
  EventListener<void> subscribeToOutboundStarted(
    OutboundStartedCallback callback,
  ) {
    return _emitter.onOutboundStarted(callback);
  }

  @override
  void unsubscribeToOutboundStarted(EventListener<void> eventListener) {
    _emitter.removeListener(eventListener);
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
      _emitter.emitError(
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
      _emitter.emitError(
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
    _emitter.emitRelation(relation);
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
    _emitter.emitError(
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
          migrationVersion: lastTx.migrationVersion,
        );
        _emitter.emitTransaction(
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
          record: deserializeRow(
            op.insert.getNullableRowData(),
            rel,
            _dbDescription,
          ),
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
          record: deserializeRow(rowData, rel, _dbDescription),
          oldRecord: deserializeRow(oldRowData, rel, _dbDescription),
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
          oldRecord: deserializeRow(oldRowData, rel, _dbDescription),
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
        oldRecord = serializeRow(change.oldRecord!, relation, _dbDescription);
      }
      if (change.record != null && change.record!.isNotEmpty) {
        record = serializeRow(change.record!, relation, _dbDescription);
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
        case DataChangeType.compensation:
          changeOp = SatTransOp(
            compensation: SatOpCompensation(
              pkData: record,
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

/// Fetches the PG type of the given column in the given table.
/// @param dbDescription Database description object
/// @param table Name of the table
/// @param column Name of the column
/// @returns The PG type of the column or null if unknown (possibly an enum at runtime via the socket)
PgType? _getColumnType(
  DBSchema dbDescription,
  String table,
  RelationColumn column,
) {
  if (dbDescription.hasTable(table) &&
      dbDescription.getFields(table).containsKey(column.name)) {
    // The table and column are known in the DB description
    final PgType pgType = dbDescription.getFields(table)[column.name]!;
    return pgType;
  } else {
    // The table or column is not known.
    // There must have been a migration that added it to the DB while the app was running.
    // i.e., it was not known at the time the Electric client for this app was generated
    //       so it is not present in the bundled DB description.
    // Thus, we return the column type that is stored in the relation.
    // Note that it is fine to fetch the column type from the relation
    // because it was received at runtime and thus will have the PG type
    // (which would not be the case for bundled relations fetched
    //  from the endpoint because the endpoint maps PG types to SQLite types).
    final PgType? pgType = maybePgTypeFromColumnType(column.type);
    // if the type is not know, it's probably an ENUM, the name of the incoming type
    // is the name of the enum
    return pgType;
  }
}

SatOpRow serializeRow(Record rec, Relation relation, DBSchema dbDescription) {
  int recordNumColumn = 0;
  final recordNullBitMask =
      Uint8List(calculateNumBytes(relation.columns.length));
  final recordValues = relation.columns.fold<List<List<int>>>(
    [],
    (List<List<int>> acc, RelationColumn c) {
      final Object? value = rec[c.name];
      if (value != null) {
        final pgColumnType = _getColumnType(dbDescription, relation.table, c);
        acc.add(serializeColumnData(value, pgColumnType));
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
  DBSchema dbDescription,
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
        final pgColumnType = _getColumnType(dbDescription, relation.table, c);
        value = deserializeColumnData(_row.values[i], pgColumnType);
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
  PgType? columnType,
) {
  switch (columnType) {
    case PgType.char:
    case PgType.date:
    case PgType.text:
    case PgType.time:
    case PgType.timestamp:
    case PgType.timestampTz:
    case PgType.uuid:
    case PgType.varchar:
    // enums (pgType == null) are decoded from text
    case null:
      return TypeDecoder.text(column);
    case PgType.bool:
      return TypeDecoder.boolean(column);
    case PgType.int:
    case PgType.int2:
    case PgType.int4:
    case PgType.int8:
    case PgType.integer:
      return num.parse(TypeDecoder.text(column));
    case PgType.float4:
    case PgType.float8:
    case PgType.real:
      return TypeDecoder.float(column);
    case PgType.timeTz:
      return TypeDecoder.timetz(column);
  }
}

// All values serialized as textual representation
List<int> serializeColumnData(Object columnValue, PgType? columnType) {
  switch (columnType) {
    case PgType.bool:
      return TypeEncoder.boolean(columnValue as int);
    case PgType.timeTz:
      return TypeEncoder.timetz(columnValue as String);
    default:
      // Enums (pgType == null) are encoded as text
      return TypeEncoder.text(_getDefaultStringToSerialize(columnValue));
  }
}

String _getDefaultStringToSerialize(Object value) {
  if (value is double) {
    if (value.isNaN) {
      return 'NaN';
    } else if (value == double.infinity) {
      return 'Infinity';
    } else if (value == double.negativeInfinity) {
      return '-Infinity';
    } else {
      final int truncated = value.truncate();
      if (truncated == value) {
        return truncated.toString();
      }
    }
  }
  return value.toString();
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

class SatelliteClientEventEmitter implements SafeEventEmitter {
  final EventEmitter _emitter = EventEmitter();

  SatelliteClientEventEmitter();

  @override
  bool emitError(SatelliteException error) {
    return _emit('error', error);
  }

  @override
  bool emitRelation(Relation relation) {
    return _emit('relation', relation);
  }

  @override
  bool emitTransaction(TransactionEvent transactionEvent) {
    return _emit('transaction', transactionEvent);
  }

  @override
  bool emitOutboundStarted(LSN lsn) {
    return _emit('outbound_started', lsn);
  }

  @override
  EventListener<SatelliteException> onError(ErrorCallback callback) {
    return _on('error', callback);
  }

  @override
  EventListener<Relation> onRelation(RelationCallback callback) {
    return _on('relation', callback);
  }

  @override
  EventListener<TransactionEvent> onTransaction(
    IncomingTransactionCallback callback,
  ) {
    return _on('transaction', callback);
  }

  @override
  EventListener<LSN> onOutboundStarted(OutboundStartedCallback callback) {
    return _on('outbound_started', callback);
  }

  @override
  int listenerCount(String event) {
    return _emitter.listeners.where((l) => l.type == event).length;
  }

  @override
  void removeAllListeners() {
    // Prevent concurrent modification
    for (final listener in [..._emitter.listeners]) {
      _emitter.removeEventListener(listener);
    }
  }

  @override
  void removeListener<T>(EventListener<T> eventListener) {
    _emitter.removeEventListener(eventListener);
  }

  EventListener<T> _on<T>(String eventName, void Function(T) callback) {
    return _emitter.on<T>(eventName, callback);
  }

  bool _emit<T>(String eventName, T data) {
    return _emitter.emit<T>(eventName, data);
  }
}
