import 'dart:io';

import 'package:electricsql_cli/src/commands/generate/drift_schema.dart';
import 'package:electricsql_cli/src/commands/generate/prisma.dart';
import 'package:path/path.dart';
import 'package:test/test.dart';

void main() {
  test('prisma schema to drift info', () {
    final _prismaSchemaFile = join(
      Directory.current.path,
      'test/fixtures/schema.prisma',
    );
    final _prismaSchema = File(_prismaSchemaFile).readAsStringSync();

    final schemaInfo = extractInfoFromPrismaSchema(_prismaSchema);

    expect(schemaInfo.tables.length, 10);

    expectValidProjectsModel(schemaInfo);
    expectValidMembershipsModel(schemaInfo);
    expectValidDatatypesModel(schemaInfo);
    expectValidWeirdNames(schemaInfo);

    expectEnums(schemaInfo);

    expectRelations(schemaInfo);
  });
}

void expectValidProjectsModel(DriftSchemaInfo schemaInfo) {
  final projectsTable = schemaInfo.tables[0];

  expect(projectsTable.columns.length, 3);
  expect(projectsTable.tableName, 'projects');
  expect(projectsTable.dartClassName, 'Project');
  expect(
    projectsTable.columns
        .where((c) => c.isPrimaryKey)
        .map((c) => c.columnName)
        .toSet(),
    {'id'},
  );

  final idColumn =
      projectsTable.columns.firstWhere((c) => c.columnName == 'id');
  expect(idColumn.isPrimaryKey, true);
  expect(idColumn.type, DriftElectricColumnType.string);
  expect(idColumn.isNullable, false);

  final nameColumn =
      projectsTable.columns.firstWhere((c) => c.columnName == 'name');
  expect(nameColumn.isPrimaryKey, false);
  expect(nameColumn.type, DriftElectricColumnType.string);
  expect(nameColumn.isNullable, true);

  final ownerColumn =
      projectsTable.columns.firstWhere((c) => c.columnName == 'owner_id');
  expect(ownerColumn.isPrimaryKey, false);
  expect(ownerColumn.type, DriftElectricColumnType.string);
  expect(ownerColumn.isNullable, false);
  expect(ownerColumn.dartName, 'ownerId');

  // Relations
  final relations = projectsTable.relations;
  expect(relations.length, 1);
  final membersRel =
      relations.firstWhere((rel) => rel.relatedModel == 'membership');
  expect(
    membersRel,
    DriftRelationInfo(
      relationField: 'memberships',
      relationFieldDartName: 'memberships',
      fromField: '',
      toField: '',
      relatedModel: 'membership',
      relationName: 'MembershipToProject',
    ),
  );
}

void expectValidMembershipsModel(DriftSchemaInfo schemaInfo) {
  final membersTable = schemaInfo.tables[1];
  expect(membersTable.columns.length, 3);
  expect(membersTable.tableName, 'memberships');
  expect(membersTable.dartClassName, 'Membership');
  expect(
    membersTable.columns
        .where((c) => c.isPrimaryKey)
        .map((c) => c.columnName)
        .toSet(),
    {'project_id', 'user_id'},
  );

  final projectIdColumn =
      membersTable.columns.firstWhere((c) => c.columnName == 'project_id');
  expect(projectIdColumn.type, DriftElectricColumnType.string);
  expect(projectIdColumn.isNullable, false);
  expect(projectIdColumn.dartName, 'projectId');

  final userIdColumn =
      membersTable.columns.firstWhere((c) => c.columnName == 'user_id');
  expect(userIdColumn.type, DriftElectricColumnType.string);
  expect(userIdColumn.isNullable, false);
  expect(userIdColumn.dartName, 'userId');

  final insertedAtColumn =
      membersTable.columns.firstWhere((c) => c.columnName == 'inserted_at');
  expect(insertedAtColumn.type, DriftElectricColumnType.date);
  expect(insertedAtColumn.isNullable, false);

  // Relations
  final relations = membersTable.relations;
  expect(relations.length, 1);
  final projectsRel =
      relations.firstWhere((rel) => rel.relatedModel == 'project');
  expect(
    projectsRel,
    DriftRelationInfo(
      relationField: 'project',
      relationFieldDartName: 'project',
      fromField: 'project_id',
      toField: 'id',
      relatedModel: 'project',
      relationName: 'MembershipToProject',
    ),
  );
}

void expectRelations(DriftSchemaInfo schemaInfo) {
  final userTable = schemaInfo.tables
      .firstWhere((element) => element.prismaModelName == 'User');
  final postTable = schemaInfo.tables
      .firstWhere((element) => element.prismaModelName == 'Post');
  final profileTable = schemaInfo.tables
      .firstWhere((element) => element.prismaModelName == 'Profile');

  final userRelations = userTable.relations;
  expect(userRelations.length, 2);
  final userPostRel =
      userRelations.firstWhere((rel) => rel.relatedModel == 'Post');
  expect(
    userPostRel,
    DriftRelationInfo(
      relationField: 'posts',
      relationFieldDartName: 'posts',
      fromField: '',
      toField: '',
      relatedModel: 'Post',
      relationName: 'PostToUser',
    ),
  );
  final userProfileRel =
      userRelations.firstWhere((rel) => rel.relatedModel == 'Profile');
  expect(
    userProfileRel,
    DriftRelationInfo(
      relationField: 'profile',
      relationFieldDartName: 'profile',
      fromField: '',
      toField: '',
      relatedModel: 'Profile',
      relationName: 'ProfileToUser',
    ),
  );

  final postRelations = postTable.relations;
  expect(postRelations.length, 1);
  final postUserRel =
      postRelations.firstWhere((rel) => rel.relatedModel == 'User');
  expect(
    postUserRel,
    DriftRelationInfo(
      relationField: 'author',
      relationFieldDartName: 'author',
      fromField: 'authorId',
      toField: 'id',
      relatedModel: 'User',
      relationName: 'PostToUser',
    ),
  );

  final profileRelations = profileTable.relations;
  expect(profileRelations.length, 1);
  final profileUserRel =
      profileRelations.firstWhere((rel) => rel.relatedModel == 'User');
  expect(
    profileUserRel,
    DriftRelationInfo(
      relationField: 'user',
      relationFieldDartName: 'user',
      fromField: 'userId',
      toField: 'id',
      relatedModel: 'User',
      relationName: 'ProfileToUser',
    ),
  );
}

/*
Migration used:

CREATE TABLE datatypes (
    c_uuid uuid PRIMARY KEY NOT NULL,
    c_text TEXT NOT NULL,
    c_int INTEGER NOT NULL,
    c_int2 INT2 NOT NULL,
    c_int4 INT4 NOT NULL,
    --c_float4 FLOAT4 NOT NULL,
    c_float8 FLOAT8 NOT NULL,
    c_bool BOOLEAN NOT NULL,
    c_date DATE NOT NULL,
    c_time TIME NOT NULL,
    --c_timetz TIMETZ NOT NULL,
    c_timestamp TIMESTAMP NOT NULL,
    c_timestamptz TIMESTAMPTZ NOT NULL
    --c_bytea BYTEA NOT NULL
);

ALTER TABLE datatypes ENABLE ELECTRIC;
*/
void expectValidDatatypesModel(DriftSchemaInfo schemaInfo) {
  final table = schemaInfo.tables[2];

  expect(table.columns.length, 16);

  expect(table.tableName, 'datatypes');
  expect(table.dartClassName, 'Datatypes');

  expect(
    table.columns.where((c) => c.isPrimaryKey).map((c) => c.columnName).toSet(),
    {'c_uuid'},
  );

  final uuidColumn = table.columns.firstWhere((c) => c.columnName == 'c_uuid');
  expect(uuidColumn.type, DriftElectricColumnType.uuid);

  final textColumn = table.columns.firstWhere((c) => c.columnName == 'c_text');
  expect(textColumn.type, DriftElectricColumnType.string);

  final intColumn = table.columns.firstWhere((c) => c.columnName == 'c_int');
  expect(intColumn.type, DriftElectricColumnType.int4);

  final int2Column = table.columns.firstWhere((c) => c.columnName == 'c_int2');
  expect(int2Column.type, DriftElectricColumnType.int2);

  final int4Column = table.columns.firstWhere((c) => c.columnName == 'c_int4');
  expect(int4Column.type, DriftElectricColumnType.int4);

  final int8Column = table.columns.firstWhere((c) => c.columnName == 'c_int8');
  expect(int8Column.type, DriftElectricColumnType.int8);

  final float4Column =
      table.columns.firstWhere((c) => c.columnName == 'c_float4');
  expect(float4Column.type, DriftElectricColumnType.float4);

  final float8Column =
      table.columns.firstWhere((c) => c.columnName == 'c_float8');
  expect(float8Column.type, DriftElectricColumnType.float8);

  final boolColumn = table.columns.firstWhere((c) => c.columnName == 'c_bool');
  expect(boolColumn.type, DriftElectricColumnType.bool);

  final dateColumn = table.columns.firstWhere((c) => c.columnName == 'c_date');
  expect(dateColumn.type, DriftElectricColumnType.date);

  final timeColumn = table.columns.firstWhere((c) => c.columnName == 'c_time');
  expect(timeColumn.type, DriftElectricColumnType.time);

  final timestampColumn =
      table.columns.firstWhere((c) => c.columnName == 'c_timestamp');
  expect(timestampColumn.type, DriftElectricColumnType.timestamp);

  final timestamptzColumn =
      table.columns.firstWhere((c) => c.columnName == 'c_timestamptz');
  expect(timestamptzColumn.type, DriftElectricColumnType.timestampTZ);

  final jsonColumn = table.columns.firstWhere((c) => c.columnName == 'c_json');
  expect(jsonColumn.type, DriftElectricColumnType.json);

  final jsonBColumn =
      table.columns.firstWhere((c) => c.columnName == 'c_jsonb');
  expect(jsonBColumn.type, DriftElectricColumnType.jsonb);

  final blobColumn = table.columns.firstWhere((c) => c.columnName == 'c_bytea');
  expect(blobColumn.type, DriftElectricColumnType.blob);
}

void expectValidWeirdNames(DriftSchemaInfo schemaInfo) {
  final table = schemaInfo.tables[3];

  expect(table.columns.length, 5);

  expect(table.tableName, 'weirdnames');
  expect(table.dartClassName, 'Weirdnames');

  expect(
    table.columns.where((c) => c.isPrimaryKey).map((c) => c.columnName).toSet(),
    {'c_uuid'},
  );

  final uuidColumn = table.columns.firstWhere((c) => c.columnName == 'c_uuid');
  expect(uuidColumn.type, DriftElectricColumnType.uuid);

  final valColumn = table.columns.firstWhere((c) => c.columnName == '1val');
  expect(valColumn.type, DriftElectricColumnType.string);
  expect(valColumn.dartName, 'val');

  // Conflict with drift and/or dart types
  final textColumn = table.columns.firstWhere((c) => c.columnName == 'text');
  expect(textColumn.type, DriftElectricColumnType.string);
  expect(textColumn.dartName, r'text$');

  // Conflict when using curly brances in the field definition
  final bracesColumn =
      table.columns.firstWhere((c) => c.columnName == 'braces');
  expect(bracesColumn.type, DriftElectricColumnType.json);

  final enumCol = table.columns.firstWhere((e) => e.columnName == 'int');
  expect(enumCol.type, DriftElectricColumnType.enumT);
  expect(enumCol.dartName, r'int$');
  expect(enumCol.enumPgType, 'integer');
}

void expectEnums(DriftSchemaInfo schemaInfo) {
  expect(schemaInfo.enums.length, 3);

  final weirdEnum = schemaInfo.enums['integer']!;
  expectWeirdEnum(weirdEnum);

  final snakeCaseEnum = schemaInfo.enums['snake_case_enum']!;
  expectSnakeCaseEnum(snakeCaseEnum);
}

void expectWeirdEnum(DriftEnum enumInfo) {
  expect(enumInfo.dartEnumName, 'DbInteger');
  expect(enumInfo.enumCodecName, 'integer');
  expect(enumInfo.driftTypeName, 'integer');
  expect(enumInfo.values.length, 10);
  expect(enumInfo.values.map((v) => v.dartVal).toList(), [
    r'int$',
    r'bool$',
    r'double$',
    'float',
    'someVal',
    r'value$1',
    r'value$2',
    r'value$3',
    'rdValue',
    'weIRdStuFf',
  ]);
  expect(enumInfo.values.map((v) => v.pgVal).toList(), [
    'int',
    'Bool',
    'DOUBLE',
    '2Float',
    '_some_val',
    '01 value',
    '2 value',
    '2Value',
    '3rd value',
    'WeIRd*Stu(ff)',
  ]);
}

void expectSnakeCaseEnum(DriftEnum enumInfo) {
  expect(enumInfo.dartEnumName, 'DbSnakeCaseEnum');
  expect(enumInfo.enumCodecName, 'snakeCaseEnum');
  expect(enumInfo.driftTypeName, 'snakeCaseEnum');
  expect(enumInfo.values.length, 2);
}
