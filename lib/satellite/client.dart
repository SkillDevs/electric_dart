import 'dart:async';
import 'dart:typed_data';

import 'package:electric_client/auth/auth.dart';
import 'package:electric_client/proto/satellite.pb.dart';
import 'package:electric_client/satellite/config.dart';
import 'package:electric_client/sockets/io.dart';
import 'package:electric_client/sockets/sockets.dart';
import 'package:electric_client/util/proto.dart';
import 'package:electric_client/util/types.dart';
import 'package:events_emitter/events_emitter.dart';

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

class Client extends EventEmitter {
  Socket? socket;
  final SatelliteClientOpts opts;

  late final Replication inbound;
  late final Replication outbound;

  Client(this.opts) {
    inbound = resetReplication();
    outbound = resetReplication();
  }

  Replication resetReplication({
    LSN? enqueued,
    LSN? ack,
    ReplicationStatus? isReplicating,
  }) {
    return Replication(
      authenticated: false,
      isReplicating: isReplicating ?? ReplicationStatus.stopped,
      ackLsn: ack,
      enqueuedlsn: enqueued,
      // TODO: transactions
    );
  }

  void Function(Uint8List bytes)? socketHandler;

  DecodedMessage toMessage(Uint8List data) {
    final code = data[0];
    final type = getMsgFromCode(code);

    if (type == null) {
      throw Exception("Null data");
    }

    return DecodedMessage(decodeMessage(data.sublist(1), type), type);
  }

  IncomingHandler getIncomingHandlerForMessage(SatMsgType msgType) {
    switch (msgType) {
      case SatMsgType.authResp:
        return IncomingHandler(
          handle: (v) => handleAuthResp(v as SatAuthResp),
          isRpc: true,
        );

      case SatMsgType.inStartReplicationReq:
        return IncomingHandler(
          handle: (v) => handleInStartReplicationReq(v as SatInStartReplicationReq),
          isRpc: false,
        );
      case SatMsgType.inStartReplicationResp:
        return IncomingHandler(
          handle: (v) => handleInStartReplicationResp(v as SatInStartReplicationResp),
          isRpc: true,
        );

      case SatMsgType.inStopReplicationReq:
        return IncomingHandler(
          handle: (v) => handleInStopReplicationReq(v as SatInStopReplicationReq),
          isRpc: false,
        );

      case SatMsgType.inStopReplicationResp:
        return IncomingHandler(
          handle: (v) => handleInStopReplicationResp(v as SatInStopReplicationResp),
          isRpc: true,
        );

      case SatMsgType.pingReq:
        return IncomingHandler(
          handle: (v) => handlePingReq(v as SatPingReq),
          isRpc: true,
        );

      case SatMsgType.pingResp:
        return IncomingHandler(
          handle: (v) => handlePingResp(v as SatPingResp),
          isRpc: false,
        );

      case SatMsgType.opLog:
        return IncomingHandler(
          handle: (v) => handleOpLog(v as SatOpLog),
          isRpc: false,
        );

      case SatMsgType.relation:
        return IncomingHandler(
          handle: (v) => handleRelation(v as SatRelation),
          isRpc: false,
        );

      case SatMsgType.errorResp:
        return IncomingHandler(
          handle: (v) => handleErrorResp(v as SatErrorResp),
          isRpc: false,
        );

      case SatMsgType.authReq:
      case SatMsgType.migrationNotification:
        throw UnimplementedError();
    }
  }

  Future<void> connect({
    bool Function(Object error, int attempt)? retryHandler,
  }) async {
    final connectPromise = Future<void>(() {
      // TODO: ensure any previous socket is closed, or reject
      if (this.socket != null) {
        throw SatelliteException(
            SatelliteErrorCode.unexpectedState, 'a socket already exist. ensure it is closed before reconnecting.');
      }
      final socket = IoSocket();
      this.socket = socket;

      socket.onceConnect(() {
        if (this.socket == null) {
          throw SatelliteException(SatelliteErrorCode.unexpectedState, 'socket got unassigned somehow');
        }
        socketHandler = (Uint8List message) => handleIncoming(message);
        //notifier.connectivityStateChange(this.dbName, 'connected')
        socket.onMessage(socketHandler!);
        socket.onError((error) {
          // this.notifier.connectivityStateChange(this.dbName, 'error')
        });
        socket.onClose(() {
          // this.notifier.connectivityStateChange(this.dbName, 'disconnected')
        });
      });

      socket.onceError((error) {
        this.socket = null;
        // this.notifier.connectivityStateChange(this.dbName, 'disconnected')
        throw error;
      });

      final host = opts.host;
      final port = opts.port;
      final ssl = opts.ssl;
      final url = "${ssl ? 'wss' : 'ws'}://$host:$port/ws";
      socket.open(ConnectionOptions(url));
    });

    await connectPromise;

    // TODO: Retry policy
    // const retryPolicy = { ...this.connectionRetryPolicy }
    // if (retryHandler) {
    //   retryPolicy.retry = retryHandler
    // }

    // return backOff(() => connectPromise, retryPolicy)
  }

  void handleIncoming(Uint8List data) {
    late final DecodedMessage messageInfo;
    try {
      // TODO: Use union instead of throwing
      messageInfo = toMessage(data);
    } catch (e) {
      print(e);
      // this.emit('error', messageOrError)
      emit("error", messageInfo);
      return;
    }

    print("Received message ${messageInfo.msg.runtimeType}");
    final handler = getIncomingHandlerForMessage(messageInfo.msgType);
    final response = handler.handle(messageInfo.msg);

    print("handle response $response");
    if (handler.isRpc) {
      emit("rpc_response", response);
    }
  }

  Future<AuthResponse> authenticate(AuthState authState) async {
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

  void sendMessage(Object request) {
    print("Sending message $request");
    final _socket = socket;
    if (_socket == null) {
      throw SatelliteException(SatelliteErrorCode.unexpectedState, 'trying to send message, but no socket exists');
    }
    final msgType = getTypeFromSatObject(request);
    if (msgType == null) {
      throw SatelliteException(SatelliteErrorCode.unexpectedMessageType, "${request.runtimeType}");
    }

    final type = getSizeBuf(msgType);
    final msg = encodeMessage(request);

    final totalBufLen = type.length + msg.length;
    final buffer = Uint8List(totalBufLen);
    buffer.setRange(0, 1, type);
    buffer.setRange(1, totalBufLen, msg);

    _socket.write(buffer);
  }

  Future<T> rpc<T>(Object request) async {
    Timer? timer;
    Completer<T> completer = Completer();

    try {
      timer = Timer(Duration(milliseconds: opts.timeout), () {
        print("${request.runtimeType}");
        final error = SatelliteException(SatelliteErrorCode.timeout, "${request.runtimeType}");
        throw error;
      });

      // reject on any error
      late final EventListener errorListener;
      errorListener = on('error', (error) {
        errorListener.cancel();
        completer.completeError(error as Object);
      });

      late final EventListener rpcRespListener;
      rpcRespListener = on('rpc_response', (resp) {
        rpcRespListener.cancel();

        completer.complete(resp as T);
      });

      sendMessage(request);

      return await completer.future;
    } finally {
      timer?.cancel();
    }
  }

  AuthResponse handleAuthResp(Object message) {
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

  void handleInStartReplicationResp(SatInStartReplicationResp value) {}

  void handleInStartReplicationReq(SatInStartReplicationReq value) {}

  void handleInStopReplicationReq(SatInStopReplicationReq value) {}

  void handleInStopReplicationResp(SatInStopReplicationResp value) {}

  void handlePingReq(SatPingReq value) {}

  void handlePingResp(SatPingResp value) {}

  void handleRelation(SatRelation value) {}

  void handleOpLog(SatOpLog value) {}

  void handleErrorResp(SatErrorResp value) {}
}
