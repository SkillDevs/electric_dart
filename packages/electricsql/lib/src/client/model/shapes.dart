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
  final String progress;
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
