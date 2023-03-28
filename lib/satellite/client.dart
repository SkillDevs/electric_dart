import 'dart:typed_data';

import 'package:electric_client/proto/satellite.pb.dart';
import 'package:electric_client/util/proto.dart';

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

class SatelliteClient {
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
