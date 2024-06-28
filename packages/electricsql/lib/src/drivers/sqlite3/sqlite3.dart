import 'package:electricsql/drivers/sqlite3.dart';
import 'package:electricsql/electricsql.dart';
import 'package:electricsql/src/config/config.dart';
import 'package:electricsql/src/electric/electric.dart' as electrify_lib;
import 'package:electricsql/src/migrators/query_builder/query_builder.dart';
import 'package:electricsql/src/sockets/sockets.dart';
import 'package:sqlite3/sqlite3.dart';

/// Electrify a [Database] from the [sqlite3] package.
/// WARNING: This is a very raw and low level driver.
/// It's recommended to use the Drift electrification instead, as it will handle multiple Electric features
/// automatically for you, like type mappings and query reactivity.
/// With this electrification you will need to take care of those yourself with
/// the [TypeConverters] and with the [Notifier] from the [ElectricClient].
Future<ElectricClientRaw> electrify({
  required String dbName,
  required Database db,
  required DBSchema dbDescription,
  required ElectricConfig config,
  ElectrifyOptions? opts,
}) async {
  final adapter = opts?.adapter ?? SqliteAdapter(db);
  final socketFactory = opts?.socketFactory ?? getDefaultSocketFactory();

  final namespace = await electrify_lib.electrifyBase(
    dbName: dbName,
    dbDescription: dbDescription,
    config: ElectricConfigWithDialect.from(
      config: config,
      dialect: Dialect.sqlite,
    ),
    adapter: adapter,
    socketFactory: socketFactory,
    opts: ElectrifyBaseOptions(
      migrator: opts?.migrator,
      notifier: opts?.notifier,
      registry: opts?.registry,
    ),
  );

  return namespace;
}
