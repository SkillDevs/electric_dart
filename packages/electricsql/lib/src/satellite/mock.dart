import 'dart:async';
import 'dart:convert';

import 'package:electricsql/src/auth/auth.dart';
import 'package:electricsql/src/client/model/schema.dart' hide Relation;
import 'package:electricsql/src/client/model/shapes.dart';
import 'package:electricsql/src/config/config.dart';
import 'package:electricsql/src/electric/adapter.dart';
import 'package:electricsql/src/migrators/migrators.dart';
import 'package:electricsql/src/notifiers/notifiers.dart';
import 'package:electricsql/src/proto/satellite.pb.dart';
import 'package:electricsql/src/satellite/config.dart';
import 'package:electricsql/src/satellite/oplog.dart';
import 'package:electricsql/src/satellite/registry.dart';
import 'package:electricsql/src/satellite/satellite.dart';
import 'package:electricsql/src/satellite/shapes/shape_manager.dart';
import 'package:electricsql/src/satellite/shapes/types.dart';
import 'package:electricsql/src/sockets/sockets.dart';
import 'package:electricsql/src/util/common.dart';
import 'package:electricsql/src/util/encoders/encoders.dart';
import 'package:electricsql/src/util/proto.dart';
import 'package:electricsql/util.dart';
import 'package:fixnum/fixnum.dart';
import 'package:meta/meta.dart';

typedef DataRecord = DbRecord;

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
  late ConnectivityState? connectivityState =
      const ConnectivityState(status: ConnectivityStatus.disconnected);

  MockSatelliteProcess({
    required this.dbName,
    required this.adapter,
    required this.migrator,
    required this.notifier,
    required this.socketFactory,
    required this.opts,
  });

  @override
  SyncStatus syncStatus(String key) {
    return SyncStatusUndefined();
  }

  @override
  Future<ShapeSubscription> subscribe(
    List<Shape> shapeDefinitions, [
    String? key,
  ]) async {
    return ShapeSubscription(
      key: 'test',
      synced: Future.value(),
    );
  }

  @override
  Future<void> unsubscribe(List<String> shapeUuids) async {
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
    ReplicatedRowTransformer<DbRecord> transform,
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

    final String namespace = migrator.queryBuilder.defaultNamespace;
    var effectiveOpts = satelliteDefaults(namespace);
    if (overrides != null) {
      effectiveOpts = effectiveOpts.copyWithOverrides(overrides);
    }

    if (satellites[dbName] != null) {
      return satellites[dbName]!;
    }

    final satellite = MockSatelliteProcess(
      dbName: dbName,
      adapter: adapter,
      migrator: migrator,
      notifier: notifier,
      socketFactory: socketFactory,
      opts: effectiveOpts,
    );
    satellites[dbName] = satellite;
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
  OutboundStartedCallback? outboundStartedCallback;

  Map<String, List<DataRecord>> relationData = {};
  Map<String, List<DataChange>> goneBatches = {};

  bool deliverFirst = false;
  bool doSkipNextEmit = false;

  Duration? _startReplicationDelay;

  Map<String, ReplicatedRowTransformer<DbRecord>> replicationTransforms = {};

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

  void setGoneBatch(
    String subscriptionId,
    List<({String tablename, Map<String, Object?> record})> batch,
  ) {
    goneBatches[subscriptionId] = batch
        .map(
          (x) => DataChange(
            type: DataChangeType.gone,
            tags: [],
            relation: relations[x.tablename]!,
            oldRecord: x.record,
          ),
        )
        .toList();
  }

  void enableDeliverFirst() {
    deliverFirst = true;
  }

  void skipNextEmit() {
    doSkipNextEmit = true;
  }

  @override
  Future<SubscribeResponse> subscribe(
    String subscriptionId,
    List<ShapeRequest> shapes,
  ) {
    final data = <InitialDataChange>[];
    final Map<String, String> shapeReqToUuid = {};

    for (final shape in shapes) {
      final tables = getTableNamesForShapes([shape.definition], 'main');

      for (final qualTable in tables) {
        final tablename = qualTable.tablename;

        if (tablename == 'failure' || tablename == 'Items') {
          return Future.value(
            SubscribeResponse(
              subscriptionId: subscriptionId,
              error: SatelliteException(SatelliteErrorCode.tableNotFound, null),
            ),
          );
        } else if (tablename == 'another' || tablename == 'User') {
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
    }

    return Future(() {
      void emit() => enqueueEmit(
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
        emit();
        Timer(const Duration(milliseconds: 1), resolve);
      } else {
        // Otherwise, we resolve the promise before delivering the subscription.
        if (!doSkipNextEmit) {
          Timer(const Duration(milliseconds: 1), emit);
        } else {
          doSkipNextEmit = false;
        }
        resolve();
      }

      return completer.future;
    });
  }

  @override
  Future<UnsubscribeResponse> unsubscribe(List<String> subIds) async {
    final gone = <DataChange>[];

    for (final id in subIds) {
      gone.addAll(goneBatches[id] ?? []);
      goneBatches.remove(id);
    }

    Timer(
      const Duration(milliseconds: 1),
      () => enqueueEmit(
        'goneBatch',
        GoneBatch(
          lsn: base64.decode(
            base64.encode(utf8.encode('124')),
          ),
          subscriptionIds: subIds,
          changes: gone,
        ),
      ),
    );
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
  void Function() subscribeToGoneBatch(GoneBatchCallback callback) {
    return _on('goneBatch', callback);
  }

  @override
  void Function() subscribeToError(ErrorCallback callback) {
    return _on('error', callback);
  }

  void emitSocketClosedError(SocketCloseReason ev) {
    enqueueEmit(
      'error',
      (SatelliteException(ev.code, 'socket closed'), StackTrace.current),
    );
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
  Future<void> shutdown() async {
    await waitForProcessing();
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
    return AuthResponse(null);
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
      return StartReplicationResponse.withError(
        SatelliteException(
          SatelliteErrorCode.behindWindow,
          'MOCK BEHIND_WINDOW_LSN ERROR',
        ),
        StackTrace.current,
      );
    }

    if (lsn != null && bytesToNumber(lsn) == kMockInternalError) {
      return StartReplicationResponse.withError(
        SatelliteException(
          SatelliteErrorCode.internal,
          'MOCK INTERNAL_ERROR',
        ),
        StackTrace.current,
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
    outboundStartedCallback = callback;
    final clean = _on<void>('outbound_started', callback);
    return () {
      clean();
      outboundStartedCallback = null;
    };
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
        SubscriptionErrorData(
          subscriptionId: subscriptionId,
          error: satError,
          stackTrace: StackTrace.current,
        ),
      );
    });
  }

  @override
  void setReplicationTransform(
    QualifiedTablename tableName,
    ReplicatedRowTransformer<DbRecord> transform,
  ) {
    replicationTransforms[tableName.tablename] = transform;
  }

  @override
  void clearReplicationTransform(QualifiedTablename tableName) {
    replicationTransforms.remove(tableName.tablename);
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
