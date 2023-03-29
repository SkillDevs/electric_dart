typedef AppName = String;
typedef EnvName = String;

class ElectricConfig {
  final AppName app;
  final EnvName env;
  // TODO: Migrations
  // migrations
  final ConsoleConfig? console;
  final ReplicationConfig? replication;
  final bool? debug;

  ElectricConfig({
    required this.app,
    required this.env,
    this.console,
    this.replication,
    this.debug,
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
