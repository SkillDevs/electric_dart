import 'package:electricsql/src/util/converters/codecs/date.dart';
import 'package:electricsql/src/util/converters/codecs/time.dart';
import 'package:electricsql/src/util/converters/codecs/timestamp.dart';
import 'package:electricsql/src/util/converters/codecs/timestamptz.dart';
import 'package:electricsql/src/util/converters/codecs/timetz.dart';

class TypeConverters {
  static const TimestampCodec timestamp = TimestampCodec();
  static const TimestampTZCodec timestampTZ = TimestampTZCodec();
  static const DateCodec date = DateCodec();
  static const TimeCodec time = TimeCodec();
  static const TimeTZCodec timeTZ = TimeTZCodec();
}
