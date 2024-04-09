import 'dart:async';
import 'dart:convert';

import 'package:electricsql/src/auth/auth.dart';
import 'package:electricsql/src/client/model/schema.dart';
import 'package:electricsql/src/config/config.dart';
import 'package:electricsql/src/electric/adapter.dart';
import 'package:electricsql/src/migrators/migrators.dart';
import 'package:electricsql/src/notifiers/notifiers.dart';
import 'package:electricsql/src/proto/satellite.pb.dart';
import 'package:electricsql/src/satellite/config.dart';
import 'package:electricsql/src/satellite/oplog.dart';
import 'package:electricsql/src/satellite/registry.dart';
import 'package:electricsql/src/satellite/satellite.dart';
import 'package:electricsql/src/satellite/shapes/types.dart';
import 'package:electricsql/src/sockets/sockets.dart';
import 'package:electricsql/src/util/common.dart';
import 'package:electricsql/src/util/proto.dart';
import 'package:electricsql/util.dart';
import 'package:fixnum/fixnum.dart';
import 'package:meta/meta.dart';

typedef DataRecord = Record;

const kMockBehindWindowLsn = 42;
const kMockInternalError = 27;

class MockSatelliteProcess implements Satellite {
  @override
  final DbName dbName;
  @override
  final DatabaseAdapter adapter;
  @override
  final Migrator migrator;
  @override
  final Notifier notifier;
  final SocketFactory socketFactory;
  final SatelliteOpts opts;

  String? token;

  @override
  ConnectivityState? connectivityState;

  MockSatelliteProcess({
    required this.dbName,
    required this.adapter,
    required this.migrator,
    required this.notifier,
    required this.socketFactory,
    required this.opts,
  });

  @override
  Future<ShapeSubscription> subscribe(
    List<Shape> shapeDefinitions,
  ) async {
    return ShapeSubscription(synced: Future.value());
  }

  @override
  Future<void> unsubscribe(String shapeUuid) async {
    throw UnimplementedError();
  }

  @override
  Future<void> start(AuthConfig? authConfig) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  @override
  void setToken(String token) {
    this.token = token;
  }

  @override
  bool hasToken() {
    return token != null;
  }

  Future<void> connect() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  @override
  Future<void> connectWithBackoff() async {
    await connect();
  }

  @override
  void disconnect(SatelliteException? error) {}

  @override
  void clientDisconnect() {}

  @override
  Future<void> authenticate(String token) async {}

  @override
  Future<void> stop({bool? shutdown}) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }

  @override
  void setReplicationTransform(
    QualifiedTablename tableName,
    ReplicatedRowTransformer<Record> transform,
  ) {}

  @override
  void clearReplicationTransform(QualifiedTablename tableName) {}
}

@visibleForTesting
class MockRegistry extends BaseRegistry {
  bool _shouldFailToStart = false;

  void setShouldFailToStart(bool shouldFail) {
    _shouldFailToStart = shouldFail;
  }

  @override
  Future<Satellite> startProcess({
    required DbName dbName,
    required DBSchema dbDescription,
    required DatabaseAdapter adapter,
    required Migrator migrator,
    required Notifier notifier,
    required SocketFactory socketFactory,
    required HydratedConfig config,
    SatelliteOverrides? overrides,
  }) async {
    if (_shouldFailToStart) {
      throw Exception('Failed to start satellite process');
    }

    var effectiveOpts = kSatelliteDefaults;
    if (overrides != null) {
      effectiveOpts = effectiveOpts.copyWithOverrides(overrides);
    }

    final satellite = MockSatelliteProcess(
      dbName: dbName,
      adapter: adapter,
      migrator: migrator,
      notifier: notifier,
      socketFactory: socketFactory,
      opts: effectiveOpts,
    );
    await satellite.start(const AuthConfig());

    return satellite;
  }
}

class MockSatelliteClient extends AsyncEventEmitter implements Client {
  bool isDown = false;
  bool replicating = false;
  bool disconnected = true;
  List<int>? inboundAck = kDefaultLogPos;

  List<int> outboundSent = kDefaultLogPos;
  List<DataTransaction> outboundTransactionsEnqueued = [];

  // to clear any pending timeouts
  List<Timer> timeouts = [];

  RelationsCache relations = {};
  void Function(Relation relation)? relationsCb;
  TransactionCallback? transactionsCb;
  AdditionalDataCallback? additionalDataCb;

  Map<String, List<DataRecord>> relationData = {};

  bool deliverFirst = false;

  Duration? _startReplicationDelay;

  void setStartReplicationDelay(Duration? delay) {
    _startReplicationDelay = delay;
  }

  void setRelations(RelationsCache relations) {
    this.relations = relations;

    final _relationsCb = relationsCb;
    if (_relationsCb != null) {
      for (final rel in relations.values) {
        _relationsCb(rel);
      }
    }
  }

  void setRelationData(String tablename, DataRecord record) {
    if (!relationData.containsKey(tablename)) {
      relationData[tablename] = [];
    }
    final data = relationData[tablename]!;

    data.add(record);
  }

  void enableDeliverFirst() {
    deliverFirst = true;
  }

  @override
  Future<SubscribeResponse> subscribe(
    String subscriptionId,
    List<ShapeRequest> shapes,
  ) {
    final data = <InitialDataChange>[];
    final Map<String, String> shapeReqToUuid = {};

    for (final shape in shapes) {
      final Shape(:tablename) = shape.definition;
      if (tablename == 'failure' || tablename == 'Items') {
        return Future.value(
          SubscribeResponse(
            subscriptionId: subscriptionId,
            error: SatelliteException(SatelliteErrorCode.tableNotFound, null),
          ),
        );
      }
      if (tablename == 'another' || tablename == 'User') {
        return Future(() {
          sendErrorAfterTimeout(subscriptionId, 1);
          return SubscribeResponse(
            subscriptionId: subscriptionId,
            error: null,
          );
        });
      } else {
        shapeReqToUuid[shape.requestId] = genUUID();
        final List<DataRecord> records = relationData[tablename] ?? [];

        for (final record in records) {
          final dataChange = InitialDataChange(
            relation: relations[tablename]!,
            record: record,
            tags: [generateTag('remote', DateTime.now())],
          );
          data.add(dataChange);
        }
      }
    }

    return Future(() {
      void emitDelivered() => enqueueEmit(
            kSubscriptionDelivered,
            SubscriptionData(
              subscriptionId: subscriptionId,
              lsn: base64.decode('MTIz'), // base64.encode("123")
              data: data,
              shapeReqToUuid: shapeReqToUuid,
            ),
          );

      final completer = Completer<SubscribeResponse>();
      void resolve() {
        completer.complete(
          SubscribeResponse(
            subscriptionId: subscriptionId,
            error: null,
          ),
        );
      }

      if (deliverFirst) {
        // When the `deliverFirst` flag is set,
        // we deliver the subscription before resolving the promise.
        emitDelivered();
        Timer(const Duration(milliseconds: 1), resolve);
      } else {
        // Otherwise, we resolve the promise before delivering the subscription.
        Timer(const Duration(milliseconds: 1), emitDelivered);
        resolve();
      }

      return completer.future;
    });
  }

  @override
  Future<UnsubscribeResponse> unsubscribe(List<String> _subIds) async {
    return UnsubscribeResponse();
  }

  @override
  SubscriptionEventListeners subscribeToSubscriptionEvents(
    SubscriptionDeliveredCallback successCallback,
    SubscriptionErrorCallback errorCallback,
  ) {
    final removeSuccessListener = _on(kSubscriptionDelivered, successCallback);
    final removeErrorListener = _on(kSubscriptionError, errorCallback);

    return SubscriptionEventListeners(
      removeListeners: () {
        removeSuccessListener();
        removeErrorListener();
      },
    );
  }

  @override
  void unsubscribeToSubscriptionEvents(SubscriptionEventListeners listeners) {
    listeners.removeListeners();
  }

  @override
  void Function() subscribeToError(ErrorCallback callback) {
    return _on('error', callback);
  }

  void emitSocketClosedError(SocketCloseReason ev) {
    enqueueEmit('error', SatelliteException(ev.code, 'socket closed'));
  }

  @override
  bool isConnected() {
    return !disconnected;
  }

  @override
  ReplicationStatus getOutboundReplicationStatus() {
    return isConnected() && replicating
        ? ReplicationStatus.active
        : ReplicationStatus.stopped;
  }

  @override
  void shutdown() {
    isDown = true;
  }

  @override
  LSN getLastSentLsn() {
    return outboundSent;
  }

  @override
  Future<void> connect({
    bool Function(Object error, int attempt)? retryHandler,
  }) async {
    if (isDown) {
      throw SatelliteException(
        SatelliteErrorCode.unexpectedState,
        'FAKE DOWN',
      );
    }

    disconnected = false;
  }

  @override
  void disconnect() {
    disconnected = true;
    for (final t in timeouts) {
      t.cancel();
    }
    return;
  }

  @override
  Future<AuthResponse> authenticate(
    AuthState _authState,
  ) async {
    return AuthResponse(
      null,
      null,
    );
  }

  @override
  Future<StartReplicationResponse> startReplication(
    LSN? lsn,
    String? schemaVersion,
    List<String>? subscriptionIds,
    List<Int64>? observedTransactionData,
    //_resume?: boolean | undefined
  ) async {
    if (_startReplicationDelay != null) {
      await Future<void>.delayed(_startReplicationDelay!);
    }

    replicating = true;
    inboundAck = lsn;

    final t = Timer(
      const Duration(milliseconds: 100),
      () => enqueueEmit<void>('outbound_started', null),
    );
    timeouts.add(t);

    if (lsn != null && bytesToNumber(lsn) == kMockBehindWindowLsn) {
      return StartReplicationResponse(
        error: SatelliteException(
          SatelliteErrorCode.behindWindow,
          'MOCK BEHIND_WINDOW_LSN ERROR',
        ),
      );
    }

    if (lsn != null && bytesToNumber(lsn) == kMockInternalError) {
      return StartReplicationResponse(
        error: SatelliteException(
          SatelliteErrorCode.internal,
          'MOCK INTERNAL_ERROR',
        ),
      );
    }

    return Future.value(StartReplicationResponse());
  }

  @override
  Future<StopReplicationResponse> stopReplication() {
    replicating = false;
    return Future.value(StopReplicationResponse());
  }

  @override
  void Function() subscribeToRelations(
    void Function(Relation relation) callback,
  ) {
    relationsCb = callback;

    return () {
      relationsCb = null;
    };
  }

  @override
  void Function() subscribeToTransactions(
    Future<void> Function(ServerTransaction transaction) callback,
  ) {
    transactionsCb = callback;

    return () {
      transactionsCb = null;
    };
  }

  @override
  void Function() subscribeToAdditionalData(AdditionalDataCallback callback) {
    additionalDataCb = callback;

    return () {
      additionalDataCb = null;
    };
  }

  @override
  void enqueueTransaction(
    DataTransaction transaction,
  ) {
    if (!replicating) {
      throw SatelliteException(
        SatelliteErrorCode.replicationNotStarted,
        'enqueuing a transaction while outbound replication has not started',
      );
    }

    outboundTransactionsEnqueued.add(transaction);
    outboundSent = transaction.lsn;
  }

  @override
  void Function() subscribeToOutboundStarted(
    OutboundStartedCallback callback,
  ) {
    return _on<void>('outbound_started', callback);
  }

  void sendErrorAfterTimeout(String subscriptionId, int timeoutMillis) {
    Timer(Duration(milliseconds: timeoutMillis), () {
      final satSubsError = SatSubsDataError(
        code: SatSubsDataError_Code.SHAPE_DELIVERY_ERROR,
        message: 'there were shape errors',
        subscriptionId: subscriptionId,
        shapeRequestError: [
          SatSubsDataError_ShapeReqError(
            code: SatSubsDataError_ShapeReqError_Code.SHAPE_SIZE_LIMIT_EXCEEDED,
            message:
                "Requested shape for table 'another' exceeds the maximum allowed shape size",
          ),
        ],
      );

      final satError = subsDataErrorToSatelliteError(satSubsError);
      enqueueEmit(
        kSubscriptionError,
        SubscriptionErrorData(subscriptionId: subscriptionId, error: satError),
      );
    });
  }

  @override
  void setReplicationTransform(
    QualifiedTablename tableName,
    ReplicatedRowTransformer<Record> transform,
  ) {
    throw UnimplementedError();
  }

  @override
  void clearReplicationTransform(QualifiedTablename tableName) {
    throw UnimplementedError();
  }

  void Function() _on<T>(
    String eventName,
    FutureOr<void> Function(T) callback,
  ) {
    FutureOr<void> wrapper(dynamic data) {
      return callback(data as T);
    }

    on(eventName, wrapper);

    return () {
      removeListener(eventName, wrapper);
    };
  }
}
