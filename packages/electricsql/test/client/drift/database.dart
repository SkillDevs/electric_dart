import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_postgres/drift_postgres.dart';
import 'package:electricsql/drivers/drift.dart';
import 'package:postgres/postgres.dart' as pg;

import 'generated/electric/drift_schema.dart';

part 'database.g.dart';

class Extra extends Table {
  IntColumn get id => integer()();

  Int64Column get int8BigInt => int64().nullable()();

  @override
  String? get tableName => 'Extra';

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

@DriftDatabase(
  tables: [...kElectrifiedTables, Extra],
  include: {'./other_tables.drift'},
)
class TestsDatabase extends _$TestsDatabase {
  TestsDatabase(super.e);

  factory TestsDatabase.memory() {
    return TestsDatabase(
      NativeDatabase.memory(
        setup: (db) {
          db.config.doubleQuotedStringLiterals = false;
        },
        // logStatements: true,
      ),
    );
  }

  factory TestsDatabase.inMemoryPostgres() {
    return TestsDatabase(
      NativeDatabase.memory(
        setup: (db) {
          db.config.doubleQuotedStringLiterals = false;
        },
        // logStatements: true,
      ).interceptWith(_PretendToBePostgres()),
    );
  }

  factory TestsDatabase.postgres(
    pg.Endpoint endpoint, {
    pg.ConnectionSettings? settings,
  }) {
    return TestsDatabase(
      PgDatabase(
        endpoint: endpoint,
        settings: settings,
        enableMigrations: false,
        // logStatements: true,
      ),
    );
  }

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.create(tableFromDriftFile);
        },
      );
}

class _PretendToBePostgres extends QueryInterceptor {
  @override
  SqlDialect dialect(QueryExecutor executor) {
    return SqlDialect.postgres;
  }
}
