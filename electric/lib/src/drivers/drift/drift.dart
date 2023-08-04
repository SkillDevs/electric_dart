import 'package:drift/drift.dart';
import 'package:electric_client/drivers/drift.dart';
import 'package:electric_client/electric_client.dart';
import 'package:electric_client/src/electric/electric.dart' as electrify_lib;
import 'package:electric_client/src/sockets/sockets.dart';

Future<ElectricClient> electrify({
  required String dbName,
  required DatabaseConnectionUser db,
  required List<Migration> migrations,
  required ElectricConfig config,
  ElectrifyOptions? opts,
}) async {
  final adapter = opts?.adapter ?? DriftAdapter(db);
  final socketFactory = opts?.socketFactory ?? getDefaultSocketFactory();

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

  final notifier = namespace.notifier;

  // TODO(dart): Where to unsubscribe?
  // ignore: unused_local_variable
  final dispose = (namespace.adapter as DriftAdapter).hookToNotifier(notifier);

  return namespace;
}
