import 'package:electricsql/src/client/model/index.dart';

abstract class Converter {
  Object? encode(Object? v, PgType pgType);
  Object? decode(Object? v, PgType pgType);
}
