import 'dart:async';
import 'dart:typed_data';

import 'package:electricsql/src/util/types.dart';
import 'package:electricsql/src/version.dart';
import 'package:web_socket/web_socket.dart';

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
  WebSocket? _socket;
  List<StreamSubscription<dynamic>> _subscriptions = [];

  List<void Function()> _onceConnectCallbacks = [];
  List<void Function(SatelliteException error, StackTrace st)> _errorCallbacks =
      [];
  List<void Function(SatelliteException error, StackTrace st)>
      _onceErrorCallbacks = [];

  void Function(CloseEvent)? _closeListener;
  void Function(Data data)? _messageListener;

  // A way to signal an error when the socket is being opened
  Completer<void>? _openingSocketErrorCompleter;

  WebSocketBase(this.protocolVsn);

  // event doesn't provide much
  void _notifyErrorAndCloseSocket({
    SatelliteException? error,
    required StackTrace stackTrace,
  }) {
    final effectiveError = error ??
        SatelliteException(SatelliteErrorCode.socketError, 'socket error');
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

  @override
  Socket open(ConnectionOptions opts) {
    _asyncStart(opts);
    return this;
  }

  Future<void> _asyncStart(ConnectionOptions opts) async {
    if (_socket != null) {
      throw SatelliteException(
        SatelliteErrorCode.internal,
        'trying to open a socket before closing existing socket',
      );
    }

    if (_openingSocketErrorCompleter != null) {
      _openingSocketErrorCompleter!.completeError(
        Exception(
          'trying to open a socket while another socket is being opened',
        ),
      );
      return;
    }

    _openingSocketErrorCompleter = Completer<void>();
    try {
      final _open = WebSocket.connect(
        Uri.parse(opts.url),
        protocols: [protocolVsn],
      );
      await Future.any([
        _open,
        _openingSocketErrorCompleter!.future,
      ]);
      _socket = await _open;
    } catch (e) {
      _notifyErrorAndCloseSocket(
        error: SatelliteException(
          SatelliteErrorCode.socketError,
          'failed to stablish a socket connection',
        ),
        stackTrace: StackTrace.current,
      );
      return;
    } finally {
      _openingSocketErrorCompleter = null;
    }

    // Notify connected
    _connectListener();

    final msgSubscription = _socket!.events //
        .listen(
      (WebSocketEvent event) async {
        switch (event) {
          case BinaryDataReceived(data: final data):
            try {
              // Notify message
              _messageListener?.call(data);
            } catch (e) {
              _notifyErrorAndCloseSocket(
                error: SatelliteException(
                  SatelliteErrorCode.internal,
                  'error parsing processing socket data',
                ),
                stackTrace: StackTrace.current,
              );
            }
          case CloseReceived(code: final code, reason: final reason):
            _socketClose(closeCode: code, closeReason: reason);
          case TextDataReceived():
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
    _socket?.sendBytes(data);
    return this;
  }

  @override
  Socket closeAndRemoveListeners() {
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

  void _socketClose({
    int? closeCode,
    String? closeReason,
  }) {
    // Check if the socket is in the process of opening
    if (_openingSocketErrorCompleter != null) {
      if (!_openingSocketErrorCompleter!.isCompleted) {
        _openingSocketErrorCompleter!.completeError(
          Exception('socket closed before it was opened'),
        );
      }
      return;
    }

    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions = [];

    final socketToClose = _socket;

    if (socketToClose != null) {
      // Close the websocket
      final closeFuture = socketToClose.close().catchError((Object e) {
        if (e is WebSocketConnectionClosed) {
          // ignore, the socket is already closed
        } else {
          throw e;
        }
      });

      if (_closeListener != null) {
        final listener = _closeListener!;
        closeFuture.then((_) {
          listener.call(
            CloseEvent(
              code: closeCode,
              reason: closeReason,
            ),
          );
        });
      }
      _closeListener = null;
    }

    _onceConnectCallbacks = [];
    _errorCallbacks = [];
    _onceErrorCallbacks = [];
    _messageListener = null;

    _socket = null;
  }
}
