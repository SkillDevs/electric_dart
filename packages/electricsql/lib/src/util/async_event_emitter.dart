import 'dart:async';

import 'package:electricsql/src/util/debug/debug.dart';
import 'package:electricsql/src/util/js_array_funs.dart';

typedef Handler<Arg> = FutureOr<void> Function(Arg arg);

typedef Events = Map<String, Handler<dynamic>>;

typedef EmittedEvent<Arg> = ({String event, Arg arg});

/// Implementation of a typed async event emitter.
/// This event emitter maintains a queue of events,
/// the events are processed in order and the next is not started
/// until all (async) event listeners for the previous event have finished.
/// Event listers for a single event are processed concurrently, events are processed sequentially.
/// Typings are inspired by the 'typed-emitter' package.
class AsyncEventEmitter {
  // after how many listeners to print a memory leak warning
  int _maxListeners = 10;

  Map<String, List<Handler<dynamic>>> _listeners = {};

  final List<EmittedEvent<dynamic>> _eventQueue = [];

  // indicates whether the event queue is currently being processed
  bool _processing = false;

  List<Handler<dynamic>> _getListeners(String event) {
    return _listeners[event] ?? [];
  }

  void _assignListeners(
    String event,
    List<Handler<dynamic>> listeners,
  ) {
    _listeners[event] = listeners;
    if (listeners.length > _maxListeners && _maxListeners != 0) {
      logger.warning(
        'Possible AsyncEventEmitter memory leak detected. ${listeners.length} listeners added.',
      );
    }
  }

  /// Adds the listener function to the end of the listeners array for the given event.
  /// The listeners will be called in order but if they are asynchronous they may run concurrently.
  /// No checks are made to see if the listener has already been added.
  /// Multiple calls passing the same combination of event and listener will result in the listener being added, and called, multiple times.
  /// @param event The event to add the listener to.
  /// @param listener The listener to add.
  /// @returns A reference to the AsyncEventEmitter, so that calls can be chained.
  AsyncEventEmitter addListener(String event, Handler<dynamic> listener) {
    final listeners = _getListeners(event);
    listeners.add(listener);
    _assignListeners(event, listeners);
    return this;
  }

  AsyncEventEmitter on(String event, Handler<dynamic> listener) {
    return addListener(event, listener);
  }

  /// Adds the listener function to the beginning of the listeners array for the given event.
  /// The listeners will be called in order but if they are asynchronous they may run concurrently.
  /// No checks are made to see if the listener has already been added.
  /// Multiple calls passing the same combination of event and listener will result in the listener being added, and called, multiple times.
  /// @param event The event to prepend the listener to.
  /// @param listener The listener to prepend.
  /// @returns A reference to the AsyncEventEmitter, so that calls can be chained.
  AsyncEventEmitter prependListener(String event, Handler<dynamic> listener) {
    final listeners = _getListeners(event);
    listeners.insert(0, listener);
    _assignListeners(event, listeners);
    return this;
  }

  /// Creates a listener that wraps the provided listener.
  /// On the first call, the listener removes itself
  /// and then calls and awaits the provided listener.
  Handler<T> _createOnceListener<T>(
    String event,
    Handler<T> listener,
  ) {
    Future<void> wrappedListener(dynamic arg) async {
      removeListener(event, wrappedListener);
      await listener(arg as T);
    }

    return wrappedListener;
  }

  /// Adds a listener that is only called on the first event.
  AsyncEventEmitter once(String event, Handler<dynamic> listener) {
    final wrappedListener = _createOnceListener(event, listener);
    return addListener(event, wrappedListener);
  }

  /// Adds a one-time listener function for the given event to the beginning of the listeners array.
  /// The next time the event is triggered, this listener is removed, and then invoked.
  /// @param event The event to prepend the listener to.
  /// @param listener The listener to prepend.
  /// @returns A reference to the AsyncEventEmitter, so that calls can be chained.
  AsyncEventEmitter prependOnceListener(
    String event,
    Handler<dynamic> listener,
  ) {
    final wrappedListener = _createOnceListener(event, listener);
    return prependListener(event, wrappedListener);
  }

  /// This synchronous method processes the queue ASYNCHRONOUSLY.
  /// IMPORTANT: When this process returns, the queue may still being processed by some asynchronous listeners.
  /// When all listeners (including async listeners) have finished processing the events from the queue,
  /// the `this.processing` flag is set to `false`.
  ///
  /// If the event emitter does not have at least one listener registered for the 'error' event,
  /// and an 'error' event is emitted, the error is thrown.
  void _processQueue() {
    _processing = true;

    final emittedEvent = _eventQueue.isEmpty ? null : _eventQueue.removeAt(0);
    if (emittedEvent != null) {
      // We call all listeners and process the next event when all listeners finished.
      // The listeners are not awaited so async listeners may execute concurrently.
      // However, we only process the next event once all listeners for this event have settled
      // this ensures that async listeners for distinct events do not run concurrently.
      // If there are no other events, the recursive call will enter the else branch below
      // and mark the queue as no longer being processed.
      final (:event, :arg) = emittedEvent;
      final listeners = _getListeners(event);

      if (event == 'error' && listeners.isEmpty) {
        _processing = false;
        throw arg as Object;
      }

      // deep copy because once listeners mutate the `this.listeners` array as they remove themselves
      // which breaks the `map` which iterates over that same array while the contents may shift
      final ls = [...listeners];
      final listenerProms = ls.map((listener) async {
        try {
          await listener(arg);
        } catch (_) {
          // ignore errors to mimick Promise.allSettled
        }
      });

      Future.wait(listenerProms)
          // only process the next event when all listeners have finished
          .whenComplete(() => _processQueue());
    } else {
      // signal that the queue is no longer being processed
      _processing = false;
    }
  }

  /// Enqueues an event to be processed by its listeners.
  /// Calls each of the listeners registered for the event named `event` in order.
  /// If several asynchronous listeners are registered for this event, they may run concurrently.
  /// However, all (asynchronous) listeners are guaranteed to execute before the next event is processed.
  /// If the `error` event is emitted and the emitter does not have at least one listener registered for it,
  /// the error is thrown.
  /// @param event The event to emit.
  /// @param args The arguments to pass to the listeners.
  void enqueueEmit<Arg>(String event, Arg arg) {
    _eventQueue.add((event: event, arg: arg));
    if (!_processing) {
      _processQueue();
    }
  }

  /// Removes all listeners, or those of the specified event.
  /// @param event The event for which to remove all listeners.
  /// @returns A reference to the AsyncEventEmitter, so that calls can be chained.
  AsyncEventEmitter removeAllListeners(String? event) {
    if (event == null) {
      // delete all listeners
      _listeners = {};
    } else {
      _listeners.remove(event);
    }
    return this;
  }

  /// Removes the given event listener.
  /// @param event The event for which to remove a listener.
  /// @param listener The listener to remove.
  /// @returns A reference to the event emitter such that calls can be chained.
  AsyncEventEmitter removeListener(String event, Handler<dynamic> listener) {
    final listeners = _getListeners(event);
    final index = listeners.indexOf(listener);
    if (index != -1) {
      listeners.splice(index, 1);
    }
    return this;
  }

  /// Alias for `removeListener`.
  AsyncEventEmitter off(String event, Handler<dynamic> listener) {
    return removeListener(event, listener);
  }

  /// @returns An array listing the events for which the emitter has registered listeners.
  List<String> eventNames() {
    return _listeners.keys.toList();
  }

  /// @returns The number of listeners associated to the given event.
  int listenerCount(String event) {
    return _getListeners(event).length;
  }

  int getMaxListeners() {
    return _maxListeners;
  }

  /// By default AsyncEventEmitters print a warning if more than 10 listeners are added for a particular event.
  /// This is a useful default that helps finding memory leaks.
  /// This method modifies the limit for this specific AsyncEventEmitter instance.
  /// The value can be set to Infinity (or 0) to indicate an unlimited number of listeners.
  /// @param maxListeners
  /// @returns A reference to the event emitter, so that calls can be chained.
  AsyncEventEmitter setMaxListeners(int maxListeners) {
    _maxListeners = maxListeners;
    return this;
  }
}
