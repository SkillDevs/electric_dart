import 'package:electricsql/src/satellite/satellite.dart';
import 'package:electricsql/src/satellite/shapes/types.dart';

typedef TableName = String;

sealed class SyncStatus {}

class SyncStatusUndefined extends SyncStatus {}

class SyncStatusActive extends SyncStatus {
  final String serverId;

  SyncStatusActive(this.serverId);
}

class SyncStatusCancelling extends SyncStatus {
  final String serverId;

  SyncStatusCancelling(this.serverId);
}

class SyncStatusEstablishing extends SyncStatus {
  final String serverId;
  final String progress;
  final String? oldServerId;

  SyncStatusEstablishing({
    required this.serverId,
    required this.progress,
    this.oldServerId,
  });
}

abstract interface class IShapeManager {
  Future<ShapeSubscription> subscribe(List<Shape> shapes, [String? key]);
  Future<void> unsubscribe(List<String> keys);
  SyncStatus syncStatus(String key);
}
