import 'package:electric_client/auth/auth.dart';
import 'package:electric_client/config/config.dart';
import 'package:electric_client/electric/adapter.dart' hide Transaction;
import 'package:electric_client/migrators/migrators.dart';
import 'package:electric_client/notifiers/notifiers.dart';
import 'package:electric_client/satellite/config.dart';
import 'package:electric_client/sockets/sockets.dart';
import 'package:electric_client/util/types.dart';
import 'package:events_emitter/events_emitter.dart';
import 'package:fpdart/fpdart.dart';

abstract class Registry {
  Future<Satellite> ensureStarted({
    required DbName dbName,
    required DatabaseAdapter adapter,
    required Migrator migrator,
    required Notifier notifier,
    required SocketFactory socketFactory,
    required ConsoleClient console,
    required ElectricConfigFilled config,
    AuthState? authState,
    SatelliteOverrides? opts,
  });

  Future<Satellite> ensureAlreadyStarted(DbName dbName);

  Future<void> stop(DbName dbName);

  Future<void> stopAll();
}

abstract class Satellite {
  DbName get dbName;
  DatabaseAdapter get adapter;
  Migrator get migrator;
  Notifier get notifier;

  Future<Either<Exception, void>> start(AuthState? authState);
  Future<void> stop();
}

abstract class Client {
  Future<Either<SatelliteException, void>> connect(
      {bool Function(Object error, int attempt)? retryHandler});
  Future<Either<SatelliteException, void>> close();
  Future<Either<SatelliteException, AuthResponse>> authenticate(
      AuthState authState);
  bool isClosed();
  Future<Either<SatelliteException, void>> startReplication(LSN? lsn);
  Future<Either<SatelliteException, void>> stopReplication();
  void subscribeToTransactions(
      Future<void> Function(Transaction transaction) callback);
  Either<SatelliteException, void> enqueueTransaction(Transaction transaction);
  EventListener<AckLsnEvent> subscribeToAck(AckCallback callback);
  void unsubscribeToAck(EventListener<AckLsnEvent> eventListener);
  void resetOutboundLogPositions(LSN sent, LSN ack);
  LogPositions getOutboundLogPositions();
  EventListener<void> subscribeToOutboundEvent(void Function() callback);
  void unsubscribeToOutboundEvent(EventListener<void> eventListener);
}

abstract class ConsoleClient {
  Future<TokenResponse> token(TokenRequest req);
}
