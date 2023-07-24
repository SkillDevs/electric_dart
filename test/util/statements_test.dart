import 'package:electric_client/src/util/statements.dart';
import 'package:electric_client/src/util/types.dart';
import 'package:test/test.dart';

void main() {
  test('prepareBatchedStatements correctly splits up data in batches', () {
    const data = [
      {"a": 1, "b": 2},
      {"a": 3, "b": 4},
      {"a": 5, "b": 6},
    ];
    final stmts = prepareBatchedStatements(
      'INSERT INTO test (a, b) VALUES',
      ['a', 'b'],
      data,
      5, // at most 5 `?`s in one SQL statement, so we should see the split
    );

    expect(stmts, [
      Statement(
        'INSERT INTO test (a, b) VALUES (?, ?), (?, ?)',
        [1, 2, 3, 4],
      ),
      Statement('INSERT INTO test (a, b) VALUES (?, ?)', [5, 6]),
    ]);
  });

  test('prepareBatchedStatements respects column order', () {
    const data = [
      {"a": 1, "b": 2},
      {"a": 3, "b": 4},
      {"a": 5, "b": 6},
    ];
    final stmts = prepareBatchedStatements(
      'INSERT INTO test (a, b) VALUES',
      ['b', 'a'],
      data,
      5,
    );

    expect(stmts, [
      Statement(
        'INSERT INTO test (a, b) VALUES (?, ?), (?, ?)',
        [2, 1, 4, 3],
      ),
      Statement('INSERT INTO test (a, b) VALUES (?, ?)', [6, 5]),
    ]);
  });
}
