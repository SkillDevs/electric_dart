import 'package:electricsql/src/sockets/sockets.dart';
import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

SocketFactory getDefaultSocketFactory() {
  return WebSocketHtmlFactory();
}

class WebSocketHtmlFactory implements SocketFactory {
  @override
  Socket create(String protocolVsn) {
    return WebSocketHtml(protocolVsn);
  }
}

class WebSocketHtml extends WebSocketBase {
  WebSocketHtml(super.protocolVsn);

  @override
  WebSocketChannel createSocketChannel(String url) {
    return HtmlWebSocketChannel.connect(
      url,
      binaryType: BinaryType.list,
      protocols: [protocolVsn],
    );
  }
}
