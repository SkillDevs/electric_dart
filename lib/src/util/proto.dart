import 'dart:typed_data';

import 'package:electric_client/src/proto/satellite.pb.dart';
import 'package:electric_client/src/satellite/shapes/types.dart';
import 'package:electric_client/src/util/types.dart';

const kProtobufPackage = "Electric.Satellite.v1_4";

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
  migrationNotification(code: 11),
  subsReq(code: 12),
  subsResp(code: 13),
  subsDataError(code: 14),
  subsDataBegin(code: 15),
  subsDataEnd(code: 16),
  shapeDataBegin(code: 17),
  shapeDataEnd(code: 18),
  unsubsReq(code: 19),
  unsubsResp(code: 20);

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
    case SatMsgType.subsReq:
      return SatSubsReq.fromBuffer(data);
    case SatMsgType.subsResp:
      return SatSubsResp.fromBuffer(data);
    case SatMsgType.subsDataError:
      return SatSubsDataError.fromBuffer(data);
    case SatMsgType.subsDataBegin:
      return SatSubsDataBegin.fromBuffer(data);
    case SatMsgType.subsDataEnd:
      return SatSubsDataEnd.fromBuffer(data);
    case SatMsgType.shapeDataBegin:
      return SatShapeDataBegin.fromBuffer(data);
    case SatMsgType.shapeDataEnd:
      return SatShapeDataEnd.fromBuffer(data);
    case SatMsgType.unsubsReq:
      return SatUnsubsReq.fromBuffer(data);
    case SatMsgType.unsubsResp:
      return SatUnsubsResp.fromBuffer(data);
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
  } else if (object is SatSubsReq) {
    return SatMsgType.subsReq;
  } else if (object is SatSubsResp) {
    return SatMsgType.subsResp;
  } else if (object is SatSubsDataError) {
    return SatMsgType.subsDataError;
  } else if (object is SatSubsDataBegin) {
    return SatMsgType.subsDataBegin;
  } else if (object is SatSubsDataEnd) {
    return SatMsgType.subsDataEnd;
  } else if (object is SatShapeDataBegin) {
    return SatMsgType.shapeDataBegin;
  } else if (object is SatShapeDataEnd) {
    return SatMsgType.shapeDataEnd;
  } else if (object is SatUnsubsReq) {
    return SatMsgType.unsubsReq;
  } else if (object is SatUnsubsResp) {
    return SatMsgType.unsubsResp;
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
  } else if (message is SatSubsReq) {
    return message.writeToBuffer();
  } else if (message is SatSubsResp) {
    return message.writeToBuffer();
  } else if (message is SatSubsDataError) {
    return message.writeToBuffer();
  } else if (message is SatSubsDataBegin) {
    return message.writeToBuffer();
  } else if (message is SatSubsDataEnd) {
    return message.writeToBuffer();
  } else if (message is SatShapeDataBegin) {
    return message.writeToBuffer();
  } else if (message is SatShapeDataEnd) {
    return message.writeToBuffer();
  } else if (message is SatUnsubsReq) {
    return message.writeToBuffer();
  } else if (message is SatUnsubsResp) {
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

const Map<SatInStartReplicationResp_ReplicationError_Code, SatelliteErrorCode>
    startReplicationErrorToSatError = {
  SatInStartReplicationResp_ReplicationError_Code.CODE_UNSPECIFIED:
      SatelliteErrorCode.internal,
  SatInStartReplicationResp_ReplicationError_Code.BEHIND_WINDOW:
      SatelliteErrorCode.behindWindow,
  SatInStartReplicationResp_ReplicationError_Code.INVALID_POSITION:
      SatelliteErrorCode.invalidPosition,
  SatInStartReplicationResp_ReplicationError_Code.SUBSCRIPTION_NOT_FOUND:
      SatelliteErrorCode.subscriptionNotFound,
};

const Map<SatSubsResp_SatSubsError_Code, SatelliteErrorCode>
    subsErrorToSatError = {
  SatSubsResp_SatSubsError_Code.CODE_UNSPECIFIED: SatelliteErrorCode.internal,
  SatSubsResp_SatSubsError_Code.SHAPE_REQUEST_ERROR:
      SatelliteErrorCode.shapeRequestError,
  SatSubsResp_SatSubsError_Code.SUBSCRIPTION_ID_ALREADY_EXISTS:
      SatelliteErrorCode.subscriptionIdAlreadyExists,
};

const Map<SatSubsResp_SatSubsError_ShapeReqError_Code, SatelliteErrorCode>
    subsErrorShapeReqErrorToSatError = {
  SatSubsResp_SatSubsError_ShapeReqError_Code.CODE_UNSPECIFIED:
      SatelliteErrorCode.internal,
  SatSubsResp_SatSubsError_ShapeReqError_Code.TABLE_NOT_FOUND:
      SatelliteErrorCode.tableNotFound,
  SatSubsResp_SatSubsError_ShapeReqError_Code.REFERENTIAL_INTEGRITY_VIOLATION:
      SatelliteErrorCode.referentialIntegrityViolation,
};

const Map<SatSubsDataError_Code, SatelliteErrorCode> subsDataErrorToSatError = {
  SatSubsDataError_Code.CODE_UNSPECIFIED: SatelliteErrorCode.internal,
  SatSubsDataError_Code.SHAPE_DELIVERY_ERROR:
      SatelliteErrorCode.shapeDeliveryError,
};

const Map<SatSubsDataError_ShapeReqError_Code, SatelliteErrorCode>
    subsDataErrorShapeReqToSatError = {
  SatSubsDataError_ShapeReqError_Code.CODE_UNSPECIFIED:
      SatelliteErrorCode.internal,
  SatSubsDataError_ShapeReqError_Code.SHAPE_SIZE_LIMIT_EXCEEDED:
      SatelliteErrorCode.shapeSizeLimitExceeded,
};

SatelliteException startReplicationErrorToSatelliteError(
  SatInStartReplicationResp_ReplicationError error,
) {
  return SatelliteException(
    startReplicationErrorToSatError[error.code] ?? SatelliteErrorCode.internal,
    error.message,
  );
}

SatelliteException subsErrorToSatelliteError(
  SatSubsResp_SatSubsError satError,
) {
  final shapeRequestError = satError.shapeRequestError;
  final message = satError.message;
  final code = satError.code;

  if (shapeRequestError.isNotEmpty) {
    final shapeErrorMsgs = shapeRequestError
        .map(subsShapeReqErrorToSatelliteError)
        .map((e) => e.message)
        .join('; ');
    final composed =
        "subscription error message: $message; shape error messages: $shapeErrorMsgs";
    return SatelliteException(
      subsErrorToSatError[code] ?? SatelliteErrorCode.internal,
      composed,
    );
  }
  return SatelliteException(
    subsErrorToSatError[code] ?? SatelliteErrorCode.internal,
    message,
  );
}

SatelliteException subsShapeReqErrorToSatelliteError(
  SatSubsResp_SatSubsError_ShapeReqError error,
) {
  return SatelliteException(
    subsErrorShapeReqErrorToSatError[error.code] ?? SatelliteErrorCode.internal,
    error.message,
  );
}

SatelliteException subsDataErrorToSatelliteError(SatSubsDataError satError) {
  final shapeRequestError = satError.shapeRequestError;
  final message = satError.message;
  final code = satError.code;

  if (shapeRequestError.isNotEmpty) {
    final shapeErrorMsgs = shapeRequestError
        .map(subsDataShapeErrorToSatelliteError)
        .map((e) => e.message)
        .join('; ');
    final composed =
        "subscription data error message: $message; shape error messages: $shapeErrorMsgs";
    return SatelliteException(
      subsDataErrorToSatError[code] ?? SatelliteErrorCode.internal,
      composed,
    );
  }
  return SatelliteException(
    subsDataErrorToSatError[code] ?? SatelliteErrorCode.internal,
    message,
  );
}

SatelliteException subsDataShapeErrorToSatelliteError(
  SatSubsDataError_ShapeReqError error,
) {
  return SatelliteException(
    subsDataErrorShapeReqToSatError[error.code] ?? SatelliteErrorCode.internal,
    error.message,
  );
}

List<SatShapeReq> shapeRequestToSatShapeReq(List<ShapeRequest> shapeRequests) {
  final shapeReqs = <SatShapeReq>[];
  for (final sr in shapeRequests) {
    final requestId = sr.requestId;
    final selects = sr.definition.selects.map(
      (s) => SatShapeDef_Select(
        tablename: s.tablename,
      ),
    );
    final shapeDefinition = SatShapeDef(selects: selects);

    final req = SatShapeReq(
      requestId: requestId,
      shapeDefinition: shapeDefinition,
    );
    shapeReqs.add(req);
  }
  return shapeReqs;
}
