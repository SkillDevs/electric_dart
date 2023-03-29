import 'dart:convert';
import 'dart:typed_data';

import 'package:electric_client/proto/satellite.pb.dart';
import 'package:electric_client/satellite/config.dart';
import 'package:electric_client/sockets/io.dart';
import 'package:electric_client/sockets/sockets.dart';
import 'package:electric_client/util/proto.dart';
import 'package:electric_client/util/types.dart';
import 'package:eventify/eventify.dart';

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

class Client with EventEmitter {
  Socket? socket;
  final SatelliteClientOpts opts;

  Client(this.opts);

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
      emit("error", null, messageInfo);
      return;
    }

    print("Received message ${messageInfo.msg.runtimeType}");
    final handler = getIncomingHandlerForMessage(messageInfo.msgType);
    final response = handler.handle(messageInfo.msg);

    if (handler.isRpc) {
      emit("rpc_response", null, response);
    }
  }

  void handleAuthResp(SatAuthResp value) {}

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
