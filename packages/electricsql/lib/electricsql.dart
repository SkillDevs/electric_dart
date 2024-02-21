/// Dart implementation of Electric SQL
library electricsql;

// Auth
export 'src/auth/index.dart';

// ElectricClient
export 'src/client/model/index.dart';

// Config
export 'src/config/config.dart' show ElectricConfig, HydratedConfig;

export 'src/electric/adapter.dart' show DatabaseAdapter;

// Electric
export 'src/electric/index.dart';

export 'src/migrators/migrators.dart' show Migration;

// Type converters
export 'src/util/converters/index.dart';

// Debug
export 'src/util/debug/index.dart';

// Utils that we embed in the main library
export 'src/util/index.dart' show ConnectivityState, ConnectivityStatus;

export 'src/version.dart' show kElectricProtocolVersion;
