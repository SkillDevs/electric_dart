import 'package:electricsql/src/migrators/query_builder/query_builder.dart';
import 'package:test/test.dart';

import '../../support/postgres.dart';
import '../../support/satellite_helpers.dart';
import '../common.dart';
import '../process_migration.dart';

const String namespace = 'public';

int port = 5000;

late SatelliteTestContext context;
late EmbeddedPostgresDb pgEmbedded;

const builder = kPostgresQueryBuilder;

void main() {
  setUpAll(() async {
    pgEmbedded = await makePgDatabase('process-migration-tests', port);
  });

  tearDownAll(() async {
    await pgEmbedded.dispose();
  });

  setUp(() async {
    context = await makePgContext(pgEmbedded, namespace);
    await commonSetup(context);
  });

  tearDown(() async {
    await context.cleanAndStopSatellite();
  });

  processMigrationTests(
    getContext: () => context,
    namespace: namespace,
    builder: builder,
    getMatchingShadowEntries: getPgMatchingShadowEntries,
  );
}
