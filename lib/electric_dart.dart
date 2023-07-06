/// Dart implementation of Electric SQL
library electric_dart;

export 'src/auth/auth.dart' show AuthConfig;
export 'src/client/model/client.dart' show ElectricClient;
export 'src/config/config.dart'
    show ConsoleConfig, ElectricConfig, HydratedConfig, ReplicationConfig;
export 'src/electric/adapter.dart' show DatabaseAdapter;
export 'src/migrators/bundle.dart' show BundleMigrator;
export "src/migrators/migrators.dart" show Migration;
export 'src/notifiers/event.dart' show EventNotifier;
export 'src/satellite/registry.dart' show globalRegistry;
export "src/satellite/satellite.dart" show Satellite;
export 'src/sockets/io.dart' show WebSocketIOFactory;
export 'src/util/debug/debug.dart' show setLogLevel;
export "src/util/types.dart" show ConnectivityState;
