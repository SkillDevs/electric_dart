import 'dart:convert';

import 'package:electricsql/src/util/converters/helpers.dart';

final class TimestampCodec extends Codec<DateTime, String> {
  const TimestampCodec();
  @override
  Converter<String, DateTime> get decoder => const _Decoder();

  @override
  Converter<DateTime, String> get encoder => const _Encoder();
}

final class _Decoder extends Converter<String, DateTime> {
  const _Decoder();

  @override
  DateTime convert(String input) {
    return DateTime.parse(input).asUtc();
  }
}

final class _Encoder extends Converter<DateTime, String> {
  const _Encoder();

  @override
  String convert(DateTime input) {
    // Returns local timestamp
    return input
        .ignoreTimeZone()
        .toISOStringUTC()
        .replaceAll('T', ' ')
        .replaceAll('Z', '');
  }
}
