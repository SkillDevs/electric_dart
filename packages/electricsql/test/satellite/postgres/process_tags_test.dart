@Tags(['postgres'])
library;

import 'package:test/test.dart';

import '../../support/postgres.dart';
import '../../support/satellite_helpers.dart';
import '../common.dart';
import '../process_tags.dart';

const String namespace = 'public';

int port = 5100;

late SatelliteTestContext context;
late EmbeddedPostgresDb pgEmbedded;

void main() {
  setUpAll(() async {
    pgEmbedded = await makePgDatabase('process-tags-tests', port);
  });

  tearDownAll(() async {
    await pgEmbedded.dispose();
  });

  setUp(() async {
    context = await makePgContext(pgEmbedded, namespace);
  });

  tearDown(() async {
    await context.cleanAndStopSatellite();
  });

  processTagsTests(
    getContext: () => context,
    namespace: namespace,
    getMatchingShadowEntries: getPgMatchingShadowEntries,
  );
}
