import 'dart:async';
import 'dart:convert';

import 'package:electricsql/satellite.dart';
import 'package:electricsql/src/client/model/shapes.dart';
import 'package:electricsql/src/util/js_array_funs.dart';
import 'package:electricsql/src/util/ohash.dart';
import 'package:electricsql/util.dart';

class RequestedSubscription {
  String? serverId;
  final List<String> overshadowsFullKeys;
  final List<Shape> shapes;
  final String shapeHash;
  final String fullKey;

  RequestedSubscription({
    this.serverId,
    required this.overshadowsFullKeys,
    required this.shapes,
    required this.shapeHash,
    required this.fullKey,
  });

  Map<String, Object?> toMap() {
    return {
      'serverId': serverId,
      'overshadowsFullKeys': overshadowsFullKeys,
      'shapes': shapes.map((s) => s.toMap()).toList(),
      'shapeHash': shapeHash,
      'fullKey': fullKey,
    };
  }

  factory RequestedSubscription.fromMap(Map<String, Object?> map) {
    return RequestedSubscription(
      serverId: map['serverId'] as String?,
      overshadowsFullKeys:
          (map['overshadowsFullKeys']! as List<dynamic>).cast<String>(),
      shapes: (map['shapes']! as List<dynamic>)
          .map((s) => Shape.fromMap(s! as Map<String, Object?>))
          .toList(),
      shapeHash: map['shapeHash']! as String,
      fullKey: map['fullKey']! as String,
    );
  }

  RequestedSubscription copyWith({
    String? Function()? serverId,
  }) {
    return RequestedSubscription(
      serverId: serverId != null ? serverId() : this.serverId,
      overshadowsFullKeys: overshadowsFullKeys,
      shapes: shapes,
      shapeHash: shapeHash,
      fullKey: fullKey,
    );
  }
}

class SyncSubInfo {
  final String key;
  final List<Shape> shapes;
  final SyncStatus status;

  SyncSubInfo({
    required this.key,
    required this.shapes,
    required this.status,
  });
}

typedef OnShapeSyncStatusUpdated = void Function(String key, SyncStatus status);

typedef OptionalRecord<T extends Object> = Map<String, T?>;

class ShapeManager {
  final OnShapeSyncStatusUpdated? _onShapeSyncStatusUpdated;

  /// Uses a full key (hash + key) for indexing
  OptionalRecord<RequestedSubscription> _knownSubscriptions = {};

  /// Maps a key without hash to the full key of latest requested subscription
  OptionalRecord<String> _requestedSubscriptions = {};

  /// Maps a key without hash to the full key of latest active subscription
  OptionalRecord<String> _activeSubscriptions = {};

  /// Maps a key to the full key of requested but not done subscription
  OptionalRecord<String> _unfulfilled = {};

  Map<String, Completer<void>> _promises = {};
  Map<String, String> _serverIds = {};
  Set<String> _incompleteUnsubs = {};

  ShapeManager({
    OnShapeSyncStatusUpdated? onShapeSyncStatusUpdated,
  }) : _onShapeSyncStatusUpdated = onShapeSyncStatusUpdated;

  /// Set internal state using a string returned from {@link ShapeManager#serialize}.
  void initialize(String serializedState) {
    final stateJ = json.decode(serializedState) as Map<String, Object?>;
    // const { unfulfilled, active, known, unsubscribes }
    _knownSubscriptions = _readMapFromStateJson(
      stateJ,
      'known',
      (raw) => RequestedSubscription.fromMap(raw as Map<String, Object?>),
    );
    _unfulfilled =
        _readMapFromStateJson(stateJ, 'unfulfilled', (raw) => raw as String?);
    _activeSubscriptions =
        _readMapFromStateJson(stateJ, 'active', (raw) => raw as String?);
    _incompleteUnsubs = Set.from(stateJ['unsubscribes']! as List<dynamic>);
    _serverIds = Map.fromEntries(
      _knownSubscriptions.values.expand(
        (x) => x?.serverId != null ? [MapEntry(x!.serverId!, x.fullKey)] : [],
      ),
    );
    _promises = {};
    _requestedSubscriptions = {};
  }

  Map<String, T> _readMapFromStateJson<T>(
    Map<String, Object?> stateJ,
    String name,
    T Function(dynamic) toValue,
  ) {
    return (stateJ[name]! as Map<String, dynamic>)
        .map((key, value) => MapEntry(key, toValue(value)));
  }

  /// Serialize internal state for external storage. Can be later loaded with {@link ShapeManager#initialize}
  String serialize() {
    return json.encode({
      'known': _knownSubscriptions
          .map((key, value) => MapEntry(key, value?.toMap())),
      'unfulfilled': _requestedSubscriptions,
      'active': _activeSubscriptions,
      'unsubscribes': [..._incompleteUnsubs],
    });
  }

  /// Reset internal state when the client is reset. Returns all tables that were touched by any of subscriptions.
  List<QualifiedTablename> reset({
    bool? reestablishSubscribed,
    required String defaultNamespace,
  }) {
    final requested = _requestedSubscriptions.values.toList();

    final tables = getTableNamesForShapes(
      _knownSubscriptions.values
          .where((x) => !requested.contains(x?.fullKey))
          .map((x) => x?.shapes)
          .nonNulls
          .expand((x) => x)
          .toList(),
      defaultNamespace,
    );

    OptionalRecord<RequestedSubscription> newKnown = {};
    OptionalRecord<String> unfulfilled = {};

    if (reestablishSubscribed == true) {
      // We'll be taking only the latest for each key
      final relevant = {
        ..._activeSubscriptions,
        ..._requestedSubscriptions,
      }
          .values
          .map((x) => _knownSubscriptions[x!]!)
          .map(
            (x) => MapEntry(
              splitFullKey(x.fullKey).key,
              x.copyWith(serverId: () => null),
            ),
          )
          .toList();

      newKnown = Map.fromEntries(relevant);
      unfulfilled = Map.fromEntries(
        relevant.map((entry) => MapEntry(entry.key, entry.value.fullKey)),
      );
    }

    _knownSubscriptions = newKnown;
    _requestedSubscriptions = {};
    _activeSubscriptions = {};
    _unfulfilled = unfulfilled;
    _promises = {};
    _serverIds = <String, String>{};
    _incompleteUnsubs = {};

    return tables;
  }

  // undefined | "requested" | "active" | "modifying" | "cancelling"

  SyncStatus status(String key) {
    final active = _activeSubscriptions[key] != null
        ? _knownSubscriptions[_activeSubscriptions[key]!]!
        : null;
    final requested = _requestedSubscriptions[key] != null
        ? _knownSubscriptions[_requestedSubscriptions[key]!]!
        : null;

    if (active != null && requested != null && requested.serverId != null) {
      return SyncStatusEstablishing(
        progress: SyncEstablishingProgress.receivingData,
        serverId: requested.serverId!,
        oldServerId: active.serverId,
      );
    } else if (requested != null && requested.serverId != null) {
      return SyncStatusEstablishing(
        progress: SyncEstablishingProgress.receivingData,
        serverId: requested.serverId!,
      );
    } else if (active != null && active.overshadowsFullKeys.isNotEmpty) {
      return SyncStatusEstablishing(
        progress: SyncEstablishingProgress.removingData,
        serverId: active.serverId!,
      );
    } else if (active != null && _incompleteUnsubs.contains(active.serverId)) {
      return SyncStatusCancelling(active.serverId!);
    } else if (active != null) {
      return SyncStatusActive(active.serverId!);
    } else {
      return SyncStatusUndefined();
    }
  }

  /// Get a list of established subscriptions we can continue on reconnection
  List<String> listContinuedSubscriptions() {
    return _activeSubscriptions.values
        .map((x) => _knownSubscriptions[x!]!.serverId!)
        .toList();
  }

  /// List actions that still need to be made after a restart.
  ///
  /// This should be done after initializing, but before any additional sync requests.
  ({
    List<({String key, List<Shape> shapes})> subscribe,
    List<String> unsubscribe,
  }) listPendingActions() {
    return (
      subscribe: _unfulfilled.entries.map((entry) {
        final key = entry.key;
        final fullKey = entry.value;
        return (
          key: key,
          shapes: _knownSubscriptions[fullKey!]!.shapes,
        );
      }).toList(),
      unsubscribe: <String>[
        ..._activeSubscriptions.values
            .expand((x) => _knownSubscriptions[x!]!.overshadowsFullKeys),
        ..._incompleteUnsubs,
      ],
    );
  }

  /// List all subscriptions as defined along with their simple key and sync status
  List<SyncSubInfo> listAllSubscriptions() {
    final allKeys = <String>[
      ..._activeSubscriptions.keys,
      ..._requestedSubscriptions.keys,
    ];

    return allKeys
        .map(
          (key) => SyncSubInfo(
            shapes: _knownSubscriptions[(_activeSubscriptions[key] ??
                    _requestedSubscriptions[key])!]!
                .shapes,
            status: status(key),
            key: key,
          ),
        )
        .toList();
  }

  /// Store a request to sync a list of shapes.
  ///
  /// This should be done before any actual API requests in order to correctly deduplicate concurrent calls
  /// using the same shape.
  ///
  /// A unique key can be used to identify the sync request. If duplicating sync requests with the same key
  /// have been made in the past, then all previous ones will be unsubscribed as soon as this one is fulfilled.
  ///
  /// @param shapes List of shapes to be included in this sync call
  /// @param key Unique key to identify the sync request by
  /// @returns A stored promise object that should be resolved when data arrives
  SyncRequest syncRequested(
    List<Shape> shapes, [
    String? key,
  ]) {
    final shapeHash = hashShapes(shapes);

    final keyOrHash = key ?? shapeHash;
    /* Since multiple requests may have the same key, we'll need to differentiate them
     * based on both hash and key. We use `:` to join them because hash is base64 that
     * won't use this symbol. This is a poor man's tuple to use as an object key.
     */
    final fullKey = makeFullKey(shapeHash, keyOrHash);

    final sub = getLatestSubscription(keyOrHash);

    if (sub != null && sub.shapeHash == shapeHash) {
      // Known & latest subscription with same key and hash.
      // Return an in-flight promise if it's in flight, or a resolved one if not
      return ExistingSyncRequest(
        key: keyOrHash,
        existing: _promises[fullKey]?.future ?? Future.value(),
      );
    } else {
      List<String> overshadowsFullKeys = [];

      if (sub != null) {
        // A known subscription with same key, but with a different hash
        // This means we'll be unsubscribing any previous subscriptions
        // NOTE: order matters here, we depend on it in `syncFailed`.
        overshadowsFullKeys = [sub.fullKey, ...sub.overshadowsFullKeys];
      }

      _knownSubscriptions[fullKey] = RequestedSubscription(
        shapes: shapes,
        shapeHash: shapeHash,
        overshadowsFullKeys: overshadowsFullKeys,
        fullKey: fullKey,
      );

      _requestedSubscriptions[keyOrHash] = fullKey;

      bool notified = false;

      _promises[fullKey] = Completer();
      return NewSyncRequest(
        key: keyOrHash,
        setServerId: (id) {
          _setServerId(fullKey, id);
          if (!notified) {
            notified = true;
            _onShapeSyncStatusUpdated?.call(keyOrHash, status(keyOrHash));
          }
        },
        syncFailed: () => syncFailed(keyOrHash, fullKey),
        promise: _promises[fullKey]!.future,
      );
    }
  }

  void syncFailed(String key, String fullKey) {
    _promises.remove(fullKey);
    final sub = _knownSubscriptions[fullKey]!;

    // We're storing full keys of any subscriptions we were meant to unsubscribe from
    // in `sub.overshadowsFullKeys`, with last subscription's key being the first element.
    // If that last subscription is a requested subscription that still may arrive
    // (i.e. not active), then we're falling back to it so that previous sync call is not
    // invalidated by this one.
    final String? shadowedKey =
        sub.overshadowsFullKeys.isEmpty ? null : sub.overshadowsFullKeys[0];
    if (shadowedKey != null &&
        _requestedSubscriptions[key] == fullKey &&
        _activeSubscriptions[key] != shadowedKey) {
      _requestedSubscriptions[key] = shadowedKey;
    } else if (_requestedSubscriptions[key] == fullKey) {
      _requestedSubscriptions.remove(key);
    }
    _knownSubscriptions.remove(fullKey);
  }

  /// Return latest known subscription for the key - requested first, active next.
  RequestedSubscription? getLatestSubscription(String key) {
    final fullKey = _requestedSubscriptions[key] ?? _activeSubscriptions[key];

    return fullKey != null ? _knownSubscriptions[fullKey] : null;
  }

  void _setServerId(String fullKey, String id) {
    _knownSubscriptions[fullKey]!.serverId ??= id;
    _serverIds[_knownSubscriptions[fullKey]!.serverId!] = fullKey;
  }

  /// Mark the subscription as delivered and resolve waiting promises.
  ///
  /// If the delivered subscription was overshadowing some other previous subscriptions,
  /// the `synced` promise will not be resolved until the unsubscribe was successfully issued.
  List<String> Function() dataDelivered(String serverId) {
    final fullKey = _serverIds[serverId];
    if (fullKey == null || _knownSubscriptions[fullKey] == null) {
      throw Exception('Data received for an unknown subscription');
    }

    final (hash: _, :key) = splitFullKey(fullKey);
    final sub = _knownSubscriptions[fullKey]!;

    if (_requestedSubscriptions[key] == fullKey) {
      _requestedSubscriptions.remove(key);
    }
    _activeSubscriptions[key] = fullKey;

    if (sub.overshadowsFullKeys.isEmpty) {
      _onShapeSyncStatusUpdated?.call(key, status(key));
      return () {
        _promises[fullKey]!.complete();
        _promises.remove(fullKey);
        return [];
      };
    } else {
      final ids = sub.overshadowsFullKeys
          .map((x) => _knownSubscriptions[x]?.serverId)
          .nonNulls
          .toList();
      return () => ids;
    }
  }

  void unsubscribeMade(List<String> serverIds) {
    for (final id in serverIds) {
      _incompleteUnsubs.add(id);

      if (_onShapeSyncStatusUpdated != null) {
        final key = getKeyForServerID(id);
        if (key == null) continue;
        _onShapeSyncStatusUpdated!(key, status(key));
      }
    }
  }

  /// Mark a GONE batch as received from the server after an unsubscribe.
  ///
  void goneBatchDelivered(List<String> serverIds) {
    for (final id in serverIds) {
      final fullKey = _serverIds[id];
      if (fullKey == null) continue;

      final (hash: _, :key) = splitFullKey(fullKey);
      _knownSubscriptions.remove(fullKey);
      _serverIds.remove(id);
      _incompleteUnsubs.remove(id);
      if (_activeSubscriptions[key] == fullKey) {
        _activeSubscriptions.remove(key);
      }

      for (final sub in _getSubscriptionsWaitingForUnsub(fullKey)) {
        sub.overshadowsFullKeys
            .splice(sub.overshadowsFullKeys.indexOf(fullKey), 1);

        if (sub.overshadowsFullKeys.isEmpty &&
            _activeSubscriptions[key] == sub.fullKey) {
          _promises[sub.fullKey]!.complete();
        }
      }

      _onShapeSyncStatusUpdated?.call(key, status(key));
    }
  }

  List<RequestedSubscription> _getSubscriptionsWaitingForUnsub(String fullKey) {
    return _knownSubscriptions.values.nonNulls
        .where((x) => x.overshadowsFullKeys.any((y) => y == fullKey))
        .toList();
  }

  void Function(Object error, [StackTrace? stackTrace])? getOnFailureCallback(
    String serverId,
  ) {
    final fullKey = _serverIds[serverId];
    return fullKey != null ? _promises[fullKey]?.completeError : null;
  }

  List<String> getServerIDs(List<String> keys) {
    return keys
        .map((k) => _activeSubscriptions[k])
        .map((k) => k != null ? _knownSubscriptions[k] : null)
        .map((x) => x?.serverId)
        .nonNulls
        .toList();
  }

  List<String> getServerIDsForShapes(List<Shape> shapes) {
    final shapeHash = hashShapes(shapes);
    final fullKey = makeFullKey(shapeHash, shapeHash);
    final serverId = _knownSubscriptions[fullKey]?.serverId;
    return serverId != null ? [serverId] : [];
  }

  String? getKeyForServerID(String serverId) {
    final fullKey = _serverIds[serverId];
    if (fullKey == null) return null;
    final (hash: _, :key) = splitFullKey(fullKey);
    return key;
  }

  String hashShapes(List<Shape> shapes) {
    // TODO: This sorts the shapes objects for hashing to make sure that order of includes
    //       does not affect the hash. This has the unfortunate consequence of sorting the FK spec,
    //       but the chance of a table having two multi-column FKs over same columns BUT in a
    //       different order feels much lower than people using includes in an arbitrary order.
    final shapeHash = ohash(
      shapes.map((s) => s.toMap()).toList(),
      opts: const OhashOpts(unorderedLists: true),
    );
    return shapeHash;
  }
}

String makeFullKey(String hash, String key) {
  return '$hash:$key';
}

({String hash, String key}) splitFullKey(String fullKey) {
  final res = splitOnce(fullKey, ':');
  return (hash: res.$1, key: res.$2);
}

(String, String) splitOnce(String str, String onS) {
  final found = str.indexOf(onS);
  if (found == -1) {
    return (str, '');
  } else {
    return (str.substring(0, found), str.substring(found + 1));
  }
}

List<QualifiedTablename> getTableNamesForShapes(
  List<Shape> shapes,
  String schema,
) {
  return uniqueList(
    shapes.expand((x) => doGetTableNamesForShape(x, schema)),
  );
}

List<QualifiedTablename> doGetTableNamesForShape(Shape shape, String schema) {
  final includes = shape.include
          ?.expand((x) => doGetTableNamesForShape(x.select, schema))
          .toList() ??
      [];
  includes.add(QualifiedTablename(schema, shape.tablename));
  return includes;
}

sealed class SyncRequest {
  final String key;

  SyncRequest({required this.key});
}

class ExistingSyncRequest extends SyncRequest {
  final Future<void> existing;

  ExistingSyncRequest({required super.key, required this.existing});
}

class NewSyncRequest extends SyncRequest {
  final void Function(String) setServerId;
  final void Function() syncFailed;
  final Future<void> promise;

  NewSyncRequest({
    required super.key,
    required this.setServerId,
    required this.syncFailed,
    required this.promise,
  });
}
