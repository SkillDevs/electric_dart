import 'package:electric_client/src/util/types.dart';

const SUBSCRIPTION_DELIVERED = 'subscription_delivered';
const SUBSCRIPTION_ERROR = 'subscription_error';

typedef SubscriptionDeliveredCallback = void Function(SubscriptionData data);
typedef SubscriptionErrorCallback = void Function(SatelliteException error);

class SubscribeResponse {
  final String subscriptionId;
  final SatelliteException? error;

  SubscribeResponse({
    required this.subscriptionId,
    required this.error,
  });
}

typedef UnsubscribeResponse = Map<String, Never>;

class ClientShapeDefinition {
  final List<ShapeSelect> selects;

  ClientShapeDefinition({
    required this.selects,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'selects': selects.map((x) => x.toMap()).toList(),
    };
  }

  factory ClientShapeDefinition.fromMap(Map<String, dynamic> map) {
    return ClientShapeDefinition(
      selects: List<ShapeSelect>.from(
        (map['selects'] as List<int>).map<ShapeSelect>(
          (x) => ShapeSelect.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }
}

sealed class ShapeRequestOrDefinition {
  final ClientShapeDefinition definition;

  ShapeRequestOrDefinition({
    required this.definition,
  });
}

class ShapeRequest extends ShapeRequestOrDefinition {
  final String requestId;

  ShapeRequest({
    required this.requestId,
    required super.definition,
  });
}

class ShapeDefinition extends ShapeRequestOrDefinition {
  final String uuid;

  ShapeDefinition({
    required this.uuid,
    required super.definition,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'definition': definition.toMap(),
      'uuid': uuid,
    };
  }

  factory ShapeDefinition.fromMap(Map<String, dynamic> map) {
    return ShapeDefinition(
      uuid: map['uuid'] as String,
      definition: ClientShapeDefinition.fromMap(
        map['definition'] as Map<String, dynamic>,
      ),
    );
  }
}

class ShapeSelect {
  final String tablename;

  ShapeSelect({
    required this.tablename,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tablename': tablename,
    };
  }

  factory ShapeSelect.fromMap(Map<String, dynamic> map) {
    return ShapeSelect(
      tablename: map['tablename'] as String,
    );
  }
}

class SubscriptionData {
  final String subscriptionId;
  final List<InitialDataChange> data;
  final Map<String, String> shapeReqToUuid;

  SubscriptionData({
    required this.subscriptionId,
    required this.data,
    required this.shapeReqToUuid,
  });
}

class InitialDataChange {
  final Relation relation;
  final Record? record;
  final List<Tag> tags;

  InitialDataChange({
    required this.relation,
    required this.record,
    required this.tags,
  });
}
