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

  String toISOStringUTC() {
    return toUtc().copyWith(microsecond: 0).toIso8601String();
  }

  DateTime asUtc() {
    if (isUtc) return this;

    final date = DateTime.fromMillisecondsSinceEpoch(
      millisecondsSinceEpoch + timeZoneOffset.inMilliseconds,
      isUtc: true,
    );

    return date;
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
