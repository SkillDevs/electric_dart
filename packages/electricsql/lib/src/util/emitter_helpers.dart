import 'package:events_emitter/emitters/event_emitter.dart';

void removeListeners(EventEmitter emitter, String type) {
  final listeners = emitter.listeners.toList();
  for (final listener in listeners) {
    if (listener.type == type) {
      emitter.removeEventListener(listener);
    }
  }
}
