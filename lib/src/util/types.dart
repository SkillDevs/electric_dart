// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:electric_client/src/proto/satellite.pb.dart';
import 'package:equatable/equatable.dart';
import 'package:events_emitter/listener.dart';
import 'package:fixnum/fixnum.dart';

typedef LSN = List<int>;
typedef DbName = String;
typedef SqlValue = Object?;
typedef RowId = int;

class Statement with EquatableMixin {
  final String sql;
  final List<Object?>? args;

  Statement(this.sql, [this.args]);

  @override
  String toString() {
    return "Statement($sql, $args)";
  }
  
  @override
  List<Object?> get props => [sql, args];
}

typedef Row = Map<String, Object?>;

class RunResult {
  final int rowsAffected;

  RunResult({required this.rowsAffected});
}

class SatelliteException implements Exception {
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

  subscriptionAlreadyExists,
  unexpectedSubscriptionState,

  // start replication errors
  behindWindow,
  invalidPosition,
  subscriptionNotFound,
  subscriptionError,
  malformedLsn,
  unknownSchemaVersion,

  // subscription errors
  shapeRequestError,
  subscriptionIdAlreadyExists,

  // shape request errors
  tableNotFound,
  referentialIntegrityViolation,
  emptyShapeDefinition,
  duplicateTableInShapeDefinition,

  // shape data errors
  shapeDeliveryError,
  shapeSizeLimitExceeded,
}

class BaseReplication<TransactionType> {
  bool authenticated;
  ReplicationStatus isReplicating;
  Map<int, Relation> relations;
  LSN? ackLsn;
  LSN? enqueuedLsn;
  List<TransactionType> transactions;

  BaseReplication({
    required this.authenticated,
    required this.isReplicating,
    required this.relations,
    required this.transactions,
    this.ackLsn,
    this.enqueuedLsn,
  });

  BaseReplication<TransactionType> clone() {
    return BaseReplication<TransactionType>(
      authenticated: authenticated,
      isReplicating: isReplicating,
      relations: relations,
      transactions: transactions,
      ackLsn: ackLsn,
      enqueuedLsn: enqueuedLsn,
    );
  }
}

typedef Replication = BaseReplication<Transaction>;
typedef OutgoingReplication = BaseReplication<DataTransaction>;

class LogPositions {
  final LSN ack;
  final LSN enqueued;

  LogPositions({
    required this.ack,
    required this.enqueued,
  });
}

class BaseTransaction<ChangeT> with EquatableMixin {
  final Int64 commitTimestamp;
  LSN lsn;

  // This field is only set by transactions coming from Electric
  String? origin;

  final List<ChangeT> changes;

  String? migrationVersion;

  BaseTransaction({
    required this.commitTimestamp,
    required this.lsn,
    required this.changes,
    this.origin,
    this.migrationVersion,
  });

  @override
  List<Object?> get props =>
      [commitTimestamp, lsn, origin, changes, migrationVersion];

  BaseTransaction<ChangeT> clone() {
    return BaseTransaction<ChangeT>(
      commitTimestamp: commitTimestamp,
      lsn: lsn,
      changes: changes,
      origin: origin,
      migrationVersion: migrationVersion,
    );
  }
}

typedef Transaction = BaseTransaction<Change>;

// A transaction whose changes are only DML statements
// i.e. the transaction does not contain migrations
typedef DataTransaction = BaseTransaction<DataChange>;

enum DataChangeType {
  insert,
  update,
  delete,
}

typedef Record = Map<String, Object?>;

typedef Tag = String;

abstract class Change {}

typedef MigrationTable = SatOpMigrate_Table;

enum ChangeType {
  dml, // Data
  ddl, // Schema
}

class SchemaChange extends Change {
  final MigrationTable table; // table affected by the schema change
  final SatOpMigrate_Type migrationType;
  final String sql;

  SchemaChange({
    required this.table,
    required this.migrationType,
    required this.sql,
  });
}

class DataChange extends Change with EquatableMixin {
  final Relation relation;
  final DataChangeType type;
  final Record? record;
  final Record? oldRecord;
  final List<Tag> tags;

  DataChange({
    required this.relation,
    required this.type,
    this.record,
    this.oldRecord,
    required this.tags,
  });

  @override
  List<Object?> get props => [
        relation,
        type,
        record,
        oldRecord,
        tags,
      ];
}

class Relation with EquatableMixin {
  final int id;
  final String schema;
  final String table;
  final SatRelation_RelationType tableType;
  final List<RelationColumn> columns;

  @override
  List<Object?> get props => [
        id,
        schema,
        table,
        // TableType is comparable already because protobuf generated
        // static const values as an enum
        tableType,
        columns,
      ];

  Relation({
    required this.id,
    required this.schema,
    required this.table,
    required this.tableType,
    required this.columns,
  });

  Relation copyWith({
    int? id,
    String? schema,
    String? table,
    SatRelation_RelationType? tableType,
    List<RelationColumn>? columns,
  }) {
    return Relation(
      id: id ?? this.id,
      schema: schema ?? this.schema,
      table: table ?? this.table,
      tableType: tableType ?? this.tableType,
      columns: columns ?? this.columns,
    );
  }
}

class RelationColumn with EquatableMixin {
  final String name;
  final String type;
  final bool? primaryKey;

  RelationColumn({
    required this.name,
    required this.type,
    this.primaryKey,
  });

  @override
  List<Object?> get props => [name, type, primaryKey];
}

enum AckType {
  localSend,
  remoteCommit,
}

typedef AckCallback = EventCallback<AckLsnEvent>;

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

enum ConnectivityState {
  available,
  connected,
  disconnected,
  error,
}
