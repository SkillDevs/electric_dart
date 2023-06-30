import 'dart:async';

import 'package:electric_client/src/auth/auth.dart';
import 'package:electric_client/src/config/config.dart';
import 'package:electric_client/src/electric/adapter.dart' hide Transaction;
import 'package:electric_client/src/migrators/migrators.dart';
import 'package:electric_client/src/notifiers/notifiers.dart';
import 'package:electric_client/src/satellite/config.dart';
import 'package:electric_client/src/satellite/registry.dart';
import 'package:electric_client/src/satellite/satellite.dart';
import 'package:electric_client/src/sockets/sockets.dart';
import 'package:electric_client/src/util/common.dart';
import 'package:electric_client/src/util/types.dart';
import 'package:events_emitter/events_emitter.dart';
import 'package:fpdart/fpdart.dart';

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

  MockSatelliteProcess({
    required this.dbName,
    required this.adapter,
    required this.migrator,
    required this.notifier,
    required this.socketFactory,
    required this.opts,
  });

  @override
  Future<ConnectionWrapper> start(AuthConfig authConfig) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));

    return ConnectionWrapper(
      connectionFuture: Future.value(const Right(null)),
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
    required ElectricConfigFilled config,
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
  List<int> inboundAck = kDefaultLogPos;

  List<int> outboundSent = kDefaultLogPos;
  List<int> outboundAck = kDefaultLogPos;

  // to clear any pending timeouts
  List<Timer> timeouts = [];

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
  Future<Either<SatelliteException, void>> connect({
    bool Function(Object error, int attempt)? retryHandler,
  }) async {
    closed = false;
    return right(null);
  }

  @override
  Future<Either<SatelliteException, void>> close() async {
    closed = true;
    for (var t in timeouts) {
      t.cancel();
    }
    return right(Future.value(null));
  }

  @override
  Future<Either<SatelliteException, AuthResponse>> authenticate(
    AuthState _authState,
  ) async {
    return right(
      AuthResponse(
        null,
        null,
      ),
    );
  }

  @override
  Future<Either<SatelliteException, void>> startReplication(
    LSN? lsn,
    //_resume?: boolean | undefined
  ) {
    replicating = true;
    inboundAck = lsn!;

    final t = Timer(
      const Duration(milliseconds: 100),
      () => emit<void>('outbound_started'),
    );
    timeouts.add(t);

    return Future<Right<SatelliteException, void>>.value(const Right(null));
  }

  @override
  Future<Either<SatelliteException, void>> stopReplication() {
    replicating = false;
    return Future<Right<SatelliteException, void>>.value(const Right(null));
  }

  @override
  void subscribeToRelations(void Function(Relation relation) callback) {}

  @override
  void subscribeToTransactions(
    Future<void> Function(Transaction transaction) callback,
  ) {}

  @override
  Either<SatelliteException, void> enqueueTransaction(
    DataTransaction transaction,
  ) {
    outboundSent = transaction.lsn;

    emit('ack_lsn', AckLsnEvent(transaction.lsn, AckType.localSend));

    // simulate ping message effect
    final t = Timer(const Duration(milliseconds: 100), () {
      outboundAck = transaction.lsn;
      emit('ack_lsn', AckLsnEvent(transaction.lsn, AckType.remoteCommit));
    });
    timeouts.add(t);

    return const Right(null);
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
}
