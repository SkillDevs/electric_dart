/// This is a custom drift generation script that
/// customizes how the electricsql CLI generates the Drift code
///
/// This file is not used in the todos code generation, but it is an example of the
/// options supported.
///
/// In order to run it you can do `dart tool/custom_drift_generation.dart`
/// instead of running `dart run electricsql_cli generate`
library;

import 'package:electricsql_cli/electricsql_cli.dart';

void main(List<String> args) async {
  await runElectricCodeGeneration(
    driftSchemaGenOpts: CustomElectricDriftGenOpts(),
    outFolder: 'lib/generated/electric',
    service: 'http://127.0.0.1:5133',
  );
}

class CustomElectricDriftGenOpts extends ElectricDriftGenOpts {
  @override
  DriftTableGenOpts? tableGenOpts(String sqlTableName) {
    switch (sqlTableName) {
      case 'todo':
        return DriftTableGenOpts(
          // This creates: `class Todos extends Table {`
          driftTableName: 'Todos',

          annotations: [
            // This generates @DataClassName('TodoClass') for the Drift table definition
            dataClassNameAnnotation(
              'TodoClass',
              // If you need to use the 'extending' parameter of the @DataClassName Drift
              // annotation you can provide it here. For example:
              // extending:
              //     refer('BaseModel', 'package:todos_electrified/base_model.dart'),
            ),
          ],
        );
    }
    return null;
  }

  @override
  DriftColumnGenOpts? columnGenOpts(String sqlTableName, String sqlColumnName) {
    if (sqlTableName == 'todo') {
      if (sqlColumnName == 'text') {
        return DriftColumnGenOpts(
          // This generates   TextColumn get myTextCol => text().named('text')();
          driftColumnName: 'myTextCol',
        );
      }

      // This adds the `clientDefault` column builder modifier from drift
      // <columnBuilder>.clientDefault(() => DateTime.now())
      if (sqlColumnName == 'edited_at') {
        return DriftColumnGenOpts(
          columnBuilderModifier: (e) => clientDefaultExpression(
            e,
            value: dateTimeNowExpression,
          ),
        );
      }
    }

    return null;
  }
}
