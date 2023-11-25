import 'package:code_builder/code_builder.dart';
import 'package:electricsql_cli/src/commands/generate/builder/util.dart';
import 'package:electricsql_cli/src/commands/generate/drift_schema.dart';
import 'package:recase/recase.dart';

typedef ElectricEnumDeclarationBlock = ({Spec enumType, Spec enumToPg});

List<ElectricEnumDeclarationBlock> getElectricEnumDeclarationBlocks(
  DriftSchemaInfo driftSchemaInfo,
) {
  final List<ElectricEnumDeclarationBlock> enumBlocks = [];

  final enums = driftSchemaInfo.enums;
  for (final enumInfo in enums.values) {
    final pgName = enumInfo.pgName;
    final Enum enumType = Enum(
      (b) => b
        ..name = enumInfo.dartEnumName
        ..docs.add('/// Dart enum for Postgres enum "$pgName"')
        ..values.addAll(
          enumInfo.values.map(
            (valInfo) => EnumValue((b) => b..name = valInfo.dartVal),
          ),
        ),
    );

    final enumRef = refer(enumInfo.dartEnumName);

    final enumToPgField = Field(
      (b) => b
        ..name = _getDartEnumToPgMapName(enumInfo.pgName)
        ..modifier = FieldModifier.constant
        ..docs.addAll(
          [
            '/// Maps Dart enum to the Postgres enum value.',
            '/// This text value is stored in the local database.',
          ],
        )
        ..assignment = literalMap(
          Map.fromEntries(
            enumInfo.values.map(
              (valInfo) {
                final enumValRef = enumRef.property(valInfo.dartVal);
                return MapEntry(enumValRef, valInfo.pgVal);
              },
            ),
          ),
          enumRef,
          refer('String'),
        ).code,
    );

    enumBlocks.add(
      (
        enumType: enumType,
        enumToPg: enumToPgField,
      ),
    );
  }

  return enumBlocks;
}

String _getDartEnumToPgMapName(String pgName) {
  return 'k${pgName.pascalCase}EnumToPg';
}

Class getElectricEnumCodecsClass(DriftSchemaInfo driftSchemaInfo) {
  final List<Field> codecFields = [];
  for (final enumInfo in driftSchemaInfo.enums.values) {
    final pgName = enumInfo.pgName;
    final enumCodecName = enumInfo.enumCodecName;

    final enumRef = refer(enumInfo.dartEnumName);
    final enumToPgField = refer(_getDartEnumToPgMapName(pgName));

    final enumCodecRef = TypeReference(
      (b) => b
        ..url = kElectricSqlImport
        ..symbol = 'ElectricEnumCodec'
        ..types.add(enumRef),
    );

    final enumCodecField = Field(
      (b) => b
        ..name = enumCodecName
        ..modifier = FieldModifier.final$
        ..static = true
        ..docs.add('/// Codec for Dart enum "$pgName"')
        ..assignment = enumCodecRef.newInstance([], {
          'dartEnumToPgEnum': enumToPgField,
          'values': enumRef.property('values'),
        }).code,
    );

    codecFields.add(enumCodecField);
  }

  return Class(
    (b) => b
      ..name = 'ElectricEnumCodecs'
      ..docs.add('/// Codecs for Electric enums')
      ..fields.addAll(codecFields),
  );
}

Class getElectricEnumTypesClass(DriftSchemaInfo driftSchemaInfo) {
  final List<Field> driftTypeFields = [];
  for (final enumInfo in driftSchemaInfo.enums.values) {
    final pgName = enumInfo.pgName;
    final driftTypeName = enumInfo.driftTypeName;

    final codecExpr =
        refer('ElectricEnumCodecs').property(enumInfo.enumCodecName);

    final customTypeRef = TypeReference(
      (b) => b
        ..url = kElectricSqlDriftImport
        ..symbol = 'CustomElectricTypeGeneric',
    );

    final enumCodecField = Field(
      (b) => b
        ..name = driftTypeName
        ..modifier = FieldModifier.final$
        ..static = true
        ..docs.add('/// Codec for Dart enum "$pgName"')
        ..assignment = customTypeRef.newInstance([], {
          'codec': codecExpr,
          'typeName': literal(pgName),
        }).code,
    );

    driftTypeFields.add(enumCodecField);
  }

  return Class(
    (b) => b
      ..name = kElectricEnumTypesClassName
      ..docs.add('/// Drift custom types for Electric enums')
      ..fields.addAll(driftTypeFields),
  );
}
