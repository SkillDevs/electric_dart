import 'dart:async';
import 'dart:io';

import 'package:electricsql_cli/src/commands/generate/drift_gen_opts.dart';
import 'package:electricsql_cli/src/commands/generate/drift_schema.dart';
import 'package:electricsql_cli/src/config.dart';
import 'package:electricsql_cli/src/logger.dart';
import 'package:electricsql_cli/src/prisma_schema_parser.dart';
import 'package:electricsql_cli/src/util.dart';
import 'package:path/path.dart';
import 'package:recase/recase.dart';

// Version of Prisma supported by the Electric Proxy
const String _kPrismaVersion = '4.8.1';
const int _kNodeVersion = 20;

const _kPrismaCLIDockerfile = '''
FROM node:$_kNodeVersion

RUN npm install -g prisma@$_kPrismaVersion

WORKDIR /cli

ENTRYPOINT ["prisma"]
''';

/// Creates a fresh Prisma schema in the provided folder.
/// The Prisma schema is initialised with a generator and a datasource.
Future<File> createIntrospectionSchema(
  Directory folder, {
  required Config config,
}) async {
  final prismaDir = Directory(join(folder.path, 'prisma'));
  final prismaSchemaFile = File(join(prismaDir.path, 'schema.prisma'));
  await prismaDir.create(recursive: true);

  final proxyUrl = buildProxyUrlForIntrospection(config);

  // RelationMode = "prisma" is used so that "array like" foreign key relations
  // are not created in the prisma schema

  final schema = '''
datasource db {
  provider = "postgresql"
  url      = "$proxyUrl"
  relationMode = "prisma"
}
''';

  await prismaSchemaFile.writeAsString(schema);
  return prismaSchemaFile;
}

String buildProxyUrlForIntrospection(Config config) {
  return buildDatabaseURL(
    // We use the "prisma" user to put the proxy into introspection mode
    user: 'prisma',
    password: config.read<String>('PG_PROXY_PASSWORD'),
    host: config.read<String>('PG_PROXY_HOST'),
    port: parsePgProxyPort(config.read<String>('PG_PROXY_PORT')).port,
    dbName: config.read<String>('DATABASE_NAME'),
  );
}

Future<void> introspectDB(PrismaCLI cli, File prismaSchema) async {
  await cli.runCommand(
    [
      'db',
      'pull',
      '--schema=${basename(prismaSchema.path)}',
    ],
    workingDirectory: prismaSchema.parent.path,
    errorMsg: 'Database introspection failed',
  );
}

class PrismaCLI {
  final Logger logger;
  final Directory folder;

  static const String _imageName = 'electric-dart/prisma-cli';

  PrismaCLI({required this.logger, required this.folder});

  // Build the Prisma CLI Docker image
  Future<void> install() async {
    await _createDockerfile();

    final res = await Process.run(
      'docker',
      [
        'build',
        '-t',
        _imageName,
        '.',
      ],
      workingDirectory: folder.path,
    );

    if (res.exitCode != 0) {
      throw Exception('Could not build Prisma CLI Docker image\n'
          'Exit code: $exitCode\n'
          'Stderr: ${res.stderr}\n'
          'Stdout: ${res.stdout}');
    }
  }

  Future<void> runCommand(
    List<String> args, {
    required String workingDirectory,
    String? errorMsg,
  }) async {
    final res = await Process.run(
      'docker',
      [
        'run',
        '--rm',
        '-v',
        '.:/cli',
        '--network',
        'host',
        _imageName,
        ...args,
      ],
      workingDirectory: workingDirectory,
    );

    //unawaited(stdout.addStream(process.stdout));

    final exitCode = res.exitCode;
    if (exitCode != 0) {
      final baseMsg = errorMsg ?? 'Could not run Prisma CLI with args: $args';
      throw Exception('$baseMsg\n'
          'Exit code: $exitCode\n'
          'Stderr: ${res.stderr}\n'
          'Stdout: ${res.stdout}');
    }
  }

  Future<File> _createDockerfile() async {
    final dockerfile = File(join(folder.path, 'Dockerfile'));
    await dockerfile.writeAsString(_kPrismaCLIDockerfile);
    return dockerfile;
  }
}

DriftSchemaInfo extractInfoFromPrismaSchema(
  String prismaSchema, {
  ElectricDriftGenOpts? genOpts,
}) {
  final enums = parseEnums(prismaSchema);
  final driftEnums = _buildDriftEnums(enums);

  final models = parseModels(prismaSchema);
  //print(models);

  final tableInfos = models.map((e) {
    final modelName = e.name;
    String tableName = modelName;

    final mapAttr = e.attributes
        .where(
          (a) => a.type == '@@map',
        )
        .firstOrNull;

    if (mapAttr != null) {
      final mappedNameLiteral = mapAttr.args.join(',');
      tableName = extractStringLiteral(mappedNameLiteral);
    }

    final tableGenOpts = genOpts?.tableGenOpts(tableName);

    final className = tableGenOpts?.driftTableName ?? modelName.pascalCase;

    return DriftTableInfo(
      tableName: tableName,
      dartClassName: className,
      columns: _prismaFieldsToColumns(
        e,
        e.fields,
        genOpts: genOpts,
        driftEnums: driftEnums,
      ).toList(),
    );
  }).toList();

  final schemaInfo = DriftSchemaInfo(
    tables: tableInfos,
    enums: driftEnums,
    genOpts: genOpts,
  );

  return schemaInfo;
}

Map<String, DriftEnum> _buildDriftEnums(List<EnumPrisma> enums) {
  return Map.fromEntries(
    enums.map((e) {
      final pgName = e.name;
      final dartType = 'Db${pgName.pascalCase}';

      final pgNameCamel = pgName.camelCase;

      final String enumFieldName = _ensureValidDartIdentifier(pgNameCamel);

      // Prisma could reuse the name of the field for different enum values
      final fieldFreqs = <String, int>{};
      for (final val in e.values) {
        final fieldName = val.field;
        fieldFreqs[fieldName] = (fieldFreqs[fieldName] ?? 0) + 1;
      }

      final Map<String, int> usedDartValuesFreqs = {};
      final values = e.values.map((prismaEnumVal) {
        final pgValue = prismaEnumVal.pgValue;
        final String origField = prismaEnumVal.field;

        final usedNTimes = usedDartValuesFreqs[origField] ?? 0;

        String field = origField;
        // If the field is reused, append $n at the end
        if (fieldFreqs[origField]! > 1) {
          field = '$field\$${usedNTimes + 1}';
        }
        final dartVal = _ensureValidDartIdentifier(field.camelCase);

        usedDartValuesFreqs[origField] = usedNTimes + 1;
        return (dartVal: dartVal, pgVal: pgValue);
      }).toList();

      return MapEntry(
        pgName,
        DriftEnum(
          pgName: pgName,
          values: values,
          dartEnumName: dartType,
          enumCodecName: enumFieldName,
          driftTypeName: enumFieldName,
        ),
      );
    }),
  );
}

Iterable<DriftColumn> _prismaFieldsToColumns(
  Model model,
  List<Field> fields, {
  required ElectricDriftGenOpts? genOpts,
  required Map<String, DriftEnum> driftEnums,
}) sync* {
  final primaryKeyFields = _getPrimaryKeysFromModel(model);

  for (final field in fields) {
    if (field.type.endsWith('[]')) {
      // No array types
      continue;
    }

    if (field.attributes.any((a) => a.type == '@relation')) {
      // No relations
      continue;
    }

    final fieldName = field.field;
    String columnName = fieldName;

    // if (columnName == 'electric_user_id') {
    //   // Don't include "electric_user_id" special column in the client schema
    //   continue;
    // }

    final mapAttr = field.attributes
        .where(
          (a) => a.type == '@map',
        )
        .firstOrNull;
    if (mapAttr != null) {
      final mappedNameLiteral = mapAttr.args.join(',');
      columnName = extractStringLiteral(mappedNameLiteral);
    }

    String? dartName;

    final columnGenOpts = genOpts?.columnGenOpts(model.name, columnName);

    // First check if the column has a custom name
    dartName = columnGenOpts?.driftColumnName;

    dartName ??= _ensureValidDartIdentifier(
      fieldName.camelCase,
      isReservedWord: _isInvalidDartIdentifierForDriftTable,
    );

    final bool isPrimaryKey = primaryKeyFields.contains(fieldName);

    final prismaType = field.type;
    final nonNullableType = prismaType.endsWith('?')
        ? prismaType.substring(0, prismaType.length - 1)
        : prismaType;

    final driftType = _convertPrismaTypeToDrift(
      nonNullableType,
      field.attributes,
      driftEnums,
      genOpts,
    );
    String? enumPgType;
    if (driftType == DriftElectricColumnType.enumT) {
      final DriftEnum driftEnum = driftEnums[nonNullableType]!;
      enumPgType = driftEnum.pgName;
    }

    yield DriftColumn(
      columnName: columnName,
      dartName: dartName,
      type: driftType,
      isNullable: field.type.endsWith('?'),
      isPrimaryKey: isPrimaryKey,
      // If the type is an enum, hold the enum name in postgres
      enumPgType: enumPgType,
    );
  }
}

DriftElectricColumnType _convertPrismaTypeToDrift(
  String nonNullableType,
  List<Attribute> attrs,
  Map<String, DriftEnum> driftEnums,
  ElectricDriftGenOpts? genOpts,
) {
  final dbAttr = attrs.where((a) => a.type.startsWith('@db.')).firstOrNull;
  final dbAttrName = dbAttr?.type.substring('@db.'.length);

  if (driftEnums.containsKey(nonNullableType)) {
    return DriftElectricColumnType.enumT;
  }

  switch (nonNullableType) {
    case 'Int':
      if (dbAttrName != null) {
        if (dbAttrName == 'SmallInt') {
          return DriftElectricColumnType.int2;
        }
      }
      return DriftElectricColumnType.int4;
    case 'Float':
      if (dbAttrName == 'Real') {
        return DriftElectricColumnType.float4;
      }
      return DriftElectricColumnType.float8;
    case 'String':
      if (dbAttrName != null) {
        if (dbAttrName == 'Uuid') {
          return DriftElectricColumnType.uuid;
        }
      }
      return DriftElectricColumnType.string;
    case 'Boolean':
      return DriftElectricColumnType.bool;
    case 'DateTime':
      // Expect to have a db. attribute with a PG type
      if (dbAttrName == null) {
        throw Exception('Expected DateTime field to have a @db. attribute');
      }

      switch (dbAttrName) {
        case 'Date':
          return DriftElectricColumnType.date;
        case 'Time':
          return DriftElectricColumnType.time;
        case 'Timetz':
          return DriftElectricColumnType.timeTZ;
        case 'Timestamp':
          return DriftElectricColumnType.timestamp;
        case 'Timestamptz':
          return DriftElectricColumnType.timestampTZ;
        default:
          throw Exception('Unknown DateTime @db. attribute: $dbAttrName');
      }
    case 'Json':
      if (dbAttrName == null) {
        return DriftElectricColumnType.jsonb;
      }

      switch (dbAttrName) {
        case 'Json':
          return DriftElectricColumnType.json;
        case 'JsonB':
          return DriftElectricColumnType.jsonb;
        default:
          throw Exception('Unknown Json @db. attribute: $dbAttrName');
      }
    case 'BigInt':
      if (genOpts?.int8AsBigInt == true) {
        return DriftElectricColumnType.bigint;
      }
      return DriftElectricColumnType.int8;
    default:
      throw Exception('Unknown Prisma type: $nonNullableType');
  }
}

Set<String> _getPrimaryKeysFromModel(Model m) {
  final idFields =
      m.fields.where((f) => f.attributes.any((a) => a.type == '@id'));
  final Set<String> idFieldsSet = idFields.map((f) => f.field).toSet();

  final Attribute? modelIdAttr =
      m.attributes.where((a) => a.type == '@@id').firstOrNull;

  if (modelIdAttr == null) {
    return idFieldsSet;
  }

  final modelIdAttrArgs = modelIdAttr.args.join(',').trim();
  assert(
    modelIdAttrArgs.startsWith('[') && modelIdAttrArgs.endsWith(']'),
    'Expected @@id to have arguments in the form of [field1, field2, ...]',
  );

  final compositeFields = modelIdAttrArgs
      .substring(1, modelIdAttrArgs.length - 1)
      .split(',')
      .map((s) => s.trim())
      .toSet();

  return compositeFields.toSet()..addAll(idFieldsSet);
}

String _ensureValidDartIdentifier(
  String name, {
  bool Function(String)? isReservedWord,
  String suffix = '\$',
}) {
  String newName = name;
  if (name.startsWith(RegExp('[0-9]'))) {
    newName = '\$$name';
  }

  final bool Function(String name) effectiveIsReservedWord =
      isReservedWord ?? _isInvalidDartIdentifier;

  if (effectiveIsReservedWord(newName)) {
    newName = '$newName$suffix';
  }
  return newName;
}

bool _isInvalidDartIdentifier(String name) {
  return const [
    // dart primitive types
    'int',
    'bool',
    'double',
    'null',
    'true',
    'false',
  ].contains(name);
}

bool _isInvalidDartIdentifierForDriftTable(String name) {
  if (_isInvalidDartIdentifier(name)) {
    return true;
  }

  return const [
    // drift table getters
    'tableName',
    'withoutRowId',
    'dontWriteConstraints',
    'isStrict',
    'primaryKey',
    'uniqueKeys',
    'customConstraints',
    'integer',
    'int64',
    'intEnum',
    'text',
    'textEnum',
    'boolean',
    'dateTime',
    'blob',
    'real',
    'customType',
  ].contains(name);
}
