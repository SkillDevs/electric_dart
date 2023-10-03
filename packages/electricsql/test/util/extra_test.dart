import 'package:electricsql/src/util/js_array_funs.dart';
import 'package:test/test.dart';

void main() {
  group('slice', () {
    test('empty', () {
      expect(<int>[].slice(0), <int>[]);
      expect(<int>[].slice(1), <int>[]);
    });

    test('start >= length', () {
      expect(<int>[2].slice(1), <int>[]);
      expect(<int>[2].slice(2), <int>[]);
    });

    test('regular', () {
      expect(<int>[2, 3, 5].slice(0), <int>[2, 3, 5]);
      expect(<int>[2, 3, 5].slice(1), <int>[3, 5]);
      expect(<int>[2, 3, 5].slice(3), <int>[]);
      expect(<int>[2, 3, 5].slice(5), <int>[]);

      expect(<int>[2, 3, 5].slice(0, 1), <int>[2]);
      expect(<int>[2, 3, 5].slice(0, 2), <int>[2, 3]);
      expect(<int>[2, 3, 5].slice(1, 2), <int>[3]);
      expect(<int>[2, 3, 5].slice(1, 6), <int>[3, 5]);
    });
  });
}
