// Merge two sets of changes, using the timestamp to arbitrate conflicts
// so that the last write wins.
import 'package:electricsql/src/satellite/oplog.dart';
import 'package:electricsql/src/util/sets.dart';
import 'package:electricsql/src/util/types.dart' show RelationsCache, Row;

/// Merge server-sent operation with local pending oplog to arrive at the same row state the server is at.
/// @param localOrigin string specifying the local origin
/// @param local local oplog entries
/// @param incomingOrigin string specifying the upstream origin
/// @param incoming incoming oplog entries
/// @returns Changes to be made to the shadow tables
PendingChanges mergeEntries(
  String localOrigin,
  List<OplogEntry> local,
  String incomingOrigin,
  List<OplogEntry> incoming,
  RelationsCache relations,
) {
  final localTableChanges = localOperationsToTableChanges(
    local,
    (DateTime timestamp) {
      return generateTag(localOrigin, timestamp);
    },
    relations,
  );
  final incomingTableChanges =
      remoteOperationsToTableChanges(incoming, relations);

  for (final incomingTableChangeEntry in incomingTableChanges.entries) {
    final tablename = incomingTableChangeEntry.key;
    final incomingMapping = incomingTableChangeEntry.value;
    final localMapping = localTableChanges[tablename];

    if (localMapping == null) {
      continue;
    }

    for (final incomingMappingEntry in incomingMapping.entries) {
      final primaryKey = incomingMappingEntry.key;
      final incomingChanges = incomingMappingEntry.value;
      final localInfo = localMapping[primaryKey];
      if (localInfo == null) {
        continue;
      }
      final localChanges = localInfo.oplogEntryChanges;

      OplogColumnChanges changes;

      if (incomingChanges.optype == ChangesOpType.gone) {
        changes = localChanges.changes;
      } else {
        changes = mergeChangesLastWriteWins(
          localOrigin,
          localChanges.changes,
          incomingOrigin,
          incomingChanges.changes,
          incomingChanges.fullRow,
        );
      }

      late final ChangesOpType optype;

      final tags = mergeOpTags(localChanges, incomingChanges);
      if (tags.isEmpty) {
        optype = ChangesOpType.delete;
      } else {
        optype = ChangesOpType.upsert;
      }

      incomingChanges.changes = changes;
      incomingChanges.optype = optype;
      incomingChanges.tags = tags;
    }
  }

  return incomingTableChanges;
}

/// Merge two sets of changes, using the timestamp to arbitrate conflicts
/// so that the last write wins.
///
/// The [fullRow] is mutated to reflect the outcome of LWW.
/// For columns that have no changes in `second` we assign the
/// column value from [first].
///
/// [firstOrigin] - Origin of the first changes
/// [first] - Changes
/// [secondOrigin] - Origin of the second changes
/// [second] - Changes
/// [fullRow] - The complete row after changes in [second]
OplogColumnChanges mergeChangesLastWriteWins(
  String firstOrigin,
  OplogColumnChanges first,
  String secondOrigin,
  OplogColumnChanges second,
  Row fullRow,
) {
  final uniqueKeys = <String>{...first.keys, ...second.keys};

  final OplogColumnChanges initialValue = {};

  return uniqueKeys.fold(initialValue, (acc, key) {
    final firstValue = first[key];
    final secondValue = second[key];

    if (firstValue == null && secondValue == null) {
      return acc;
    }

    if (firstValue == null) {
      acc[key] = secondValue!;
    } else if (secondValue == null) {
      acc[key] = firstValue;
    } else {
      if (firstValue.timestamp == secondValue.timestamp) {
        // origin lexicographic ordered on timestamp equality
        acc[key] =
            firstOrigin.compareTo(secondOrigin) > 0 ? firstValue : secondValue;
      } else {
        acc[key] = firstValue.timestamp > secondValue.timestamp
            ? firstValue
            : secondValue;
      }
    }

    // update value of this key in the full row with the value picked by LWW
    // if the value was modified in `first` but not in `second`
    // acc[key] will contain the value of that column in `first`
    fullRow[key] = acc[key]!.value;

    return acc;
  });
}

List<Tag> mergeOpTags(OplogEntryChanges local, ShadowEntryChanges remote) {
  // When the server sends a GONE message, it means we need to delete this row from our side as no further
  // updates will come through. Server doesn't keep track of seen tags, however, so we make the GONE operation
  // have a higher priority than anything else.

  // TODO: Does deleting on GONE make sense at all?
  if (remote.optype == ChangesOpType.gone) return [];

  return calculateTags(local.tag, remote.tags, local.clearTags);
}

List<Tag> calculateTags(Tag? tag, List<Tag> tags, List<Tag> clear) {
  if (tag == null) {
    return difference(tags, clear);
  } else {
    return union([tag], difference(tags, clear));
  }
}
