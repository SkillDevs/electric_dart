import 'package:electricsql/src/sockets/sockets.dart';
import 'package:electricsql/src/util/types.dart';
import 'package:events_emitter/emitters/event_emitter.dart';

class MockSocketFactory implements SocketFactory {
  @override
  Socket create() {
    return MockSocket();
  }
}

class MockSocket extends EventEmitter implements Socket {
  @override
  Socket open(ConnectionOptions opts) {
    return this;
  }

  @override
  Socket write(Data data) {
    return this;
  }

  @override
  Socket closeAndRemoveListeners() {
    return this;
  }

  @override
  void onClose(void Function() cb) {}

  @override
  void onError(void Function(SatelliteException error) cb) {}

  @override
  void onMessage(void Function(Data data) cb) {}

  @override
  void onceConnect(void Function() cb) {}

  @override
  void onceError(void Function(SatelliteException error) cb) {}

  @override
  void removeErrorListener(void Function(SatelliteException error) cb) {}
}
