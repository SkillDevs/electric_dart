import 'package:code_builder/code_builder.dart';
import 'package:electricsql_cli/src/commands/generate/builder/util.dart';
import 'package:electricsql_cli/src/commands/generate/drift_schema.dart';

List<Enum> getElectricEnumDeclarations(
  DriftSchemaInfo driftSchemaInfo,
) {
  final List<Enum> enumBlocks = [];

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

    enumBlocks.add(enumType);
  }

  return enumBlocks;
}

Expression _getDartEnumToPgExpr(DriftEnum enumInfo) {
  final enumRef = refer(enumInfo.dartEnumName);

  return literalMap(
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
  );
}

Class getElectricEnumCodecsClass(DriftSchemaInfo driftSchemaInfo) {
  final List<Field> codecFields = [];
  for (final enumInfo in driftSchemaInfo.enums.values) {
    final pgName = enumInfo.pgName;
    final enumCodecName = enumInfo.enumCodecName;

    final enumRef = refer(enumInfo.dartEnumName);

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
          'dartEnumToPgEnum': _getDartEnumToPgExpr(enumInfo),
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
        ..symbol = 'CustomElectricTypeEnum',
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
