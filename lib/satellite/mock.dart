import 'dart:async';

import 'package:electric_client/auth/auth.dart';
import 'package:electric_client/satellite/satellite.dart';
import 'package:electric_client/util/common.dart';
import 'package:electric_client/util/types.dart';
import 'package:events_emitter/events_emitter.dart';
import 'package:fpdart/fpdart.dart';

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

  LogPositions getOutboundLogPositions() {
    return LogPositions(enqueued: outboundSent, ack: outboundAck);
  }

  @override
  Future<Either<SatelliteException, void>> connect({bool Function(Object error, int attempt)? retryHandler}) async {
    closed = false;
    return right(null);
  }

  Future<Either<SatelliteException, void>> close() async {
    closed = true;
    for (var t in timeouts) {
      t.cancel();
    }
    return right(Future.value(null));
  }

  @override
  Future<Either<SatelliteException, AuthResponse>> authenticate(AuthState _authState) async {
    return right(AuthResponse(
      null,
      null,
    ));
  }

  @override
  Future<Either<SatelliteException, void>> startReplication(
    LSN? lsn,
    //_resume?: boolean | undefined
  ) {
    replicating = true;
    inboundAck = lsn!;

    final t = Timer(Duration(milliseconds: 100), () => emit('outbound_started'));
    timeouts.add(t);

    return Future<Right<SatelliteException, void>>.value(Right(null));
  }

  @override
  Future<Either<SatelliteException, void>> stopReplication() {
    replicating = false;
    return Future<Right<SatelliteException, void>>.value(Right(null));
  }

  @override
  void subscribeToTransactions(Future<void> Function(Transaction transaction) callback) {}

  @override
  Either<SatelliteException, void> enqueueTransaction(Transaction transaction) {
    outboundSent = transaction.lsn;

    emit('ack_lsn', AckLsnEvent(transaction.lsn, AckType.localSend));

    // simulate ping message effect
    final t = Timer(Duration(milliseconds: 100), () {
      outboundAck = transaction.lsn;
      emit('ack_lsn', AckLsnEvent(transaction.lsn, AckType.remoteCommit));
    });
    timeouts.add(t);

    return Right(null);
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
