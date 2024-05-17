import 'package:electricsql/src/satellite/shapes/types.dart';
import 'package:electricsql/src/util/js_array_funs.dart';
import 'package:electricsql/src/util/tablename.dart';

// TODO(dart): Remove in official client?
/// Manages the state of satellite shape subscriptions
abstract class SubscriptionsManager {
  /// Stores the identifier for a subscription
  /// request that was accepted by the server
  ///
  /// @param subId the identifier of the subscription
  /// @param shapeRequests the shapes definitions of the request
  void subscriptionRequested(String subId, List<ShapeRequest> shapeRequests);

  /// Cancel the subscription with the given subscription id
  ///
  /// @param subId the identifier of the subscription
  void subscriptionCancelled(String subId);

  /// Registers that a subsciption that was in-flight is now
  /// delivered.
  /// @param data the data for the subscription
  void subscriptionDelivered(SubscriptionData data);

  /// Returns the shape definitions for subscriptions avalailable locally
  /// @param subId the identifier of the subscription
  List<ShapeDefinition>? shapesForActiveSubscription(String subId);

  /// @returns An array of fulfilled subscriptions that are active.
  List<SubscriptionId> getFulfilledSubscriptions();

  /// Check if a subscription with exactly the same shape requests has already been issued
  /// @param shapes Shapes for a potential request
  DuplicatingSubRes? getDuplicatingSubscription(
    List<Shape> shapes,
  );

  /// Deletes the subscription(s) from the manager.
  /// @param An array of subscription identifiers for the subscription
  void unsubscribe(List<SubscriptionId> subIds);

  /// Delete the subscriptions from the manager and call a GC function
  Future<void> unsubscribeAndGC(List<SubscriptionId> subIds);

  /// Deletes all subscriptions from the manager. Useful to
  /// reset the state of the manager. Calls the configured GC.
  /// Returns the subscription identifiers of all subscriptions
  /// that were deleted.
  Future<List<SubscriptionId>> unsubscribeAllAndGC();

  /// Converts the state of the manager to a string format that
  /// can be used to persist it
  String serialize();

  /// loads the subscription manager state from a text representation
  void setState(String serialized);

  String hash(List<Shape> shapes);
}

sealed class DuplicatingSubRes {}

class DuplicatingSubInFlight extends DuplicatingSubRes {
  final String inFlight;

  DuplicatingSubInFlight(this.inFlight);
}

class DuplicatingSubFulfilled extends DuplicatingSubRes {
  final String fulfilled;

  DuplicatingSubFulfilled(this.fulfilled);
}

/// List all tables covered by a given shape
List<QualifiedTablename> getAllTablesForShape(
  Shape shape, {
  String schema = 'main',
}) {
  return uniqueList(_doGetAllTablesForShape(shape, schema: schema));
}

List<QualifiedTablename> _doGetAllTablesForShape(
  Shape shape, {
  String schema = 'main',
}) {
  final includes = shape.include
          ?.expand((x) => _doGetAllTablesForShape(x.select, schema: schema))
          .toList() ??
      [];
  includes.add(QualifiedTablename(schema, shape.tablename));
  return includes;
}
