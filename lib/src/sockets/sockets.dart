import 'dart:typed_data';

typedef Data = Uint8List;

abstract class Socket {
  Socket open(ConnectionOptions opts);
  Socket write(Data data);
  Socket closeAndRemoveListeners();

  void onMessage(void Function(Data data) cb);
  void onError(void Function(Object error) cb);
  void onClose(void Function() cb);

  void onceConnect(void Function() cb);
  void onceError(void Function(Object error) cb);
}

class ConnectionOptions {
  final String url;

  ConnectionOptions(this.url);
}

abstract class SocketFactory {
  Socket create();
}
