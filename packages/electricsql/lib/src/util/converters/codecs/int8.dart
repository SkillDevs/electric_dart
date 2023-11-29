import 'package:electricsql/src/util/converters/type_converters.dart';

final class Int8Codec extends ValidationCodec<int> {
  const Int8Codec() : super(_validate);

  static const int _min = -9223372036854775808;
  static const int _max = 9223372036854775807;

  static void _validate(int value) {
    if (value < _min || value > _max) {
      throw RangeError.range(value, _min, _max);
    }
  }
}
