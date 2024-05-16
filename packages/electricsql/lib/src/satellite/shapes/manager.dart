import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:electricsql/src/satellite/shapes/shapes.dart';
import 'package:electricsql/src/satellite/shapes/types.dart';
import 'package:electricsql/src/util/types.dart';
import 'package:events_emitter/events_emitter.dart';

typedef SubcriptionShapeDefinitions = Map<String, List<ShapeDefinition>>;

typedef SubcriptionShapeRequests = Map<String, List<ShapeRequest>>;

typedef GarbageCollectShapeHandler = Future<void> Function(
  List<ShapeDefinition> shapeDefs,
);

class InMemorySubscriptionsManager extends EventEmitter
    implements SubscriptionsManager {
  SubcriptionShapeRequests _inFlight = {};
  SubcriptionShapeDefinitions _fulfilledSubscriptions = {};
  final Map<String, SubscriptionId> _shapeRequestHashmap = {};

  final GarbageCollectShapeHandler? _gcHandler;

  InMemorySubscriptionsManager(GarbageCollectShapeHandler? gcHandler)
      : _gcHandler = gcHandler;

  @override
  void subscriptionRequested(
    SubscriptionId subId,
    List<ShapeRequest> shapeRequests,
  ) {
    if (_inFlight[subId] != null || _fulfilledSubscriptions[subId] != null) {
      throw SatelliteException(
        SatelliteErrorCode.subscriptionAlreadyExists,
        'a subscription with id $subId already exists',
      );
    }

    final requestHash = computeRequestsHash(shapeRequests);

    if (_shapeRequestHashmap.containsKey(requestHash)) {
      throw SatelliteException(
        SatelliteErrorCode.subscriptionAlreadyExists,
        'Subscription with exactly the same shape requests exists. Calling code should use "getDuplicatingSubscription" to avoid establishing same subscription twice',
      );
    }

    _inFlight[subId] = shapeRequests;
    _shapeRequestHashmap[requestHash] = subId;
  }

  @override
  void subscriptionCancelled(SubscriptionId subId) {
    _inFlight.remove(subId);
    removeSubscriptionFromHash(subId);
  }

  @override
  void subscriptionDelivered(SubscriptionData data) {
    final SubscriptionData(:subscriptionId, :shapeReqToUuid) = data;
    if (!_inFlight.containsKey(subscriptionId)) {
      // unknown, or already unsubscribed. delivery is noop
      return;
    }

    final inflight = _inFlight[subscriptionId]!;
    _inFlight.remove(subscriptionId);
    for (final shapeReq in inflight) {
      final resolvedRequest = ShapeDefinition(
        uuid: shapeReqToUuid[shapeReq.requestId]!,
        definition: shapeReq.definition,
      );

      _fulfilledSubscriptions[subscriptionId] =
          _fulfilledSubscriptions[subscriptionId] ?? [];
      _fulfilledSubscriptions[subscriptionId]!.add(resolvedRequest);
    }
  }

  @override
  List<ShapeDefinition>? shapesForActiveSubscription(SubscriptionId subId) {
    return _fulfilledSubscriptions[subId];
  }

  @override
  List<SubscriptionId> getFulfilledSubscriptions() {
    return _fulfilledSubscriptions.keys.toList();
  }

  @override
  DuplicatingSubRes? getDuplicatingSubscription(
    List<Shape> shapes,
  ) {
    final subId = _shapeRequestHashmap[computeClientDefsHash(shapes)];
    if (subId != null) {
      if (_inFlight[subId] != null) {
        return DuplicatingSubInFlight(subId);
      } else {
        return DuplicatingSubFulfilled(subId);
      }
    } else {
      return null;
    }
  }

  void _gcSubscription(SubscriptionId subId) {
    _inFlight.remove(subId);
    _fulfilledSubscriptions.remove(subId);
    removeSubscriptionFromHash(subId);
  }

  void _gcSubscriptions(List<SubscriptionId> subs) {
    for (final sub in subs) {
      _gcSubscription(sub);
    }
  }

  /// Unsubscribes from one or more subscriptions.
  /// @param subId A subscription ID or an array of subscription IDs.
  @override
  void unsubscribe(List<SubscriptionId> subIds) {
    // remove all subscriptions from memory
    _gcSubscriptions(subIds);
  }

  @override
  Future<void> unsubscribeAndGC(List<SubscriptionId> subIds) async {
    final List<ShapeDefinition> shapes = subIds
        .expand(
          (id) => shapesForActiveSubscription(id) ?? <ShapeDefinition>[],
        )
        .toList();

    // GC all subscriptions in a single DB transaction
    if (_gcHandler != null) {
      await _gcHandler!(shapes);
    }
    // also remove all subscriptions from memory
    unsubscribe(subIds);
  }

  @override
  Future<List<SubscriptionId>> unsubscribeAllAndGC() async {
    final ids = _fulfilledSubscriptions.keys.toList();
    await unsubscribeAndGC(ids);
    return ids;
  }

  @override
  String serialize() {
    return json
        .encode(_subcriptionShapeDefinitionsToJson(_fulfilledSubscriptions));
  }

  // TODO: input validation
  @override
  void setState(String serialized) {
    _inFlight = {};
    _fulfilledSubscriptions = _subcriptionShapeDefinitionsFromJson(
      json.decode(serialized) as Map<String, Object?>,
    );

    _shapeRequestHashmap.clear();
    for (final entry in _fulfilledSubscriptions.entries) {
      _shapeRequestHashmap[computeRequestsHash(entry.value)] = entry.key;
    }
  }

  void removeSubscriptionFromHash(SubscriptionId subId) {
    // Rare enough that we can spare inefficiency of not having a reverse map
    for (final MapEntry(key: hash, value: subscription)
        in _shapeRequestHashmap.entries) {
      if (subscription == subId) {
        _shapeRequestHashmap.remove(hash);
        break;
      }
    }
  }
}

Map<String, Object?> _subcriptionShapeDefinitionsToJson(
  SubcriptionShapeDefinitions defs,
) {
  final out = <String, Object?>{};
  for (final entry in defs.entries) {
    final subId = entry.key;
    final shapeDefs = entry.value;
    final shapeDefsJson = shapeDefs.map((e) => e.toMap()).toList();
    out[subId] = shapeDefsJson;
  }
  return out;
}

SubcriptionShapeDefinitions _subcriptionShapeDefinitionsFromJson(
  Map<String, Object?> json,
) {
  final out = <String, List<ShapeDefinition>>{};

  for (final entry in json.entries) {
    final subId = entry.key;
    final shapeDefsJson = entry.value! as List<dynamic>;
    final shapeDefs = shapeDefsJson
        .map((e) => ShapeDefinition.fromMap(e as Map<String, Object?>))
        .toList();
    out[subId] = shapeDefs;
  }

  return out;
}

String computeRequestsHash(List<ShapeRequestOrDefinition> requests) {
  return computeClientDefsHash(requests.map((x) => x.definition).toList());
}

String computeClientDefsHash(List<Shape> requests) {
  // Mimics ohash from NPM
  final StringBuffer buf = StringBuffer();
  buf.write('list:${requests.length}:');
  for (final req in requests) {
    buf.write(_mapPropsToString(req.runtimeType, req.props));
    buf.write(',');
  }

  final strBytes = utf8.encode(buf.toString());
  final sha256bytes = sha256.convert(strBytes).bytes;
  final hash = base64.encode(sha256bytes);
  final substr = hash.substring(0, min(10, hash.length));

  // print("HASH: $buf $hash");
  return substr;
}

String _mapPropsToString(Type runtimeType, List<Object?> props) =>
    '$runtimeType(${props.map((prop) => prop.toString()).join(', ')})';

class MockSubscriptionsManager extends InMemorySubscriptionsManager {
  MockSubscriptionsManager(super.gcHandler) {
    _fulfilledSubscriptions = {
      '1': [
        ShapeDefinition(
          uuid: '00000000-0000-0000-0000-000000000001',
          definition: Shape(tablename: 'users'),
        ),
      ],
      '2': [
        ShapeDefinition(
          uuid: '00000000-0000-0000-0000-000000000002',
          definition: Shape(tablename: 'posts'),
        ),
      ],
    };
  }
}
