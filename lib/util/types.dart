import 'dart:typed_data';

import 'package:electric_client/proto/satellite.pb.dart';

typedef LSN = List<int>;

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
  Map<int, Relation> relations;
  LSN? ackLsn;
  LSN? enqueuedLsn;
  List<Transaction> transactions;

  Replication({
    required this.authenticated,
    required this.isReplicating,
    required this.relations,
    required this.transactions,
    this.ackLsn,
    this.enqueuedLsn,
  });

  Replication clone() {
    return Replication(
      authenticated: authenticated,
      isReplicating: isReplicating,
      relations: relations,
      transactions: transactions,
      ackLsn: ackLsn,
      enqueuedLsn: enqueuedLsn,
    );
  }
}

class Transaction {
  final int commitTimestamp;
  final Uint8List lsn;
  final List<Change> changes;

  Transaction(this.commitTimestamp, this.lsn, this.changes);
}

enum ChangeType {
  insert,
  update,
  delete,
}

typedef Record = Map<String, Object?>;

class Change {
  final Relation relation;
  final ChangeType type;
  final Record? record;
  final Record? oldRecord;

  Change(this.relation, this.type, this.record, this.oldRecord);
}

class Relation {
  final int id;
  final String schema;
  final String table;
  final SatRelation_RelationType tableType;
  final List<RelationColumn> columns;

  Relation(this.id, this.schema, this.table, this.tableType, this.columns);
}

class RelationColumn {
  final String name;
  final String type;
  final bool? primaryKey;

  RelationColumn(this.name, this.type, this.primaryKey);
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
