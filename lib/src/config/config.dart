import 'package:electric_client/src/auth/auth.dart';

typedef AppName = String;
typedef EnvName = String;

class ElectricConfig {
  final AuthConfig auth;

  /// Optional path to the Electric sync service.
  /// Should have the following format:
  /// `electric://<host>:<port>`
  /// Defaults to:
  /// `electric://127.0.0.1:5133`
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

class InternalElectricConfig {
  final AuthConfig auth;
  final ReplicationConfig? replication;
  final bool? debug;

  InternalElectricConfig({
    required this.auth,
    required this.replication,
    required this.debug,
  });
}

class ConsoleConfig {
  final String host;
  final int port;
  final bool ssl;

  ConsoleConfig({
    required this.host,
    required this.port,
    required this.ssl,
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

  final url = config.url ?? 'electric://127.0.0.1:5133';
  final match = RegExp(r'(?:electric:\/\/)(.+):([0-9]*)').firstMatch(url);
  if (match == null) {
    throw Exception(
      "Invalid Electric URL. Must be of the form: 'electric://<host>:<port>'",
    );
  }

  final host = match.group(1)!;
  final portStr = match.group(2)!;

  final replication = ReplicationConfig(
    host: host,
    port: int.parse(portStr),
    ssl: false,
  );

  return HydratedConfig(
    auth: auth,
    replication: replication,
    debug: debug,
  );
}
