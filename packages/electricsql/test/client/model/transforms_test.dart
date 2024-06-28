import 'package:drift/drift.dart';
import 'package:electricsql/src/client/model/schema.dart';
import 'package:electricsql/src/client/model/transform.dart';
import 'package:electricsql/src/client/validation/validation.dart';
import 'package:electricsql/src/drivers/drift/drift.dart';
import 'package:electricsql/src/drivers/drift/schema.dart';
import 'package:electricsql/util.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import '../drift/database.dart';

const post1 = PostData(
  id: 1,
  title: 't1',
  contents: 'c1',
  nbr: 18,
  authorId: 1,
);

late TestsDatabase db;
late DBSchema schema;

Future<void> main() async {
  setUp(() async {
    db = TestsDatabase.memory();

    schema = DBSchemaDrift(db: db, migrations: [], pgMigrations: []);
  });

  tearDown(() async {
    await db.close();
  });

  void transformTableRecordUtil(
    Insertable<PostData> r, {
    required DbRecord Function(DbRecord)? update,
    required List<String> immutableFields,
  }) {
    final fields = schema.getFields('Post');

    final origCols = driftInsertableToValues(r);
    transformTableRecordGeneric<Insertable<PostData>>(
      r,
      (row) {
        final Map<String, Expression<Object>> updated;
        if (update != null) {
          updated = update(origCols).map(
            (key, value) =>
                MapEntry(key, value is Expression ? value : Variable(value)),
          );
        } else {
          updated =
              origCols.map((key, value) => MapEntry(key, Variable(value)));
        }

        return RawValuesInsertable(updated);
      },
      fields,
      immutableFields,
      validateFun: (d) => validateDriftRecord(db.post, d),
      toRecord: (d) => driftInsertableToValues(d),
    );
  }

  test('transformTableRecord should validate the input', () {
    void liftedTransform(PostData r, {DbRecord Function(DbRecord)? update}) {
      transformTableRecordUtil(
        r,
        update: update,
        immutableFields: [],
      );
    }

    final Matcher isATypeCastError = isA<TypeError>().having(
      (e) => e.toString(),
      'message',
      contains('is not a subtype of type'),
    );

    // Expectations

    // should not throw for properly typed input
    liftedTransform(post1);

    liftedTransform(post1, update: (r) => {...r, 'title': 'ab'});

    // should throw for improperly typed input
    expect(
      () => liftedTransform(
        post1,
        update: (r) => {...r, 'title': 3},
      ),
      throwsA(isATypeCastError),
    );

    expect(
      () => liftedTransform(
        post1,
        update: (r) => {...r, 'contents': 3},
      ),
      throwsA(isATypeCastError),
    );

    expect(
      () => liftedTransform(
        post1,
        update: (r) => {...r, 'nbr': 'string'},
      ),
      throwsA(isATypeCastError),
    );

    expect(
      () => liftedTransform(
        post1,
        update: (r) => {...r, 'non_existent': 'string'},
      ),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Unrecognized column: non_existent'),
        ),
      ),
    );
  });

  test('transformTableRecord should validate the output', () {
    void liftedTransform(PostData r, {DbRecord Function(DbRecord)? update}) {
      transformTableRecordUtil(
        r,
        update: update,
        immutableFields: [],
      );
    }

    // should throw for improperly typed input
    expect(
      () => liftedTransform(
        post1,
        update: (r) => {...r, 'title': 3},
      ),
      throwsA(
        isA<Object>().having(
          (e) => e.toString(),
          'message',
          contains("'int' is not a subtype of type 'String?'"),
        ),
      ),
    );
  });

  test(
      'transformTableRecord should validate output does not modify immutable fields',
      () {
    void liftedTransform(PostData r, {DbRecord Function(DbRecord)? update}) {
      transformTableRecordUtil(
        r,
        update: update,
        immutableFields: ['title'],
      );
    }

    expect(
      () => liftedTransform(
        post1,
        update: (r) => {...r, 'title': '${r['title']! as String}modified'},
      ),
      throwsA(isA<InvalidRecordTransformationError>()),
    );
  });

  test('setReplicationTransform throws an error if table does not exist', () {
    expect(
      () => setReplicationTransform<DbRecord>(
        dbDescription: schema,
        replicationTransformManager: ReplicatedRowTransformManagerMock(),
        qualifiedTableName:
            const QualifiedTablename('main', 'non_existent_table'),
        transformInbound: (r) => r,
        transformOutbound: (r) => r,
        validateFun: null,
        toRecord: (r) => r,
        fromRecord: (r) => r,
      ),
      throwsA(
        isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains(
            "Cannot set replication transform for table 'non_existent_table'. Table does not exist in the database schema.",
          ),
        ),
      ),
    );
  });
}

class ReplicatedRowTransformManagerMock extends Mock
    implements IReplicationTransformManager {}
