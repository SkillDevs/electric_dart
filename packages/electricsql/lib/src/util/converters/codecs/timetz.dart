import 'dart:convert';

import 'package:electricsql/src/util/converters/helpers.dart';

final class TimeTZCodec extends Codec<DateTime, String> {
  const TimeTZCodec();
  @override
  Converter<String, DateTime> get decoder => const _Decoder();

  @override
  Converter<DateTime, String> get encoder => const _Encoder();
}

final class _Decoder extends Converter<String, DateTime> {
  const _Decoder();

  @override
  DateTime convert(String input) {
    // interpret as UTC time
    final timestamp = '1970-01-01 $input+00';
    return DateTime.parse(timestamp);
  }
}

final class _Encoder extends Converter<DateTime, String> {
  const _Encoder();

  @override
  String convert(DateTime input) {
    return extractDateAndTime(input).time;
  }
}
