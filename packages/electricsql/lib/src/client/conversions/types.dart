enum PgType {
  bool('BOOL'),
  int('INT'),
  int2('INT2'),
  int4('INT4'),
  int8('INT8'),
  integer('INTEGER'),
  real('REAL'),
  float4('FLOAT4'),
  float8('FLOAT8'),
  text('TEXT'),
  varchar('VARCHAR'),
  char('CHAR'),
  uuid('UUID'),
  // DATES
  timestamp('TIMESTAMP'),
  timestampTz('TIMESTAMPTZ'),
  date('DATE'),
  time('TIME'),
  timeTz('TIMETZ');

  const PgType(this.id);
  final String id;
}

final Map<String, PgType> _pgTypeMap = Map.fromEntries(
  PgType.values.map(
    (v) => MapEntry(v.id, v),
  ),
);

PgType pgTypeFromColumnType(String columnType) {
  final key = columnType.toUpperCase();
  final pgType = _pgTypeMap[key];

  if (pgType == null) {
    throw Exception('Unknown PG type: $key');
  }

  return pgType;
}
