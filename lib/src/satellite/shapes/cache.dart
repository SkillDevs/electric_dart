

import 'package:electric_client/src/proto/satellite.pb.dart';
import 'package:electric_client/src/satellite/client.dart';
import 'package:electric_client/src/satellite/shapes/types.dart';
import 'package:electric_client/src/util/proto.dart';
import 'package:electric_client/src/util/types.dart';
import 'package:events_emitter/events_emitter.dart';

class SubscriptionDataInternal {
  final String subscriptionId;
  final List<SatTransOp> transaction;
  final Map<String, String> shapeReqToUuid;

  SubscriptionDataInternal({
    required this.subscriptionId,
    required this.transaction,
    required this.shapeReqToUuid,
  });
}

 class SubscriptionsDataCache extends EventEmitter {
  String? requestedSubscription = null;
  Set<String> remainingShapes = {};
  String? currentShapeRequestId;
  SubscriptionDataInternal? inDelivery; 

  SubscriptionsDataCache();
  
  bool isDelivering() {
    return inDelivery != null;
  }

  void subscriptionRequest(SatSubsReq subsRequest) {
    final SatSubsReq(:subscriptionId, :shapeRequests) = subsRequest;
    if (remainingShapes.isNotEmpty) {
      internalError(
        SatelliteErrorCode.unexpectedSubscriptionState,
        "received subscription request but a subscription is already being delivered",
      );
    }
    shapeRequests.forEach((rid) => remainingShapes.add(rid.requestId));
    requestedSubscription = subscriptionId;
  }

  void subscriptionResponse( SatSubsResp resp) {
    if (remainingShapes.isEmpty) {
      internalError(
        SatelliteErrorCode.unexpectedSubscriptionState,
        "Received subscribe response but no subscription has been requested",
      );
    }

    final subscriptionId = resp.subscriptionId;

    if (subscriptionId != requestedSubscription) {
      internalError(
        SatelliteErrorCode.unexpectedSubscriptionState,
        "Received subscribe response but the subscription id does not match the expected",
      );
    }
  }

  void subscriptionDataBegin(SatSubsDataBegin dataBegin) {
    if (requestedSubscription == null) {
      internalError(
        SatelliteErrorCode.unexpectedSubscriptionState,
        "Received SatSubsDataBegin but no subscription is being delivered",
      );
    }

    final subscriptionId = dataBegin.subscriptionId;

    if (requestedSubscription != subscriptionId) {
      internalError(
        SatelliteErrorCode.unexpectedSubscriptionState,
        "subscription identifier in SatSubsDataBegin does not match the expected",
      );
    }

    if (inDelivery != null) {
      internalError(
        SatelliteErrorCode.unexpectedSubscriptionState,
        "received SatSubsDataStart for subscription $subscriptionId but a subscription is already being delivered",
      );
    }

    inDelivery = SubscriptionDataInternal(
      subscriptionId: subscriptionId,
      transaction: [],
      shapeReqToUuid: {},
    );
  }

  SubscriptionDataInternal subscriptionDataEnd(
    Map<int, Relation> relations,
  ) {
    final _inDelivery = inDelivery;
    if (_inDelivery == null) {
      internalError(
        SatelliteErrorCode.unexpectedSubscriptionState,
        "Received SatSubDataEnd but no subscription is being delivered",
      );
    }

    if (remainingShapes.isNotEmpty) {
      internalError(
        SatelliteErrorCode.unexpectedSubscriptionState,
        "Received SatSubDataEnd but not all shapes have been delivered",
      );
    }

    final delivered = _inDelivery;
    final subscriptionData = SubscriptionData(
      subscriptionId: delivered.subscriptionId,
      data: delivered.transaction.map((t) =>
        proccessShapeDataOperations(t, relations),
      ).toList(),
      shapeReqToUuid: delivered.shapeReqToUuid,
    );

    reset();
    emit(SUBSCRIPTION_DELIVERED, subscriptionData);
    return delivered;
  }

  void shapeDataBegin(SatShapeDataBegin shape) {
    final _inDelivery = inDelivery;
    if (_inDelivery == null) {
      internalError(
        SatelliteErrorCode.unexpectedSubscriptionState,
        "Received SatShapeDataBegin but no subscription is being delivered",
      );
    }

    if (remainingShapes.isEmpty) {
      internalError(
        SatelliteErrorCode.unexpectedSubscriptionState,
        "Received SatShapeDataBegin but all shapes have been delivered for this subscription",
      );
    }

    if (currentShapeRequestId != null) {
      internalError(
        SatelliteErrorCode.unexpectedSubscriptionState,
        "Received SatShapeDataBegin for shape with uuid ${shape.uuid} but a shape is already being delivered",
      );
    }

    if (_inDelivery.shapeReqToUuid[shape.requestId] != null) {
      internalError(
        SatelliteErrorCode.unexpectedSubscriptionState,
        "Received SatShapeDataBegin for shape with uuid ${shape.uuid} but shape has already been delivered",
      );
    }

    _inDelivery.shapeReqToUuid[shape.requestId] = shape.uuid;
    currentShapeRequestId = shape.requestId;
  }

  void shapeDataEnd() {
    final _inDelivery = inDelivery;
    if (_inDelivery == null) {
      internalError(
        SatelliteErrorCode.unexpectedSubscriptionState,
        "Received SatShapeDataEnd but no subscription is being delivered",
      );
    }

    if (currentShapeRequestId == null) {
      internalError(
        SatelliteErrorCode.unexpectedSubscriptionState,
        "Received SatShapeDataEnd but no shape is being delivered",
      );
    }

    remainingShapes.remove(currentShapeRequestId);
    currentShapeRequestId = null;
  }

  void transaction(List< SatTransOp> ops) {
    final _inDelivery = inDelivery;
    if (
      remainingShapes.isEmpty ||
      _inDelivery == null ||
      currentShapeRequestId == null
    ) {
      internalError(
        SatelliteErrorCode.unexpectedSubscriptionState,
        "Received SatOpLog but no shape is being delivered",
      );
    }
    for (final op in ops) {
      if (op.hasBegin() || op.hasCommit() || op.hasUpdate() || op.hasDelete()) {
        internalError(
          SatelliteErrorCode.unexpectedMessageType,
          "Received begin, commit, update or delete message, but these messages are not valid in subscriptions",
        );
      }

     _inDelivery.transaction.add(op);
    }
  }

  Never internalError( SatelliteErrorCode code, String msg) {
    reset();
    final error = SatelliteException(code, msg);
    emit(SUBSCRIPTION_ERROR, SubscriptionErrorData(subscriptionId: null, error: error));

    throw error;
  }

  // It is safe to reset the cache state without throwing.
  // However, if message is unexpected, we emit the error
  void subscriptionError() {
    if (remainingShapes.isEmpty || requestedSubscription == null) {
      internalError(
        SatelliteErrorCode.unexpectedSubscriptionState,
        "received subscription error, but no subscription is being requested",
      );
    }

    reset();
  }

  Never subscriptionDataError(SatSubsDataError msg) {
    reset();
    var error = subsDataErrorToSatelliteError(msg);

    if (inDelivery == null) {
      error = SatelliteException(
        SatelliteErrorCode.unexpectedSubscriptionState,
        "received subscription data error, but no subscription is being delivered: ${error.message}",
      );
    }

    emit(SUBSCRIPTION_ERROR, SubscriptionErrorData(subscriptionId: null, error: error));
    throw error;
  }

  void reset() {
    requestedSubscription = null;
    remainingShapes = {};
    currentShapeRequestId = null;
    inDelivery = null;
  }

  InitialDataChange proccessShapeDataOperations(
    SatTransOp op,
    Map<int, Relation> relations,
  ) {
    if (!op.hasInsert()) {
      internalError(
        SatelliteErrorCode.unexpectedMessageType,
        'invalid shape data operation',
      );
    }

    final SatOpInsert(:relationId, :rowData, :tags ) = op.insert;

    final relation = relations[relationId];
    if (relation == null) {
      internalError(
        SatelliteErrorCode.protocolViolation,
        "missing relation $relationId for incoming operation",
      );
    }

    final record = deserializeRow(rowData, relation);

    if (record == null) {
      internalError(
        SatelliteErrorCode.protocolViolation,
        'INSERT operations has no data',
      );
    }

    return InitialDataChange(
      relation: relation,
      record: record,
      tags: tags,
    );
  }
}
