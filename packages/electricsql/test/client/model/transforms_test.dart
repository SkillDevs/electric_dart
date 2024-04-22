import 'package:drift/drift.dart';
import 'package:electricsql/src/client/model/transform.dart';
import 'package:electricsql/util.dart';
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

Future<void> main() async {
  setUp(() async {
    db = TestsDatabase.memory();
  });

  test('transformTableRecord should validate the input', () {
    void liftedTransform(PostData r, {Record Function(Record)? update}) {
      final origCols = r.toColumns(false);

      transformTableRecord(
        db.post,
        r,
        (PostData row) {
          final Map<String, Expression<Object>> updated;
          if (update != null) {
            updated = update(origCols).map(
              (key, value) =>
                  MapEntry(key, value is Expression ? value : Variable(value)),
            );
          } else {
            updated = origCols;
          }

          return RawValuesInsertable<PostData>(updated);
        },
        [],
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
}
