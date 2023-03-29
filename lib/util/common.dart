import 'package:uuid/uuid.dart' as uuid_lib;

final _uuidGen = uuid_lib.Uuid();

String uuid() {
  return _uuidGen.v4();
}
