import 'package:electricsql/drivers/sqlite3.dart';
import 'package:electricsql/electricsql.dart';
import 'package:electricsql/src/electric/electric.dart' as electrify_lib;
import 'package:electricsql/src/electric/electric.dart';
import 'package:electricsql/src/sockets/sockets.dart';
import 'package:sqlite3/sqlite3.dart';

Future<ElectricClient> electrify({
  required String dbName,
  required Database db,
  required List<Migration> migrations,
  required ElectricConfig config,
  ElectrifyOptions? opts,
}) async {
  final adapter = opts?.adapter ?? SqliteAdapter(db);
  final socketFactory = opts?.socketFactory ?? getDefaultSocketFactory();

  final namespace = await electrify_lib.electrify(
    dbName: dbName,
    migrations: migrations,
    config: config,
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
