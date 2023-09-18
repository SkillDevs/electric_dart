import 'dart:async';
import 'dart:convert';
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

  static List<int> text(String text) {
    return utf8.encode(text);
  }

  static List<int> boolean(int b) {
    return boolToBytes(b);
  }
}

class TypeDecoder {
  static int number(List<int> bytes) {
    return bytesToNumber(bytes);
  }

  static String text(List<int> bytes) {
    return bytesToString(bytes);
  }

  static int boolean(List<int> bytes) {
    return bytesToBool(bytes);
  }
}

final trueByte = 't'.codeUnitAt(0);
final falseByte = 'f'.codeUnitAt(0);

List<int> boolToBytes(int b) {
  if (b != 0 && b != 1) {
    throw Exception('Invalid boolean value: $b');
  }
  return [if (b == 1) trueByte else falseByte];
}

int bytesToBool(List<int> bs) {
  if (bs.length == 1 && (bs[0] == trueByte || bs[0] == falseByte)) {
    return bs[0] == trueByte ? 1 : 0;
  }

  throw Exception('Invalid binary-encoded boolean value: $bs');
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

String bytesToString(List<int> bytes) {
  return utf8.decode(bytes);
}

extension DateExtension on DateTime {
  String toISOStringUTC() {
    return toUtc().copyWith(microsecond: 0).toIso8601String();
  }
}

class Waiter {
  bool _waiting = false;
  bool _finished = false;
  final Completer<void> _completer = Completer();

  Future<void> waitOn() async {
    _waiting = true;
    await _completer.future;
  }

  void complete() {
    if (_completer.isCompleted) return;

    _finished = true;
    _completer.complete();
  }

  void completeError(Object error) {
    if (_completer.isCompleted) return;

    _finished = true;
    _waiting ? _completer.completeError(error) : _completer.complete();
  }

  bool get finished => _finished;
}
