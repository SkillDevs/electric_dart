import 'dart:async';
import 'dart:convert';

import 'package:electricsql/src/auth/auth.dart';
import 'package:electricsql/src/config/config.dart';
import 'package:electricsql/src/electric/adapter.dart' hide Transaction;
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
import 'package:electricsql/src/util/types.dart';
import 'package:events_emitter/events_emitter.dart';

typedef DataRecord = Record;

const kMockBehindWindowLsn = 42;
const kMockInvalidPositionLsn = 27;

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
    List<ClientShapeDefinition> shapeDefinitions,
  ) async {
    return ShapeSubscription(synced: Future.value());
  }

  @override
  Future<void> unsubscribe(String shapeUuid) async {
    throw UnimplementedError();
  }

  @override
  Future<ConnectionWrapper> start(AuthConfig authConfig) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));

    return ConnectionWrapper(
      connectionFuture: Future.value(),
    );
  }

  @override
  Future<void> stop() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
  }
}

class MockRegistry extends BaseRegistry {
  @override
  Future<Satellite> startProcess({
    required DbName dbName,
    required DatabaseAdapter adapter,
    required Migrator migrator,
    required Notifier notifier,
    required SocketFactory socketFactory,
    required HydratedConfig config,
    SatelliteOverrides? overrides,
  }) async {
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
    await satellite.start(config.auth);

    return satellite;
  }
}

class MockSatelliteClient extends EventEmitter implements Client {
  bool replicating = false;
  bool closed = true;
  List<int>? inboundAck = kDefaultLogPos;

  List<int> outboundSent = kDefaultLogPos;
  List<int> outboundAck = kDefaultLogPos;

  // to clear any pending timeouts
  List<Timer> timeouts = [];

  RelationsCache relations = {};

  Map<String, List<DataRecord>> relationData = {};

  void setRelations(RelationsCache relations) {
    this.relations = relations;
  }

  void setRelationData(String tablename, DataRecord record) {
    if (!relationData.containsKey(tablename)) {
      relationData[tablename] = [];
    }
    final data = relationData[tablename]!;

    data.add(record);
  }

  @override
  Future<SubscribeResponse> subscribe(
    String subscriptionId,
    List<ShapeRequest> shapes,
  ) {
    final data = <InitialDataChange>[];
    final Map<String, String> shapeReqToUuid = {};

    for (final shape in shapes) {
      for (final ShapeSelect(:tablename) in shape.definition.selects) {
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
          shapeReqToUuid[shape.requestId] = uuid();
          final List<DataRecord> records = relationData[tablename]!;

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
      Timer(const Duration(milliseconds: 1), () {
        emit(
          kSubscriptionDelivered,
          SubscriptionData(
            subscriptionId: subscriptionId,
            lsn: base64.decode('MTIz'), // base64.encode("123")
            data: data,
            shapeReqToUuid: shapeReqToUuid,
          ),
        );
      });

      return SubscribeResponse(
        subscriptionId: subscriptionId,
        error: null,
      );
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
    final successListener = on(kSubscriptionDelivered, successCallback);
    final errorListener = on(kSubscriptionError, errorCallback);

    return SubscriptionEventListeners(
      successEventListener: successListener,
      errorEventListener: errorListener,
    );
  }

  @override
  void unsubscribeToSubscriptionEvents(SubscriptionEventListeners listeners) {
    removeEventListener(listeners.successEventListener);
    removeEventListener(listeners.errorEventListener);
  }

  @override
  bool isClosed() {
    return closed;
  }

  @override
  void resetOutboundLogPositions(LSN sent, LSN ack) {
    outboundSent = sent;
    outboundAck = ack;
  }

  @override
  LogPositions getOutboundLogPositions() {
    return LogPositions(enqueued: outboundSent, ack: outboundAck);
  }

  @override
  Future<void> connect({
    bool Function(Object error, int attempt)? retryHandler,
  }) async {
    closed = false;
  }

  @override
  void close() {
    closed = true;
    _removeAllListeners();
    for (final t in timeouts) {
      t.cancel();
    }
    return;
  }

  void _removeAllListeners() {
    // Prevent concurrent modification
    for (final listener in [...listeners]) {
      removeEventListener(listener);
    }
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
    //_resume?: boolean | undefined
  ) {
    replicating = true;
    inboundAck = lsn;

    final t = Timer(
      const Duration(milliseconds: 100),
      () => emit<void>('outbound_started'),
    );
    timeouts.add(t);

    if (lsn != null && bytesToNumber(lsn) == kMockBehindWindowLsn) {
      return Future.value(
        StartReplicationResponse(
          error: SatelliteException(
            SatelliteErrorCode.behindWindow,
            'MOCK BEHIND_WINDOW_LSN ERROR',
          ),
        ),
      );
    }

    if (lsn != null && bytesToNumber(lsn) == kMockInvalidPositionLsn) {
      return Future.value(
        StartReplicationResponse(
          error: SatelliteException(
            SatelliteErrorCode.invalidPosition,
            'MOCK INVALID_POSITION ERROR',
          ),
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
  void subscribeToRelations(void Function(Relation relation) callback) {}

  @override
  void subscribeToTransactions(
    Future<void> Function(Transaction transaction) callback,
  ) {}

  @override
  void enqueueTransaction(
    DataTransaction transaction,
  ) {
    outboundSent = transaction.lsn;

    emit('ack_lsn', AckLsnEvent(transaction.lsn, AckType.localSend));

    // simulate ping message effect
    final t = Timer(const Duration(milliseconds: 500), () {
      outboundAck = transaction.lsn;
      emit('ack_lsn', AckLsnEvent(transaction.lsn, AckType.remoteCommit));
    });
    timeouts.add(t);
  }

  @override
  EventListener<AckLsnEvent> subscribeToAck(AckCallback ackCallback) {
    return on('ack_lsn', ackCallback);
  }

  @override
  void unsubscribeToAck(EventListener<AckLsnEvent> eventListener) {
    removeEventListener(eventListener);
  }

  void setOutboundLogPositions(LSN sent, LSN ack) {
    outboundSent = sent;
    outboundAck = ack;
  }

  @override
  EventListener<void> subscribeToOutboundEvent(void Function() callback) {
    return on<void>('outbound_started', (_) => callback());
  }

  @override
  void unsubscribeToOutboundEvent(EventListener<void> eventListener) {
    removeEventListener(eventListener);
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
      emit(
        kSubscriptionError,
        SubscriptionErrorData(subscriptionId: subscriptionId, error: satError),
      );
    });
  }
}
