import 'package:code_builder/code_builder.dart';
import 'package:electricsql_cli/src/commands/generate/builder/util.dart';

const kElectricMigrationsFieldName = 'kElectricMigrations';

Field getElectricMigrationsField() {
  /*
  const kElectricMigrations = ElectricMigrations(
    sqliteMigrations: kSqliteMigrations,
    pgMigrations: kPostgresMigrations,
  );
  */

  final electricMigrationsRef = refer('ElectricMigrations', kElectricSqlImport);

  return Field(
    (b) => b
      ..name = 'kElectricMigrations'
      ..modifier = FieldModifier.constant
      ..assignment = electricMigrationsRef.newInstance([], {
        'sqliteMigrations': getSqliteMigrationsRef(),
        'pgMigrations': getPgMigrationsRef(),
      }).code,
  );
}

Reference getSqliteMigrationsRef() {
  return refer('kSqliteMigrations', './$kSqliteMigrationsFileName');
}

Reference getPgMigrationsRef() {
  return refer('kPostgresMigrations', './$kPostgresMigrationsFileName');
}
