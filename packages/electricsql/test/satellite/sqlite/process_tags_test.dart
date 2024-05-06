import 'package:test/test.dart';

import '../../support/satellite_helpers.dart';
import '../common.dart';
import '../process_tags.dart';

const String namespace = 'main';

late SatelliteTestContext context;

void main() {
  setUp(() async {
    context = await makeContext(namespace);
  });

  tearDown(() async {
    await context.cleanAndStopSatellite();
  });

  processTagsTests(
    getContext: () => context,
    namespace: namespace,
    getMatchingShadowEntries: getSQLiteMatchingShadowEntries,
  );
}
