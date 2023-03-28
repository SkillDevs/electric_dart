import 'dart:typed_data';

import 'package:electric_client/proto/satellite.pb.dart';

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
  return SatMsgType.values.cast<SatMsgType?>().firstWhere((e) => e!.code == code, orElse: () => null);
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
      return SatPingReq.fromBuffer(data);
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
