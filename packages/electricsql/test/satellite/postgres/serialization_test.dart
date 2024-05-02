import 'package:electricsql/src/drivers/drift/drift_adapter.dart';
import 'package:electricsql/src/migrators/query_builder/query_builder.dart';
import 'package:electricsql/src/util/encoders/encoders.dart';
import 'package:electricsql/src/util/random.dart';
import 'package:test/test.dart';

import '../../support/postgres.dart';
import '../common.dart';
import '../serialization.dart';

int port = 4800;

void main() {
  serializationTests(
    dialect: Dialect.postgres,
    typeEncoder: kPostgresTypeEncoder,
    typeDecoder: kPostgresTypeDecoder,
    setup: () async {
      final dbName = 'serialization-test-${randomValue()}';
      final pgEmbedded = await makePgDatabase(dbName, port++);
      addTearDown(() => pgEmbedded.dispose());
      final db = pgEmbedded.db;
      const namespace = 'public';
      final adapter = DriftAdapter(db);

      return [adapter, kPostgresQueryBuilder, opts(namespace)];
    },
  );
}
