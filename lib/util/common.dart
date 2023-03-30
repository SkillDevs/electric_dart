import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:uuid/uuid.dart' as uuid_lib;

final _uuidGen = uuid_lib.Uuid();

String uuid() {
  return _uuidGen.v4();
}

final kDefaultLogPos = numberToBytes(0);

void Function() throttle(void Function() callback, Duration duration) {
  Timer? timer;
  bool pending = false;
  return () {
    if (timer == null) {
      timer = Timer(duration, () {
        if (pending) {
          callback();
          pending = false;
          timer = null;
        }
      });
      callback();
    } else {
      pending = true;
    }
  };
}

class TypeEncoder {
  static List<int> number(int n) {
    return numberToBytes(n);
  }

  static Uint8List text(String text) {
    return Uint8List.fromList(utf8.encode(text));
  }
}

class TypeDecoder {
  static int number(List<int> bytes) {
    return bytesToNumber(bytes);
  }

  static String text(List<int> bytes) {
    return utf8.decode(bytes);
  }
}

List<int> numberToBytes(int i) {
  return [
    (i & 0xff000000) >> 24,
    (i & 0x00ff0000) >> 16,
    (i & 0x0000ff00) >> 8,
    (i & 0x000000ff) >> 0,
  ];
}

int bytesToNumber(List<int> bytes) {
  int n = 0;
  for (var byte in bytes) {
    n = (n << 8) | byte;
  }
  return n;
}
