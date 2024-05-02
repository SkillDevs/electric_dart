import 'package:test/test.dart';

import '../common.dart';
import '../process_timing.dart';

late SatelliteTestContext context;

int port = 4900;

void main() {
  setUp(() async {
    context = await makePgContext(port++, 'public');
  });

  tearDown(() async {
    await context.cleanAndStopSatellite();
  });

  processTimingTests(
    getContext: () => context,
  );
}
