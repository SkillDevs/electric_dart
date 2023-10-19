import 'dart:convert';

import 'package:electricsql/src/util/converters/helpers.dart';

final class Float8Codec extends Codec<double, Object> {
  const Float8Codec();
  @override
  Converter<Object, double> get decoder => const _Decoder();

  @override
  Converter<double, Object> get encoder => const _Encoder();
}

final class _Decoder extends Converter<Object, double> {
  const _Decoder();

  @override
  double convert(Object input) {
    if (input == 'NaN') {
      // it's a serialised NaN
      return double.nan;
    } else if (input is num) {
      return input.toDouble();
    } else {
      throw Exception("Unexpected float8 value: '$input'");
    }
  }
}

final class _Encoder extends Converter<double, Object> {
  const _Encoder();

  @override
  Object convert(double input) {
    if (input.isNaN) {
      return 'NaN';
    } else {
      return input;
    }
  }
}
