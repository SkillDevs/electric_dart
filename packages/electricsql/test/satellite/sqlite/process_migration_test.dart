import 'package:electricsql/src/migrators/query_builder/query_builder.dart';
import 'package:electricsql/src/util/tablename.dart';
import 'package:test/test.dart';

import '../../support/satellite_helpers.dart';
import '../common.dart';
import '../process_migration.dart';

const QueryBuilder builder = kSqliteQueryBuilder;
const String namespace = 'main';

late SatelliteTestContext context;
final qualifiedParentTableName = const QualifiedTablename(
  namespace,
  'parent',
).toString();

void main() {
  setUp(() async {
    context = await makeContext(namespace);
    await commonSetup(context);
  });

  tearDown(() async {
    await context.cleanAndStopSatellite();
  });

  processMigrationTests(
    getContext: () => context,
    namespace: namespace,
    builder: builder,
    qualifiedParentTableName: qualifiedParentTableName,
    getMatchingShadowEntries: getSQLiteMatchingShadowEntries,
  );
}
