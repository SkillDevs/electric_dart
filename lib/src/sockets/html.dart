import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:electric_client/src/sockets/sockets.dart';
import 'package:web_socket_channel/html.dart';

class WebSocketHtmlFactory implements SocketFactory {
  @override
  Socket create() {
    return WebSocketHtml();
  }
}

class WebSocketHtml implements Socket {
  HtmlWebSocketChannel? _channel;
  List<StreamSubscription<dynamic>> _subscriptions = [];

  List<void Function()> _onceConnectCallbacks = [];
  List<void Function(Object error)> _onceErrorCallbacks = [];

  List<void Function(Object error)> _errorCallbacks = [];
  List<void Function()> _closeCallbacks = [];
  List<void Function(Data data)> _messageCallbacks = [];

  @override
  Socket closeAndRemoveListeners() {
    _socketClose();
    _onceConnectCallbacks = [];
    _onceErrorCallbacks = [];

    return this;
  }

  void _socketClose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions = [];

    _channel?.sink.close();

    final closeCallbacks = [..._closeCallbacks];
    _closeCallbacks = [];
    for (final cb in closeCallbacks) {
      cb();
    }

    _errorCallbacks = [];
    _messageCallbacks = [];

    _channel = null;
  }

  @override
  void onClose(void Function() cb) {
    _closeCallbacks.add(cb);
  }

  @override
  void onError(void Function(Object error) cb) {
    _errorCallbacks.add(cb);
  }

  @override
  void onMessage(void Function(Data data) cb) {
    _messageCallbacks.add(cb);
  }

  @override
  void onceConnect(void Function() cb) {
    _onceConnectCallbacks.add(cb);
  }

  @override
  void onceError(void Function(Object error) cb) {
    _onceErrorCallbacks.add(cb);
  }

  @override
  Socket open(ConnectionOptions opts) {
    _asyncStart(opts);
    return this;
  }

  Future<void> _asyncStart(ConnectionOptions opts) async {
    late final html.WebSocket ws;
    try {
      ws = html.WebSocket(
        opts.url,
      );
    } catch (e) {
      _notifyErrorAndCloseSocket(Exception('failed to establish connection'));
      return;
    }

    // Notify connected
    while (_onceConnectCallbacks.isNotEmpty) {
      _onceConnectCallbacks.removeLast()();
    }

    _channel = HtmlWebSocketChannel(ws);
    final msgSubscription = _channel!.stream //
        .listen(
      (rawData) {
        try {
          final bytes = rawData as Uint8List;

          // Notify message
          for (final cb in _messageCallbacks) {
            cb(bytes);
          }
        } catch (e) {
          _notifyErrorAndCloseSocket(e);
        }
      },
      cancelOnError: true,
      onError: (Object e) {
        _notifyErrorAndCloseSocket(e);
      },
      onDone: () {
        _socketClose();
      },
    );
    _subscriptions.add(msgSubscription);
  }

  void _notifyErrorAndCloseSocket(Object e) {
    for (final cb in _errorCallbacks) {
      cb(e);
    }

    while (_onceErrorCallbacks.isNotEmpty) {
      _onceErrorCallbacks.removeLast()(e);
    }

    _socketClose();
  }

  @override
  Socket write(Data data) {
    _channel?.sink.add(data);
    return this;
  }
}
