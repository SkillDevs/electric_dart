import 'package:electricsql/src/sockets/sockets.dart';

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
}
