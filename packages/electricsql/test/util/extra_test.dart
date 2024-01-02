import 'package:electricsql/src/util/converters/helpers.dart';
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

  group('splice', () {
    test('empty', () {
      late List<int> list;

      list = <int>[];
      expect(list.splice(0), <int>[]);
      expect(list, <int>[]);

      list = <int>[];
      expect(list.splice(1), <int>[]);
      expect(list, <int>[]);
    });

    test('start >= length', () {
      late List<int> list;

      list = <int>[2];
      expect(list.splice(1), <int>[]);
      expect(list, <int>[2]);

      list = <int>[2];
      expect(list.splice(2), <int>[]);
      expect(list, <int>[2]);
    });

    test('regular', () {
      late List<int> list;

      list = <int>[2, 3, 5];
      expect(list.splice(0), <int>[2, 3, 5]);
      expect(list, <int>[]);

      list = <int>[2, 3, 5];
      expect(list.splice(1), <int>[3, 5]);
      expect(list, <int>[2]);

      list = <int>[2, 3, 5];
      expect(list.splice(3), <int>[]);
      expect(list, <int>[2, 3, 5]);

      list = <int>[2, 3, 5];
      expect(list.splice(5), <int>[]);
      expect(list, <int>[2, 3, 5]);

      list = <int>[2, 3, 5];
      expect(list.splice(0, 1), <int>[2]);
      expect(list, <int>[3, 5]);

      list = <int>[2, 3, 5];
      expect(list.splice(0, 2), <int>[2, 3]);
      expect(list, <int>[5]);

      list = <int>[2, 3, 5];
      expect(list.splice(1, 2), <int>[3, 5]);
      expect(list, <int>[2]);

      list = <int>[2, 3, 5];
      expect(list.splice(1, 6), <int>[3, 5]);
      expect(list, <int>[2]);
    });
  });

  group('ignoreTimeZone', () {
    test('input utc', () {
      final inputDateUTC = DateTime.utc(2023, 10, 25, 12, 0, 0);

      const mockTimezoneOffset = Duration(hours: 5);
      final out = inputDateUTC.ignoreTimeZone(
        mockTimezoneOffset: mockTimezoneOffset,
      );

      // ignoredTZ - inputDate = timezone offset
      expect(out.difference(inputDateUTC), mockTimezoneOffset);
    });

    test('input local', () {
      final inputDateUTC = DateTime(2023, 10, 25, 12, 0, 0);

      const mockTimezoneOffset = Duration(hours: 5);
      final out = inputDateUTC.ignoreTimeZone(
        mockTimezoneOffset: mockTimezoneOffset,
      );

      // ignoredTZ - inputDate = timezone offset
      expect(out.difference(inputDateUTC), mockTimezoneOffset);
    });
  });
}
