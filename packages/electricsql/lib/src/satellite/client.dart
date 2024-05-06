import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:electricsql/src/auth/auth.dart';
import 'package:electricsql/src/client/conversions/types.dart';
import 'package:electricsql/src/client/model/schema.dart';
import 'package:electricsql/src/migrators/query_builder/query_builder.dart';
import 'package:electricsql/src/proto/satellite.pb.dart';
import 'package:electricsql/src/satellite/config.dart';
import 'package:electricsql/src/satellite/rpc.dart';
import 'package:electricsql/src/satellite/satellite.dart';
import 'package:electricsql/src/satellite/shapes/cache.dart';
import 'package:electricsql/src/satellite/shapes/types.dart';
import 'package:electricsql/src/sockets/sockets.dart';
import 'package:electricsql/src/util/async_event_emitter.dart';
import 'package:electricsql/src/util/bitmask_helpers.dart';
import 'package:electricsql/src/util/common.dart';
import 'package:electricsql/src/util/debug/debug.dart';
import 'package:electricsql/src/util/emitter_helpers.dart';
import 'package:electricsql/src/util/encoders/encoders.dart';
import 'package:electricsql/src/util/extension.dart';
import 'package:electricsql/src/util/js_array_funs.dart';
import 'package:electricsql/src/util/proto.dart';
import 'package:electricsql/src/util/tablename.dart';
import 'package:electricsql/src/util/types.dart';
import 'package:fixnum/fixnum.dart';
import 'package:meta/meta.dart';
import 'package:synchronized/synchronized.dart';

const kDefaultAckPeriod = 60000;

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
  void Function() onError(ErrorCallback callback);
  void Function() onRelation(RelationCallback callback);
  void Function() onTransaction(
    IncomingTransactionCallback callback,
  );
  void Function() onAdditionalData(
    IncomingAdditionalDataCallback callback,
  );
  void Function() onOutboundStarted(OutboundStartedCallback callback);
  void Function() onSubscriptionDelivered(
    SubscriptionDeliveredCallback callback,
  );
  void Function() onSubscriptionError(SubscriptionErrorCallback callback);

  void enqueueEmitError(SatelliteException error, StackTrace stackTrace);
  void enqueueEmitSubscriptionDelivered(SubscriptionData data);
  void enqueueEmitSubscriptionError(SubscriptionErrorData error);
  void enqueueEmitRelation(Relation relation);
  void enqueueEmitTransaction(TransactionEvent transactionEvent);
  void enqueueEmitOutboundStarted(LSN lsn);
  void enqueueEmitAdditionalData(AdditionalDataEvent additionalDataEvent);

  void removeAllListeners();

  int listenerCount(String event);
}

class SatelliteClient implements Client {
  final SocketFactory socketFactory;
  final SatelliteClientOpts opts;
  late final SatInStartReplicationReq_Dialect _dialect;
  late final TypeEncoder _encoder;
  late final TypeDecoder _decoder;
  late final SafeEventEmitter _emitter;

  @visibleForTesting
  SafeEventEmitter get emitter => _emitter;

  Socket? socket;

  late InboundReplication inbound;
  late Replication<DataTransaction> outbound;

  // can only handle a single subscription at a time
  late final SubscriptionsDataCache _subscriptionsDataCache;

  final Map<String, ReplicatedRowTransformer<DbRecord>> replicationTransforms =
      {};

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
    _dialect = opts.dialect == Dialect.sqlite
        ? SatInStartReplicationReq_Dialect.SQLITE
        : SatInStartReplicationReq_Dialect.POSTGRES;
    _encoder = opts.dialect == Dialect.sqlite
        ? kSqliteTypeEncoder
        : kPostgresTypeEncoder;
    _decoder = opts.dialect == Dialect.sqlite
        ? kSqliteTypeDecoder
        : kPostgresTypeDecoder;

    // This cannot be lazyly instantiated in the 'late final' property, otherwise
    // it won't be properly ready to emit events at the right time
    _subscriptionsDataCache = SubscriptionsDataCache(_dbDescription, _decoder);

    _emitter = SatelliteClientEventEmitter();

    inbound = resetInboundReplication(null, null);
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

  InboundReplication resetInboundReplication(
    LSN? lastLsn,
    ReplicationStatus? isReplicating,
  ) {
    final replicationResetted =
        resetReplication<ServerTransaction>(lastLsn, isReplicating);
    return InboundReplication(
      authenticated: replicationResetted.authenticated,
      isReplicating: replicationResetted.isReplicating,
      relations: replicationResetted.relations,
      transactions: replicationResetted.transactions,
      lastLsn: replicationResetted.lastLsn,
      //

      lastTxId: null,
      lastAckedTxId: null,
      unackedTxs: 0,
      maxUnackedTxs: 30,
      ackPeriod: kDefaultAckPeriod,
      ackTimer: Timer(
        const Duration(milliseconds: kDefaultAckPeriod),
        () => maybeSendAck('timeout'),
      ),
      additionalData: [],
      unseenAdditionalDataRefs: {},
      seenAdditionalDataSinceLastTx: SeenAdditionalDataInfo(
        dataRefs: [],
        subscriptions: [],
      ),
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
      case SatMsgType.opLogAck:
        return (v) {}; // Server doesn't send that
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

    void onceError(Object error, StackTrace st) {
      disconnect();
      completer.completeError(error, st);
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
      socket.onError((error, st) {
        if (_emitter.listenerCount('error') == 0) {
          disconnect();
          logger.error(
            'socket error but no listener is attached: $error',
          );
        }
        _emitter.enqueueEmitError(error, st);
      });
      socket.onClose((reason) {
        disconnect();
        if (_emitter.listenerCount('error') == 0) {
          logger.error('socket closed but no listener is attached');
        }
        _emitter.enqueueEmitError(
          SatelliteException(reason.code, 'socket closed'),
          StackTrace.current,
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
    inbound = resetInboundReplication(inbound.lastLsn, null);

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
  ReplicationStatus getOutboundReplicationStatus() {
    return outbound.isReplicating;
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
    } catch (error, st) {
      if (error is SatelliteException) {
        // subscription errors are emitted through specific event
        if (!subscriptionError.contains(error.code)) {
          _emitter.enqueueEmitError(error, st);
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
  void Function() subscribeToTransactions(
    TransactionCallback callback,
  ) {
    return _emitter.onTransaction((txnEvent) async {
      await callback(txnEvent.transaction);
      txnEvent.ackCb();
    });
  }

  @override
  void Function() subscribeToAdditionalData(
    AdditionalDataCallback callback,
  ) {
    return _emitter.onAdditionalData((dataEvent) async {
      await callback(dataEvent.additionalData);
      dataEvent.ackCb();
    });
  }

  @override
  void Function() subscribeToRelations(
    RelationCallback callback,
  ) {
    return _emitter.onRelation(callback);
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

    // apply any specified transforms to the data changes
    transaction.changes = transaction.changes
        .map(
          (dc) => _applyDataChangeTransform(dc, isInbound: false),
        )
        .toList();

    outbound.transactions.add(transaction);
    outbound.lastLsn = transaction.lsn;

    throttledPushTransaction?.call();
  }

  @override
  Future<StartReplicationResponse> startReplication(
    LSN? lsn,
    String? schemaVersion,
    List<String>? subscriptionIds,
    List<Int64>? observedTransactionData,
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
      request = SatInStartReplicationReq(
        schemaVersion: schemaVersion,
        sqlDialect: _dialect,
      );
    } else {
      logger.info(
        'starting replication with lsn: ${base64.encode(lsn)} subscriptions: $subscriptionIds',
      );
      request = SatInStartReplicationReq(
        lsn: lsn,
        subscriptionIds: subscriptionIds,
        observedTransactionData: observedTransactionData,
        sqlDialect: _dialect,
      );
    }

    // Then set the replication state
    inbound = resetInboundReplication(lsn, ReplicationStatus.starting);

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

    return (error != null)
        ? AuthResponse.withError(error, StackTrace.current)
        : AuthResponse(serverId);
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
        return StartReplicationResponse.withError(
          startReplicationErrorToSatelliteError(resp.err),
          StackTrace.current,
        );
      } else {
        inbound.isReplicating = ReplicationStatus.active;
        inbound.maxUnackedTxs =
            resp.hasUnackedWindowSize() ? resp.unackedWindowSize : 30;
      }
    } else {
      return StartReplicationResponse.withError(
        SatelliteException(
          SatelliteErrorCode.unexpectedState,
          "unexpected state ${inbound.isReplicating} handling 'start' response",
        ),
        StackTrace.current,
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

      _emitter.enqueueEmitOutboundStarted(message.lsn);
      return SatInStartReplicationResp();
    } else {
      _emitter.enqueueEmitError(
        SatelliteException(
          SatelliteErrorCode.unexpectedState,
          "unexpected state ${outbound.isReplicating} handling 'start' request",
        ),
        StackTrace.current,
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
  void Function() subscribeToError(ErrorCallback callback) {
    return _emitter.onError(callback);
  }

  @override
  void Function() subscribeToOutboundStarted(
    OutboundStartedCallback callback,
  ) {
    return _emitter.onOutboundStarted(callback);
  }

  @override
  SubscriptionEventListeners subscribeToSubscriptionEvents(
    SubscriptionDeliveredCallback successCallback,
    SubscriptionErrorCallback errorCallback,
  ) {
    Future<void> newCb(SubscriptionData data) async {
      await successCallback(data);
      inbound.seenAdditionalDataSinceLastTx.subscriptions
          .add(data.subscriptionId);
      maybeSendAck('additionalData');
    }

    // We're remapping this callback to internal emitter to keep event queue correct -
    // a delivered subscription processing should not interleave with next transaction processing
    final removeSuccessListener = emitter.onSubscriptionDelivered(newCb);
    _subscriptionsDataCache.on(
      kSubscriptionDelivered,
      (SubscriptionData data) => emitter.enqueueEmitSubscriptionDelivered(data),
    );
    final removeErrorListener = emitter.onSubscriptionError(errorCallback);
    _subscriptionsDataCache.on(
      kSubscriptionError,
      (SubscriptionErrorData error) =>
          emitter.enqueueEmitSubscriptionError(error),
    );

    return SubscriptionEventListeners(
      removeListeners: () {
        removeSuccessListener();
        removeErrorListener();

        removeListeners(_subscriptionsDataCache, kSubscriptionDelivered);
        removeListeners(_subscriptionsDataCache, kSubscriptionError);
      },
    );
  }

  @override
  void unsubscribeToSubscriptionEvents(
    SubscriptionEventListeners listeners,
  ) {
    listeners.removeListeners();
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

    return delayIncomingMessages(
      () async {
        final resp = await _service.subscribe(null, request);
        return handleSubscription(resp);
      },
      allowedRpcResponses: ['subscribe'],
    );
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
      _emitter.enqueueEmitError(
        SatelliteException(
          SatelliteErrorCode.unexpectedState,
          "unexpected state ${inbound.isReplicating} handling 'stop' request",
        ),
        StackTrace.current,
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
      return StopReplicationResponse.withError(
        SatelliteException(
          SatelliteErrorCode.unexpectedState,
          "unexpected state ${inbound.isReplicating} handling 'stop' response",
        ),
        StackTrace.current,
      );
    }
  }

  void handleRelation(SatRelation message) {
    if (inbound.isReplicating != ReplicationStatus.active) {
      _emitter.enqueueEmitError(
        SatelliteException(
          SatelliteErrorCode.unexpectedState,
          "unexpected state ${inbound.isReplicating} handling 'relation' message",
        ),
        StackTrace.current,
      );
      return;
    }

    /* TODO: This makes a generally incorrect assumption that PK columns come in order in the relation
             It works in most cases, but we need actual PK order information on the protocol
             for multi-col PKs to work */
    int pkPosition = 1;

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
              primaryKey: c.primaryKey ? pkPosition++ : null,
            ),
          )
          .toList(),
    );

    inbound.relations[relation.id] = relation;
    _emitter.enqueueEmitRelation(relation);
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
    _emitter.enqueueEmitError(
      serverErrorToSatelliteError(error),
      StackTrace.current,
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

  Relation _getRelation(int relationId) {
    final rel = inbound.relations[relationId];
    if (rel == null) {
      throw SatelliteException(
        SatelliteErrorCode.protocolViolation,
        'missing relation $relationId for incoming operation',
      );
    }
    return rel;
  }

  void processOpLogMessage(SatOpLog opLogMessage) {
    final replication = inbound;

    //print("PROCESS! ${opLogMessage.ops.length}");
    for (final op in opLogMessage.ops) {
      if (op.hasBegin()) {
        final transaction = ServerTransaction(
          commitTimestamp: op.begin.commitTimestamp,
          lsn: op.begin.lsn,
          changes: [],
          origin: op.begin.origin,
          id: op.begin.transactionId,
        );
        replication.incomplete = IncompletionType.transaction;
        replication.transactions.add(transaction);
      }

      if (op.hasAdditionalBegin()) {
        replication.incomplete = IncompletionType.additionalData;
        replication.additionalData.add(
          AdditionalData(
            ref: op.additionalBegin.ref,
            changes: [],
          ),
        );
      }

      final lastTxnIdx = replication.transactions.length - 1;
      final lastDataIdx = replication.additionalData.length - 1;
      if (op.hasCommit()) {
        if (replication.incomplete != IncompletionType.transaction) {
          throw Exception(
            'Unexpected commit message while not waiting for txn',
          );
        }

        final lastTx = replication.transactions[lastTxnIdx];

        // apply any specified transforms to the data changes
        final transformedChanges = lastTx.changes.map((change) {
          if (change is! DataChange) return change;
          return _applyDataChangeTransform(change, isInbound: true);
        }).toList();

        final transaction = ServerTransaction(
          commitTimestamp: lastTx.commitTimestamp,
          lsn: lastTx.lsn,
          changes: transformedChanges,
          origin: lastTx.origin,
          migrationVersion: lastTx.migrationVersion,
          id: lastTx.id,
          additionalDataRef: op.commit.additionalDataRef.isZero
              ? null
              : op.commit.additionalDataRef,
        );
        _emitter.enqueueEmitTransaction(
          TransactionEvent(transaction, () {
            inbound.lastLsn = transaction.lsn;
            inbound.lastTxId = transaction.id;
            inbound.unackedTxs++;
            inbound.seenAdditionalDataSinceLastTx = SeenAdditionalDataInfo(
              dataRefs: [],
              subscriptions: [],
            );
            maybeSendAck(null);
          }),
        );
        replication.transactions.removeAt(lastTxnIdx);
        replication.incomplete = null;
        if (!op.commit.additionalDataRef.isZero) {
          replication.unseenAdditionalDataRefs
              .add(op.commit.additionalDataRef.toString());
        }
      }

      if (op.hasAdditionalCommit()) {
        if (replication.incomplete != IncompletionType.additionalData) {
          throw Exception(
            'Unexpected additionalCommit message while not waiting for additionalData',
          );
        }
        final ref = op.additionalCommit.ref;

        // TODO: We need to include these in the ACKs as well
        emitter.enqueueEmitAdditionalData(
          AdditionalDataEvent(replication.additionalData[lastDataIdx], () {
            inbound.seenAdditionalDataSinceLastTx.dataRefs.add(ref);
            maybeSendAck('additionalData');
          }),
        );
        replication.additionalData.splice(lastDataIdx);
        replication.incomplete = null;
        replication.unseenAdditionalDataRefs.remove(ref.toString());
      }

      if (op.hasInsert()) {
        final rid = op.insert.relationId;
        final rel = _getRelation(rid);

        final change = DataChange(
          relation: rel,
          type: DataChangeType.insert,
          record: deserializeRow(
            op.insert.getNullableRowData(),
            rel,
            _dbDescription,
            _decoder,
          ),
          tags: op.insert.tags,
        );

        if (replication.incomplete == IncompletionType.transaction) {
          replication.transactions[lastTxnIdx].changes.add(change);
        } else {
          replication.additionalData[lastDataIdx].changes.add(change);
        }
      }

      if (op.hasUpdate()) {
        final rid = op.update.relationId;
        final rel = _getRelation(rid);
        final rowData = op.update.getNullableRowData();
        final oldRowData = op.update.getNullableOldRowData();

        final change = DataChange(
          relation: rel,
          type: DataChangeType.update,
          record: deserializeRow(
            rowData,
            rel,
            _dbDescription,
            _decoder,
          ),
          oldRecord: deserializeRow(
            oldRowData,
            rel,
            _dbDescription,
            _decoder,
          ),
          tags: op.update.tags,
        );

        replication.transactions[lastTxnIdx].changes.add(change);
      }

      if (op.hasDelete()) {
        final rid = op.delete.relationId;
        final rel = _getRelation(rid);

        final oldRowData = op.delete.getNullableOldRowData();

        final change = DataChange(
          relation: rel,
          type: DataChangeType.delete,
          oldRecord: deserializeRow(
            oldRowData,
            rel,
            _dbDescription,
            _decoder,
          ),
          tags: op.delete.tags,
        );
        replication.transactions[lastTxnIdx].changes.add(change);
      }

      if (op.hasGone()) {
        final rid = op.gone.relationId;
        final rel = _getRelation(rid);

        final change = DataChange(
          relation: rel,
          type: DataChangeType.gone,
          oldRecord: deserializeRow(
            op.gone.pkData,
            rel,
            _dbDescription,
            _decoder,
          ),
          tags: [],
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
        oldRecord = serializeRow(
          change.oldRecord!,
          relation,
          _dbDescription,
          _encoder,
        );
      }
      if (change.record != null && change.record!.isNotEmpty) {
        record = serializeRow(
          change.record!,
          relation,
          _dbDescription,
          _encoder,
        );
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
        case DataChangeType.gone:
          throw SatelliteException(
            SatelliteErrorCode.protocolViolation,
            'Client is not expected to send GONE messages',
          );
      }
      ops.add(changeOp);
    }

    ops.add(SatTransOp(commit: SatOpCommit()));
    return SatOpLog(ops: ops);
  }

  void maybeSendAck(String? reason) {
    // Restart the timer regardless
    if (reason == 'timeout') {
      inbound.ackTimer = Timer(
        Duration(milliseconds: inbound.ackPeriod),
        () => maybeSendAck('timeout'),
      );
    }

    // Cannot ack while offline
    if (socket == null || !isConnected()) return;
    // or when there's nothing to be ack'd
    if (inbound.lastTxId == null) return;
    // Shouldn't ack the same message
    if (inbound.lastAckedTxId == inbound.lastTxId) return;

    // Send acks earlier rather than later to keep the stream continuous -
    // definitely send at 70% of allowed lag.
    final boundary = (inbound.maxUnackedTxs * 0.7).floor();

    // Send the ack if we're over the boundary, or wait to ack until the timer runs
    // out to avoid making more traffic than required, but we always try to ack on additional data
    if (inbound.unackedTxs >= boundary ||
        reason == 'timeout' ||
        reason == 'additionalData') {
      final SatOpLogAck msg = SatOpLogAck(
        ackTimestamp: Int64.ZERO + DateTime.now().millisecondsSinceEpoch,
        lsn: inbound.lastLsn,
        transactionId: inbound.lastTxId,
        subscriptionIds: inbound.seenAdditionalDataSinceLastTx.subscriptions,
        additionalDataSourceIds: inbound.seenAdditionalDataSinceLastTx.dataRefs,
      );

      sendMessage(msg);
      inbound.lastAckedTxId = msg.transactionId;
    }
  }

  @override
  void setReplicationTransform(
    QualifiedTablename tableName,
    ReplicatedRowTransformer<DbRecord> transform,
  ) {
    replicationTransforms[tableName.tablename] = transform;
  }

  @override
  void clearReplicationTransform(QualifiedTablename tableName) {
    replicationTransforms.remove(tableName.tablename);
  }

  DataChange _applyDataChangeTransform(
    DataChange dataChange, {
    required bool isInbound,
  }) {
    final transforms = replicationTransforms[dataChange.relation.table];
    if (transforms == null) return dataChange;
    final transformToUse =
        isInbound ? transforms.transformInbound : transforms.transformOutbound;
    try {
      return dataChange.copyWith(
        record: () => dataChange.record == null
            ? null
            : transformToUse(dataChange.record!),
        oldRecord: () => dataChange.oldRecord == null
            ? null
            : transformToUse(dataChange.oldRecord!),
      );
    } catch (err) {
      throw SatelliteException(
        SatelliteErrorCode.replicationTransformError,
        err.toString(),
      );
    }
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

SatOpRow serializeRow(
  DbRecord rec,
  Relation relation,
  DBSchema dbDescription,
  TypeEncoder encoder,
) {
  int recordNumColumn = 0;
  final recordNullBitMask =
      Uint8List(calculateNumBytes(relation.columns.length));
  final recordValues = relation.columns.fold<List<List<int>>>(
    [],
    (List<List<int>> acc, RelationColumn c) {
      final Object? value = rec[c.name];
      if (value != null) {
        final pgColumnType = _getColumnType(dbDescription, relation.table, c);
        acc.add(serializeColumnData(value, pgColumnType, encoder));
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

DbRecord? deserializeRow(
  SatOpRow? row,
  Relation relation,
  DBSchema dbDescription,
  TypeDecoder decoder,
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
        value = deserializeColumnData(_row.values[i], pgColumnType, decoder);
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
  TypeDecoder decoder,
) {
  switch (columnType) {
    case PgType.char:
    case PgType.date:
    case PgType.int8:
    case PgType.text:
    case PgType.time:
    case PgType.timestamp:
    case PgType.timestampTz:
    case PgType.uuid:
    case PgType.varchar:
    // enums (pgType == null) are decoded from text
    case null:
      return decoder.text(column);
    case PgType.bool:
      return decoder.boolean(column);
    case PgType.int:
    case PgType.int2:
    case PgType.int4:
    case PgType.integer:
      return num.parse(decoder.text(column));
    case PgType.float4:
    case PgType.float8:
    case PgType.real:
      return decoder.float(column);
    case PgType.timeTz:
      return decoder.timetz(column);
    case PgType.json:
    case PgType.jsonb:
      return decoder.json(column);
    case PgType.bytea:
      // no-op
      return column;
  }
}

// All values serialized as textual representation
List<int> serializeColumnData(
  Object columnValue,
  PgType? columnType,
  TypeEncoder encoder,
) {
  switch (columnType) {
    case PgType.bool:
      // the encoder accepts the number or bool
      return encoder.boolean(columnValue);
    case PgType.timeTz:
      return encoder.timetz(columnValue as String);
    case PgType.bytea:
      return columnValue as List<int>;
    case PgType.json:
    case PgType.jsonb:
      return encoder.json(columnValue);
    default:
      // Enums (pgType == null) are encoded as text
      return encoder.text(_getDefaultStringToSerialize(columnValue));
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
  return Uint8List(0);
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
  final AsyncEventEmitter _emitter = AsyncEventEmitter();

  SatelliteClientEventEmitter();

  @override
  void enqueueEmitError(SatelliteException error, StackTrace stackTrace) {
    return _enqueueEmit('error', (error, stackTrace));
  }

  @override
  void enqueueEmitRelation(Relation relation) {
    return _enqueueEmit('relation', relation);
  }

  @override
  void enqueueEmitTransaction(TransactionEvent transactionEvent) {
    return _enqueueEmit('transaction', transactionEvent);
  }

  @override
  void enqueueEmitOutboundStarted(LSN lsn) {
    return _enqueueEmit('outbound_started', lsn);
  }

  @override
  void enqueueEmitAdditionalData(AdditionalDataEvent additionalDataEvent) {
    return _enqueueEmit('additionalData', additionalDataEvent);
  }

  @override
  void enqueueEmitSubscriptionDelivered(SubscriptionData data) {
    return _enqueueEmit(kSubscriptionDelivered, data);
  }

  @override
  void enqueueEmitSubscriptionError(SubscriptionErrorData error) {
    return _enqueueEmit(kSubscriptionError, error);
  }

  @override
  void Function() onError(ErrorCallback callback) {
    return _on('error', callback);
  }

  @override
  void Function() onRelation(RelationCallback callback) {
    return _on('relation', callback);
  }

  @override
  void Function() onTransaction(
    IncomingTransactionCallback callback,
  ) {
    return _on('transaction', callback);
  }

  @override
  void Function() onOutboundStarted(OutboundStartedCallback callback) {
    return _on('outbound_started', callback);
  }

  @override
  void Function() onAdditionalData(IncomingAdditionalDataCallback callback) {
    return _on('additionalData', callback);
  }

  @override
  void Function() onSubscriptionDelivered(
    SubscriptionDeliveredCallback callback,
  ) {
    return _on(kSubscriptionDelivered, callback);
  }

  @override
  void Function() onSubscriptionError(SubscriptionErrorCallback callback) {
    return _on(kSubscriptionError, callback);
  }

  @override
  int listenerCount(String event) {
    return _emitter.listenerCount(event);
  }

  @override
  void removeAllListeners() {
    _emitter.removeAllListeners(null);
  }

  void Function() _on<T>(
    String eventName,
    FutureOr<void> Function(T) callback,
  ) {
    FutureOr<void> wrapper(dynamic data) {
      return callback(data as T);
    }

    _emitter.on(eventName, wrapper);

    return () {
      _emitter.removeListener(eventName, wrapper);
    };
  }

  void _enqueueEmit<T>(String eventName, T data) {
    return _emitter.enqueueEmit<T>(eventName, data);
  }
}
