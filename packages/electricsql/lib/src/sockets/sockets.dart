import 'dart:async';
import 'dart:typed_data';

import 'package:electricsql/src/util/types.dart';
import 'package:meta/meta.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

export 'stub.dart'
    if (dart.library.io) 'io.dart'
    if (dart.library.html) 'html.dart';

typedef Data = Uint8List;

abstract class Socket {
  Socket open(ConnectionOptions opts);
  Socket write(Data data);
  Socket closeAndRemoveListeners();

  void onMessage(void Function(Data data) cb);
  void onError(void Function(SatelliteException error) cb);
  void onClose(void Function() cb);

  void onceConnect(void Function() cb);
  void onceError(void Function(SatelliteException error) cb);

  void removeErrorListener(void Function(SatelliteException error) cb);
}

class ConnectionOptions {
  final String url;

  ConnectionOptions(this.url);
}

abstract class SocketFactory {
  Socket create();
}

/// Socket implementation that uses web_socket_channel
/// io and html both derive from the main logic here
abstract class WebSocketBase<SocketType> implements Socket {
  WebSocketChannel? _channel;
  List<StreamSubscription<dynamic>> _subscriptions = [];

  List<void Function()> _onceConnectCallbacks = [];
  List<void Function(SatelliteException error)> _onceErrorCallbacks = [];

  List<void Function(SatelliteException error)> _errorCallbacks = [];
  List<void Function()> _closeCallbacks = [];
  List<void Function(Data data)> _messageCallbacks = [];

  @protected
  Future<SocketType> createNativeSocketConnection(String url);

  @protected
  WebSocketChannel createSocketChannel(SocketType socketType);

  @override
  Socket closeAndRemoveListeners() {
    _socketClose();
    _onceConnectCallbacks = [];
    _onceErrorCallbacks = [];

    return this;
  }

  void _socketClose() {
    for (final subscription in _subscriptions) {
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
  void onError(void Function(SatelliteException error) cb) {
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
  void onceError(void Function(SatelliteException error) cb) {
    _onceErrorCallbacks.add(cb);
  }

  @override
  void removeErrorListener(void Function(SatelliteException error) cb) {
    _errorCallbacks.remove(cb);
  }

  @override
  Socket open(ConnectionOptions opts) {
    _asyncStart(opts);
    return this;
  }

  Future<void> _asyncStart(ConnectionOptions opts) async {
    if (this._channel != null) {
      throw SatelliteException(
        SatelliteErrorCode.internal,
        'trying to open a socket before closing existing socket',
      );
    }

    late final SocketType ws;
    try {
      ws = await createNativeSocketConnection(opts.url);
    } catch (e) {
      _notifyErrorAndCloseSocket(
        SatelliteException(
          SatelliteErrorCode.socketError,
          'failed to stablish a socket connection',
        ),
      );
      return;
    }

    // Notify connected
    while (_onceConnectCallbacks.isNotEmpty) {
      _onceConnectCallbacks.removeLast()();
    }

    _channel = createSocketChannel(ws);
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
          _notifyErrorAndCloseSocket(
            SatelliteException(
              SatelliteErrorCode.internal,
              'error parsing processing socket data',
            ),
          );
        }
      },
      cancelOnError: true,
      onError: (Object e) {
        _notifyErrorAndCloseSocket(
          SatelliteException(SatelliteErrorCode.socketError, 'socket error'),
        );
      },
      onDone: () {
        _socketClose();
      },
    );
    _subscriptions.add(msgSubscription);
  }

  void _notifyErrorAndCloseSocket(SatelliteException e) {
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
