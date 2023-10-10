import 'dart:math';

extension JsArrayFuns<T> on List<T> {
  List<T> slice(int start, [int? end]) {
    if (isEmpty || start >= length) {
      return [];
    }

    end ??= length;
    return sublist(start, min(end, length));
  }

  List<T> splice(int start, [int? end]) {
    if (isEmpty || start >= length) {
      return [];
    }

    end ??= length;
    final removed = sublist(start, min(end, length));
    removeRange(start, min(end, length));
    return removed;
  }
}
