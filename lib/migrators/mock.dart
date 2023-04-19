import 'package:electric_client/migrators/migrators.dart';

class MockMigrator implements Migrator {
  @override
  Future<int> up() async {
    return 0;
  }
}
