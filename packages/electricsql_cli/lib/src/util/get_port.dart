import 'dart:io';

bool _maySupportIPv6 = true;

/// Returns a port that is not in use.
Future<DisposablePort> getUnusedPort() async {
  late int port;
  late Future<void> Function() dispose;
  if (_maySupportIPv6) {
    try {
      final socket = await ServerSocket.bind(
        InternetAddress.loopbackIPv6,
        0,
        v6Only: true,
      );
      port = socket.port;
      dispose = socket.close;
    } on SocketException {
      _maySupportIPv6 = false;
    }
  }
  if (!_maySupportIPv6) {
    final socket = await RawServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    port = socket.port;
    dispose = socket.close;
  }
  return DisposablePort(port, dispose);
}

class DisposablePort {
  DisposablePort(this.port, this.dispose);

  final int port;
  final Future<void> Function() dispose;
}
