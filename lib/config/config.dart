import 'package:electric_client/migrators/migrators.dart';

typedef AppName = String;
typedef EnvName = String;

class ElectricConfig {
  final AppName app;
  final EnvName env;
  final List<Migration> migrations;
  final ConsoleConfig? console;
  final ReplicationConfig? replication;
  final bool? debug;

  ElectricConfig({
    required this.app,
    required this.env,
    required this.migrations,
    this.console,
    this.replication,
    this.debug,
  });
}

class ElectricConfigFilled {
  final AppName app;
  final EnvName env;
  final List<Migration> migrations;
  final ConsoleConfig console;
  final ReplicationConfig replication;
  final bool debug;

  ElectricConfigFilled({
    required this.app,
    required this.env,
    required this.console,
    required this.migrations,
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
