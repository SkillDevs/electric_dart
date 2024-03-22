import 'package:electricsql/src/proto/satellite.pb.dart';
import 'package:electricsql/src/util/types.dart';
import 'package:equatable/equatable.dart';

const kSubscriptionDelivered = 'subscription_delivered';
const kSubscriptionError = 'subscription_error';

typedef SubscriptionId = String;
typedef TableName = String;
typedef ColumnName = String;

typedef SubscriptionDeliveredCallback = Future<void> Function(
  SubscriptionData data,
);
typedef SubscriptionErrorCallback = void Function(SubscriptionErrorData error);

class SubscriptionErrorData {
  final SubscriptionId? subscriptionId;
  final SatelliteException error;

  SubscriptionErrorData({
    required this.subscriptionId,
    required this.error,
  });
}

class SubscribeResponse {
  final SubscriptionId subscriptionId;
  final SatelliteException? error;

  SubscribeResponse({
    required this.subscriptionId,
    required this.error,
  });
}

class UnsubscribeResponse with EquatableMixin {
  @override
  List<Object?> get props => [];
}

class Shape with EquatableMixin {
  final TableName tablename;
  final List<Rel>? include;
  final String? where;

  Shape({required this.tablename, this.include, this.where});

  Map<String, dynamic> toMap() {
    return {
      'tablename': tablename,
      if (where != null) 'where': where,
      if (include != null) 'include': include?.map((e) => e.toMap()).toList(),
    };
  }

  factory Shape.fromMap(Map<String, dynamic> map) {
    return Shape(
      tablename: map['tablename']! as TableName,
      where: map['where'] as String?,
      include: (map['include'] as List<dynamic>?)
          ?.map<Rel>(
            (x) => Rel.fromMap(x as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  @override
  List<Object?> get props => [tablename, include, where];

  SatShapeDef_Select toProto() {
    return SatShapeDef_Select(
      tablename: tablename,
      where: where,
      include: include
          ?.map(
            (e) => SatShapeDef_Relation(
              foreignKey: e.foreignKey,
              select: e.select.toProto(),
            ),
          )
          .toList(),
    );
  }
}

class Rel with EquatableMixin {
  final List<ColumnName> foreignKey; // allows composite FKs
  final Shape select;

  Rel({required this.foreignKey, required this.select});

  @override
  List<Object?> get props => [foreignKey, select];

  Map<String, dynamic> toMap() {
    return {
      'foreignKey': foreignKey,
      'select': select.toMap(),
    };
  }

  factory Rel.fromMap(Map<String, dynamic> map) {
    return Rel(
      foreignKey: List<ColumnName>.from(map['foreignKey'] as List<String>),
      select: Shape.fromMap(map['select'] as Map<String, dynamic>),
    );
  }
}

sealed class ShapeRequestOrDefinition with EquatableMixin {
  final Shape definition;

  ShapeRequestOrDefinition({
    required this.definition,
  });

  @override
  List<Object?> get props => [definition];
}

class ShapeRequest extends ShapeRequestOrDefinition {
  final String requestId;

  ShapeRequest({
    required this.requestId,
    required super.definition,
  });

  @override
  List<Object?> get props => [...super.props, requestId];
}

class ShapeDefinition extends ShapeRequestOrDefinition {
  final String uuid;

  ShapeDefinition({
    required this.uuid,
    required super.definition,
  });

  @override
  List<Object?> get props => [...super.props, uuid];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'definition': definition.toMap(),
      'uuid': uuid,
    };
  }

  factory ShapeDefinition.fromMap(Map<String, dynamic> map) {
    return ShapeDefinition(
      uuid: map['uuid'] as String,
      definition: Shape.fromMap(
        map['definition'] as Map<String, dynamic>,
      ),
    );
  }
}

class SubscriptionData {
  final SubscriptionId subscriptionId;
  final List<int> lsn;
  final List<InitialDataChange> data;
  final Map<String, String> shapeReqToUuid;

  SubscriptionData({
    required this.subscriptionId,
    required this.lsn,
    required this.data,
    required this.shapeReqToUuid,
  });
}

class InitialDataChange {
  final Relation relation;
  final Record record;
  final List<Tag> tags;

  InitialDataChange({
    required this.relation,
    required this.record,
    required this.tags,
  });
}
