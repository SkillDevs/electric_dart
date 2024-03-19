import 'package:electricsql/src/proto/satellite.pb.dart';
import 'package:electricsql/src/satellite/shapes/types.dart';
import 'package:electricsql/src/util/proto.dart';
import 'package:test/test.dart';

void main() {
  test('shapeRequestToSatShapeReq: correctly converts a nested request', () {
    final shapeReq = ShapeRequest(
      requestId: 'fake_id',
      definition: Shape(
        tablename: 'fake',
        include: [
          Rel(foreignKey: ['fake_table_id'], select: Shape(tablename: 'other')),
        ],
      ),
    );

    final req = shapeRequestToSatShapeReq([shapeReq]);

    expect(req.length, 1);
    expect(req[0].requestId, 'fake_id');
    expect(req[0].shapeDefinition, isNotNull);
    final SatShapeDef(:selects) = req[0].shapeDefinition;

    expect(selects.length, 1);

    final sel = selects[0];
    expect(sel.tablename, 'fake');
    expect(sel.include.length, 1);
    final include = sel.include[0];
    expect(include.foreignKey, ['fake_table_id']);
    final includeSel = include.select;
    expect(includeSel.tablename, 'other');
    expect(includeSel.include, <Object>[]);
    expect(includeSel.where, '');
  });
}
