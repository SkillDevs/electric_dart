import 'dart:math';

import 'package:electricsql/src/util/common.dart';

final _random = Random();

String randomValue() {
  return List.generate(13, (_) => _randomHex()).join('');
}

String _randomHex() {
  return _random.nextInt(16).toRadixString(16);
}

String genUUID() {
  return uuid();
}
