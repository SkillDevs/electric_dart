import 'dart:typed_data';

import 'package:electric_client/src/proto/satellite.pb.dart';

const kProtobufPackage = "Electric.Satellite.v1_3";

enum SatMsgType {
  errorResp(code: 0),
  authReq(code: 1),
  authResp(code: 2),
  pingReq(code: 3),
  pingResp(code: 4),
  inStartReplicationReq(code: 5),
  inStartReplicationResp(code: 6),
  inStopReplicationReq(code: 7),
  inStopReplicationResp(code: 8),
  opLog(code: 9),
  relation(code: 10),
  migrationNotification(code: 11);

  const SatMsgType({
    required this.code,
  });

  final int code;
}

SatMsgType? getMsgFromCode(int code) {
  return SatMsgType.values
      .cast<SatMsgType?>()
      .firstWhere((e) => e!.code == code, orElse: () => null);
}

Object decodeMessage(Uint8List data, SatMsgType type) {
  switch (type) {
    case SatMsgType.errorResp:
      return SatErrorResp.fromBuffer(data);
    case SatMsgType.authReq:
      return SatAuthReq.fromBuffer(data);
    case SatMsgType.authResp:
      return SatAuthResp.fromBuffer(data);
    case SatMsgType.pingReq:
      return SatPingReq.fromBuffer(data);
    case SatMsgType.pingResp:
      return SatPingResp.fromBuffer(data);
    case SatMsgType.inStartReplicationReq:
      return SatInStartReplicationReq.fromBuffer(data);
    case SatMsgType.inStartReplicationResp:
      return SatInStartReplicationResp.fromBuffer(data);
    case SatMsgType.inStopReplicationReq:
      return SatInStopReplicationReq.fromBuffer(data);
    case SatMsgType.inStopReplicationResp:
      return SatInStopReplicationResp.fromBuffer(data);
    case SatMsgType.opLog:
      return SatOpLog.fromBuffer(data);
    case SatMsgType.relation:
      return SatRelation.fromBuffer(data);
    case SatMsgType.migrationNotification:
      return SatMigrationNotification.fromBuffer(data);
  }
}

SatMsgType? getTypeFromSatObject(Object object) {
  if (object is SatAuthReq) {
    return SatMsgType.authReq;
  } else if (object is SatPingReq) {
    return SatMsgType.pingReq;
  } else if (object is SatPingResp) {
    return SatMsgType.pingResp;
  } else if (object is SatErrorResp) {
    return SatMsgType.errorResp;
  } else if (object is SatAuthResp) {
    return SatMsgType.authResp;
  } else if (object is SatInStartReplicationResp) {
    return SatMsgType.inStartReplicationResp;
  } else if (object is SatInStartReplicationReq) {
    return SatMsgType.inStartReplicationReq;
  } else if (object is SatInStopReplicationReq) {
    return SatMsgType.inStopReplicationReq;
  } else if (object is SatInStopReplicationResp) {
    return SatMsgType.inStopReplicationResp;
  } else if (object is SatOpLog) {
    return SatMsgType.opLog;
  } else if (object is SatRelation) {
    return SatMsgType.relation;
  } else if (object is SatMigrationNotification) {
    return SatMsgType.migrationNotification;
  }

  return null;
}

Uint8List encodeMessage(Object message) {
  if (message is SatAuthReq) {
    return message.writeToBuffer();
  } else if (message is SatPingReq) {
    return message.writeToBuffer();
  } else if (message is SatPingResp) {
    return message.writeToBuffer();
  } else if (message is SatErrorResp) {
    return message.writeToBuffer();
  } else if (message is SatAuthResp) {
    return message.writeToBuffer();
  } else if (message is SatInStartReplicationResp) {
    return message.writeToBuffer();
  } else if (message is SatInStartReplicationReq) {
    return message.writeToBuffer();
  } else if (message is SatInStopReplicationReq) {
    return message.writeToBuffer();
  } else if (message is SatInStopReplicationResp) {
    return message.writeToBuffer();
  } else if (message is SatOpLog) {
    return message.writeToBuffer();
  } else if (message is SatRelation) {
    return message.writeToBuffer();
  } else if (message is SatMigrationNotification) {
    return message.writeToBuffer();
  }

  throw UnimplementedError("Can't encode ${message.runtimeType}");
}

Uint8List getSizeBuf(SatMsgType msgType) {
  final buf = Uint8List(1);
  buf.setRange(0, 1, [msgType.code]);
  return buf;
}

String getProtocolVersion() {
  return kProtobufPackage;
}
