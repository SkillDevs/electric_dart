import 'dart:async';
import 'dart:convert';

import 'package:electricsql/src/proto/satellite.pb.dart';
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
    return 'Statement(sql: $sql, args: $args)';
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
  String toString() => 'Satellite Exception ($code) $message';

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'code': code.index,
      'message': message,
    };
  }

  factory SatelliteException.fromMap(Map<String, dynamic> map) {
    return SatelliteException(
      SatelliteErrorCode.values[map['code'] as int],
      map['message'] as String?,
    );
  }
}

enum SatelliteErrorCode {
  connectionCancelledByDisconnect,
  connectionFailedAfterRetry,
  internal,
  timeout,
  replicationNotStarted,
  replicationAlreadyStarted,
  unexpectedState,
  unexpectedMessageType,
  protocolViolation,
  unknownDataType,
  socketError,
  unrecognized,
  fatalError,

  // auth errors
  authError,
  authFailed,
  authRequired,
  authExpired,

  // server errors
  invalidRequest,
  protoVersionMismatch,
  replicationFailed,

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
  subscriptionAlreadyExists,
  unexpectedSubscriptionState,

  // shape request errors
  tableNotFound,
  referentialIntegrityViolation,
  emptyShapeDefinition,
  duplicateTableInShapeDefinition,
  invalidWhereClauseInShapeDefinition,
  invalidIncludeTreeInShapeDefinition,

  // shape data errors
  shapeDeliveryError,
  shapeSizeLimitExceeded,

  // replication transform errors
  replicationTransformError,
}

class SocketCloseReason {
  final SatelliteErrorCode code;

  SocketCloseReason._(this.code);

  static final authExpired =
      SocketCloseReason._(SatelliteErrorCode.authExpired);

  static final socketError =
      SocketCloseReason._(SatelliteErrorCode.socketError);
}

class Replication<TransactionType> {
  bool authenticated;
  ReplicationStatus isReplicating;
  Map<int, Relation> relations;
  LSN? lastLsn;
  List<TransactionType> transactions;

  Replication({
    required this.authenticated,
    required this.isReplicating,
    required this.relations,
    required this.transactions,
    this.lastLsn,
  });

  Replication<TransactionType> clone() {
    return Replication<TransactionType>(
      authenticated: authenticated,
      isReplicating: isReplicating,
      relations: relations,
      transactions: transactions,
      lastLsn: lastLsn,
    );
  }
}

enum IncompletionType { transaction, additionalData }

class SeenAdditionalDataInfo {
  final List<String> subscriptions;
  final List<Int64> dataRefs;

  SeenAdditionalDataInfo({required this.subscriptions, required this.dataRefs});
}

class InboundReplication extends Replication<ServerTransaction> {
  Int64? lastTxId;
  Int64? lastAckedTxId;
  int unackedTxs;
  int maxUnackedTxs;
  Timer ackTimer;
  int ackPeriod;
  List<AdditionalData> additionalData;
  Set<String> unseenAdditionalDataRefs;
  IncompletionType? incomplete;
  SeenAdditionalDataInfo seenAdditionalDataSinceLastTx;

  InboundReplication({
    required super.authenticated,
    required super.isReplicating,
    required super.relations,
    required super.transactions,
    super.lastLsn,
    this.lastTxId,
    this.lastAckedTxId,
    required this.unackedTxs,
    required this.maxUnackedTxs,
    required this.ackTimer,
    required this.ackPeriod,
    required this.additionalData,
    required this.unseenAdditionalDataRefs,
    this.incomplete,
    required this.seenAdditionalDataSinceLastTx,
  });
}

class BaseTransaction<ChangeT> with EquatableMixin {
  final Int64 commitTimestamp;
  LSN lsn;

  // This field is only set by transactions coming from Electric
  String? origin;

  List<ChangeT> changes;

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

class ServerTransaction extends Transaction {
  final Int64? id;
  final Int64? additionalDataRef;

  ServerTransaction({
    required super.commitTimestamp,
    required super.lsn,
    required super.changes,
    super.origin,
    super.migrationVersion,
    required this.id,
    this.additionalDataRef,
  });
}

class AdditionalData {
  final Int64 ref;
  final List<DataChange> changes;

  AdditionalData({
    required this.ref,
    required this.changes,
  }) : assert(
          changes.every((element) => element.type == DataChangeType.insert),
          'AdditionalData changes must be of type insert',
        );
}

enum DataChangeType {
  insert,
  update,
  delete,
  compensation,
  gone,
}

typedef DbRecord = Map<String, Object?>;

typedef Tag = String;

abstract class Change {}

typedef MigrationTable = SatOpMigrate_Table;

enum ChangeType {
  dml, // Data
  ddl, // Schema
}

class SchemaChange extends Change with EquatableMixin {
  final MigrationTable table; // table affected by the schema change
  final SatOpMigrate_Type migrationType;
  final String sql;

  SchemaChange({
    required this.table,
    required this.migrationType,
    required this.sql,
  });

  @override
  List<Object?> get props => [table, migrationType, sql];
}

class DataChange extends Change with EquatableMixin {
  final Relation relation;
  final DataChangeType type;
  final DbRecord? record;
  final DbRecord? oldRecord;
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

  DataChange copyWith({
    Relation? relation,
    DataChangeType? type,
    DbRecord? Function()? record,
    DbRecord? Function()? oldRecord,
    List<Tag>? tags,
  }) {
    return DataChange(
      relation: relation ?? this.relation,
      type: type ?? this.type,
      record: record?.call() ?? this.record,
      oldRecord: oldRecord?.call() ?? this.oldRecord,
      tags: tags ?? this.tags,
    );
  }
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
  final bool isNullable;
  final int? primaryKey;

  RelationColumn({
    required this.name,
    required this.type,
    required this.isNullable,
    this.primaryKey,
  });

  @override
  List<Object?> get props => [name, type, isNullable, primaryKey];
}

class ReplicatedRowTransformer<RowType> {
  final RowType Function(RowType row) transformInbound;
  final RowType Function(RowType row) transformOutbound;

  ReplicatedRowTransformer({
    required this.transformInbound,
    required this.transformOutbound,
  });
}

typedef ErrorCallback = EventCallbackCall<(SatelliteException, StackTrace)>;
typedef RelationCallback = EventCallbackCall<Relation>;
typedef AdditionalDataCallback = Future<void> Function(AdditionalData);
typedef TransactionCallback = Future<void> Function(ServerTransaction);
typedef IncomingTransactionCallback = EventCallbackCall<TransactionEvent>;
typedef IncomingAdditionalDataCallback = EventCallbackCall<AdditionalDataEvent>;
typedef OutboundStartedCallback = EventCallbackCall<void>;

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
  final StackTrace? stackTrace;

  AuthResponse(this.serverId)
      : error = null,
        stackTrace = null;

  AuthResponse.withError(
    Object this.error,
    StackTrace this.stackTrace,
  ) : serverId = null;
}

class StartReplicationResponse {
  final SatelliteException? error;
  final StackTrace? stackTrace;

  StartReplicationResponse()
      : error = null,
        stackTrace = null;

  StartReplicationResponse.withError(
    SatelliteException this.error,
    StackTrace this.stackTrace,
  );
}

class StopReplicationResponse {
  final SatelliteException? error;
  final StackTrace? stackTrace;

  StopReplicationResponse()
      : error = null,
        stackTrace = null;

  StopReplicationResponse.withError(
    SatelliteException this.error,
    StackTrace this.stackTrace,
  );
}

class TransactionEvent {
  final ServerTransaction transaction;
  final void Function() ackCb;

  TransactionEvent(this.transaction, this.ackCb);
}

class AdditionalDataEvent {
  final AdditionalData additionalData;
  final void Function() ackCb;

  AdditionalDataEvent(this.additionalData, this.ackCb);
}

enum ConnectivityStatus {
  connected,
  disconnected,
}

class ConnectivityState {
  final ConnectivityStatus status;

  /// reason for `disconnected` status
  final SatelliteException? reason;

  const ConnectivityState({required this.status, this.reason});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'status': status.index,
      'reason': reason?.toMap(),
    };
  }

  factory ConnectivityState.fromMap(Map<String, dynamic> map) {
    return ConnectivityState(
      status: ConnectivityStatus.values[map['status'] as int],
      reason: map['reason'] != null
          ? SatelliteException.fromMap(map['reason'] as Map<String, dynamic>)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ConnectivityState.fromJson(String source) =>
      ConnectivityState.fromMap(json.decode(source) as Map<String, dynamic>);
}
