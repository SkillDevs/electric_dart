import 'package:electricsql/src/util/tablename.dart';

class ConnectionBackoffOptions {
  /// Delay factor to double after every connection attempt.
  ///
  /// Defaults to 1 second, which results in the following delays:
  ///  1. 1 s
  ///  2. 2 s
  ///  3. 4 s
  ///  4. 8 s
  ///  5. 10 s
  ///
  /// Before application of [randomizationFactor].
  final Duration startingDelay;

  /// Percentage the delay should be randomized, given as fraction between
  /// 0 and 1.
  ///
  /// If [randomizationFactor] is `0.25` (default) this indicates 25 % of the
  /// delay should be increased or decreased by 25 %.
  final double randomizationFactor;

  /// Maximum delay between retries, defaults to 10 seconds.
  final Duration maxDelay;

  /// Maximum number of attempts before giving up, defaults to 50.
  final int numOfAttempts;

  const ConnectionBackoffOptions({
    required this.numOfAttempts,
    required this.startingDelay,
    required this.maxDelay,
    required this.randomizationFactor,
  });
}

const SatelliteOpts kSatelliteDefaults = SatelliteOpts(
  metaTable: QualifiedTablename('main', '_electric_meta'),
  migrationsTable: QualifiedTablename('main', '_electric_migrations'),
  oplogTable: QualifiedTablename('main', '_electric_oplog'),
  triggersTable: QualifiedTablename('main', '_electric_trigger_settings'),
  shadowTable: QualifiedTablename('main', '_electric_shadow'),
  pollingInterval: Duration(milliseconds: 2000),
  minSnapshotWindow: Duration(milliseconds: 40),
  clearOnBehindWindow: true,
  connectionBackoffOptions: ConnectionBackoffOptions(
    numOfAttempts: 50,
    startingDelay: Duration(milliseconds: 1000),
    maxDelay: Duration(seconds: 10000),
    randomizationFactor: 0.25, // Taken from `retry` package defaults
  ),
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

  /// On reconnect, clear client's state if cannot catch up with Electric buffered WAL
  final bool clearOnBehindWindow;

  /// Backoff options for connecting with Electric
  final ConnectionBackoffOptions connectionBackoffOptions;

  const SatelliteOpts({
    required this.metaTable,
    required this.migrationsTable,
    required this.oplogTable,
    required this.triggersTable,
    required this.shadowTable,
    required this.pollingInterval,
    required this.minSnapshotWindow,
    required this.clearOnBehindWindow,
    required this.connectionBackoffOptions,
  });

  SatelliteOpts copyWith({
    QualifiedTablename? metaTable,
    QualifiedTablename? migrationsTable,
    QualifiedTablename? oplogTable,
    QualifiedTablename? triggersTable,
    QualifiedTablename? shadowTable,
    Duration? pollingInterval,
    Duration? minSnapshotWindow,
    bool? clearOnBehindWindow,
    ConnectionBackoffOptions? connectionBackoffOptions,
  }) {
    return SatelliteOpts(
      metaTable: metaTable ?? this.metaTable,
      migrationsTable: migrationsTable ?? this.migrationsTable,
      oplogTable: oplogTable ?? this.oplogTable,
      triggersTable: triggersTable ?? this.triggersTable,
      shadowTable: shadowTable ?? this.shadowTable,
      pollingInterval: pollingInterval ?? this.pollingInterval,
      minSnapshotWindow: minSnapshotWindow ?? this.minSnapshotWindow,
      clearOnBehindWindow: clearOnBehindWindow ?? this.clearOnBehindWindow,
      connectionBackoffOptions:
          connectionBackoffOptions ?? this.connectionBackoffOptions,
    );
  }

  SatelliteOpts copyWithOverrides(SatelliteOverrides overrides) {
    return copyWith(
      metaTable: overrides.metaTable,
      migrationsTable: overrides.migrationsTable,
      oplogTable: overrides.oplogTable,
      pollingInterval: overrides.pollingInterval,
      minSnapshotWindow: overrides.minSnapshotWindow,
      clearOnBehindWindow: overrides.clearOnBehindWindow,
    );
  }
}

class SatelliteOverrides {
  final QualifiedTablename? metaTable;
  final QualifiedTablename? migrationsTable;
  final QualifiedTablename oplogTable;
  final Duration? pollingInterval;
  final Duration? minSnapshotWindow;
  final bool? clearOnBehindWindow;

  SatelliteOverrides({
    this.metaTable,
    this.migrationsTable,
    required this.oplogTable,
    this.pollingInterval,
    this.minSnapshotWindow,
    this.clearOnBehindWindow,
  });
}
