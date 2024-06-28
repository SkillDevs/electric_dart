import 'package:electricsql_cli/electricsql_cli.dart';
import 'package:electricsql_cli/src/commands/generate/builder/util.dart';

String getRelationsClassName(DriftTableInfo tableInfo) {
  final driftTableName = tableInfo.dartClassName;
  return '\$${driftTableName}TableRelations';
}

List<Class> getRelationClasses(DriftSchemaInfo driftSchemaInfo) {
  final relationClasses = <Class>[];

  for (final tableInfo in driftSchemaInfo.tables) {
    if (tableInfo.relations.isEmpty) continue;

    final List<Method> relationGetters = tableInfo.relations
        .map(
          (relationInfo) =>
              _getTableRelationGetter(driftSchemaInfo, tableInfo, relationInfo),
        )
        .toList();

    final relationsListGetter =
        _getRelationsListGetter(driftSchemaInfo, tableInfo, relationGetters);

    final relationClass = Class(
      (b) => b
        ..constructors.add(Constructor((b) => b.constant = true))
        ..name = getRelationsClassName(tableInfo)
        ..implements
            .add(refer(kTableRelationsInterfaceName, kElectricSqlDriftImport))
        ..methods.addAll([
          ...relationGetters,
          relationsListGetter,
        ]),
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

  final tableRelationRef =
      refer('TableRelation<$relatedDriftTableName>', kElectricSqlDriftImport);
  final tableRelationExpr = tableRelationRef.constInstance([], {
    'fromField': literal(relation.fromField),
    'toField': literal(relation.toField),
    'relationName': literal(relation.relationName),
  });

  return Method(
    (b) => b
      ..name = relation.relationFieldDartName
      ..returns = tableRelationRef
      ..type = MethodType.getter
      ..body = tableRelationExpr.code,
  );
}

Method _getRelationsListGetter(
  DriftSchemaInfo schemaInfo,
  DriftTableInfo tableInfo,
  List<Method> relationGetters,
) {
  return Method(
    (b) => b
      ..name = '\$relationsList'
      ..returns = refer('List<TableRelation<Table>>', kElectricSqlDriftImport)
      ..type = MethodType.getter
      ..annotations.add(
        const CodeExpression(Code('override')),
      )
      ..body = literalList(relationGetters.map((m) => refer(m.name!))).code,
  );
}
