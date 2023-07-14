import 'package:electric_client/electric_dart.dart';
import 'package:electric_client/io.dart';

SocketFactory getDefaultSocketFactory() {
  return WebSocketIOFactory();
}
