// Merge two sets of changes, using the timestamp to arbitrate conflicts
// so that the last write wins.
import 'package:electric_client/src/satellite/oplog.dart';
import 'package:electric_client/src/util/sets.dart';
import 'package:electric_client/src/util/types.dart' show Row;

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
      // TODO(dart): Could this break?
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
  return calculateTags(local.tag, remote.tags, local.clearTags);
}

List<Tag> calculateTags(Tag? tag, List<Tag> tags, List<Tag> clear) {
  if (tag == null) {
    return difference(tags, clear);
  } else {
    return union([tag], difference(tags, clear));
  }
}
