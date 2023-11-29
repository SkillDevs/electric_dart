import 'dart:convert';
import 'dart:typed_data';

final class Float4Codec extends Codec<double, Object> {
  const Float4Codec();
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
      // convert to float4 in case someone would have written a bigger value to SQLite directly
      return fround(input);
    } else {
      throw Exception("Unexpected float4 value: '$input'");
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
      // Limit precision to float 32 bits
      return fround(input);
    }
  }
}

@pragma('vm:prefer-inline')
double fround(num x) {
  final list = Float32List(1);
  list[0] = x.toDouble();
  return list[0];
}
