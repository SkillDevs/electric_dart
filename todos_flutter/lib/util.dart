import 'package:uuid/uuid.dart';

const _uuid = Uuid();

String newUUID() {
  return _uuid.v4();
}
