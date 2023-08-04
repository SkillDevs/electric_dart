import 'dart:async';
import 'dart:html' as html;

import 'package:electricsql/src/sockets/sockets.dart';
import 'package:web_socket_channel/html.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

SocketFactory getDefaultSocketFactory() {
  return WebSocketHtmlFactory();
}

class WebSocketHtmlFactory implements SocketFactory {
  @override
  Socket create() {
    return WebSocketHtml();
  }
}

class WebSocketHtml extends WebSocketBase<html.WebSocket> {
  @override
  Future<html.WebSocket> createNativeSocketConnection(String url) async {
    final ws = html.WebSocket(url);
    ws.binaryType = 'arraybuffer';
    return ws;
  }

  @override
  WebSocketChannel createSocketChannel(html.WebSocket socketType) {
    return HtmlWebSocketChannel(socketType);
  }
}
