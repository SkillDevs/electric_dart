import 'package:electric_client/src/proto/satellite.pb.dart';
import 'package:electric_client/src/util/types.dart';

Map<String, Relation> kTestRelations = {
  "child": Relation(
    id: 0,
    schema: 'public',
    table: 'child',
    tableType: SatRelation_RelationType.TABLE,
    columns: [
      RelationColumn(
        name: 'id',
        type: 'INTEGER',
        primaryKey: true,
      ),
      RelationColumn(
        name: 'parent',
        type: 'INTEGER',
        primaryKey: false,
      ),
    ],
  ),
  "parent": Relation(
    id: 1,
    schema: 'public',
    table: 'parent',
    tableType: SatRelation_RelationType.TABLE,
    columns: [
      RelationColumn(
        name: 'id',
        type: 'INTEGER',
        primaryKey: true,
      ),
      RelationColumn(
        name: 'value',
        type: 'TEXT',
        primaryKey: false,
      ),
      RelationColumn(
        name: 'other',
        type: 'INTEGER',
        primaryKey: false,
      ),
    ],
  ),
};
