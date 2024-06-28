import 'package:electricsql/drivers/drivers.dart';
import 'package:electricsql/src/auth/auth.dart';
import 'package:electricsql/src/client/model/schema.dart';
import 'package:electricsql/src/client/model/shapes.dart';
import 'package:electricsql/src/config/config.dart';
import 'package:electricsql/src/migrators/migrators.dart';
import 'package:electricsql/src/notifiers/notifiers.dart';
import 'package:electricsql/src/satellite/shapes/types.dart';
import 'package:electricsql/src/sockets/sockets.dart';
import 'package:electricsql/util.dart';
import 'package:fixnum/fixnum.dart';

export 'package:electricsql/src/satellite/process.dart' show ShapeSubscription;

abstract class Registry {
  Map<DbName, Satellite> get satellites;

  Future<Satellite> ensureStarted({
    required DbName dbName,
    required DBSchema dbDescription,
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

abstract class Satellite implements IShapeManager {
  DbName get dbName;
  DatabaseAdapter get adapter;
  Migrator get migrator;
  Notifier get notifier;

  ConnectivityState? connectivityState;

  Future<void> start(AuthConfig? authConfig);
  Future<void> stop({bool? shutdown});
  void setToken(String token);
  bool hasToken();
  Future<void> connectWithBackoff();
  void disconnect(SatelliteException? error);
  void clientDisconnect();
  Future<void> authenticate(String token);

  void setReplicationTransform(
    QualifiedTablename tableName,
    ReplicatedRowTransformer<DbRecord> transform,
  );
  void clearReplicationTransform(QualifiedTablename tableName);
}

abstract class Client {
  Future<void> connect();
  void disconnect();
  Future<void> shutdown();
  Future<AuthResponse> authenticate(
    AuthState authState,
  );
  bool isConnected();
  ReplicationStatus getOutboundReplicationStatus();
  Future<StartReplicationResponse> startReplication(
    LSN? lsn,
    String? schemaVersion,
    List<String>? subscriptionIds,
    List<Int64> observedTransactionData,
  );
  Future<StopReplicationResponse> stopReplication();
  void Function() subscribeToRelations(RelationCallback callback);
  void Function() subscribeToTransactions(TransactionCallback callback);
  void Function() subscribeToAdditionalData(AdditionalDataCallback callback);
  void Function() subscribeToGoneBatch(GoneBatchCallback callback);
  void enqueueTransaction(
    DataTransaction transaction,
  );
  LSN getLastSentLsn();
  void Function() subscribeToOutboundStarted(
    OutboundStartedCallback callback,
  );
  void Function() subscribeToError(ErrorCallback callback);

  Future<SubscribeResponse> subscribe(
    String subscriptionId,
    List<ShapeRequest> shapes,
  );
  Future<UnsubscribeResponse> unsubscribe(List<String> subIds);

  SubscriptionEventListeners subscribeToSubscriptionEvents(
    SubscriptionDeliveredCallback successCallback,
    SubscriptionErrorCallback errorCallback,
  );
  void unsubscribeToSubscriptionEvents(SubscriptionEventListeners listeners);

  void setReplicationTransform(
    QualifiedTablename tableName,
    ReplicatedRowTransformer<DbRecord> transform,
  );
  void clearReplicationTransform(QualifiedTablename tableName);
}

class SubscriptionEventListeners {
  final void Function() removeListeners;

  SubscriptionEventListeners({
    required this.removeListeners,
  });
}
