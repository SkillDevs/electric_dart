import 'dart:convert';

import 'package:electricsql/src/util/converters/helpers.dart';

final class TimeCodec extends Codec<DateTime, String> {
  const TimeCodec();
  @override
  Converter<String, DateTime> get decoder => const _Decoder();

  @override
  Converter<DateTime, String> get encoder => const _Encoder();
}

final class _Decoder extends Converter<String, DateTime> {
  const _Decoder();

  @override
  DateTime convert(String input) {
    // interpret as local time
    final timestamp = '1970-01-01 $input';
    return DateTime.parse(timestamp).asUtc();
  }
}

final class _Encoder extends Converter<DateTime, String> {
  const _Encoder();

  @override
  String convert(DateTime input) {
    return extractDateAndTime(input.ignoreTimeZone()).time;
  }
}
