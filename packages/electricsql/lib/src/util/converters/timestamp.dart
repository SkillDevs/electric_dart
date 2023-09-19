import 'dart:convert';

import 'package:electricsql/src/util/converters/helpers.dart';

final class TimestampCodec extends Codec<DateTime, String> {
  const TimestampCodec();
  @override
  Converter<String, DateTime> get decoder => const TimestampDecoder();

  @override
  Converter<DateTime, String> get encoder => const TimestampEncoder();
}

final class TimestampDecoder extends Converter<String, DateTime> {
  const TimestampDecoder();

  @override
  DateTime convert(String input) {
    return DateTime.parse(input).asUtc();
  }
}

final class TimestampEncoder extends Converter<DateTime, String> {
  const TimestampEncoder();

  @override
  String convert(DateTime input) {
    return input.toISOStringUTC();
  }
}
