import 'package:electricsql/src/drivers/drift/drift_adapter.dart';
import 'package:electricsql/src/migrators/query_builder/query_builder.dart';
import 'package:electricsql/src/util/encoders/encoders.dart';
import 'package:electricsql/src/util/random.dart';
import 'package:test/test.dart';

import '../../support/postgres.dart';
import '../common.dart';
import '../serialization.dart';

int port = 4800;

Future<void> main() async {
  late EmbeddedPostgresDb pgEmbedded;

  setUpAll(() async {
    pgEmbedded = await makePgDatabase('serialization-tests', port);
  });

  tearDownAll(() async {
    await pgEmbedded.dispose();
  });

  serializationTests(
    dialect: Dialect.postgres,
    typeEncoder: kPostgresTypeEncoder,
    typeDecoder: kPostgresTypeDecoder,
    setup: () async {
      final dbName = 'serialization-test-${randomValue()}';
      final scopedDb = await initScopedPostgresDatabase(pgEmbedded, dbName);
      addTearDown(() => scopedDb.dispose());

      const namespace = 'public';
      final adapter = DriftAdapter(scopedDb.db);

      return [adapter, kPostgresQueryBuilder, opts(namespace)];
    },
  );
}
