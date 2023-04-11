import 'dart:async';
import 'dart:typed_data';

import 'package:electric_client/sockets/sockets.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:io' as io;

class WebSocketIOFactory implements SocketFactory {
  @override
  Socket create() {
    return WebSocketIO();
  }
}

class WebSocketIO implements Socket {
  IOWebSocketChannel? _channel;
  List<StreamSubscription<dynamic>> _subscriptions = [];

  List<void Function()> _onceConnectCallbacks = [];
  List<void Function(Object error)> _onceErrorCallbacks = [];

  List<void Function(Object error)> _errorCallbacks = [];
  List<void Function()> _closeCallbacks = [];
  List<void Function(Data data)> _messageCallbacks = [];

  @override
  Socket closeAndRemoveListeners() {
    _channel?.sink.close();
    for (final cb in _closeCallbacks) {
      cb();
    }

    _subscriptions = [];
    _onceConnectCallbacks = [];
    _onceErrorCallbacks = [];
    _errorCallbacks = [];
    _closeCallbacks = [];
    _messageCallbacks = [];
    return this;
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
    () async {
      try {
        final ws = await io.WebSocket.connect(
          opts.url,
        );
        while (_onceConnectCallbacks.isNotEmpty) {
          _onceConnectCallbacks.removeLast()();
        }

        _channel = IOWebSocketChannel(ws);
        final msgSubscription = _channel!.stream.listen(
          (rawData) {
            print("Raw Message $rawData");
            final bytes = rawData as Uint8List;

            for (final cb in _messageCallbacks) {
              cb(bytes);
            }
          },
          cancelOnError: true,
        );
        _subscriptions.add(msgSubscription);
      } catch (e) {
        for (final cb in _errorCallbacks) {
          cb(e);
        }

        while (_onceErrorCallbacks.isNotEmpty) {
          _onceErrorCallbacks.removeLast()(Exception('failed to establish connection'));
        }
      }

      //.timeout(opts.);

      // this.socket = socket;
      // //socket.binaryType = 'arraybuffer'

      // final connectionSubs = socket.stream.listen(
      //   (ConnectionState connectionState) {
      //     // TODO: Reconnected state === open ??
      //     print(connectionState);
      //     if (connectionState is Connected) {
      //       while (_onceConnectCallbacks.isNotEmpty) {
      //         _onceConnectCallbacks.removeLast()();
      //       }
      //     }
      //   },
      //   onError: (Object e, st) {
      //     print("On error connction $e");

      //     for (final cb in _errorCallbacks) {
      //       cb(e);
      //     }

      //     while (_onceErrorCallbacks.isNotEmpty) {
      //       _onceErrorCallbacks.removeLast()(Exception('failed to establish connection'));
      //     }
      //   },
      //   onDone: () {
      //     for (final cb in _closeCallbacks) {
      //       cb();
      //     }
      //   },
      // );
      // _subscriptions.add(connectionSubs);
    }();
    return this;
  }

  @override
  Socket write(Data data) {
    _channel?.sink.add(data);
    return this;
  }
}
