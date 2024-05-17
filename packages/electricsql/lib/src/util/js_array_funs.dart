import 'dart:math';

extension JsArrayFuns<T> on List<T> {
  List<T> slice(int start, [int? end]) {
    if (start < 0) throw ArgumentError.value(start, 'start', 'must be >= 0');

    if (isEmpty || start >= length) {
      return [];
    }

    end ??= length;
    return sublist(start, min(end, length));
  }

  List<T> splice(int start, [int? deleteCount]) {
    if (start < 0) throw ArgumentError.value(start, 'start', 'must be >= 0');

    if (isEmpty || start >= length) {
      return [];
    }

    final end = start + (deleteCount ?? length - start);
    final removed = sublist(start, min(end, length));
    removeRange(start, min(end, length));
    return removed;
  }
}

List<T> uniqueList<T>(Iterable<T> list) {
  final Set<T> itemsSet = {};
  final List<T> nonRepeated = [];

  for (final e in list) {
    if (itemsSet.add(e)) {
      nonRepeated.add(e);
    }
  }
  return nonRepeated;
}
