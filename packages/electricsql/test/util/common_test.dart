import 'package:electricsql/src/util/common.dart';
import 'package:electricsql/src/util/types.dart';
import 'package:test/test.dart';

void main() {
  test('test getWaiter onWait resolve', () async {
    final waiter = Waiter();

    final p = waiter.waitOn();

    waiter.complete();

    await p;

    expect(waiter.finished, isTrue);
  });

  test('test getWaiter onWait reject', () async {
    final waiter = Waiter();

    final p = waiter.waitOn();

    waiter.completeError(SatelliteException(SatelliteErrorCode.internal, ''));

    try {
      await p;
      fail('should have thrown');
    } catch (e) {
      expect(waiter.finished, isTrue);
    }
  });
}
