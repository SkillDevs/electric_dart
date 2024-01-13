import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:electricsql/drivers/drift.dart';
import 'package:satellite_dart_client/generated/electric/drift_schema.dart';

part 'database.g.dart';

@DriftDatabase(tables: [
  ...kElectrifiedTables,
])
class ClientDatabase extends _$ClientDatabase {
  ClientDatabase(super.e);

  factory ClientDatabase.memory() {
    return ClientDatabase(
      NativeDatabase.memory(
        setup: (db) {
          db.config.doubleQuotedStringLiterals = false;
        },
      ),
    );
  }

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          // Empty on create, we don't need it with Electric
        },
      );

  @override
  int get schemaVersion => 1;
}
