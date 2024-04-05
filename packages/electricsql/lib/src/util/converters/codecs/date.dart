import 'dart:convert';

import 'package:electricsql/src/util/converters/helpers.dart';

final class DateCodec extends Codec<DateTime, String> {
  const DateCodec();
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
    return extractDateAndTime(input.ignoreTimeZone()).date;
  }
}
