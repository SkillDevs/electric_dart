import 'package:electricsql/src/util/converters/type_converters.dart';

final class Int8Codec extends ValidationCodec<int> {
  const Int8Codec() : super(_validate);

  static void _validate(int value) {
    // Nothing to validate. Int in Dart VM is at most 64 bits.
    // On Dart JS, the limited integer value also fits
  }
}
