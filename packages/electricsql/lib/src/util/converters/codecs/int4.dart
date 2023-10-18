import 'package:electricsql/src/util/converters/type_converters.dart';

final class Int4Codec extends ValidationCodec<int> {
  const Int4Codec() : super(_validate);

  static const int _min = -2147483648;
  static const int _max = 2147483647;

  static void _validate(int value) {
    if (value < _min || value > _max) {
      throw RangeError.range(value, _min, _max);
    }
  }
}
