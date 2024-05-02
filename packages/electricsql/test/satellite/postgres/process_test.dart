import 'package:drift/drift.dart';
import 'package:electricsql/src/drivers/drift/drift_adapter.dart';
import 'package:electricsql/src/migrators/query_builder/query_builder.dart';
import 'package:electricsql/src/util/tablename.dart';
import 'package:postgres/postgres.dart';
import 'package:test/test.dart';

import '../../support/postgres.dart';
import '../../support/satellite_helpers.dart';
import '../common.dart';
import '../process.dart';

const QueryBuilder builder = kPostgresQueryBuilder;
const String namespace = 'public';

int port = 5200;

late SatelliteTestContext context;
final qualifiedParentTableName = const QualifiedTablename(
  namespace,
  'parent',
).toString();

late EmbeddedPostgresDb pgEmbedded;

void main() {
  setUpAll(() async {
    pgEmbedded = await makePgDatabase('process-tests', port);
  });

  tearDownAll(() async {
    await pgEmbedded.dispose();
  });

  setUp(() async {
    context = await makePgContext(pgEmbedded, 'public');
  });

  tearDown(() async {
    await context.cleanAndStopSatellite();
  });

  processTests(
    getContext: () => context,
    namespace: namespace,
    builder: builder,
    qualifiedParentTableName: qualifiedParentTableName,
    getMatchingShadowEntries: getPgMatchingShadowEntries,
  );
}
