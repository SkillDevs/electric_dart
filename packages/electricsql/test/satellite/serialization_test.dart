import 'dart:convert';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:electricsql/src/client/conversions/types.dart';
import 'package:electricsql/src/client/model/schema.dart';
import 'package:electricsql/src/drivers/sqlite3/sqlite3_adapter.dart';
import 'package:electricsql/src/proto/satellite.pb.dart';
import 'package:electricsql/src/satellite/client.dart';
import 'package:electricsql/src/satellite/config.dart';
import 'package:electricsql/src/util/relations.dart';
import 'package:electricsql/src/util/types.dart';
import 'package:test/test.dart';

import '../util/sqlite.dart';

void main() {
  test('serialize/deserialize row data', () {
    final rel = Relation(
      id: 1,
      schema: 'schema',
      table: 'table',
      tableType: SatRelation_RelationType.TABLE,
      columns: [
        RelationColumn(name: 'name1', type: 'TEXT', isNullable: true),
        RelationColumn(name: 'name2', type: 'TEXT', isNullable: true),
        RelationColumn(name: 'name3', type: 'TEXT', isNullable: true),
        RelationColumn(name: 'blob1', type: 'BYTEA', isNullable: true),
        RelationColumn(name: 'blob2', type: 'BYTEA', isNullable: true),
        RelationColumn(name: 'blob3', type: 'BYTEA', isNullable: true),
        RelationColumn(name: 'int1', type: 'INTEGER', isNullable: true),
        RelationColumn(name: 'int2', type: 'INTEGER', isNullable: true),
        RelationColumn(name: 'float1', type: 'REAL', isNullable: true),
        RelationColumn(name: 'float2', type: 'FLOAT4', isNullable: true),
        RelationColumn(name: 'float3', type: 'FLOAT8', isNullable: true),
        RelationColumn(name: 'bool1', type: 'BOOL', isNullable: true),
        RelationColumn(name: 'bool2', type: 'BOOL', isNullable: true),
        RelationColumn(name: 'bool3', type: 'BOOL', isNullable: true),
        // bundled migrations contain type 'TEXT' for enums
        RelationColumn(name: 'enum1', type: 'TEXT', isNullable: true),
        RelationColumn(name: 'enum2', type: 'TEXT', isNullable: true),
      ],
    );

    final dbDescription = DBSchemaRaw(
      fields: {
        'table': {
          'name1': PgType.text,
          'name2': PgType.text,
          'name3': PgType.text,
          'blob1': PgType.bytea,
          'blob2': PgType.bytea,
          'blob3': PgType.bytea,
          'int1': PgType.integer,
          'int2': PgType.integer,
          'float1': PgType.real,
          'float2': PgType.float4,
          'float3': PgType.float4,
          'bool1': PgType.bool,
          'bool2': PgType.bool,
          'bool3': PgType.bool,
          // enum types are transformed to text type by our generator
          'enum1': PgType.text,
          'enum2': PgType.text,
        },
      },
      migrations: [],
    );

    final record = <String, Object?>{
      'name1': 'Hello',
      'name2': 'World!',
      'name3': null,
      'blob1': Uint8List.fromList([1, 15, 255, 145]),
      'blob2': Uint8List.fromList([]),
      'blob3': null,
      'int1': 1,
      'int2': -30,
      'float1': 1.0,
      'float2': -30.3,
      'float3': 5e234,
      'bool1': 1,
      'bool2': 0,
      'bool3': null,
      'enum1': 'red',
      'enum2': null,
    };
    final recordKeys = record.keys.toList();
    final sRow = serializeRow(record, rel, dbDescription);
    expect(
      sRow.values.mapIndexed(
        (i, bytes) =>
            recordKeys[i].startsWith('blob') ? 'blob' : utf8.decode(bytes),
      ),
      [
        'Hello',
        'World!',
        '',
        'blob',
        'blob',
        'blob',
        '1',
        '-30',
        '1',
        '-30.3',
        '5e+234',
        't',
        'f',
        '',
        'red',
        '',
      ],
    );
    final dRow = deserializeRow(sRow, rel, dbDescription);

    expect(dRow, record);

    // Test edge cases for floats such as NaN, Infinity, -Infinity
    final record2 = <String, Object?>{
      'name1': 'Edge cases for Floats',
      'name2': null,
      'name3': null,
      'blob1': Uint8List.fromList([1, 15, 255, 145]),
      'blob2': Uint8List.fromList([]),
      'blob3': null,
      'int1': null,
      'int2': null,
      'float1': double.nan,
      'float2': double.infinity,
      'float3': double.negativeInfinity,
      'bool1': null,
      'bool2': null,
      'bool3': null,
      'enum1': 'red',
      'enum2': null,
    };

    final recordKeys2 = record2.keys.toList();
    final sRow2 = serializeRow(record2, rel, dbDescription);
    expect(
      sRow2.values.mapIndexed(
        (i, bytes) =>
            recordKeys2[i].startsWith('blob') ? 'blob' : utf8.decode(bytes),
      ),
      [
        'Edge cases for Floats',
        '',
        '',
        'blob',
        'blob',
        'blob',
        '',
        '',
        'NaN',
        'Infinity',
        '-Infinity',
        '',
        '',
        '',
        'red',
        '',
      ],
    );
    final dRow2 = deserializeRow(sRow2, rel, dbDescription);

    expect(dRow2, {
      ...record2,
      // SQLite does not support NaN so we deserialise it into the string 'NaN'
      'float1': 'NaN',
    });
  });

  test('Null mask uses bits as if they were a list', () {
    final rel = Relation(
      id: 1,
      schema: 'schema',
      table: 'table',
      tableType: SatRelation_RelationType.TABLE,
      columns: [
        RelationColumn(name: 'bit0', type: 'TEXT', isNullable: true),
        RelationColumn(name: 'bit1', type: 'TEXT', isNullable: true),
        RelationColumn(name: 'bit2', type: 'TEXT', isNullable: true),
        RelationColumn(name: 'bit3', type: 'TEXT', isNullable: true),
        RelationColumn(name: 'bit4', type: 'TEXT', isNullable: true),
        RelationColumn(name: 'bit5', type: 'TEXT', isNullable: true),
        RelationColumn(name: 'bit6', type: 'TEXT', isNullable: true),
        RelationColumn(name: 'bit7', type: 'TEXT', isNullable: true),
        RelationColumn(name: 'bit8', type: 'TEXT', isNullable: true),
      ],
    );

    final dbDescription = DBSchemaRaw(
      fields: {
        'table': {
          'bit0': PgType.text,
          'bit1': PgType.text,
          'bit2': PgType.text,
          'bit3': PgType.text,
          'bit4': PgType.text,
          'bit5': PgType.text,
          'bit6': PgType.text,
          'bit7': PgType.text,
          'bit8': PgType.text,
        },
      },
      migrations: [],
    );

    final record = {
      'bit0': null,
      'bit1': null,
      'bit2': 'Filled',
      'bit3': null,
      'bit4': 'Filled',
      'bit5': 'Filled',
      'bit6': 'Filled',
      'bit7': 'Filled',
      'bit8': null,
    };
    final sRow = serializeRow(record, rel, dbDescription);

    final mask = [...sRow.nullsBitmask].map((x) => x.toRadixString(2)).join('');

    expect(mask, '1101000010000000');
  });

  test('Prioritize PG types in the schema before inferred SQLite types',
      () async {
    final db = openSqliteDbMemory();
    addTearDown(() => db.dispose());

    final adapter = SqliteAdapter(db);
    await adapter.run(
      Statement('CREATE TABLE bools (id INTEGER PRIMARY KEY, b INTEGER)'),
    );

    final sqliteInferredRelations =
        await inferRelationsFromSQLite(adapter, kSatelliteDefaults);
    final boolsInferredRelation = sqliteInferredRelations['bools']!;

    // Inferred types only support SQLite types, so the bool column is INTEGER
    final boolColumn = boolsInferredRelation.columns[1];
    expect(boolColumn.name, 'b');
    expect(boolColumn.type, 'INTEGER');

    // Db schema holds the correct Postgres types
    final boolsDbDescription = DBSchemaRaw(
      fields: {
        'bools': {
          'id': PgType.integer,
          'b': PgType.bool,
        },
      },
      migrations: [],
    );

    final satOpRow = serializeRow(
      {'id': 5, 'b': 1},
      boolsInferredRelation,
      boolsDbDescription,
    );

    // Encoded values ["5", "t"]
    expect(
      satOpRow.values,
      [
        Uint8List.fromList(['5'.codeUnitAt(0)]),
        Uint8List.fromList(['t'.codeUnitAt(0)]),
      ],
    );

    final deserializedRow =
        deserializeRow(satOpRow, boolsInferredRelation, boolsDbDescription);

    expect(deserializedRow, {'id': 5, 'b': 1});
  });

  test('Use incoming Relation types if not found in the schema', () async {
    final db = openSqliteDbMemory();
    addTearDown(() => db.dispose());

    final adapter = SqliteAdapter(db);

    final sqliteInferredRelations =
        await inferRelationsFromSQLite(adapter, kSatelliteDefaults);

    // Empty database
    expect(sqliteInferredRelations.length, 0);

    // Empty Db schema
    final testDbDescription = DBSchemaRaw(
      fields: {},
      migrations: [],
    );

    final newTableRelation = Relation(
      id: 1,
      schema: 'schema',
      table: 'new_table',
      tableType: SatRelation_RelationType.TABLE,
      columns: [
        RelationColumn(name: 'value', type: 'INTEGER', isNullable: true),
        // at runtime, incoming SatRelation messages contain the name of the enum type
        RelationColumn(name: 'color', type: 'COLOR', isNullable: true),
      ],
    );

    final row = <String, Object?>{
      'value': 6,
      'color': 'red',
    };
    final satOpRow = serializeRow(
      row,
      newTableRelation,
      testDbDescription,
    );

    expect(
      satOpRow.values.map((bytes) => utf8.decode(bytes)),
      ['6', 'red'],
    );

    final deserializedRow =
        deserializeRow(satOpRow, newTableRelation, testDbDescription);

    expect(deserializedRow, row);
  });
}
