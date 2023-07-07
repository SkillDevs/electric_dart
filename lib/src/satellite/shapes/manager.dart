import 'dart:convert';

import 'package:electric_client/src/satellite/shapes/shapes.dart';
import 'package:electric_client/src/satellite/shapes/types.dart';
import 'package:electric_client/src/util/types.dart';
import 'package:events_emitter/events_emitter.dart';

typedef SubcriptionShapeDefinitions = Map<String, List<ShapeDefinition>>;

typedef SubcriptionShapeRequests = Map<String, List<ShapeRequest>>;

typedef GarbageCollectShapeHandler = Future<void> Function(
    List<ShapeDefinition> shapeDefs,);

class InMemorySubscriptionsManager extends EventEmitter
    implements SubscriptionsManager {
  SubcriptionShapeRequests _inFlight = {};
  SubcriptionShapeDefinitions _subToShapes = {};

  final GarbageCollectShapeHandler? _gcHandler;

  InMemorySubscriptionsManager(GarbageCollectShapeHandler? gcHandler)
      : _gcHandler = gcHandler;

  @override
  void subscriptionRequested(String subId, List<ShapeRequest> shapeRequests) {
    if (_inFlight[subId] != null || _subToShapes[subId] != null) {
      throw SatelliteException(SatelliteErrorCode.subscriptionAlreadyExists,
          "a subscription with id $subId already exists",);
    }

    _inFlight[subId] = shapeRequests;
  }

  @override
  void subscriptionCancelled(String subId) {
    _inFlight.remove(subId);
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
      final shapeRequestOrResolved = shapeReq; // as ShapeRequestOrDefinition;

      if (!_subToShapes.containsKey(subscriptionId)) {
        _subToShapes[subscriptionId] = [];
      }
      final shapes = _subToShapes[subscriptionId]!;

      final uuid = shapeReqToUuid[shapeReq.requestId]!;
      final shapeDef = ShapeDefinition(
          uuid: uuid, definition: shapeRequestOrResolved.definition,);
      shapes.add(shapeDef);
    }
  }

  @override
  List<ShapeDefinition>? shapesForActiveSubscription(String subId) {
    return _subToShapes[subId];
  }

  @override
  Future<void> unsubscribe(String subId) async {
    final shapes = shapesForActiveSubscription(subId);
    if (shapes != null) {
      if (_gcHandler != null) {
        await _gcHandler!(shapes);
      }

      _inFlight.remove(subId);
      _subToShapes.remove(subId);
    }
  }

  @override
  Future<List<String>> unsubscribeAll() async {
    final ids = _subToShapes.keys.toList();
    for (final subId in ids) {
      await unsubscribe(subId);
    }
    return ids;
  }

  @override
  String serialize() {
    return json.encode(_subcriptionShapeDefinitionsToJson(_subToShapes));
  }

  // TODO: input validation
  @override
  void setState(String serialized) {
    _inFlight = {};
    _subToShapes = _subcriptionShapeDefinitionsFromJson(json.decode(serialized) as Map<String, Object?>);
  }
}

Map<String, Object?> _subcriptionShapeDefinitionsToJson(
    SubcriptionShapeDefinitions defs,) {
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
