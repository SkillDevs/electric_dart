import 'package:electric_client/src/util/tablename.dart';

const SatelliteOpts kSatelliteDefaults = SatelliteOpts(
  metaTable: QualifiedTablename('main', '_electric_meta'),
  migrationsTable: QualifiedTablename('main', '_electric_migrations'),
  oplogTable: QualifiedTablename('main', '_electric_oplog'),
  triggersTable: QualifiedTablename('main', '_electric_trigger_settings'),
  shadowTable: QualifiedTablename('main', '_electric_shadow'),
  pollingInterval: Duration(milliseconds: 2000),
  minSnapshotWindow: Duration(milliseconds: 40),
);

const kDefaultSatelliteTimeout = 3000;
const kDefaultSatellitePushPeriod = 500;

class SatelliteClientOpts {
  final String host;
  final int port;
  final bool ssl;
  int timeout;
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
  /// The database table where Satellite keeps its processing metadata.
  final QualifiedTablename metaTable;

  /// The database table where the bundle migrator keeps its metadata.
  final QualifiedTablename migrationsTable;

  /// The database table where change operations are written to by the triggers
  /// automatically added to all tables in the user defined DDL schema.
  final QualifiedTablename oplogTable;

  /// The database table that controls active opLog triggers.
  final QualifiedTablename triggersTable;

  /// The database table that contains dependency tracking information
  final QualifiedTablename shadowTable;

  /// Polls the database for changes every `pollingInterval` milliseconds.
  final Duration pollingInterval;

  /// Throttle snapshotting to once per `minSnapshotWindow` milliseconds.
  final Duration minSnapshotWindow;

  const SatelliteOpts({
    required this.metaTable,
    required this.migrationsTable,
    required this.oplogTable,
    required this.triggersTable,
    required this.shadowTable,
    required this.pollingInterval,
    required this.minSnapshotWindow,
  });

  SatelliteOpts copyWith({
    QualifiedTablename? metaTable,
    QualifiedTablename? migrationsTable,
    QualifiedTablename? oplogTable,
    QualifiedTablename? triggersTable,
    QualifiedTablename? shadowTable,
    Duration? pollingInterval,
    Duration? minSnapshotWindow,
  }) {
    return SatelliteOpts(
      metaTable: metaTable ?? this.metaTable,
      migrationsTable: migrationsTable ?? this.migrationsTable,
      oplogTable: oplogTable ?? this.oplogTable,
      triggersTable: triggersTable ?? this.triggersTable,
      shadowTable: shadowTable ?? this.shadowTable,
      pollingInterval: pollingInterval ?? this.pollingInterval,
      minSnapshotWindow: minSnapshotWindow ?? this.minSnapshotWindow,
    );
  }

  SatelliteOpts copyWithOverrides(SatelliteOverrides overrides) {
    return copyWith(
      metaTable: overrides.metaTable,
      migrationsTable: overrides.migrationsTable,
      oplogTable: overrides.oplogTable,
      pollingInterval: overrides.pollingInterval,
      minSnapshotWindow: overrides.minSnapshotWindow,
    );
  }
}

class SatelliteOverrides {
  final QualifiedTablename? metaTable;
  final QualifiedTablename? migrationsTable;
  final QualifiedTablename oplogTable;
  final Duration? pollingInterval;
  final Duration? minSnapshotWindow;

  SatelliteOverrides({
    this.metaTable,
    this.migrationsTable,
    required this.oplogTable,
    this.pollingInterval,
    this.minSnapshotWindow,
  });
}
