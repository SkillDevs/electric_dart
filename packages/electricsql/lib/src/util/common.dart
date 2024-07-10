import 'dart:async';
import 'package:electricsql/src/util/encoders/common.dart';
import 'package:rate_limiter/rate_limiter.dart' as rt;

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

  void completeError(Object error, [StackTrace? stackTrace]) {
    if (_completer.isCompleted) return;

    _finished = true;
    _waiting
        ? _completer.completeError(error, stackTrace)
        : _completer.complete();
  }

  bool get finished => _finished;
}

String capitalizeString(String s) {
  if (s.isEmpty) return s;
  return s[0].toUpperCase() + s.substring(1);
}
