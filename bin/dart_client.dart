import 'package:electric_client/auth/auth.dart';
import 'package:electric_client/config/config.dart';
import 'package:electric_client/satellite/client.dart';
import 'package:electric_client/satellite/config.dart';
import 'package:electric_client/satellite/process.dart';
import 'package:electric_client/websocket.dart';

void main(List<String> arguments) async {
  final appId = "my-todos";
  final env = "local";

  final replicationConfig = ReplicationConfig(
    host: '127.0.0.1',
    port: 5133,
    ssl: false,
  );

  final client = Client(
    SatelliteClientOpts(
      host: replicationConfig.host,
      port: replicationConfig.port,
      ssl: replicationConfig.ssl,
    ),
  );

  final satellite = Satellite(
    client: client,
    config: SatelliteConfig(app: appId, env: env),
    console: ConsoleClient(
      ElectricConfig(
        app: appId,
        env: env,
        console: ConsoleConfig(
          host: '127.0.0.1',
          port: 4000,
          ssl: false,
        ),
        replication: replicationConfig,
      ),
    ),
  );

  await satellite.start(null);
  // final ws = WebsocketIO(client);
  // ws.open();
}
