import 'dart:async';
import 'dart:typed_data';

import 'package:electric_client/sockets/sockets.dart';
import 'package:web_socket_client/web_socket_client.dart';

class IoSocket implements Socket {
  WebSocket? socket;
  final List<StreamSubscription<dynamic>> _subscriptions = [];

  final List<void Function()> _onceConnectCallbacks = [];
  final List<void Function(Object error)> _onceErrorCallbacks = [];

  final List<void Function(Object error)> _errorCallbacks = [];
  final List<void Function()> _closeCallbacks = [];
  final List<void Function(Data data)> _messageCallbacks = [];

  @override
  Socket closeAndRemoveListeners() {
    socket?.close();

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
    final socket = WebSocket(Uri.parse(opts.url));
    this.socket = socket;
    //socket.binaryType = 'arraybuffer'

    final connectionSubs = socket.connection.listen(
      (ConnectionState connectionState) {
        // TODO: Reconnected state === open ??
        print(connectionState);
        if (connectionState is Connected) {
          while (_onceConnectCallbacks.isNotEmpty) {
            _onceConnectCallbacks.removeLast()();
          }
        }
      },
      onError: (Object e, st) {
        print("On error connction $e");

        for (final cb in _errorCallbacks) {
          cb(e);
        }

        while (_onceErrorCallbacks.isNotEmpty) {
          _onceErrorCallbacks.removeLast()(Exception('failed to establish connection'));
        }
      },
      onDone: () {
        for (final cb in _closeCallbacks) {
          cb();
        }
      },
    );
    _subscriptions.add(connectionSubs);

    final msgSubscription = socket.messages.listen((rawData) {
      print("Msg $rawData");
      final bytes = rawData as Uint8List;

      for (final cb in _messageCallbacks) {
        cb(bytes);
      }
    });
    _subscriptions.add(msgSubscription);

    return this;
  }

  @override
  Socket write(Data data) {
    socket?.send(data);
    return this;
  }
}
