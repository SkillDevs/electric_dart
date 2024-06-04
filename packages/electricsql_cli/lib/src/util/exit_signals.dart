import 'dart:async';
import 'dart:io';

typedef DisposeFun = Future<void> Function();

DisposeFun handleExitSignals({
  required Future<bool> Function(ProcessSignal) onExit,
}) {
  StreamSubscription<ProcessSignal>? s1;
  StreamSubscription<ProcessSignal>? s2;

  Future<void> dispose() async {
    await s1?.cancel();
    await s2?.cancel();
  }

  Future<void> effectiveOnExit(ProcessSignal signal) async {
    final exitRes = await onExit(signal);

    if (exitRes) {
      await dispose();
      //print("Exit syscall has been called");
      exit(1);
    }
  }

  s1 = ProcessSignal.sigint.watch().listen(effectiveOnExit);

  // SIGTERM is not supported on Windows. Attempting to register a SIGTERM
  // handler raises an exception.
  if (!Platform.isWindows) {
    s2 = ProcessSignal.sigterm.watch().listen(effectiveOnExit);
  }

  return dispose;
}
