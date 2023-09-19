import 'package:electricsql/electricsql.dart';
import 'package:test/test.dart';

void main() {
  group('timestamp', () {
    test('encode', () {
      var encoded =
          TypeConverters.timestamp.encode(DateTime.utc(2023, 8, 23, 9, 10, 11));
      expect(encoded, '2023-08-23T09:10:11.000Z');

      encoded = TypeConverters.timestamp
          .encode(DateTime.utc(1900, 8, 23, 9, 10, 11, 1));
      expect(encoded, '1900-08-23T09:10:11.001Z');
    });

    test('decode', () {
      var decoded = TypeConverters.timestamp.decode('2023-08-23T09:10:11.000Z');
      expect(decoded, DateTime.utc(2023, 8, 23, 9, 10, 11));

      decoded = TypeConverters.timestamp.decode('1900-08-23T09:10:11.001Z');
      expect(decoded, DateTime.utc(1900, 8, 23, 9, 10, 11, 1));

      decoded = TypeConverters.timestamp.decode('2023-08-23 09:10:11.001Z');
      expect(decoded, DateTime.utc(2023, 8, 23, 9, 10, 11, 1));

      decoded = TypeConverters.timestamp.decode('2023-08-23 09:10:11');
      expect(decoded, DateTime.utc(2023, 8, 23, 9, 10, 11));
    });
  });
}
