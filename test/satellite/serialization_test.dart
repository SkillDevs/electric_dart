import 'package:electric_client/proto/satellite.pb.dart';
import 'package:electric_client/satellite/client.dart';
import 'package:electric_client/util/types.dart';
import 'package:test/test.dart';

void main() {
  test('serialize/deserialize row data', () {
    final rel = Relation(
      id: 1,
      schema: 'schema',
      table: 'table',
      tableType: SatRelation_RelationType.TABLE,
      columns: [
        RelationColumn(name: 'name1', type: 'TEXT'),
        RelationColumn(name: 'name2', type: 'TEXT'),
        RelationColumn(name: 'name3', type: 'TEXT'),
      ],
    );

    final record = <String, Object?>{
      "name1": 'Hello',
      "name2": 'World!',
      "name3": null,
    };
    final s_row = serializeRow(record, rel);
    final d_row = deserializeRow(s_row, rel);

    expect(record, d_row);
  });

  test('Null mask uses bits as if they were a list', () {
    final rel = Relation(
      id: 1,
      schema: 'schema',
      table: 'table',
      tableType: SatRelation_RelationType.TABLE,
      columns: [
        RelationColumn(name: 'bit0', type: 'TEXT'),
        RelationColumn(name: 'bit1', type: 'TEXT'),
        RelationColumn(name: 'bit2', type: 'TEXT'),
        RelationColumn(name: 'bit3', type: 'TEXT'),
        RelationColumn(name: 'bit4', type: 'TEXT'),
        RelationColumn(name: 'bit5', type: 'TEXT'),
        RelationColumn(name: 'bit6', type: 'TEXT'),
        RelationColumn(name: 'bit7', type: 'TEXT'),
        RelationColumn(name: 'bit8', type: 'TEXT'),
      ],
    );

    final record = {
      "bit0": null,
      "bit1": null,
      "bit2": 'Filled',
      "bit3": null,
      "bit4": 'Filled',
      "bit5": 'Filled',
      "bit6": 'Filled',
      "bit7": 'Filled',
      "bit8": null,
    };
    final s_row = serializeRow(record, rel);

    final mask = [...s_row.nullsBitmask].map((x) => x.toRadixString(2)).join('');

    expect(mask, '1101000010000000');
  });
}
