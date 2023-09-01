import 'package:electricsql/src/auth/auth.dart';

class ElectricConfig {
  final AuthConfig auth;

  /// Optional URL string to connect to the Electric sync service.
  ///
  /// Should have the following format:
  /// `protocol://<host>:<port>[?ssl=true]`
  ///
  /// If the protocol is `https` or `wss` then `ssl`
  /// defaults to true. Otherwise it defaults to false.
  ///
  /// If port is not provided, defaults to 443 when
  /// ssl is enabled or 80 when it isn't.
  ///
  /// Defaults to:
  /// `http://127.0.0.1:5133`
  final String? url;

  ///  Optional flag to activate debug mode
  ///  which produces more verbose output.
  ///  Defaults to `false`.
  final bool? debug;

  ElectricConfig({
    required this.auth,
    this.url,
    this.debug,
  });
}

class HydratedConfig {
  final AuthConfig auth;
  final ReplicationConfig replication;
  final bool debug;

  HydratedConfig({
    required this.auth,
    required this.replication,
    required this.debug,
  });
}

class ReplicationConfig {
  final String host;
  final int port;
  final bool ssl;

  ReplicationConfig({
    required this.host,
    required this.port,
    required this.ssl,
  });
}

HydratedConfig hydrateConfig(ElectricConfig config) {
  final auth = config.auth;

  final debug = config.debug ?? false;

  final url = Uri.parse(config.url ?? 'http://127.0.0.1:5133');

  final isSecureProtocol = url.scheme == 'https' || url.scheme == 'wss';
  final sslEnabled = isSecureProtocol || url.queryParameters['ssl'] == 'true';

  final defaultPort = sslEnabled ? 443 : 80;
  final port = url.hasPort ? url.port : defaultPort;

  final replication = ReplicationConfig(
    host: url.host,
    port: port,
    ssl: sslEnabled,
  );

  return HydratedConfig(
    auth: auth,
    replication: replication,
    debug: debug,
  );
}
