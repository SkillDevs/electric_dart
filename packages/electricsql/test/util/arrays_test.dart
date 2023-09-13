import 'package:electricsql/src/util/arrays.dart';
import 'package:fast_immutable_collections/fast_immutable_collections.dart';
import 'package:test/test.dart';

void main() {
  test('chunkBy: correctly chunks an array based on a predicate', () {
    const source = ['a', 'b', '', 'aa', 'bb', 'a'];

    final result = [...chunkBy(source, (x, _, __) => x.length)];

    expect(
      result,
      EqualChunks([
        (1, ['a', 'b']),
        (0, ['']),
        (2, ['aa', 'bb']),
        (1, ['a']),
      ]),
    );
  });

  test('chunkBy: correctly chunks an array based on a false-ish predicate', () {
    const source = ['a', 'b', '', 'bb', 'aa', 'a', 'b'];

    final result = [...chunkBy(source, (x, _, __) => x.contains('a'))];

    expect(
      result,
      EqualChunks([
        (true, ['a']),
        (false, ['b', '', 'bb']),
        (true, ['aa', 'a']),
        (false, ['b']),
      ]),
    );
  });

  test('chunkBy: returns an empty iterator on empty source', () {
    const source = <String>[];

    final result = [...chunkBy(source, (x, _, __) => x.contains('a'))];

    expect(result, <(bool, List<String>)>[]);
  });

  test('chunkBy: works on a single element', () {
    final source = ['a'];

    final result = [...chunkBy(source, (_, __, ___) => null)];

    expect(
      result,
      EqualChunks(
        [
          (null, ['a']),
        ],
      ),
    );
  });
}

class EqualChunks<K, T> extends CustomMatcher {
  EqualChunks(List<(K, List<T>)> chunks)
      : super('Chunks are', 'chunks', equals(_mapChunks<K, T>(chunks)));

  @override
  Object? featureValueOf(dynamic actual) {
    return _mapChunks<K, T>(actual);
  }

  static Object? _mapChunks<K, T>(dynamic chunks) {
    return (chunks as List<(K, List<T>)>).map((e) => (e.$1, e.$2.lock));
  }
}
