import 'package:test/test.dart';

import '../../../util/pg_docker.dart';
import '../../drift/client_test_util.dart';
import '../../drift/database.dart';
import '../datatype.dart';

void main() {
  withPostgresServer('postgres', (server) {
    late TestsDatabase db;

    setUp(() async {
      final endpoint = await server.endpoint();
      db = TestsDatabase.postgres(endpoint);
      await db.customSelect('SELECT 1').getSingle();

      final electric = await electrifyTestDatabase(db);
      await electric.syncTable(db.dataTypes);
      await initClientTestsDb(db);
    });

    tearDown(() async {
      await db.close();
    });

    dataTypeTests(getDb: () => db, isPostgres: true);
  });
}
