import 'package:electric_client/src/satellite/shapes/types.dart';

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

  /**
   * @returns An array of fulfilled subscriptions that are active.
   */
  List<SubscriptionId> getFulfilledSubscriptions();

  /**
   * Check if a subscription with exactly the same shape requests has already been issued
   * @param shapes Shapes for a potential request
   */
  DuplicatingSubRes? getDuplicatingSubscription(
    List<ClientShapeDefinition> shapes,
  );

  /// Deletes the subscription from the manager.
  /// @param subId the identifier of the subscription
  Future<void> unsubscribe(String subId);

  /// Deletes all subscriptions from the manager. Useful to
  /// reset the state of the manager.
  /// Returns the subscription identifiers of all subscriptions
  /// that were deleted.
  Future<List<String>> unsubscribeAll();

  /// Converts the state of the manager to a string format that
  /// can be used to persist it
  String serialize();

  /// loads the subscription manager state from a text representation
  void setState(String serialized);
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
