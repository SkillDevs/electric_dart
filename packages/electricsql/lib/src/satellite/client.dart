import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:electricsql/src/auth/auth.dart';
import 'package:electricsql/src/notifiers/notifiers.dart' hide Change;
import 'package:electricsql/src/proto/satellite.pb.dart';
import 'package:electricsql/src/satellite/config.dart';
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
import 'package:logging/logging.dart';

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

  late Replication inbound;
  late OutgoingReplication outbound;

  // can only handle a single subscription at a time
  final SubscriptionsDataCache _subscriptionsDataCache =
      SubscriptionsDataCache();

  Throttle<void>? throttledPushTransaction;
  void Function(Uint8List bytes)? socketHandler;

  SatelliteClient({
    // ignore: avoid_unused_constructor_parameters
    required DbName dbName,
    required this.socketFactory,
    // ignore: avoid_unused_constructor_parameters
    required Notifier notifier,
    required this.opts,
  }) {
    inbound = resetReplication<Transaction>(null, null, null);
    outbound = resetReplication<DataTransaction>(null, null, null);
  }

  BaseReplication<TransactionType> resetReplication<TransactionType>(
    LSN? enqueued,
    LSN? ack,
    ReplicationStatus? isReplicating,
  ) {
    return BaseReplication<TransactionType>(
      authenticated: false,
      isReplicating: isReplicating ?? ReplicationStatus.stopped,
      relations: {},
      transactions: [],
      ackLsn: ack,
      enqueuedLsn: enqueued,
    );
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

      case SatMsgType.subsResp:
        return IncomingHandler(
          handle: (v) => handleSubscription(v! as SatSubsResp),
          isRpc: true,
        );

      case SatMsgType.subsDataError:
        return IncomingHandler(
          handle: (v) => handleSubscriptionError(v! as SatSubsDataError),
          isRpc: false,
        );
      case SatMsgType.subsDataBegin:
        return IncomingHandler(
          handle: (v) => handleSubscriptionDataBegin(v! as SatSubsDataBegin),
          isRpc: false,
        );

      case SatMsgType.subsDataEnd:
        return IncomingHandler(
          handle: (v) => handleSubscriptionDataEnd(v! as SatSubsDataEnd),
          isRpc: false,
        );
      case SatMsgType.shapeDataBegin:
        return IncomingHandler(
          handle: (v) => handleShapeDataBegin(v! as SatShapeDataBegin),
          isRpc: false,
        );
      case SatMsgType.shapeDataEnd:
        return IncomingHandler(
          handle: (v) => handleShapeDataEnd(v! as SatShapeDataEnd),
          isRpc: false,
        );
      case SatMsgType.unsubsResp:
        return IncomingHandler(
          handle: (v) => handleUnsubscribeResponse(v! as SatUnsubsResp),
          isRpc: true,
        );
      case SatMsgType.subsReq:
      case SatMsgType.unsubsReq:
      case SatMsgType.authReq:
      case SatMsgType.migrationNotification:
        throw UnimplementedError();
    }
  }

  @override
  Future<void> connect() async {
    if (!isClosed()) {
      close();
    }

    final completer = Completer<void>();

    final socket = socketFactory.create();
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
          logger.severe(
            'socket error but no listener is attached: $error',
          );
        }
        emit('error', error);
      });
      socket.onClose(() {
        close();
        if (listenerCount('error') == 0) {
          logger.severe('socket closed but no listener is attached');
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
    outbound = resetReplication(outbound.enqueuedLsn, outbound.ackLsn, null);
    inbound = resetReplication(
      inbound.enqueuedLsn,
      inbound.ackLsn,
      null,
    );

    socketHandler = null;
    // TODO(update): SHould this be removed??
    // removeAllListeners();

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

  void handleIncoming(Uint8List data) {
    bool handleIsRpc = false;
    try {
      final messageInfo = toMessage(data);

      if (logger.level <= Level.FINE) {
        logger.fine('[proto] recv: ${msgToString(messageInfo.msg)}');
      }

      final handler = getIncomingHandlerForMessage(messageInfo.msgType);
      final response = handler.handle(messageInfo.msg);
      handleIsRpc = handler.isRpc;
      if (handleIsRpc) {
        emit('rpc_response', response);
      }
    } catch (error) {
      if (error is SatelliteException) {
        if (handleIsRpc) {
          emit('rpc_error', error);
        } else {
          // subscription errors are emitted through specific event
          if (!subscriptionError.contains(error.code)) {
            emit('error', error);
          }
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
    return rpc<AuthResponse>(request);
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
    outbound.enqueuedLsn = transaction.lsn;

    if (throttledPushTransaction != null) {
      throttledPushTransaction!.call();
    }
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
    inbound = resetReplication(lsn, lsn, ReplicationStatus.starting);

    return rpc<StartReplicationResponse>(request);
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
    return rpc<StopReplicationResponse>(request);
  }

  void sendMessage(Object request) {
    if (logger.level <= Level.FINE) {
      logger.fine('[proto] send: ${msgToString(request)}');
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

  Future<T> rpc<T>(
    Object request, {
    Object Function(Object msg)? distinguishOn,
  }) async {
    Timer? timer;
    EventListener? rpcRespListener;
    EventListener? errorListener;
    final Completer<T> completer = Completer();

    try {
      timer = Timer(Duration(milliseconds: opts.timeout), () {
        final error = SatelliteException(
          SatelliteErrorCode.timeout,
          '${request.runtimeType}',
        );
        completer.completeError(error);
      });

      // reject on any error
      errorListener = on('rpc_error', (error) {
        errorListener?.cancel();
        errorListener = null;
        completer.completeError(error as Object);
      });

      if (distinguishOn != null) {
        dynamic handleRpcResp(T resp) {
          // TODO: remove this comment when RPC types are fixed
          // @ts-ignore this comparison is valid because we expect the same field to be present on both request and response, but it's too much work at the moment to rewrite typings for it
          final respValue = distinguishOn(resp as Object);
          final reqValue = distinguishOn(request);
          if (respValue == reqValue) {
            errorListener?.cancel();
            errorListener = null;

            return completer.complete(resp);
          } else {
            // This WAS an RPC response, but not the one we were expecting, waiting more
            rpcRespListener = on('rpc_response', (resp) {
              rpcRespListener?.cancel();
              rpcRespListener = null;
              handleRpcResp(resp as T);
            });
          }
        }

        rpcRespListener = on('rpc_response', (resp) {
          rpcRespListener?.cancel();
          rpcRespListener = null;
          handleRpcResp(resp as T);
        });
      } else {
        rpcRespListener = on('rpc_response', (resp) {
          rpcRespListener?.cancel();
          rpcRespListener = null;

          errorListener?.cancel();
          errorListener = null;

          completer.complete(resp as T);
        });
      }

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
        'An internal error occurred during authentication',
      );
    } else {
      throw StateError('Unexpected message $message');
    }

    return AuthResponse(serverId, error);
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

  void handleInStartReplicationReq(SatInStartReplicationReq message) {
    logger.info('received replication request $message');
    if (outbound.isReplicating == ReplicationStatus.stopped) {
      final replication = outbound.clone();
      replication.ackLsn = kDefaultLogPos;
      replication.enqueuedLsn = kDefaultLogPos;

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

      sendMessage(satOpLog);
      emit<AckLsnEvent>('ack_lsn', AckLsnEvent(next.lsn, AckType.localSend));
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
    return rpc<SubscribeResponse>(
      request,
      distinguishOn: (Object o) {
        if (o is SatSubsReq) {
          return o.subscriptionId;
        } else if (o is SubscribeResponse) {
          return o.subscriptionId;
        } else {
          throw StateError('Unexpected SatSubs');
        }
      },
    );
  }

  @override
  Future<UnsubscribeResponse> unsubscribe(List<String> subIds) {
    if (inbound.isReplicating != ReplicationStatus.active) {
      return Future.error(
        SatelliteException(
          SatelliteErrorCode.replicationNotStarted,
          'replication not active',
        ),
      );
    }

    final request = SatUnsubsReq(
      subscriptionIds: subIds,
    );

    return rpc(request);
  }

  void sendMissingRelations(
    DataTransaction transaction,
    OutgoingReplication replication,
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

  void handlePingReq() {
    logger.info(
      "respond to ping with last ack ${inbound.ackLsn != null ? base64.encode(inbound.ackLsn!) : 'NULL'}",
    );
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
      throw StateError('Unexpected ping resp message');
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
        acc.add(serializeColumnData(value));
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
List<int> serializeColumnData(Object columnValue) {
  return TypeEncoder.text(columnValue.toString());
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
