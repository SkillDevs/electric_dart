import 'package:collection/collection.dart';
import 'package:electricsql/src/auth/auth.dart';
import 'package:electricsql/src/notifiers/notifiers.dart';
import 'package:electricsql/src/util/debug/debug.dart';
import 'package:electricsql/src/util/random.dart';
import 'package:electricsql/src/util/tablename.dart';
import 'package:electricsql/src/util/types.dart' hide Change;
import 'package:events_emitter/events_emitter.dart';
import 'package:meta/meta.dart';

class EventNames {
  static const String authChange = 'auth:changed';
  static const actualDataChange = 'data:actually:changed';
  static const potentialDataChange = 'data:potentially:changed';
  static const connectivityStateChange = 'network:connectivity:changed';
}

// Global singleton that all event notifiers use by default. Emitting an event
// on this object will notify all subscribers in the same thread. Cross thread
// notifications use the `./bridge` notifiers.
final globalEmitter = EventEmitter();

class EventNotifier implements Notifier {
  @override
  final DbName dbName;

  @override
  late final AttachedDbIndex attachedDbIndex;

  late final EventEmitter events;

  late final Map<String, EventListener<dynamic>> _changeCallbacks;

  @visibleForTesting
  Map<String, EventListener<dynamic>> get changeCallbacks => _changeCallbacks;

  late final Map<String, EventListener<dynamic>> _connectivityStatusCallbacks;

  @visibleForTesting
  Map<String, EventListener<dynamic>> get connectivityStatusCallbacks =>
      _connectivityStatusCallbacks;

  EventNotifier({required this.dbName, EventEmitter? eventEmitter}) {
    attachedDbIndex = AttachedDbIndex(
      byAlias: {},
      byName: {},
    );

    events = eventEmitter ?? globalEmitter;

    _changeCallbacks = {};
    _connectivityStatusCallbacks = {};
  }

  @override
  void attach(DbName dbName, String dbAlias) {
    final idx = attachedDbIndex;

    idx.byAlias[dbAlias] = dbName;
    idx.byName[dbName] = dbAlias;
  }

  @override
  void detach(String dbAlias) {
    final idx = attachedDbIndex;

    if (idx.byAlias.containsKey(dbAlias)) {
      final dbName = idx.byAlias[dbAlias];

      idx.byAlias.remove(dbAlias);
      idx.byName.remove(dbName);
    }
  }

  @override
  List<QualifiedTablename> alias(ChangeNotification notification) {
    final dbName = notification.dbName;
    final changes = notification.changes;
    final idx = attachedDbIndex;
    final primaryDbName = this.dbName;

    return changes
        .map((change) {
          final qualifiedTablename = change.qualifiedTablename;
          if (dbName == primaryDbName) {
            return qualifiedTablename;
          }

          final dbAlias = idx.byName[dbName];
          if (dbAlias != null) {
            return QualifiedTablename(dbAlias, qualifiedTablename.tablename);
          }
        })
        .whereNotNull()
        .toList();
  }

  @override
  void authStateChanged(AuthState authState) {
    _emitAuthStateChange(authState);
  }

  @override
  String subscribeToAuthStateChanges(AuthStateCallback callback) {
    final key = randomValue();

    final eventListener = EventListener(EventNames.authChange, callback);

    _changeCallbacks[key] = eventListener;
    _subscribe(eventListener);

    return key;
  }

  @override
  void unsubscribeFromAuthStateChanges(String key) {
    final listener = _changeCallbacks[key];

    if (listener == null) {
      return;
    }

    _unsubscribe(listener);

    _changeCallbacks.remove(key);
  }

  @override
  void potentiallyChanged() {
    final dbNames = _getDbNames();

    dbNames.forEach(_emitPotentialChange);
  }

  @override
  void actuallyChanged(DbName dbName, List<Change> changes) {
    logger.info('actually changed notifier');
    if (!_hasDbName(dbName)) {
      return;
    }

    _emitActualChange(dbName, changes);
  }

  @override
  String subscribeToPotentialDataChanges(PotentialChangeCallback callback) {
    final key = randomValue();

    void wrappedCallback(PotentialChangeNotification notification) {
      if (_hasDbName(notification.dbName)) {
        callback(notification);
      }
    }

    final eventListener =
        EventListener(EventNames.potentialDataChange, wrappedCallback);

    _changeCallbacks[key] = eventListener;
    _subscribe(eventListener);

    return key;
  }

  @override
  void unsubscribeFromPotentialDataChanges(String key) {
    final listener = _changeCallbacks[key];

    if (listener == null) {
      return;
    }

    _unsubscribe(listener);

    _changeCallbacks.remove(key);
  }

  @override
  String subscribeToDataChanges(ChangeCallback callback) {
    final key = randomValue();

    void wrappedCallback(ChangeNotification notification) {
      if (_hasDbName(notification.dbName)) {
        callback(notification);
      }
    }

    final eventListener =
        EventListener(EventNames.actualDataChange, wrappedCallback);
    _changeCallbacks[key] = eventListener;
    _subscribe(eventListener);

    return key;
  }

  @override
  void unsubscribeFromDataChanges(String key) {
    final listener = _changeCallbacks[key];

    if (listener == null) {
      return;
    }

    _unsubscribe(listener);

    _changeCallbacks.remove(key);
  }

  @override
  void connectivityStateChanged(String dbName, ConnectivityState status) {
    if (!_hasDbName(dbName)) {
      return;
    }

    _emitConnectivityStatus(dbName, status);
  }

  @override
  String subscribeToConnectivityStateChanges(
    ConnectivityStateChangeCallback callback,
  ) {
    final key = randomValue();

    void wrappedCallback(ConnectivityStateChangeNotification notification) {
      if (_hasDbName(notification.dbName)) {
        callback(notification);
      }
      return;
    }

    final eventListener =
        EventListener(EventNames.connectivityStateChange, wrappedCallback);
    _connectivityStatusCallbacks[key] = eventListener;
    _subscribe(eventListener);

    return key;
  }

  @override
  void unsubscribeFromConnectivityStateChanges(String key) {
    final listener = _connectivityStatusCallbacks[key];

    if (listener == null) {
      return;
    }

    _unsubscribe(listener);

    _connectivityStatusCallbacks.remove(key);
  }

  List<DbName> _getDbNames() {
    final idx = attachedDbIndex;

    return [dbName, ...idx.byName.keys];
  }

  bool _hasDbName(DbName dbName) {
    final idx = attachedDbIndex;

    return dbName == this.dbName || idx.byAlias.containsKey(dbName);
  }

  // Extracting out these methods allows them to be overridden
  // without duplicating any dbName filter / check logic, etc.
  AuthStateNotification _emitAuthStateChange(AuthState authState) {
    final notification = AuthStateNotification(
      authState: authState,
    );

    emit(EventNames.authChange, notification);

    return notification;
  }

  PotentialChangeNotification _emitPotentialChange(DbName dbName) {
    final notification = PotentialChangeNotification(
      dbName: dbName,
    );

    emit(EventNames.potentialDataChange, notification);

    return notification;
  }

  ChangeNotification _emitActualChange(DbName dbName, List<Change> changes) {
    final notification = ChangeNotification(
      dbName: dbName,
      changes: changes,
    );

    emit(EventNames.actualDataChange, notification);

    return notification;
  }

  ConnectivityStateChangeNotification _emitConnectivityStatus(
    DbName dbName,
    ConnectivityState connectivityState,
  ) {
    final notification = ConnectivityStateChangeNotification(
      dbName: dbName,
      connectivityState: connectivityState,
    );

    emit(EventNames.connectivityStateChange, notification);

    return notification;
  }

  @protected
  void emit(String eventName, Notification notification) {
    events.emit(eventName, notification);
  }

  void _subscribe(EventListener<dynamic> eventListener) {
    events.addEventListener(eventListener);
  }

  void _unsubscribe(EventListener<dynamic> eventListener) {
    events.removeEventListener(eventListener);
  }
}
