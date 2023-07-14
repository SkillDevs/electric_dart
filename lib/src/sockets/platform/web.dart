import 'package:electric_client/electric_dart.dart';
import 'package:electric_client/html.dart';

SocketFactory getDefaultSocketFactory() {
  return WebSocketHtmlFactory();
}
