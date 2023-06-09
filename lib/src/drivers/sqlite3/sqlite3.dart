import 'package:electric_client/electric_dart.dart';
import 'package:electric_client/src/client/model/client.dart';
import 'package:electric_client/src/electric/electric.dart' as electrify_lib;
import 'package:electric_client/src/electric/electric.dart';
import 'package:sqlite3/sqlite3.dart';

Future<ElectricClient> electrify({
  required String dbName,
  required Database db,
  required List<Migration> migrations,
  required ElectricConfig config,
  ElectrifyOptions? opts,
}) async {
  final adapter = opts?.adapter ?? SqliteAdapter(db);
  final socketFactory = opts?.socketFactory ?? WebSocketIOFactory();

  final namespace = await electrify_lib.electrify(
    dbName: dbName,
    migrations: migrations,
    config: config,
    opts: ElectrifyOptions(
      adapter: adapter,
      socketFactory: socketFactory,
      migrator: opts?.migrator,
      notifier: opts?.notifier,
      registry: opts?.registry,
    ),
  );

  return namespace;
}
