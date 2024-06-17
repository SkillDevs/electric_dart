import 'dart:async';
import 'dart:typed_data';

import 'package:electricsql/src/util/types.dart';
import 'package:electricsql/src/version.dart';
import 'package:meta/meta.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

export 'stub.dart'
    if (dart.library.io) 'io.dart'
    if (dart.library.js_interop) 'web.dart';

typedef Data = Uint8List;

const kAuthExpiredCloseEvent = 'JWT-expired';

/// Returns the protocol version string as the server expects. i.e: 'electric.0.6'
const kProtocolVsn = 'electric.$kElectricProtocolVersion';

abstract class Socket {
  Socket open(ConnectionOptions opts);
  Socket write(Data data);
  Socket closeAndRemoveListeners();

  void onMessage(void Function(Data data) cb);
  void onError(void Function(SatelliteException error, StackTrace st) cb);
  void onClose(void Function(SocketCloseReason reason) cb);

  void onceConnect(void Function() cb);
  void onceError(void Function(SatelliteException error, StackTrace st) cb);

  void removeErrorListener(
    void Function(SatelliteException error, StackTrace st) cb,
  );
}

class ConnectionOptions {
  final String url;

  ConnectionOptions(this.url);
}

abstract class SocketFactory {
  Socket create(String protocolVsn);
}

class CloseEvent {
  final int? code;
  final String? reason;

  CloseEvent({required this.code, required this.reason});
}

/// Socket implementation that uses web_socket_channel
/// io and html both derive from the main logic here
abstract class WebSocketBase implements Socket {
  final String protocolVsn;
  WebSocketChannel? _channel;
  List<StreamSubscription<dynamic>> _subscriptions = [];

  List<void Function()> _onceConnectCallbacks = [];
  List<void Function(SatelliteException error, StackTrace st)> _errorCallbacks =
      [];
  List<void Function(SatelliteException error, StackTrace st)>
      _onceErrorCallbacks = [];

  void Function(CloseEvent)? _closeListener;
  void Function(Data data)? _messageListener;

  WebSocketBase(this.protocolVsn);

  // event doesn't provide much
  void _notifyErrorAndCloseSocket({
    SatelliteException? error,
    required StackTrace stackTrace,
  }) {
    final effectiveError = error ??
        SatelliteException(SatelliteErrorCode.socketError, 'socket error');
    print("${DateTime.now()} NOTIFY ERROR AND CLOSE SOCKET ${effectiveError.message} ${effectiveError.code}");
    for (final callback in _errorCallbacks) {
      callback(effectiveError, stackTrace);
    }

    while (_onceErrorCallbacks.isNotEmpty) {
      final callback = _onceErrorCallbacks.removeLast();

      callback(effectiveError, stackTrace);
    }

    _socketClose();
  }

  void _connectListener() {
    while (_onceConnectCallbacks.isNotEmpty) {
      _onceConnectCallbacks.removeLast()();
    }
  }

  @protected
  WebSocketChannel createSocketChannel(String url);

  @override
  Socket open(ConnectionOptions opts) {
    _asyncStart(opts);
    return this;
  }

  Future<void> _asyncStart(ConnectionOptions opts) async {
    if (_channel != null) {
      throw SatelliteException(
        SatelliteErrorCode.internal,
        'trying to open a socket before closing existing socket',
      );
    }

    try {
      _channel = createSocketChannel(opts.url);
      print("${DateTime.now()} WAITING SOCKET CHANNEL READY");
      await _channel!.ready;
      print("${DateTime.now()} SOCKET CHANNEL IS READY");
    } catch (e) {
      _notifyErrorAndCloseSocket(
        error: SatelliteException(
          SatelliteErrorCode.socketError,
          'failed to stablish a socket connection',
        ),
        stackTrace: StackTrace.current,
      );
      return;
    }

    // Notify connected
    _connectListener();

    final msgSubscription = _channel!.stream //
        .listen(
      (rawData) {
        try {
          final bytes = rawData as Uint8List;

          // Notify message
          _messageListener?.call(bytes);
        } catch (e) {
          _notifyErrorAndCloseSocket(
            error: SatelliteException(
              SatelliteErrorCode.internal,
              'error parsing processing socket data',
            ),
            stackTrace: StackTrace.current,
          );
        }
      },
      cancelOnError: true,
      onError: (Object e) {
        _notifyErrorAndCloseSocket(stackTrace: StackTrace.current);
      },
      onDone: () {
        _socketClose();
      },
    );
    _subscriptions.add(msgSubscription);
  }

  @override
  Socket write(Data data) {
    _channel?.sink.add(data);
    return this;
  }

  @override
  Socket closeAndRemoveListeners() {
    print("${DateTime.now()} CLOSE SOCKET AND REMOVE LISTENERS");
    _messageListener = null;
    _closeListener = null;

    _socketClose();

    return this;
  }

  @override
  void onMessage(void Function(Data data) cb) {
    if (_messageListener != null) {
      throw SatelliteException(
        SatelliteErrorCode.internal,
        'socket does not support multiple message listeners',
      );
    }
    _messageListener = cb;
  }

  @override
  void onError(void Function(SatelliteException error, StackTrace st) cb) {
    _errorCallbacks.add(cb);
  }

  @override
  void onClose(void Function(SocketCloseReason reason) cb) {
    if (_closeListener != null) {
      throw SatelliteException(
        SatelliteErrorCode.internal,
        'socket does not support multiple close listeners',
      );
    }

    // ignore: prefer_function_declarations_over_variables
    final callback = (CloseEvent ev) {
      final reason = ev.reason == kAuthExpiredCloseEvent
          ? SocketCloseReason.authExpired
          : SocketCloseReason.socketError;
      cb(reason);
    };

    _closeListener = callback;
  }

  @override
  void onceConnect(void Function() cb) {
    _onceConnectCallbacks.add(cb);
  }

  @override
  void onceError(
    void Function(SatelliteException error, StackTrace stackTrace) cb,
  ) {
    _onceErrorCallbacks.add(cb);
  }

  @override
  void removeErrorListener(
    void Function(SatelliteException error, StackTrace st) cb,
  ) {
    _errorCallbacks.remove(cb);
    _onceErrorCallbacks.remove(cb);
  }

  void _socketClose() {
    print("${DateTime.now()} SOCKET CLOSE");
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions = [];

    final channelToClose = _channel;

    if (channelToClose != null) {
      final closeFuture = channelToClose.sink.close();
      if (_closeListener != null) {
        final listener = _closeListener!;
        closeFuture.then((_) {
          listener.call(
            CloseEvent(
              code: channelToClose.closeCode,
              reason: channelToClose.closeReason,
            ),
          );
        });
      }
    }

    _closeListener = null;

    _onceConnectCallbacks = [];
    _errorCallbacks = [];
    _onceErrorCallbacks = [];
    _messageListener = null;

    _channel = null;
  }
}
