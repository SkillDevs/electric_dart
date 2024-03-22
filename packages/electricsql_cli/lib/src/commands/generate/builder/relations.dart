import 'package:electricsql_cli/electricsql_cli.dart';
import 'package:electricsql_cli/src/commands/generate/builder/util.dart';
import 'package:electricsql_cli/src/commands/generate/prisma.dart';

String getRelationsClassName(DriftTableInfo tableInfo) {
  final driftTableName = tableInfo.dartClassName;
  return '_\$${driftTableName}Relations';
}

List<Class> getRelationClasses(DriftSchemaInfo driftSchemaInfo) {
  final relationClasses = <Class>[];

  for (final tableInfo in driftSchemaInfo.tables) {
    if (tableInfo.relations.isEmpty) continue;

    final List<Method> relationMethods = tableInfo.relations
        .map(
          (relationInfo) =>
              _getTableRelationGetter(driftSchemaInfo, tableInfo, relationInfo),
        )
        .toList();

    final relationClass = Class(
      (b) => b
        ..constructors.add(Constructor((b) => b.constant = true))
        ..name = getRelationsClassName(tableInfo)
        ..methods.addAll(relationMethods),
    );
    relationClasses.add(relationClass);
  }
  return relationClasses;
}

Method _getTableRelationGetter(
  DriftSchemaInfo schemaInfo,
  DriftTableInfo tableInfo,
  DriftRelationInfo relation,
) {
  final relatedDriftTableName =
      schemaInfo.tablesByPrismaModel[relation.relatedModel]!.dartClassName;

  final tableRelationRef = refer('TableRelation<$relatedDriftTableName>', kElectricSqlImport);
  final tableRelationExpr = tableRelationRef.constInstance([], {
    'fromField': literal(relation.fromField),
    'toField': literal(relation.toField),
    'relationName': literal(relation.relationName),
  });

  return Method(
    (b) => b
      ..name = ensureValidDartIdentifier(relation.relationField)
      ..returns = tableRelationRef
      ..type = MethodType.getter
      ..body = tableRelationExpr.code,
  );
}
