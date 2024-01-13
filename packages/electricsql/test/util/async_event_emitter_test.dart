import 'package:electricsql/src/util/async_event_emitter.dart';
import 'package:test/test.dart';

void main() {
  test('test AsyncEventEmitter multiple events', () async {
    final emitter = AsyncEventEmitter();

    final log = <int>[];

    Future<void> listener1(void _) async {
      await Future<void>.delayed(const Duration(milliseconds: 20));
      log.add(1);
    }

    void listener2(void _) {
      log.add(2);
    }

    emitter.on('event1', listener1);
    emitter.on('event2', listener2);

    emitter.enqueueEmit('event1', null);
    emitter.enqueueEmit('event2', null);

    // Give the emitter some time to process the queue
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(log, [1, 2]);
  });

  // Test that the AsyncEventEmitter calls one-time listeners only once
  test('test AsyncEventEmitter once listeners', () async {
    final emitter = AsyncEventEmitter();

    int count = 0;
    void listener(void _) {
      count++;
    }

    emitter.once('event', listener);
    emitter.once('event', listener);
    emitter.enqueueEmit('event', null);

    emitter.once('event', listener);
    emitter.enqueueEmit('event', null);

    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(count, 3);
  });

// Test that listeners can be prepended
  test('test AsyncEventEmitter prependListener', () async {
    final emitter = AsyncEventEmitter();

    final log = <int>[];

    void listener1(void _) {
      log.add(1);
    }

    void listener2(void _) {
      log.add(2);
    }

    emitter.on('event', listener1);
    emitter.prependListener('event', listener2);

    emitter.enqueueEmit('event', null);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(log, [2, 1]);
  });

  // Test that the AsyncEventEmitter correctly removes listeners
  test('test AsyncEventEmitter removeListener', () async {
    final emitter = AsyncEventEmitter();

    bool l1 = false;
    bool l2 = false;
    bool l3 = false;
    bool l4 = false;

    Future<void> listener1(void _) async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      l1 = true;
    }

    void listener2(void _) {
      l2 = true;
    }

    void listener3(void _) {
      l3 = true;
    }

    void listener4(void _) {
      l4 = true;
    }

    emitter.on('event', listener1);
    emitter.on('event', listener2);
    emitter.on('event', listener3);
    emitter.on('event', listener4);

    emitter.removeListener('event', listener2);
    emitter.off('event', listener4);

    emitter.enqueueEmit('event', null);

    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(l1, true);
    expect(l2, false);
    expect(l3, true);
    expect(l4, false);
  });

  // Test that the AsyncEventEmitter correctly removes all listeners
  test('test AsyncEventEmitter remove listeners', () async {
    final emitter = AsyncEventEmitter();

    bool l1 = false;
    bool l2 = false;

    void listener1(void _) {
      l1 = true;
    }

    void listener2(void _) {
      l2 = true;
    }

    emitter.on('event', listener1);
    expect(emitter.listenerCount('event'), 1);

    emitter.on('event', listener2);
    expect(emitter.listenerCount('event'), 2);

    emitter.removeAllListeners('event');
    expect(emitter.listenerCount('event'), 0);

    emitter.enqueueEmit('event', null);

    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(l1, false);
    expect(l2, false);
  });

  // Test that eventNames returns the correct event names
  test('test AsyncEventEmitter eventNames', () async {
    final emitter = AsyncEventEmitter();

    emitter.on('event1', (_) => {});
    emitter.on('event2', (_) => {});

    final eventNames = emitter.eventNames();
    expect(eventNames, ['event1', 'event2']);

    emitter.removeAllListeners('event1');
    final eventNames2 = emitter.eventNames();
    expect(eventNames2, ['event2']);

    emitter.removeAllListeners(null);
    final eventNames3 = emitter.eventNames();
    expect(eventNames3, isEmpty);
  });

  // Test that the AsyncEventEmitter correctly handles errors
  test('test AsyncEventEmitter handles errors correctly', () async {
    final emitter = AsyncEventEmitter();

    final err = Exception('test error');

    // If an error event is emitted and there are no listeners, the error is thrown
    try {
      emitter.enqueueEmit('error', err);
      fail('Should have thrown');
    } catch (e) {
      expect(err.toString(), 'Exception: test error');
    }

    // If an error event is emitted and there are listeners, the listeners are called
    bool called = false;
    emitter.on('error', (err) {
      called = true;
      expect(err.toString(), 'Exception: test error');
    });

    emitter.enqueueEmit('error', err);

    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(called, true);
  });
}
