// Merge two sets of changes, using the timestamp to arbitrate conflicts
// so that the last write wins.
import 'package:electric_client/satellite/oplog.dart';
import 'package:electric_client/util/sets.dart';

OplogColumnChanges mergeChangesLastWriteWins(
  String firstOrigin,
  OplogColumnChanges first,
  String secondOrigin,
  OplogColumnChanges second,
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
