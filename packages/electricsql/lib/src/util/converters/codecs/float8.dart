import 'dart:convert';

import 'package:electricsql/src/util/converters/helpers.dart';

final class Float8Codec extends Codec<double, double> {
  const Float8Codec();
  @override
  Converter<double, double> get decoder => const _Decoder();

  @override
  Converter<double, double> get encoder => const _Encoder();
}

final class _Decoder extends Converter<double, double> {
  const _Decoder();

  @override
  double convert(double input) {
    if (input == 'NaN') {
      // it's a serialised NaN
      return double.nan;
    } else if (input is double) {
      return input;
    } else {
      throw Exception("Unexpected float8 value: '$input'");
    }
  }
}

final class _Encoder extends Converter<double, double> {
  const _Encoder();

  @override
  double convert(double input) {
    if (input.isNaN) {
      throw UnimplementedError();
      //return 'NaN';
    } else {
      return input;
    }
  }
}

// TODO(dart): Properly support float8. We currently cannot because we cannot map all values to a single type in sqlite, which drift doesn't support. We might be able to use
// the customType feature from drift, which is unreleased yet.
// ignore: unused_element
const _a = 0;

/* final class Float8Codec extends Codec<double, Object> {
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
    } else if (input is double) {
      return input;
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
 */
