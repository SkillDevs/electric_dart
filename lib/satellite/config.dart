import 'package:electric_client/util/tablename.dart';

class SatelliteConfig {
  final String app;
  final String env;

  SatelliteConfig({required this.app, required this.env});
}

const SatelliteOpts kSatelliteDefaults = SatelliteOpts(
  metaTable: QualifiedTablename('main', '_electric_meta'),
  migrationsTable: QualifiedTablename('main', '_electric_migrations'),
  oplogTable: QualifiedTablename('main', '_electric_oplog'),
  triggersTable: QualifiedTablename('main', '_electric_trigger_settings'),
  shadowTable: QualifiedTablename('main', '_electric_shadow'),
  pollingInterval: 2000,
  minSnapshotWindow: 40,
);

const kDefaultSatelliteTimeout = 3000;
const kDefaultSatellitePushPeriod = 500;

class SatelliteClientOpts {
  final String host;
  final int port;
  final bool ssl;
  final int timeout;
  final int pushPeriod;

  SatelliteClientOpts({
    required this.host,
    required this.port,
    required this.ssl,
    this.timeout = kDefaultSatelliteTimeout,
    this.pushPeriod = kDefaultSatellitePushPeriod,
  });
}

class SatelliteOpts {
  // The database table where Satellite keeps its processing metadata.
  final QualifiedTablename metaTable;
  // The database table where the bundle migrator keeps its metadata.
  final QualifiedTablename migrationsTable;
  // The database table where change operations are written to by the triggers
  // automatically added to all tables in the user defined DDL schema.
  final QualifiedTablename oplogTable;
  // The database table that controls active opLog triggers.
  final QualifiedTablename triggersTable;
  // The database table that contains dependency tracking information
  final QualifiedTablename shadowTable;
  // Polls the database for changes every `pollingInterval` milliseconds.
  final int pollingInterval;
  // Throttle snapshotting to once per `minSnapshotWindow` milliseconds.
  final int minSnapshotWindow;

  const SatelliteOpts({
    required this.metaTable,
    required this.migrationsTable,
    required this.oplogTable,
    required this.triggersTable,
    required this.shadowTable,
    required this.pollingInterval,
    required this.minSnapshotWindow,
  });
}
