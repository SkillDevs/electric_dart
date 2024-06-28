import 'package:electricsql/src/client/input/sync_input.dart';
import 'package:electricsql/src/satellite/satellite.dart';
import 'package:electricsql/src/satellite/shapes/types.dart';
import 'package:equatable/equatable.dart';

typedef TableName = String;

enum SyncStatusType {
  undefined,
  active,
  cancelling,
  establishing,
}

enum SyncEstablishingProgress {
  receivingData,
  removingData,
}

sealed class SyncStatus with EquatableMixin {
  SyncStatusType get statusType;
}

class SyncStatusUndefined extends SyncStatus {
  @override
  SyncStatusType get statusType => SyncStatusType.undefined;

  @override
  List<Object?> get props => [statusType];
}

class SyncStatusActive extends SyncStatus {
  final String serverId;

  @override
  SyncStatusType get statusType => SyncStatusType.active;

  SyncStatusActive(this.serverId);

  @override
  List<Object?> get props => [statusType, serverId];
}

class SyncStatusCancelling extends SyncStatus {
  final String serverId;

  @override
  SyncStatusType get statusType => SyncStatusType.cancelling;

  SyncStatusCancelling(this.serverId);

  @override
  List<Object?> get props => [statusType, serverId];
}

class SyncStatusEstablishing extends SyncStatus {
  final String serverId;
  final SyncEstablishingProgress progress;
  final String? oldServerId;

  @override
  SyncStatusType get statusType => SyncStatusType.establishing;

  SyncStatusEstablishing({
    required this.serverId,
    required this.progress,
    this.oldServerId,
  });

  @override
  List<Object?> get props => [statusType, serverId, progress, oldServerId];
}

abstract interface class IShapeManager {
  Future<ShapeSubscription> subscribe(List<Shape> shapes, [String? key]);
  Future<void> unsubscribe(List<String> keys);
  SyncStatus syncStatus(String key);
}

abstract interface class SyncManager {
  /// Subscribes to the given shape, returnig a [ShapeSubscription] object which
  /// can be used to wait for the shape to sync initial data.
  ///
  /// https://electric-sql.com/docs/usage/data-access/shapes
  ///
  /// NOTE: If you establish a shape subscription that has already synced its initial data,
  /// awaiting `shape.synced` will always resolve immediately as shape subscriptions are persisted.
  /// i.e.: imagine that you re-sync the same shape during subsequent application loads.
  /// Awaiting `shape.synced` a second time will only ensure that the initial
  /// shape load is complete. It does not ensure that the replication stream
  /// has caught up to the central DB's more recent state.
  ///
  /// @param i - The shape to subscribe to
  /// @param key - An optional unique key that identifies the subscription
  /// @returns A shape subscription
  Future<ShapeSubscription> subscribe(
    ShapeInputRaw i, [
    String? key,
  ]);

  Future<void> unsubscribe(List<String> keys);
  SyncStatus syncStatus(String key);
}
