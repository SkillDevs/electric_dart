import 'package:electric_client/src/proto/satellite.pb.dart';
import 'package:electric_client/src/satellite/client.dart';
import 'package:electric_client/src/satellite/shapes/types.dart';
import 'package:electric_client/src/util/proto.dart';
import 'package:electric_client/src/util/types.dart';
import 'package:events_emitter/events_emitter.dart';

typedef SubscriptionId = String;
typedef RequestId = String;

class SubscriptionDataInternal {
  final SubscriptionId subscriptionId;
  final List<int> lsn;
  final List<SatTransOp> transaction;
  final Map<String, String> shapeReqToUuid;

  SubscriptionDataInternal({
    required this.subscriptionId,
    required this.lsn,
    required this.transaction,
    required this.shapeReqToUuid,
  });
}

class SubscriptionsDataCache extends EventEmitter {
  Map<String, Set<RequestId>> requestedSubscriptions = {};
  Set<RequestId> remainingShapes = {};
  RequestId? currentShapeRequestId;
  SubscriptionDataInternal? inDelivery;

  SubscriptionsDataCache();

  bool isDelivering() {
    return inDelivery != null;
  }

  void subscriptionRequest(SatSubsReq subsRequest) {
    final SatSubsReq(:subscriptionId, :shapeRequests) = subsRequest;
    final requestedShapes = Set.of(
      shapeRequests.map((shape) => shape.requestId),
    );
    requestedSubscriptions[subscriptionId] = requestedShapes;
  }

  void subscriptionResponse(SatSubsResp resp) {
    final subscriptionId = resp.subscriptionId;
    if (!requestedSubscriptions.containsKey(subscriptionId)) {
      internalError(
        SatelliteErrorCode.unexpectedSubscriptionState,
        "Received subscribe response for unknown subscription $subscriptionId",
        subId: subscriptionId,
      );
    }
  }

  void subscriptionDataBegin(SatSubsDataBegin dataBegin) {
    final subscriptionId = dataBegin.subscriptionId;
    final lsn = dataBegin.lsn;

    if (!requestedSubscriptions.containsKey(subscriptionId)) {
      internalError(
        SatelliteErrorCode.unexpectedSubscriptionState,
        "Received SatSubsDataBegin but for unknown subscription $subscriptionId",
        subId: subscriptionId,
      );
    }

    final _inDelivery = inDelivery;
    if (_inDelivery != null) {
      internalError(
        SatelliteErrorCode.unexpectedSubscriptionState,
        "received SatSubsDataStart for subscription $subscriptionId but a subscription (${_inDelivery.subscriptionId}) is already being delivered",
        subId: subscriptionId,
      );
    }

    remainingShapes = requestedSubscriptions[subscriptionId]!;
    inDelivery = SubscriptionDataInternal(
      subscriptionId: subscriptionId,
      lsn: lsn,
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
      lsn: delivered.lsn,
      data: delivered.transaction
          .map(
            (t) => proccessShapeDataOperations(t, relations),
          )
          .toList(),
      shapeReqToUuid: delivered.shapeReqToUuid,
    );

    reset(subscriptionData.subscriptionId);
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

  void transaction(List<SatTransOp> ops) {
    final _inDelivery = inDelivery;
    if (remainingShapes.isEmpty ||
        _inDelivery == null ||
        currentShapeRequestId == null) {
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

  Never internalError(
    SatelliteErrorCode code,
    String msg, {
    SubscriptionId? subId,
  }) {
    subId = subId ?? inDelivery?.subscriptionId;
    reset(subId);
    final error = SatelliteException(code, msg);
    emit(
      SUBSCRIPTION_ERROR,
      SubscriptionErrorData(subscriptionId: null, error: error),
    );

    throw error;
  }

  // It is safe to reset the cache state without throwing.
  // However, if message is unexpected, we emit the error
  void subscriptionError(SubscriptionId subId) {
    if (!requestedSubscriptions.containsKey(subId)) {
      internalError(
        SatelliteErrorCode.subscriptionNotFound,
        "received subscription error for unknown subscription $subId",
        subId: subId,
      );
    }

    reset(subId);
  }

  Never subscriptionDataError(SubscriptionId subId, SatSubsDataError msg) {
    reset(subId);
    var error = subsDataErrorToSatelliteError(msg);

    if (inDelivery == null) {
      error = SatelliteException(
        SatelliteErrorCode.unexpectedSubscriptionState,
        "received subscription data error, but no subscription is being delivered: ${error.message}",
      );
    }

    emit(
      SUBSCRIPTION_ERROR,
      SubscriptionErrorData(subscriptionId: null, error: error),
    );
    throw error;
  }

  void reset(SubscriptionId? subscriptionId) {
    if (subscriptionId != null) {
      requestedSubscriptions.remove(subscriptionId);
    }
    if (subscriptionId == inDelivery?.subscriptionId) {
      // Only reset the delivery information
      // if the reset is meant for the subscription
      // that is currently being delivered.
      // This ensures we do not reset delivery information
      // if there is an error for another subscription
      // that is not the one being delivered.

      remainingShapes = {};
      currentShapeRequestId = null;
      inDelivery = null;
    }
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

    final SatOpInsert(:relationId, :rowData, :tags) = op.insert;

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
