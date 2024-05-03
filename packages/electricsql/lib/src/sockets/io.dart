import 'package:electricsql/src/sockets/sockets.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// The interval at which the client pings the server.
/// Needed so that Electric doesn't close the connection
/// We use the same tick as the Electric service
/// https://github.com/electric-sql/electric/blob/364b60365bf48bf8c3a746ec9acf0be74ba8ea15/components/electric/lib/electric/satellite/ws_server.ex#L47
const _kSocketsPingInterval = Duration(seconds: 5);

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
