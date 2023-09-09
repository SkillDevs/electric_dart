import 'package:electricsql/src/sockets/sockets.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

SocketFactory getDefaultSocketFactory() {
  return WebSocketIOFactory();
}

class WebSocketIOFactory implements SocketFactory {
  @override
  Socket create() {
    return WebSocketIO();
  }
}

class WebSocketIO extends WebSocketBase {
  WebSocketIO();

  @override
  WebSocketChannel createSocketChannel(String url) {
    return IOWebSocketChannel.connect(url);
  }
}
