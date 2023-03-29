import 'dart:typed_data';

typedef LSN = Uint8List;

class SatelliteException {
  final SatelliteErrorCode code;
  final String? message;

  SatelliteException(this.code, this.message);

  @override
  String toString() => "Satellite Exception ($code) $message";
}

enum SatelliteErrorCode {
  internal,
  timeout,
  replicationNotStarted,
  replicationAlreadyStarted,
  unexpectedState,
  unexpectedMessageType,
  protocolViolation,
  unknownDataType,
  authError,
}

class Replication {
  bool authenticated;
  ReplicationStatus isReplicating;
  //Map<int, Relation> relations;
  LSN? ackLsn;
  LSN? enqueuedlsn;
  // List<Transaction> transactions;

  Replication({
    required this.authenticated,
    required this.isReplicating,
    this.ackLsn,
    this.enqueuedlsn,
  });
}

enum AckType {
  localSend,
  remoteCommit,
}

// class Relation {
//   final int id;
//   final String schema;
//   final String table;
//   tableType: SatRelation_RelationType
//   columns: RelationColumn[]
// }

enum ReplicationStatus {
  stopped,
  starting,
  stopping,
  active,
}

class AuthResponse {
  final String? serverId;
  final Object? error;

  AuthResponse(this.serverId, this.error);
}
