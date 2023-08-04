import 'dart:async';
import 'dart:io' as io;

import 'package:electric_client/src/sockets/sockets.dart';
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

class WebSocketIO extends WebSocketBase<io.WebSocket> {
  @override
  Future<io.WebSocket> createNativeSocketConnection(String url) async {
    final ws = await io.WebSocket.connect(
      url,
    );

    return ws;
  }

  @override
  WebSocketChannel createSocketChannel(io.WebSocket socketType) {
    return IOWebSocketChannel(socketType);
  }
}
