import 'package:electric_client/src/auth/auth.dart';
import 'package:electric_client/src/config/config.dart';
import 'package:electric_client/src/electric/adapter.dart' hide Transaction;
import 'package:electric_client/src/migrators/migrators.dart';
import 'package:electric_client/src/notifiers/notifiers.dart';
import 'package:electric_client/src/satellite/process.dart';
import 'package:electric_client/src/satellite/shapes/types.dart';
import 'package:electric_client/src/sockets/sockets.dart';
import 'package:electric_client/src/util/types.dart';
import 'package:events_emitter/events_emitter.dart';
import 'package:fpdart/fpdart.dart';

export 'package:electric_client/src/satellite/process.dart' show Sub;

abstract class Registry {
  Future<Satellite> ensureStarted({
    required DbName dbName,
    required DatabaseAdapter adapter,
    required Migrator migrator,
    required Notifier notifier,
    required SocketFactory socketFactory,
    required HydratedConfig config,
  });

  Future<Satellite> ensureAlreadyStarted(DbName dbName);

  Future<void> stop(DbName dbName);

  Future<void> stopAll();
}

class ConnectionWrapper {
  final Future<Either<SatelliteException, void>> connectionFuture;

  ConnectionWrapper({
    required this.connectionFuture,
  });
}

class SatelliteReplicationOptions {
  final bool clearOnBehindWindow;

  SatelliteReplicationOptions({required this.clearOnBehindWindow});
}

abstract class Satellite {
  DbName get dbName;
  DatabaseAdapter get adapter;
  Migrator get migrator;
  Notifier get notifier;

  Future<ConnectionWrapper> start(
    AuthConfig authConfig, {
    SatelliteReplicationOptions? opts,
  });
  Future<void> stop();
  Future<Sub> subscribe(List<ClientShapeDefinition> shapeDefinitions);
  Future<void> unsubscribe(String shapeUuid);
}

abstract class Client {
  Future<Either<SatelliteException, void>> connect({
    bool Function(Object error, int attempt)? retryHandler,
  });
  Future<Either<SatelliteException, void>> close();
  Future<Either<SatelliteException, AuthResponse>> authenticate(
    AuthState authState,
  );
  bool isClosed();
  Future<Either<SatelliteException, void>> startReplication(
    LSN? lsn,
    List<String>? subscriptionIds,
  );
  Future<Either<SatelliteException, void>> stopReplication();
  void subscribeToRelations(void Function(Relation relation) callback);
  void subscribeToTransactions(
    Future<void> Function(Transaction transaction) callback,
  );
  Either<SatelliteException, void> enqueueTransaction(
    DataTransaction transaction,
  );
  EventListener<AckLsnEvent> subscribeToAck(AckCallback callback);
  void unsubscribeToAck(EventListener<AckLsnEvent> eventListener);
  void resetOutboundLogPositions(LSN sent, LSN ack);
  LogPositions getOutboundLogPositions();
  EventListener<void> subscribeToOutboundEvent(void Function() callback);
  void unsubscribeToOutboundEvent(EventListener<void> eventListener);

  Future<SubscribeResponse> subscribe(
    String subscriptionId,
    List<ShapeRequest> shapes,
  );
  Future<UnsubscribeResponse> unsubscribe(List<String> subIds);

  // TODO: there is currently no way of unsubscribing from the server
  // unsubscribe(subscriptionId: string): Promise<void>

  SubscriptionEventListeners subscribeToSubscriptionEvents(
    SubscriptionDeliveredCallback successCallback,
    SubscriptionErrorCallback errorCallback,
  );
  void unsubscribeToSubscriptionEvents(SubscriptionEventListeners listeners);
}

class SubscriptionEventListeners {
  final EventListener<SubscriptionData> successEventListener;
  final EventListener<SubscriptionErrorData> errorEventListener;

  SubscriptionEventListeners({
    required this.successEventListener,
    required this.errorEventListener,
  });
}
