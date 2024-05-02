@Tags(['postgres'])
library;

import 'package:test/test.dart';

import '../../support/postgres.dart';
import '../common.dart';
import '../process_timing.dart';

late SatelliteTestContext context;

int port = 4900;

void main() {

  late EmbeddedPostgresDb pgEmbedded;

  setUpAll(() async {
    pgEmbedded = await makePgDatabase('process-timing-tests', port);
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

  processTimingTests(
    getContext: () => context,
  );
}
