import 'package:test/test.dart';

import '../../drift/client_test_util.dart';
import '../../drift/database.dart';
import '../datatype.dart';

late TestsDatabase db;

void main() {
  setUp(() async {
    db = TestsDatabase.memory();

    final electric = await electrifyTestDatabase(db);
    await electric.syncTable(db.dataTypes);
    await initClientTestsDb(db);
  });

  tearDown(() async {
    await db.close();
  });

  dataTypeTests(
    getDb: () => db,
  );
}
