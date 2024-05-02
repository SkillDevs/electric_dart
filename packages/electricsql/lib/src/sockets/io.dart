import 'package:electricsql/src/sockets/sockets.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// The interval at which the client ping the server.
/// Needed so that Electric doesn't close the connection
/// https://socket.io/docs/v4/server-options/#pinginterval
const _kSocketsPingInterval = Duration(seconds: 25);

SocketFactory getDefaultSocketFactory() {
  return WebSocketIOFactory();
}

class WebSocketIOFactory implements SocketFactory {
  @override
  Socket create(String protocolVsn) {
    return WebSocketIO(protocolVsn);
  }
}

class WebSocketIO extends WebSocketBase {
  WebSocketIO(super.protocolVsn);

  @override
  WebSocketChannel createSocketChannel(String url) {
    return IOWebSocketChannel.connect(
      url,
      pingInterval: _kSocketsPingInterval,
      protocols: [protocolVsn],
    );
  }
}
