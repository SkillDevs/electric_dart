import 'package:electricsql/src/util/converters/type_converters.dart';

final class Int2Codec extends ValidationCodec<int> {
  const Int2Codec() : super(validateInt);

  static const int _min = -32768;
  static const int _max = 32767;

  static void validateInt(int value) {
    if (value < _min || value > _max) {
      throw RangeError.range(value, _min, _max);
    }
  }
}
