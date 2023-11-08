// ignore: depend_on_referenced_packages
import 'package:electricsql_cli/electricsql_cli.dart';

/// This is a custom drift generation script that overrides the default
/// that customizes how the electric-sql cli generates the Drift code
void main(List<String> args) async {
  await runElectricCodeGeneration(
    driftSchemaGenOpts: CustomElectricDriftGenOpts(),
    outFolder: 'lib/generated/electric',
    service: 'http://127.0.0.1:5133',
  );
}

class CustomElectricDriftGenOpts extends ElectricDriftGenOpts {
  @override
  String? resolveTableName(String sqlTableName) {
    switch (sqlTableName) {
      case 'todo':
        // This creates: class Todos extends Table {
        return 'Todos';
    }
    return null;
  }

  @override
  DataClassNameInfo? resolveDataClassName(String sqlTableName) {
    switch (sqlTableName) {
      case 'todo':
        // This generates @DataClassName('TodoClass') for the Drift table definition
        return DataClassNameInfo(
          'TodoClass',
          // If you need to use the 'extending' parameter of the @DataClassName Drift
          // annotation you can provide it here. For example:
          // extending:
          //     refer('BaseModel', 'package:todos_electrified/base_model.dart'),
        );
    }
    return null;
  }

  @override
  String? resolveColumnName(String sqlTableName, String sqlColumnName) {
    if (sqlTableName == 'todo' && sqlColumnName == 'text') {
      // This generates   TextColumn get myTextCol => text().named('text')();
      return 'myTextCol';
    }
    return null;
  }
}
