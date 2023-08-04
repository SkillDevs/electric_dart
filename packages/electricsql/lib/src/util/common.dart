import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:rate_limiter/rate_limiter.dart' as rt;

import 'package:uuid/uuid.dart' as uuid_lib;

const _uuidGen = uuid_lib.Uuid();

String uuid() {
  return _uuidGen.v4();
}

final kDefaultLogPos = numberToBytes(0);

// Typed wrapper around `rate_limiter` [Throttle]
class Throttle<T> {
  final Duration duration;
  final FutureOr<T> Function() callback;

  late final rt.Throttle _throttle;

  Throttle(this.callback, this.duration) {
    _throttle = rt.Throttle(
      callback,
      duration,
      leading: true,
      trailing: true,
    );
  }

  Future<T> call() async {
    return (_throttle()) as FutureOr<T>;
  }

  void cancel() {
    _throttle.cancel();
  }
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
  for (final byte in bytes) {
    n = (n << 8) | byte;
  }
  return n;
}

extension DateExtension on DateTime {
  String toISOStringUTC() {
    return toUtc().copyWith(microsecond: 0).toIso8601String();
  }
}
