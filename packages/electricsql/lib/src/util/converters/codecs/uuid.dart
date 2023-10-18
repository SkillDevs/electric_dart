import 'package:electricsql/src/util/converters/type_converters.dart';
import 'package:uuid/uuid.dart';

final class UUIDCodec extends ValidationCodec<String> {
  const UUIDCodec() : super(_validate);

  static void _validate(String value) {
    UuidValue(value, true);
  }
}
