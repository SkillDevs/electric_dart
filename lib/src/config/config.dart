import 'package:electric_client/src/auth/auth.dart';
import 'package:electric_client/src/migrators/migrators.dart';

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

class ElectricConfigFilled {
  final AuthConfig auth;
  final ReplicationConfig replication;
  final bool debug;

  ElectricConfigFilled({
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
