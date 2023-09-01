import 'package:electricsql/src/auth/auth.dart';
import 'package:electricsql/src/config/config.dart';
import 'package:electricsql/src/electric/adapter.dart' hide Transaction;
import 'package:electricsql/src/migrators/migrators.dart';
import 'package:electricsql/src/notifiers/notifiers.dart';
import 'package:electricsql/src/satellite/process.dart';
import 'package:electricsql/src/satellite/shapes/types.dart';
import 'package:electricsql/src/sockets/sockets.dart';
import 'package:electricsql/src/util/types.dart';
import 'package:events_emitter/events_emitter.dart';

export 'package:electricsql/src/satellite/process.dart' show ShapeSubscription;

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
  final Future<void> connectionFuture;

  ConnectionWrapper({
    required this.connectionFuture,
  });
}

abstract class Satellite {
  DbName get dbName;
  DatabaseAdapter get adapter;
  Migrator get migrator;
  Notifier get notifier;

  ConnectivityState? connectivityState;

  Future<ConnectionWrapper> start(AuthConfig authConfig);
  Future<void> stop();
  Future<ShapeSubscription> subscribe(
    List<ClientShapeDefinition> shapeDefinitions,
  );
  Future<void> unsubscribe(String shapeUuid);
}

abstract class Client {
  Future<void> connect();
  void close();
  Future<AuthResponse> authenticate(
    AuthState authState,
  );
  bool isClosed();
  Future<StartReplicationResponse> startReplication(
    LSN? lsn,
    String? schemaVersion,
    List<String>? subscriptionIds,
  );
  Future<StopReplicationResponse> stopReplication();
  void subscribeToRelations(void Function(Relation relation) callback);
  void subscribeToTransactions(
    Future<void> Function(Transaction transaction) callback,
  );
  void enqueueTransaction(
    DataTransaction transaction,
  );
  LSN getLastSentLsn();
  EventListener<void> subscribeToOutboundEvent(void Function() callback);
  void unsubscribeToOutboundEvent(EventListener<void> eventListener);
  EventListener<SatelliteException> subscribeToError(ErrorCallback callback);
  void unsubscribeToError(EventListener<SatelliteException> eventListener);

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
