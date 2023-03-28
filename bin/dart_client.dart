import 'package:electric_client/satellite/client.dart';
import 'package:electric_client/websocket.dart';

void main(List<String> arguments) {
  final client = SatelliteClient();
  final ws = WebsocketIO(client);
  ws.open();
}
