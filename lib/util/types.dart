import 'package:electric_client/proto/satellite.pb.dart';

typedef LSN = List<int>;

class Statement {
  final String sql;
  final List<Object?>? args;

  Statement(this.sql, [this.args]);

  @override
  String toString() {
    return "Statement($sql, $args)";
  }
}

typedef Row = Map<String, Object?>;

class RunResult {
  final int rowsAffected;

  RunResult({required this.rowsAffected});
}

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

class LogPositions {
  final LSN ack;
  final LSN enqueued;

  LogPositions({
    required this.ack,
    required this.enqueued,
  });
}

class Transaction {
  final int commitTimestamp;
  final LSN lsn;
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

  Change({required this.relation, required this.type, this.record, this.oldRecord});
}

class Relation {
  final int id;
  final String schema;
  final String table;
  final SatRelation_RelationType tableType;
  final List<RelationColumn> columns;

  Relation({
    required this.id,
    required this.schema,
    required this.table,
    required this.tableType,
    required this.columns,
  });
}

class RelationColumn {
  final String name;
  final String type;
  final bool? primaryKey;

  RelationColumn({
    required this.name,
    required this.type,
    this.primaryKey,
  });
}

enum AckType {
  localSend,
  remoteCommit,
}

typedef AckCallback = Function(AckLsnEvent evt);

// class Relation {
//   final int id;
//   final String schema;
//   final String table;
//   tableType: SatRelation_RelationType
//   columns: RelationColumn[]
// }

typedef RelationsCache = Map<String, Relation>;

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

class TransactionEvent {
  final Transaction transaction;
  final void Function() ackCb;

  TransactionEvent(this.transaction, this.ackCb);
}

class AckLsnEvent {
  final LSN lsn;
  final AckType ackType;

  AckLsnEvent(this.lsn, this.ackType);
}
