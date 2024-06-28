import 'package:electricsql/src/sockets/sockets.dart';

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
}
