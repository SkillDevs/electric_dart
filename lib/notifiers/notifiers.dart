import 'package:electric_client/auth/auth.dart';
import 'package:electric_client/util/tablename.dart';
import 'package:electric_client/util/types.dart';

class AuthStateNotification extends Notification {
  final AuthState authState;

  AuthStateNotification({required this.authState});
}

class Change {
  final QualifiedTablename qualifiedTablename;
  List<RowId>? rowids;

  Change({
    required this.qualifiedTablename,
    this.rowids,
  });
}

class ChangeNotification extends Notification {
  final DbName dbName;
  final List<Change> changes;

  ChangeNotification({required this.dbName, required this.changes});
}

class PotentialChangeNotification extends Notification {
  final DbName dbName;
  PotentialChangeNotification({required this.dbName});
}

class ConnectivityStateChangeNotification extends Notification {
  final DbName dbName;
  final ConnectivityState connectivityState;

  ConnectivityStateChangeNotification({
    required this.dbName,
    required this.connectivityState,
  });
}

abstract class Notification {}

typedef AuthStateCallback = void Function(AuthStateNotification notification);
typedef ChangeCallback = void Function(ChangeNotification notification);
typedef PotentialChangeCallback = void Function(
  PotentialChangeNotification notification,
);

typedef ConnectivityStateChangeCallback = void Function(
  ConnectivityStateChangeNotification notification,
);

typedef NotificationCallback = void Function(Notification notification);

abstract class Notifier {
  // The name of the primary database that components communicating via this
  // notifier have open and are using.
  DbName get dbName;

  // Some drivers can attach other open databases and reference them by alias
  // (i.e.: first you `attach('foo.db')` then you can write SQL queries like
  // `select * from foo.bars`. We keep track of attached databases and their
  // aliases, so we can map the table namespaces in SQL queries to their real
  // database names and thus emit and handle notifications to and from them.
  void attach(DbName dbName, String dbAlias);
  void detach(String dbAlias);

  // Technically, we keep track of the attached dbs in two mappings -- one is
  // `alias: name`, the other `name: alias`.
  AttachedDbIndex get attachedDbIndex;

  // And we provide a helper method to alias changes in the form
  // `{attachedDbName, tablenames}` to `aliasedTablenames`.
  List<QualifiedTablename> alias(ChangeNotification notification);

  // Calling `authStateChanged` notifies the Satellite process that the
  // user's authentication credentials have changed.
  void authStateChanged(AuthState authState);
  String subscribeToAuthStateChanges(AuthStateCallback callback);
  void unsubscribeFromAuthStateChanges(String key);

  // The data change notification workflow starts by the electric database
  // clients (or the user manually) calling `potentiallyChanged` whenever
  // a write or transaction has been issued that may have changed the
  // contents of either the primary or any of the attached databases.
  void potentiallyChanged();

  // Satellite processes subscribe to these "data has potentially changed"
  // notifications. When they get one, they check the `_oplog` table in the
  // database for *actual* changes persisted by the triggers.
  String subscribeToPotentialDataChanges(PotentialChangeCallback callback);
  void unsubscribeFromPotentialDataChanges(String key);

  // When Satellite detects actual data changes in the oplog for a given
  // database, it replicates it and calls  `actuallyChanged` with the list
  // of changes.
  void actuallyChanged(DbName dbName, List<Change> changes);

  // Reactive hooks then subscribe to "data has actually changed" notifications,
  // using the info to trigger re-queries, iff the changes affect databases and
  // tables that their queries depend on. This then trigger re-rendering iff
  // the query results are actually affected by the data changes.
  String subscribeToDataChanges(ChangeCallback callback);
  void unsubscribeFromDataChanges(String key);

  // Notification for network connectivity state changes.
  // A connectivity change s can be triggered manually,
  // or automatically in consequence of internal client events.
  // 'available': network is, or has become, available
  // 'connected': connection to Electric established
  // 'disconnected': Electric is unreachable, or network is unavailable
  // 'error': disconnected with an error (TODO: add error info)
  void connectivityStateChange(String dbName, ConnectivityState state);
  String subscribeToConnectivityStateChange(
    ConnectivityStateChangeCallback callback,
  );
  void unsubscribeFromConnectivityStateChange(String key);
}

class AttachedDbIndex {
  final Map<String, DbName> byAlias;
  final Map<DbName, String> byName;

  AttachedDbIndex({
    required this.byAlias,
    required this.byName,
  });
}
