import 'dart:math';

import 'package:electricsql/util.dart';

int _kNumSamples = 100;

List<Map<String, Object?>> debugGetSampleRows() {
  Map<String, Object?> buildRow(int i) {
    return {
      'pos': i,
      'age': _random.nextInt(100),
      'nullable': _nullOrVal(_random.nextInt(100)),
      'bool': _random.nextBool(),
      'mixed': _random.nextDouble() < 0.5 ? _random.nextInt(100) : genUUID(),
      'bytes': List.generate(100, (i) => _random.nextInt(256)),
      'json': List.generate(
        5,
        (i) => {
          'a': _random.nextInt(100),
          'b': _random.nextDouble(),
          'c': _random.nextBool(),
          'd': genUUID(),
        },
      ),
    };
  }

  return List.generate(_kNumSamples, (i) => buildRow(i));
}

T _nullOrVal<T>(T randomVal) {
  if (_random.nextDouble() < 0.2) {
    return null as T;
  } else {
    return randomVal;
  }
}

final _random = Random();
