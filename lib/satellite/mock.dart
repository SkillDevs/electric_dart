import 'dart:async';

import 'package:electric_client/auth/auth.dart';
import 'package:electric_client/config/config.dart';
import 'package:electric_client/electric/adapter.dart' hide Transaction;
import 'package:electric_client/migrators/migrators.dart';
import 'package:electric_client/notifiers/notifiers.dart';
import 'package:electric_client/satellite/config.dart';
import 'package:electric_client/satellite/registry.dart';
import 'package:electric_client/satellite/satellite.dart';
import 'package:electric_client/sockets/sockets.dart';
import 'package:electric_client/util/common.dart';
import 'package:electric_client/util/types.dart';
import 'package:events_emitter/events_emitter.dart';
import 'package:fpdart/fpdart.dart';

class MockSatelliteProcess implements Satellite {
  final SatelliteConfig config;
  @override
  final DbName dbName;
  @override
  final DatabaseAdapter adapter;
  @override
  final Migrator migrator;
  @override
  final Notifier notifier;
  final SocketFactory socketFactory;
  final ConsoleClient console;
  final SatelliteOpts opts;

  MockSatelliteProcess({
    required this.dbName,
    required this.adapter,
    required this.migrator,
    required this.notifier,
    required this.socketFactory,
    required this.console,
    required this.config,
    required this.opts,
  });

  @override
  Future<Either<Exception, void>> start(AuthState? authState) async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return const Right(null);
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
    required ConsoleClient console,
    required ElectricConfigFilled config,
    AuthState? authState,
    SatelliteOverrides? opts,
  }) async {
    var effectiveOpts = kSatelliteDefaults;
    if (opts != null) {
      effectiveOpts = effectiveOpts.copyWithOverrides(opts);
    }

    final satellite = MockSatelliteProcess(
      dbName: dbName,
      adapter: adapter,
      migrator: migrator,
      notifier: notifier,
      socketFactory: socketFactory,
      console: console,
      config: SatelliteConfig(
        app: config.app,
        env: config.env,
      ),
      opts: effectiveOpts,
    );
    await satellite.start(authState);

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
  Future<Either<SatelliteException, void>> connect(
      {bool Function(Object error, int attempt)? retryHandler}) async {
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
      AuthState _authState) async {
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

    final t = Timer(const Duration(milliseconds: 100),
        () => emit<void>('outbound_started'));
    timeouts.add(t);

    return Future<Right<SatelliteException, void>>.value(const Right(null));
  }

  @override
  Future<Either<SatelliteException, void>> stopReplication() {
    replicating = false;
    return Future<Right<SatelliteException, void>>.value(const Right(null));
  }

  @override
  void subscribeToTransactions(
      Future<void> Function(Transaction transaction) callback) {}

  @override
  Either<SatelliteException, void> enqueueTransaction(Transaction transaction) {
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
