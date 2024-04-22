import 'package:electricsql/src/util/converters/type_converters.dart';
import 'package:uuid/validation.dart';

final class UUIDCodec extends ValidationCodec<String> {
  const UUIDCodec() : super(validateString);

  static void validateString(String value) {
    UuidValidation.isValidOrThrow(fromString: value);
  }
}
