import 'dart:convert';

import 'package:electric_client/src/satellite/shapes/manager.dart';
import 'package:electric_client/src/satellite/shapes/types.dart';
import 'package:test/test.dart';

import '../satellite/common.dart';

void main() {
  late InMemorySubscriptionsManager manager;

  setUp(() {
    manager = InMemorySubscriptionsManager(null);
  });

  test('some tests', () {
    // the ids
    const subscriptionId = 'sub';
    const requestId = 'shaxx_1';
    const uuid = 'shape_1';
    const tablename = 'parent';
    const shapeReqToUuid = <String, String>{
      requestId: uuid,
    };

    // the shape
    final definition = ClientShapeDefinition(
      selects: [
        ShapeSelect(
          tablename: tablename,
        ),
      ],
    );

    final shapeRequest = ShapeRequest(
      requestId: requestId,
      definition: definition,
    );

    final shapeDefinition = ShapeDefinition(
      uuid: uuid,
      definition: definition,
    );

    const parentRecord = {
      "id": 1,
      "value": 'incoming',
      "other": 1,
    };

    final dataChange = InitialDataChange(
      relation: kTestRelations[tablename]!,
      record: parentRecord,
      tags: [],
    );

    final subscriptionData = SubscriptionData(
      subscriptionId: subscriptionId,
      lsn: base64.decode('MTIz'),
      data: [dataChange],
      shapeReqToUuid: shapeReqToUuid,
    );

    // no active subscription while inflight
    manager.subscriptionRequested(subscriptionId, [shapeRequest]);
    expect(manager.shapesForActiveSubscription(subscriptionId), null);

    // active after subscription is delivered
    manager.subscriptionDelivered(subscriptionData);
    expect(
      manager.shapesForActiveSubscription(subscriptionId),
      [shapeDefinition],
    );

    // redeliver is noop
    manager.subscriptionDelivered(subscriptionData);

    // not active after unsubscribe
    manager.unsubscribe(subscriptionId);
    expect(manager.shapesForActiveSubscription(subscriptionId), null);

    // able to subscribe again after unsubscribe
    try {
      manager.subscriptionRequested(subscriptionId, [shapeRequest]);
    } catch (e) {
      fail('throws if re-subscribing');
    }

    // but not if inflight
    try {
      manager.subscriptionRequested(subscriptionId, [shapeRequest]);
      fail('should throw');
    } catch (e) {
      // Pass
    }
  });
}
