import 'package:test/test.dart';

import '../common.dart';
import '../process_timing.dart';

late SatelliteTestContext context;

void main() {
  setUp(() async {
    context = await makeContext('main');
  });

  tearDown(() async {
    await context.cleanAndStopDb();
  });

  processTimingTests(
    getContext: () => context,
  );
}
