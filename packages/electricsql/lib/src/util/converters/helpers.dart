extension DateExtension on DateTime {
  // It doesn't show milliseconds if they are 0
  String toIso8601StringCompact() {
    final String y =
        (year >= -9999 && year <= 9999) ? _fourDigits(year) : _sixDigits(year);
    final String m = _twoDigits(month);
    final String d = _twoDigits(day);
    final String h = _twoDigits(hour);
    final String min = _twoDigits(minute);
    final String sec = _twoDigits(second);
    final String ms =
        microsecond == 0 && millisecond == 0 ? '' : _threeDigits(millisecond);
    final String us = microsecond == 0 ? '' : _threeDigits(microsecond);

    final msUs = ms.isEmpty && us.isEmpty ? '' : '.$ms$us';

    if (isUtc) {
      return '$y-$m-${d}T$h:$min:$sec${msUs}Z';
    } else {
      return '$y-$m-${d}T$h:$min:$sec$msUs';
    }
  }

  String toTimeString() {
    final String h = _twoDigits(hour);
    final String min = _twoDigits(minute);
    final String sec = _twoDigits(second);
    final String ms = _threeDigits(millisecond);
    final String us = microsecond == 0 ? '' : _threeDigits(microsecond);

    return '$h:$min:$sec.$ms$us';
  }

  // Gets the ISO8601 string in UTC time. It removes the microseconds.
  String toISOStringUTC() {
    return toUtc().copyWith(microsecond: 0).toIso8601String();
  }

  /// Corrects the provided `Date` such that
  /// the current date is set as UTC date.
  /// e.g. if it is 3PM in GMT+2 then it is 1PM UTC.
  ///      This function would return a date in which it is 3PM UTC.
  /// The output is always in UTC time
  DateTime ignoreTimeZone({Duration? mockTimezoneOffset}) {
    if (isUtc) {
      return this;
    }

    // `v.toISOString` returns the UTC time but we want the time in this timezone
    // so we get the timezone offset and subtract it from the current time in order to
    // compensate for the timezone correction done by `toISOString`
    final effectiveTimezoneOffset =
        mockTimezoneOffset ?? toLocal().timeZoneOffset;
    final offsetInMs = effectiveTimezoneOffset.inMilliseconds;
    return DateTime.fromMillisecondsSinceEpoch(
      millisecondsSinceEpoch + offsetInMs,
      isUtc: true,
    );
  }

  DateTime asUtc() {
    if (isUtc) {
      return this;
    }
    return DateTime.utc(
      year,
      month,
      day,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }

  DateTime asLocal() {
    if (!isUtc) {
      return this;
    }
    return DateTime(
      year,
      month,
      day,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }
}

String _threeDigits(int n) {
  if (n >= 100) return '$n';
  if (n >= 10) return '0$n';
  return '00$n';
}

String _twoDigits(int n) {
  if (n >= 10) return '$n';
  return '0$n';
}

String _fourDigits(int n) {
  final int absN = n.abs();
  final String sign = n < 0 ? '-' : '';
  if (absN >= 1000) return '$n';
  if (absN >= 100) return '${sign}0$absN';
  if (absN >= 10) return '${sign}00$absN';
  return '${sign}000$absN';
}

String _sixDigits(int n) {
  assert(n < -9999 || n > 9999);
  final int absN = n.abs();
  final String sign = n < 0 ? '-' : '+';
  if (absN >= 100000) return '$sign$absN';
  return '${sign}0$absN';
}

typedef ExtractedDateTime = ({String date, String time});

ExtractedDateTime extractDateAndTime(DateTime v) {
  final regex = RegExp('([0-9-]*)T([0-9:.]*)Z');
  final match = regex.firstMatch(v.toISOStringUTC());
  if (match == null) {
    throw Exception('Could not extract date and time from $v');
  }
  final date = match.group(1)!;
  final time = match.group(2)!;
  return (date: date, time: time);
}

extension BigIntExt on BigInt {
  static final _bigIntMinValue64 = BigInt.from(-9223372036854775808);
  static final _bigIntMaxValue64 = BigInt.from(9223372036854775807);

  int rangeCheckedToInt() {
    if (this < _bigIntMinValue64 || this > _bigIntMaxValue64) {
      throw ArgumentError.value(
        this,
        'this',
        'BigInt value exceeds the range of 64 bits',
      );
    }

    return toInt();
  }
}
