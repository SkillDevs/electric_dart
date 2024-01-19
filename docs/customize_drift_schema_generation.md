# Customize Drift Schema generation

By default, Electric will generate the Drift schema for you. However, you can customize how the schema gets generated (different names, data classes, additional column modifiers...)

The default generation it's run via `dart run electricsql_cli generate`, but if you need a custom code generation configuration you need to run it via a custom Dart script.

You can create a file under `bin/custom_electric_generate.dart` with the following content.
It can be run with `dart run bin/custom_electric_generate.dart`.

You can refer to this file [here](https://github.com/SkillDevs/electric_dart/blob/master/todos_flutter/tool/custom_drift_generation.dart) to see how the options are used. 

```dart
import 'package:electricsql_cli/electricsql_cli.dart';

void main(List<String> args) async {
  await runElectricCodeGeneration(
    driftSchemaGenOpts: CustomElectricDriftGenOpts(),
  );
}

class CustomElectricDriftGenOpts extends ElectricDriftGenOpts {
  @override
  DriftTableGenOpts? tableGenOpts(String sqlTableName) {
    return null;
  }

  @override
  DriftColumnGenOpts? columnGenOpts(String sqlTableName, String sqlColumnName) {
    return null;
  }
}
```

## Supported options

### Table (DriftTableGenOpts)

- `driftTableName`

  The name of the table in the Drift schema. By default it's the same as the SQL table name in Pascal case.

- `annotations`

  A list of annotation expressions to add to the Drift table definition. This can be used to add `UseRowClass` or `DataClassName` annotations from drift. Auxiliary functions to build these annotations are provided: `useRowClassAnnotation` and `dataClassNameAnnotation` respectively.


### Column (DriftColumnGenOpts)

- `driftColumnName`
  
  The name of the column in the Drift schema. By default it's the same as the SQL column name in Camel case.

- `annotations`

  A list of annotation expressions to add to the Drift column definition. This can be used to add the `JsonKey` annotation from drift. An auxiliary function to build this annotation is provided: `jsonKeyAnnotation`.


- `columnBuilderModifier`
  
  A function that receives the column builder and returns a modified version of it. This can be used to add extra modifiers to the column, such as `clientDefault`.

  If you need custom code you would need to use the package [`code_builder`](https://pub.dev/packages/code_builder) to build a custom [Expression] that will be converted in Dart code. 

```dart
return DriftColumnGenOpts(
    // This example adds the modifier:
    // .clientDefault(() => DateTime.now()) 
    columnBuilderModifier: (e) => clientDefaultExpression(
        e,
        value: dateTimeNowExpression,
    ),
);
```