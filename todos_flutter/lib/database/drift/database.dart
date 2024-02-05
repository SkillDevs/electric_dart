import 'package:drift/drift.dart';
import 'package:electricsql_flutter/drivers/drift.dart';
import 'package:todos_electrified/generated/electric/drift_schema.dart';

part 'database.g.dart';

@DriftDatabase(tables: kElectrifiedTables)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        //
        print("Dummy onCreate");
      },
    );
  }
}
