import 'dart:math';

import 'package:uuid/uuid.dart' as uuid_lib;

final _random = Random();

String randomValue() {
  return List.generate(13, (_) => _randomHex()).join('');
}

String _randomHex() {
  return _random.nextInt(16).toRadixString(16);
}

const _uuidGen = uuid_lib.Uuid();

String genUUID() {
  return _uuidGen.v4();
}
