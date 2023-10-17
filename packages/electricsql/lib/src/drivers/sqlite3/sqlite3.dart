import 'package:electricsql/drivers/sqlite3.dart';
import 'package:electricsql/electricsql.dart';
import 'package:electricsql/src/client/model/schema.dart';
import 'package:electricsql/src/electric/electric.dart' as electrify_lib;
import 'package:electricsql/src/electric/electric.dart';
import 'package:electricsql/src/sockets/sockets.dart';
import 'package:sqlite3/sqlite3.dart';

// TODO(update): Consider removing support for raw sqlite3 electrification
Future<ElectricClient> electrify({
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
