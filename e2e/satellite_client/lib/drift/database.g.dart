// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $BlobsTable extends Blobs with TableInfo<$BlobsTable, Blob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BlobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _blob$Meta = const VerificationMeta('blob\$');
  @override
  late final GeneratedColumn<Uint8List> blob$ = GeneratedColumn<Uint8List>(
      'blob', aliasedName, true,
      type: DriftSqlType.blob, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, blob$];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'blobs';
  @override
  VerificationContext validateIntegrity(Insertable<Blob> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('blob')) {
      context.handle(
          _blob$Meta, blob$.isAcceptableOrUnknown(data['blob']!, _blob$Meta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Blob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Blob(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      blob$: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}blob']),
    );
  }

  @override
  $BlobsTable createAlias(String alias) {
    return $BlobsTable(attachedDatabase, alias);
  }
}

class Blob extends DataClass implements Insertable<Blob> {
  final String id;
  final Uint8List? blob$;
  const Blob({required this.id, this.blob$});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || blob$ != null) {
      map['blob'] = Variable<Uint8List>(blob$);
    }
    return map;
  }

  BlobsCompanion toCompanion(bool nullToAbsent) {
    return BlobsCompanion(
      id: Value(id),
      blob$:
          blob$ == null && nullToAbsent ? const Value.absent() : Value(blob$),
    );
  }

  factory Blob.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Blob(
      id: serializer.fromJson<String>(json['id']),
      blob$: serializer.fromJson<Uint8List?>(json['blob\$']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'blob\$': serializer.toJson<Uint8List?>(blob$),
    };
  }

  Blob copyWith({String? id, Value<Uint8List?> blob$ = const Value.absent()}) =>
      Blob(
        id: id ?? this.id,
        blob$: blob$.present ? blob$.value : this.blob$,
      );
  Blob copyWithCompanion(BlobsCompanion data) {
    return Blob(
      id: data.id.present ? data.id.value : this.id,
      blob$: data.blob$.present ? data.blob$.value : this.blob$,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Blob(')
          ..write('id: $id, ')
          ..write('blob\$: ${blob$}')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, $driftBlobEquality.hash(blob$));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Blob &&
          other.id == this.id &&
          $driftBlobEquality.equals(other.blob$, this.blob$));
}

class BlobsCompanion extends UpdateCompanion<Blob> {
  final Value<String> id;
  final Value<Uint8List?> blob$;
  final Value<int> rowid;
  const BlobsCompanion({
    this.id = const Value.absent(),
    this.blob$ = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BlobsCompanion.insert({
    required String id,
    this.blob$ = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<Blob> custom({
    Expression<String>? id,
    Expression<Uint8List>? blob$,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (blob$ != null) 'blob': blob$,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BlobsCompanion copyWith(
      {Value<String>? id, Value<Uint8List?>? blob$, Value<int>? rowid}) {
    return BlobsCompanion(
      id: id ?? this.id,
      blob$: blob$ ?? this.blob$,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (blob$.present) {
      map['blob'] = Variable<Uint8List>(blob$.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BlobsCompanion(')
          ..write('id: $id, ')
          ..write('blob\$: ${blob$}, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BoolsTable extends Bools with TableInfo<$BoolsTable, Bool> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BoolsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bMeta = const VerificationMeta('b');
  @override
  late final GeneratedColumn<bool> b = GeneratedColumn<bool>(
      'b', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("b" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns => [id, b];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bools';
  @override
  VerificationContext validateIntegrity(Insertable<Bool> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('b')) {
      context.handle(_bMeta, b.isAcceptableOrUnknown(data['b']!, _bMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bool map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bool(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      b: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}b']),
    );
  }

  @override
  $BoolsTable createAlias(String alias) {
    return $BoolsTable(attachedDatabase, alias);
  }
}

class Bool extends DataClass implements Insertable<Bool> {
  final String id;
  final bool? b;
  const Bool({required this.id, this.b});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || b != null) {
      map['b'] = Variable<bool>(b);
    }
    return map;
  }

  BoolsCompanion toCompanion(bool nullToAbsent) {
    return BoolsCompanion(
      id: Value(id),
      b: b == null && nullToAbsent ? const Value.absent() : Value(b),
    );
  }

  factory Bool.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bool(
      id: serializer.fromJson<String>(json['id']),
      b: serializer.fromJson<bool?>(json['b']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'b': serializer.toJson<bool?>(b),
    };
  }

  Bool copyWith({String? id, Value<bool?> b = const Value.absent()}) => Bool(
        id: id ?? this.id,
        b: b.present ? b.value : this.b,
      );
  Bool copyWithCompanion(BoolsCompanion data) {
    return Bool(
      id: data.id.present ? data.id.value : this.id,
      b: data.b.present ? data.b.value : this.b,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bool(')
          ..write('id: $id, ')
          ..write('b: $b')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, b);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bool && other.id == this.id && other.b == this.b);
}

class BoolsCompanion extends UpdateCompanion<Bool> {
  final Value<String> id;
  final Value<bool?> b;
  final Value<int> rowid;
  const BoolsCompanion({
    this.id = const Value.absent(),
    this.b = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BoolsCompanion.insert({
    required String id,
    this.b = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<Bool> custom({
    Expression<String>? id,
    Expression<bool>? b,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (b != null) 'b': b,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BoolsCompanion copyWith(
      {Value<String>? id, Value<bool?>? b, Value<int>? rowid}) {
    return BoolsCompanion(
      id: id ?? this.id,
      b: b ?? this.b,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (b.present) {
      map['b'] = Variable<bool>(b.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BoolsCompanion(')
          ..write('id: $id, ')
          ..write('b: $b, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DatetimesTable extends Datetimes
    with TableInfo<$DatetimesTable, Datetime> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DatetimesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dMeta = const VerificationMeta('d');
  @override
  late final GeneratedColumn<DateTime> d = GeneratedColumn<DateTime>(
      'd', aliasedName, false,
      type: ElectricTypes.date, requiredDuringInsert: true);
  static const VerificationMeta _tMeta = const VerificationMeta('t');
  @override
  late final GeneratedColumn<DateTime> t = GeneratedColumn<DateTime>(
      't', aliasedName, false,
      type: ElectricTypes.time, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, d, t];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'datetimes';
  @override
  VerificationContext validateIntegrity(Insertable<Datetime> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('d')) {
      context.handle(_dMeta, d.isAcceptableOrUnknown(data['d']!, _dMeta));
    } else if (isInserting) {
      context.missing(_dMeta);
    }
    if (data.containsKey('t')) {
      context.handle(_tMeta, t.isAcceptableOrUnknown(data['t']!, _tMeta));
    } else if (isInserting) {
      context.missing(_tMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Datetime map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Datetime(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      d: attachedDatabase.typeMapping
          .read(ElectricTypes.date, data['${effectivePrefix}d'])!,
      t: attachedDatabase.typeMapping
          .read(ElectricTypes.time, data['${effectivePrefix}t'])!,
    );
  }

  @override
  $DatetimesTable createAlias(String alias) {
    return $DatetimesTable(attachedDatabase, alias);
  }
}

class Datetime extends DataClass implements Insertable<Datetime> {
  final String id;
  final DateTime d;
  final DateTime t;
  const Datetime({required this.id, required this.d, required this.t});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['d'] = Variable<DateTime>(d, ElectricTypes.date);
    map['t'] = Variable<DateTime>(t, ElectricTypes.time);
    return map;
  }

  DatetimesCompanion toCompanion(bool nullToAbsent) {
    return DatetimesCompanion(
      id: Value(id),
      d: Value(d),
      t: Value(t),
    );
  }

  factory Datetime.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Datetime(
      id: serializer.fromJson<String>(json['id']),
      d: serializer.fromJson<DateTime>(json['d']),
      t: serializer.fromJson<DateTime>(json['t']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'd': serializer.toJson<DateTime>(d),
      't': serializer.toJson<DateTime>(t),
    };
  }

  Datetime copyWith({String? id, DateTime? d, DateTime? t}) => Datetime(
        id: id ?? this.id,
        d: d ?? this.d,
        t: t ?? this.t,
      );
  Datetime copyWithCompanion(DatetimesCompanion data) {
    return Datetime(
      id: data.id.present ? data.id.value : this.id,
      d: data.d.present ? data.d.value : this.d,
      t: data.t.present ? data.t.value : this.t,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Datetime(')
          ..write('id: $id, ')
          ..write('d: $d, ')
          ..write('t: $t')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, d, t);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Datetime &&
          other.id == this.id &&
          other.d == this.d &&
          other.t == this.t);
}

class DatetimesCompanion extends UpdateCompanion<Datetime> {
  final Value<String> id;
  final Value<DateTime> d;
  final Value<DateTime> t;
  final Value<int> rowid;
  const DatetimesCompanion({
    this.id = const Value.absent(),
    this.d = const Value.absent(),
    this.t = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DatetimesCompanion.insert({
    required String id,
    required DateTime d,
    required DateTime t,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        d = Value(d),
        t = Value(t);
  static Insertable<Datetime> custom({
    Expression<String>? id,
    Expression<DateTime>? d,
    Expression<DateTime>? t,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (d != null) 'd': d,
      if (t != null) 't': t,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DatetimesCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? d,
      Value<DateTime>? t,
      Value<int>? rowid}) {
    return DatetimesCompanion(
      id: id ?? this.id,
      d: d ?? this.d,
      t: t ?? this.t,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (d.present) {
      map['d'] = Variable<DateTime>(d.value, ElectricTypes.date);
    }
    if (t.present) {
      map['t'] = Variable<DateTime>(t.value, ElectricTypes.time);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DatetimesCompanion(')
          ..write('id: $id, ')
          ..write('d: $d, ')
          ..write('t: $t, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EnumsTable extends Enums with TableInfo<$EnumsTable, Enum> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnumsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cMeta = const VerificationMeta('c');
  @override
  late final GeneratedColumn<DbColor> c = GeneratedColumn<DbColor>(
      'c', aliasedName, true,
      type: ElectricEnumTypes.color, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, c];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'enums';
  @override
  VerificationContext validateIntegrity(Insertable<Enum> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('c')) {
      context.handle(_cMeta, c.isAcceptableOrUnknown(data['c']!, _cMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Enum map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Enum(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      c: attachedDatabase.typeMapping
          .read(ElectricEnumTypes.color, data['${effectivePrefix}c']),
    );
  }

  @override
  $EnumsTable createAlias(String alias) {
    return $EnumsTable(attachedDatabase, alias);
  }
}

class Enum extends DataClass implements Insertable<Enum> {
  final String id;
  final DbColor? c;
  const Enum({required this.id, this.c});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || c != null) {
      map['c'] = Variable<DbColor>(c, ElectricEnumTypes.color);
    }
    return map;
  }

  EnumsCompanion toCompanion(bool nullToAbsent) {
    return EnumsCompanion(
      id: Value(id),
      c: c == null && nullToAbsent ? const Value.absent() : Value(c),
    );
  }

  factory Enum.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Enum(
      id: serializer.fromJson<String>(json['id']),
      c: serializer.fromJson<DbColor?>(json['c']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'c': serializer.toJson<DbColor?>(c),
    };
  }

  Enum copyWith({String? id, Value<DbColor?> c = const Value.absent()}) => Enum(
        id: id ?? this.id,
        c: c.present ? c.value : this.c,
      );
  Enum copyWithCompanion(EnumsCompanion data) {
    return Enum(
      id: data.id.present ? data.id.value : this.id,
      c: data.c.present ? data.c.value : this.c,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Enum(')
          ..write('id: $id, ')
          ..write('c: $c')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, c);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Enum && other.id == this.id && other.c == this.c);
}

class EnumsCompanion extends UpdateCompanion<Enum> {
  final Value<String> id;
  final Value<DbColor?> c;
  final Value<int> rowid;
  const EnumsCompanion({
    this.id = const Value.absent(),
    this.c = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EnumsCompanion.insert({
    required String id,
    this.c = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<Enum> custom({
    Expression<String>? id,
    Expression<DbColor>? c,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (c != null) 'c': c,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EnumsCompanion copyWith(
      {Value<String>? id, Value<DbColor?>? c, Value<int>? rowid}) {
    return EnumsCompanion(
      id: id ?? this.id,
      c: c ?? this.c,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (c.present) {
      map['c'] = Variable<DbColor>(c.value, ElectricEnumTypes.color);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnumsCompanion(')
          ..write('id: $id, ')
          ..write('c: $c, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FloatsTable extends Floats with TableInfo<$FloatsTable, Float> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FloatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _f4Meta = const VerificationMeta('f4');
  @override
  late final GeneratedColumn<double> f4 = GeneratedColumn<double>(
      'f4', aliasedName, true,
      type: ElectricTypes.float4, requiredDuringInsert: false);
  static const VerificationMeta _f8Meta = const VerificationMeta('f8');
  @override
  late final GeneratedColumn<double> f8 = GeneratedColumn<double>(
      'f8', aliasedName, true,
      type: ElectricTypes.float8, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, f4, f8];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'floats';
  @override
  VerificationContext validateIntegrity(Insertable<Float> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('f4')) {
      context.handle(_f4Meta, f4.isAcceptableOrUnknown(data['f4']!, _f4Meta));
    }
    if (data.containsKey('f8')) {
      context.handle(_f8Meta, f8.isAcceptableOrUnknown(data['f8']!, _f8Meta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Float map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Float(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      f4: attachedDatabase.typeMapping
          .read(ElectricTypes.float4, data['${effectivePrefix}f4']),
      f8: attachedDatabase.typeMapping
          .read(ElectricTypes.float8, data['${effectivePrefix}f8']),
    );
  }

  @override
  $FloatsTable createAlias(String alias) {
    return $FloatsTable(attachedDatabase, alias);
  }
}

class Float extends DataClass implements Insertable<Float> {
  final String id;
  final double? f4;
  final double? f8;
  const Float({required this.id, this.f4, this.f8});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || f4 != null) {
      map['f4'] = Variable<double>(f4, ElectricTypes.float4);
    }
    if (!nullToAbsent || f8 != null) {
      map['f8'] = Variable<double>(f8, ElectricTypes.float8);
    }
    return map;
  }

  FloatsCompanion toCompanion(bool nullToAbsent) {
    return FloatsCompanion(
      id: Value(id),
      f4: f4 == null && nullToAbsent ? const Value.absent() : Value(f4),
      f8: f8 == null && nullToAbsent ? const Value.absent() : Value(f8),
    );
  }

  factory Float.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Float(
      id: serializer.fromJson<String>(json['id']),
      f4: serializer.fromJson<double?>(json['f4']),
      f8: serializer.fromJson<double?>(json['f8']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'f4': serializer.toJson<double?>(f4),
      'f8': serializer.toJson<double?>(f8),
    };
  }

  Float copyWith(
          {String? id,
          Value<double?> f4 = const Value.absent(),
          Value<double?> f8 = const Value.absent()}) =>
      Float(
        id: id ?? this.id,
        f4: f4.present ? f4.value : this.f4,
        f8: f8.present ? f8.value : this.f8,
      );
  Float copyWithCompanion(FloatsCompanion data) {
    return Float(
      id: data.id.present ? data.id.value : this.id,
      f4: data.f4.present ? data.f4.value : this.f4,
      f8: data.f8.present ? data.f8.value : this.f8,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Float(')
          ..write('id: $id, ')
          ..write('f4: $f4, ')
          ..write('f8: $f8')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, f4, f8);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Float &&
          other.id == this.id &&
          other.f4 == this.f4 &&
          other.f8 == this.f8);
}

class FloatsCompanion extends UpdateCompanion<Float> {
  final Value<String> id;
  final Value<double?> f4;
  final Value<double?> f8;
  final Value<int> rowid;
  const FloatsCompanion({
    this.id = const Value.absent(),
    this.f4 = const Value.absent(),
    this.f8 = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FloatsCompanion.insert({
    required String id,
    this.f4 = const Value.absent(),
    this.f8 = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<Float> custom({
    Expression<String>? id,
    Expression<double>? f4,
    Expression<double>? f8,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (f4 != null) 'f4': f4,
      if (f8 != null) 'f8': f8,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FloatsCompanion copyWith(
      {Value<String>? id,
      Value<double?>? f4,
      Value<double?>? f8,
      Value<int>? rowid}) {
    return FloatsCompanion(
      id: id ?? this.id,
      f4: f4 ?? this.f4,
      f8: f8 ?? this.f8,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (f4.present) {
      map['f4'] = Variable<double>(f4.value, ElectricTypes.float4);
    }
    if (f8.present) {
      map['f8'] = Variable<double>(f8.value, ElectricTypes.float8);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FloatsCompanion(')
          ..write('id: $id, ')
          ..write('f4: $f4, ')
          ..write('f8: $f8, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $IntsTable extends Ints with TableInfo<$IntsTable, Int> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IntsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _i2Meta = const VerificationMeta('i2');
  @override
  late final GeneratedColumn<int> i2 = GeneratedColumn<int>(
      'i2', aliasedName, true,
      type: ElectricTypes.int2, requiredDuringInsert: false);
  static const VerificationMeta _i4Meta = const VerificationMeta('i4');
  @override
  late final GeneratedColumn<int> i4 = GeneratedColumn<int>(
      'i4', aliasedName, true,
      type: ElectricTypes.int4, requiredDuringInsert: false);
  static const VerificationMeta _i8Meta = const VerificationMeta('i8');
  @override
  late final GeneratedColumn<BigInt> i8 = GeneratedColumn<BigInt>(
      'i8', aliasedName, true,
      type: DriftSqlType.bigInt, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, i2, i4, i8];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ints';
  @override
  VerificationContext validateIntegrity(Insertable<Int> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('i2')) {
      context.handle(_i2Meta, i2.isAcceptableOrUnknown(data['i2']!, _i2Meta));
    }
    if (data.containsKey('i4')) {
      context.handle(_i4Meta, i4.isAcceptableOrUnknown(data['i4']!, _i4Meta));
    }
    if (data.containsKey('i8')) {
      context.handle(_i8Meta, i8.isAcceptableOrUnknown(data['i8']!, _i8Meta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Int map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Int(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      i2: attachedDatabase.typeMapping
          .read(ElectricTypes.int2, data['${effectivePrefix}i2']),
      i4: attachedDatabase.typeMapping
          .read(ElectricTypes.int4, data['${effectivePrefix}i4']),
      i8: attachedDatabase.typeMapping
          .read(DriftSqlType.bigInt, data['${effectivePrefix}i8']),
    );
  }

  @override
  $IntsTable createAlias(String alias) {
    return $IntsTable(attachedDatabase, alias);
  }
}

class Int extends DataClass implements Insertable<Int> {
  final String id;
  final int? i2;
  final int? i4;
  final BigInt? i8;
  const Int({required this.id, this.i2, this.i4, this.i8});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || i2 != null) {
      map['i2'] = Variable<int>(i2, ElectricTypes.int2);
    }
    if (!nullToAbsent || i4 != null) {
      map['i4'] = Variable<int>(i4, ElectricTypes.int4);
    }
    if (!nullToAbsent || i8 != null) {
      map['i8'] = Variable<BigInt>(i8);
    }
    return map;
  }

  IntsCompanion toCompanion(bool nullToAbsent) {
    return IntsCompanion(
      id: Value(id),
      i2: i2 == null && nullToAbsent ? const Value.absent() : Value(i2),
      i4: i4 == null && nullToAbsent ? const Value.absent() : Value(i4),
      i8: i8 == null && nullToAbsent ? const Value.absent() : Value(i8),
    );
  }

  factory Int.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Int(
      id: serializer.fromJson<String>(json['id']),
      i2: serializer.fromJson<int?>(json['i2']),
      i4: serializer.fromJson<int?>(json['i4']),
      i8: serializer.fromJson<BigInt?>(json['i8']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'i2': serializer.toJson<int?>(i2),
      'i4': serializer.toJson<int?>(i4),
      'i8': serializer.toJson<BigInt?>(i8),
    };
  }

  Int copyWith(
          {String? id,
          Value<int?> i2 = const Value.absent(),
          Value<int?> i4 = const Value.absent(),
          Value<BigInt?> i8 = const Value.absent()}) =>
      Int(
        id: id ?? this.id,
        i2: i2.present ? i2.value : this.i2,
        i4: i4.present ? i4.value : this.i4,
        i8: i8.present ? i8.value : this.i8,
      );
  Int copyWithCompanion(IntsCompanion data) {
    return Int(
      id: data.id.present ? data.id.value : this.id,
      i2: data.i2.present ? data.i2.value : this.i2,
      i4: data.i4.present ? data.i4.value : this.i4,
      i8: data.i8.present ? data.i8.value : this.i8,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Int(')
          ..write('id: $id, ')
          ..write('i2: $i2, ')
          ..write('i4: $i4, ')
          ..write('i8: $i8')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, i2, i4, i8);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Int &&
          other.id == this.id &&
          other.i2 == this.i2 &&
          other.i4 == this.i4 &&
          other.i8 == this.i8);
}

class IntsCompanion extends UpdateCompanion<Int> {
  final Value<String> id;
  final Value<int?> i2;
  final Value<int?> i4;
  final Value<BigInt?> i8;
  final Value<int> rowid;
  const IntsCompanion({
    this.id = const Value.absent(),
    this.i2 = const Value.absent(),
    this.i4 = const Value.absent(),
    this.i8 = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IntsCompanion.insert({
    required String id,
    this.i2 = const Value.absent(),
    this.i4 = const Value.absent(),
    this.i8 = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<Int> custom({
    Expression<String>? id,
    Expression<int>? i2,
    Expression<int>? i4,
    Expression<BigInt>? i8,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (i2 != null) 'i2': i2,
      if (i4 != null) 'i4': i4,
      if (i8 != null) 'i8': i8,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IntsCompanion copyWith(
      {Value<String>? id,
      Value<int?>? i2,
      Value<int?>? i4,
      Value<BigInt?>? i8,
      Value<int>? rowid}) {
    return IntsCompanion(
      id: id ?? this.id,
      i2: i2 ?? this.i2,
      i4: i4 ?? this.i4,
      i8: i8 ?? this.i8,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (i2.present) {
      map['i2'] = Variable<int>(i2.value, ElectricTypes.int2);
    }
    if (i4.present) {
      map['i4'] = Variable<int>(i4.value, ElectricTypes.int4);
    }
    if (i8.present) {
      map['i8'] = Variable<BigInt>(i8.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IntsCompanion(')
          ..write('id: $id, ')
          ..write('i2: $i2, ')
          ..write('i4: $i4, ')
          ..write('i8: $i8, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItemsTable extends Items with TableInfo<$ItemsTable, Item> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentTextNullMeta =
      const VerificationMeta('contentTextNull');
  @override
  late final GeneratedColumn<String> contentTextNull = GeneratedColumn<String>(
      'content_text_null', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _contentTextNullDefaultMeta =
      const VerificationMeta('contentTextNullDefault');
  @override
  late final GeneratedColumn<String> contentTextNullDefault =
      GeneratedColumn<String>('content_text_null_default', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _intvalueNullMeta =
      const VerificationMeta('intvalueNull');
  @override
  late final GeneratedColumn<int> intvalueNull = GeneratedColumn<int>(
      'intvalue_null', aliasedName, true,
      type: ElectricTypes.int4, requiredDuringInsert: false);
  static const VerificationMeta _intvalueNullDefaultMeta =
      const VerificationMeta('intvalueNullDefault');
  @override
  late final GeneratedColumn<int> intvalueNullDefault = GeneratedColumn<int>(
      'intvalue_null_default', aliasedName, true,
      type: ElectricTypes.int4, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        content,
        contentTextNull,
        contentTextNullDefault,
        intvalueNull,
        intvalueNullDefault
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'items';
  @override
  VerificationContext validateIntegrity(Insertable<Item> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('content_text_null')) {
      context.handle(
          _contentTextNullMeta,
          contentTextNull.isAcceptableOrUnknown(
              data['content_text_null']!, _contentTextNullMeta));
    }
    if (data.containsKey('content_text_null_default')) {
      context.handle(
          _contentTextNullDefaultMeta,
          contentTextNullDefault.isAcceptableOrUnknown(
              data['content_text_null_default']!, _contentTextNullDefaultMeta));
    }
    if (data.containsKey('intvalue_null')) {
      context.handle(
          _intvalueNullMeta,
          intvalueNull.isAcceptableOrUnknown(
              data['intvalue_null']!, _intvalueNullMeta));
    }
    if (data.containsKey('intvalue_null_default')) {
      context.handle(
          _intvalueNullDefaultMeta,
          intvalueNullDefault.isAcceptableOrUnknown(
              data['intvalue_null_default']!, _intvalueNullDefaultMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Item map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Item(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      contentTextNull: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}content_text_null']),
      contentTextNullDefault: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}content_text_null_default']),
      intvalueNull: attachedDatabase.typeMapping
          .read(ElectricTypes.int4, data['${effectivePrefix}intvalue_null']),
      intvalueNullDefault: attachedDatabase.typeMapping.read(
          ElectricTypes.int4, data['${effectivePrefix}intvalue_null_default']),
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
}

class Item extends DataClass implements Insertable<Item> {
  final String id;
  final String content;
  final String? contentTextNull;
  final String? contentTextNullDefault;
  final int? intvalueNull;
  final int? intvalueNullDefault;
  const Item(
      {required this.id,
      required this.content,
      this.contentTextNull,
      this.contentTextNullDefault,
      this.intvalueNull,
      this.intvalueNullDefault});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || contentTextNull != null) {
      map['content_text_null'] = Variable<String>(contentTextNull);
    }
    if (!nullToAbsent || contentTextNullDefault != null) {
      map['content_text_null_default'] =
          Variable<String>(contentTextNullDefault);
    }
    if (!nullToAbsent || intvalueNull != null) {
      map['intvalue_null'] = Variable<int>(intvalueNull, ElectricTypes.int4);
    }
    if (!nullToAbsent || intvalueNullDefault != null) {
      map['intvalue_null_default'] =
          Variable<int>(intvalueNullDefault, ElectricTypes.int4);
    }
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      id: Value(id),
      content: Value(content),
      contentTextNull: contentTextNull == null && nullToAbsent
          ? const Value.absent()
          : Value(contentTextNull),
      contentTextNullDefault: contentTextNullDefault == null && nullToAbsent
          ? const Value.absent()
          : Value(contentTextNullDefault),
      intvalueNull: intvalueNull == null && nullToAbsent
          ? const Value.absent()
          : Value(intvalueNull),
      intvalueNullDefault: intvalueNullDefault == null && nullToAbsent
          ? const Value.absent()
          : Value(intvalueNullDefault),
    );
  }

  factory Item.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Item(
      id: serializer.fromJson<String>(json['id']),
      content: serializer.fromJson<String>(json['content']),
      contentTextNull: serializer.fromJson<String?>(json['contentTextNull']),
      contentTextNullDefault:
          serializer.fromJson<String?>(json['contentTextNullDefault']),
      intvalueNull: serializer.fromJson<int?>(json['intvalueNull']),
      intvalueNullDefault:
          serializer.fromJson<int?>(json['intvalueNullDefault']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'content': serializer.toJson<String>(content),
      'contentTextNull': serializer.toJson<String?>(contentTextNull),
      'contentTextNullDefault':
          serializer.toJson<String?>(contentTextNullDefault),
      'intvalueNull': serializer.toJson<int?>(intvalueNull),
      'intvalueNullDefault': serializer.toJson<int?>(intvalueNullDefault),
    };
  }

  Item copyWith(
          {String? id,
          String? content,
          Value<String?> contentTextNull = const Value.absent(),
          Value<String?> contentTextNullDefault = const Value.absent(),
          Value<int?> intvalueNull = const Value.absent(),
          Value<int?> intvalueNullDefault = const Value.absent()}) =>
      Item(
        id: id ?? this.id,
        content: content ?? this.content,
        contentTextNull: contentTextNull.present
            ? contentTextNull.value
            : this.contentTextNull,
        contentTextNullDefault: contentTextNullDefault.present
            ? contentTextNullDefault.value
            : this.contentTextNullDefault,
        intvalueNull:
            intvalueNull.present ? intvalueNull.value : this.intvalueNull,
        intvalueNullDefault: intvalueNullDefault.present
            ? intvalueNullDefault.value
            : this.intvalueNullDefault,
      );
  Item copyWithCompanion(ItemsCompanion data) {
    return Item(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
      contentTextNull: data.contentTextNull.present
          ? data.contentTextNull.value
          : this.contentTextNull,
      contentTextNullDefault: data.contentTextNullDefault.present
          ? data.contentTextNullDefault.value
          : this.contentTextNullDefault,
      intvalueNull: data.intvalueNull.present
          ? data.intvalueNull.value
          : this.intvalueNull,
      intvalueNullDefault: data.intvalueNullDefault.present
          ? data.intvalueNullDefault.value
          : this.intvalueNullDefault,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Item(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('contentTextNull: $contentTextNull, ')
          ..write('contentTextNullDefault: $contentTextNullDefault, ')
          ..write('intvalueNull: $intvalueNull, ')
          ..write('intvalueNullDefault: $intvalueNullDefault')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, content, contentTextNull,
      contentTextNullDefault, intvalueNull, intvalueNullDefault);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Item &&
          other.id == this.id &&
          other.content == this.content &&
          other.contentTextNull == this.contentTextNull &&
          other.contentTextNullDefault == this.contentTextNullDefault &&
          other.intvalueNull == this.intvalueNull &&
          other.intvalueNullDefault == this.intvalueNullDefault);
}

class ItemsCompanion extends UpdateCompanion<Item> {
  final Value<String> id;
  final Value<String> content;
  final Value<String?> contentTextNull;
  final Value<String?> contentTextNullDefault;
  final Value<int?> intvalueNull;
  final Value<int?> intvalueNullDefault;
  final Value<int> rowid;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.contentTextNull = const Value.absent(),
    this.contentTextNullDefault = const Value.absent(),
    this.intvalueNull = const Value.absent(),
    this.intvalueNullDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsCompanion.insert({
    required String id,
    required String content,
    this.contentTextNull = const Value.absent(),
    this.contentTextNullDefault = const Value.absent(),
    this.intvalueNull = const Value.absent(),
    this.intvalueNullDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        content = Value(content);
  static Insertable<Item> custom({
    Expression<String>? id,
    Expression<String>? content,
    Expression<String>? contentTextNull,
    Expression<String>? contentTextNullDefault,
    Expression<int>? intvalueNull,
    Expression<int>? intvalueNullDefault,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (contentTextNull != null) 'content_text_null': contentTextNull,
      if (contentTextNullDefault != null)
        'content_text_null_default': contentTextNullDefault,
      if (intvalueNull != null) 'intvalue_null': intvalueNull,
      if (intvalueNullDefault != null)
        'intvalue_null_default': intvalueNullDefault,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? content,
      Value<String?>? contentTextNull,
      Value<String?>? contentTextNullDefault,
      Value<int?>? intvalueNull,
      Value<int?>? intvalueNullDefault,
      Value<int>? rowid}) {
    return ItemsCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      contentTextNull: contentTextNull ?? this.contentTextNull,
      contentTextNullDefault:
          contentTextNullDefault ?? this.contentTextNullDefault,
      intvalueNull: intvalueNull ?? this.intvalueNull,
      intvalueNullDefault: intvalueNullDefault ?? this.intvalueNullDefault,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (contentTextNull.present) {
      map['content_text_null'] = Variable<String>(contentTextNull.value);
    }
    if (contentTextNullDefault.present) {
      map['content_text_null_default'] =
          Variable<String>(contentTextNullDefault.value);
    }
    if (intvalueNull.present) {
      map['intvalue_null'] =
          Variable<int>(intvalueNull.value, ElectricTypes.int4);
    }
    if (intvalueNullDefault.present) {
      map['intvalue_null_default'] =
          Variable<int>(intvalueNullDefault.value, ElectricTypes.int4);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('contentTextNull: $contentTextNull, ')
          ..write('contentTextNullDefault: $contentTextNullDefault, ')
          ..write('intvalueNull: $intvalueNull, ')
          ..write('intvalueNullDefault: $intvalueNullDefault, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $JsonsTable extends Jsons with TableInfo<$JsonsTable, Json> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $JsonsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _jsbMeta = const VerificationMeta('jsb');
  @override
  late final GeneratedColumn<Object> jsb = GeneratedColumn<Object>(
      'jsb', aliasedName, true,
      type: ElectricTypes.jsonb, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, jsb];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'jsons';
  @override
  VerificationContext validateIntegrity(Insertable<Json> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('jsb')) {
      context.handle(
          _jsbMeta, jsb.isAcceptableOrUnknown(data['jsb']!, _jsbMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Json map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Json(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      jsb: attachedDatabase.typeMapping
          .read(ElectricTypes.jsonb, data['${effectivePrefix}jsb']),
    );
  }

  @override
  $JsonsTable createAlias(String alias) {
    return $JsonsTable(attachedDatabase, alias);
  }
}

class Json extends DataClass implements Insertable<Json> {
  final String id;
  final Object? jsb;
  const Json({required this.id, this.jsb});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || jsb != null) {
      map['jsb'] = Variable<Object>(jsb, ElectricTypes.jsonb);
    }
    return map;
  }

  JsonsCompanion toCompanion(bool nullToAbsent) {
    return JsonsCompanion(
      id: Value(id),
      jsb: jsb == null && nullToAbsent ? const Value.absent() : Value(jsb),
    );
  }

  factory Json.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Json(
      id: serializer.fromJson<String>(json['id']),
      jsb: serializer.fromJson<Object?>(json['jsb']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'jsb': serializer.toJson<Object?>(jsb),
    };
  }

  Json copyWith({String? id, Value<Object?> jsb = const Value.absent()}) =>
      Json(
        id: id ?? this.id,
        jsb: jsb.present ? jsb.value : this.jsb,
      );
  Json copyWithCompanion(JsonsCompanion data) {
    return Json(
      id: data.id.present ? data.id.value : this.id,
      jsb: data.jsb.present ? data.jsb.value : this.jsb,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Json(')
          ..write('id: $id, ')
          ..write('jsb: $jsb')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, jsb);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Json && other.id == this.id && other.jsb == this.jsb);
}

class JsonsCompanion extends UpdateCompanion<Json> {
  final Value<String> id;
  final Value<Object?> jsb;
  final Value<int> rowid;
  const JsonsCompanion({
    this.id = const Value.absent(),
    this.jsb = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  JsonsCompanion.insert({
    required String id,
    this.jsb = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<Json> custom({
    Expression<String>? id,
    Expression<Object>? jsb,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jsb != null) 'jsb': jsb,
      if (rowid != null) 'rowid': rowid,
    });
  }

  JsonsCompanion copyWith(
      {Value<String>? id, Value<Object?>? jsb, Value<int>? rowid}) {
    return JsonsCompanion(
      id: id ?? this.id,
      jsb: jsb ?? this.jsb,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (jsb.present) {
      map['jsb'] = Variable<Object>(jsb.value, ElectricTypes.jsonb);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JsonsCompanion(')
          ..write('id: $id, ')
          ..write('jsb: $jsb, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OtherItemsTable extends OtherItems
    with TableInfo<$OtherItemsTable, OtherItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OtherItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<String> itemId = GeneratedColumn<String>(
      'item_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, content, itemId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'other_items';
  @override
  VerificationContext validateIntegrity(Insertable<OtherItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(_itemIdMeta,
          itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OtherItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OtherItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      itemId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}item_id']),
    );
  }

  @override
  $OtherItemsTable createAlias(String alias) {
    return $OtherItemsTable(attachedDatabase, alias);
  }
}

class OtherItem extends DataClass implements Insertable<OtherItem> {
  final String id;
  final String content;
  final String? itemId;
  const OtherItem({required this.id, required this.content, this.itemId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || itemId != null) {
      map['item_id'] = Variable<String>(itemId);
    }
    return map;
  }

  OtherItemsCompanion toCompanion(bool nullToAbsent) {
    return OtherItemsCompanion(
      id: Value(id),
      content: Value(content),
      itemId:
          itemId == null && nullToAbsent ? const Value.absent() : Value(itemId),
    );
  }

  factory OtherItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OtherItem(
      id: serializer.fromJson<String>(json['id']),
      content: serializer.fromJson<String>(json['content']),
      itemId: serializer.fromJson<String?>(json['itemId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'content': serializer.toJson<String>(content),
      'itemId': serializer.toJson<String?>(itemId),
    };
  }

  OtherItem copyWith(
          {String? id,
          String? content,
          Value<String?> itemId = const Value.absent()}) =>
      OtherItem(
        id: id ?? this.id,
        content: content ?? this.content,
        itemId: itemId.present ? itemId.value : this.itemId,
      );
  OtherItem copyWithCompanion(OtherItemsCompanion data) {
    return OtherItem(
      id: data.id.present ? data.id.value : this.id,
      content: data.content.present ? data.content.value : this.content,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OtherItem(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('itemId: $itemId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, content, itemId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OtherItem &&
          other.id == this.id &&
          other.content == this.content &&
          other.itemId == this.itemId);
}

class OtherItemsCompanion extends UpdateCompanion<OtherItem> {
  final Value<String> id;
  final Value<String> content;
  final Value<String?> itemId;
  final Value<int> rowid;
  const OtherItemsCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.itemId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OtherItemsCompanion.insert({
    required String id,
    required String content,
    this.itemId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        content = Value(content);
  static Insertable<OtherItem> custom({
    Expression<String>? id,
    Expression<String>? content,
    Expression<String>? itemId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (itemId != null) 'item_id': itemId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OtherItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? content,
      Value<String?>? itemId,
      Value<int>? rowid}) {
    return OtherItemsCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      itemId: itemId ?? this.itemId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<String>(itemId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OtherItemsCompanion(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('itemId: $itemId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TimestampsTable extends Timestamps
    with TableInfo<$TimestampsTable, Timestamp> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimestampsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: ElectricTypes.timestamp, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: ElectricTypes.timestampTZ, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timestamps';
  @override
  VerificationContext validateIntegrity(Insertable<Timestamp> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Timestamp map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Timestamp(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(ElectricTypes.timestamp, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping.read(
          ElectricTypes.timestampTZ, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $TimestampsTable createAlias(String alias) {
    return $TimestampsTable(attachedDatabase, alias);
  }
}

class Timestamp extends DataClass implements Insertable<Timestamp> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Timestamp(
      {required this.id, required this.createdAt, required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt, ElectricTypes.timestamp);
    map['updated_at'] =
        Variable<DateTime>(updatedAt, ElectricTypes.timestampTZ);
    return map;
  }

  TimestampsCompanion toCompanion(bool nullToAbsent) {
    return TimestampsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Timestamp.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Timestamp(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Timestamp copyWith({String? id, DateTime? createdAt, DateTime? updatedAt}) =>
      Timestamp(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Timestamp copyWithCompanion(TimestampsCompanion data) {
    return Timestamp(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Timestamp(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Timestamp &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TimestampsCompanion extends UpdateCompanion<Timestamp> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TimestampsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TimestampsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Timestamp> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TimestampsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return TimestampsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] =
          Variable<DateTime>(createdAt.value, ElectricTypes.timestamp);
    }
    if (updatedAt.present) {
      map['updated_at'] =
          Variable<DateTime>(updatedAt.value, ElectricTypes.timestampTZ);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimestampsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UuidsTable extends Uuids with TableInfo<$UuidsTable, Uuid> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UuidsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: ElectricTypes.uuid, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'uuids';
  @override
  VerificationContext validateIntegrity(Insertable<Uuid> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Uuid map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Uuid(
      id: attachedDatabase.typeMapping
          .read(ElectricTypes.uuid, data['${effectivePrefix}id'])!,
    );
  }

  @override
  $UuidsTable createAlias(String alias) {
    return $UuidsTable(attachedDatabase, alias);
  }
}

class Uuid extends DataClass implements Insertable<Uuid> {
  final String id;
  const Uuid({required this.id});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id, ElectricTypes.uuid);
    return map;
  }

  UuidsCompanion toCompanion(bool nullToAbsent) {
    return UuidsCompanion(
      id: Value(id),
    );
  }

  factory Uuid.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Uuid(
      id: serializer.fromJson<String>(json['id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
    };
  }

  Uuid copyWith({String? id}) => Uuid(
        id: id ?? this.id,
      );
  Uuid copyWithCompanion(UuidsCompanion data) {
    return Uuid(
      id: data.id.present ? data.id.value : this.id,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Uuid(')
          ..write('id: $id')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => id.hashCode;
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Uuid && other.id == this.id);
}

class UuidsCompanion extends UpdateCompanion<Uuid> {
  final Value<String> id;
  final Value<int> rowid;
  const UuidsCompanion({
    this.id = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UuidsCompanion.insert({
    required String id,
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<Uuid> custom({
    Expression<String>? id,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UuidsCompanion copyWith({Value<String>? id, Value<int>? rowid}) {
    return UuidsCompanion(
      id: id ?? this.id,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value, ElectricTypes.uuid);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UuidsCompanion(')
          ..write('id: $id, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ClientDatabase extends GeneratedDatabase {
  _$ClientDatabase(QueryExecutor e) : super(e);
  $ClientDatabaseManager get managers => $ClientDatabaseManager(this);
  late final $BlobsTable blobs = $BlobsTable(this);
  late final $BoolsTable bools = $BoolsTable(this);
  late final $DatetimesTable datetimes = $DatetimesTable(this);
  late final $EnumsTable enums = $EnumsTable(this);
  late final $FloatsTable floats = $FloatsTable(this);
  late final $IntsTable ints = $IntsTable(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $JsonsTable jsons = $JsonsTable(this);
  late final $OtherItemsTable otherItems = $OtherItemsTable(this);
  late final $TimestampsTable timestamps = $TimestampsTable(this);
  late final $UuidsTable uuids = $UuidsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        blobs,
        bools,
        datetimes,
        enums,
        floats,
        ints,
        items,
        jsons,
        otherItems,
        timestamps,
        uuids
      ];
}

typedef $$BlobsTableCreateCompanionBuilder = BlobsCompanion Function({
  required String id,
  Value<Uint8List?> blob$,
  Value<int> rowid,
});
typedef $$BlobsTableUpdateCompanionBuilder = BlobsCompanion Function({
  Value<String> id,
  Value<Uint8List?> blob$,
  Value<int> rowid,
});

class $$BlobsTableTableManager extends RootTableManager<
    _$ClientDatabase,
    $BlobsTable,
    Blob,
    $$BlobsTableFilterComposer,
    $$BlobsTableOrderingComposer,
    $$BlobsTableCreateCompanionBuilder,
    $$BlobsTableUpdateCompanionBuilder> {
  $$BlobsTableTableManager(_$ClientDatabase db, $BlobsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$BlobsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$BlobsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<Uint8List?> blob$ = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BlobsCompanion(
            id: id,
            blob$: blob$,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<Uint8List?> blob$ = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BlobsCompanion.insert(
            id: id,
            blob$: blob$,
            rowid: rowid,
          ),
        ));
}

class $$BlobsTableFilterComposer
    extends FilterComposer<_$ClientDatabase, $BlobsTable> {
  $$BlobsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<Uint8List> get blob$ => $state.composableBuilder(
      column: $state.table.blob$,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$BlobsTableOrderingComposer
    extends OrderingComposer<_$ClientDatabase, $BlobsTable> {
  $$BlobsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<Uint8List> get blob$ => $state.composableBuilder(
      column: $state.table.blob$,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$BoolsTableCreateCompanionBuilder = BoolsCompanion Function({
  required String id,
  Value<bool?> b,
  Value<int> rowid,
});
typedef $$BoolsTableUpdateCompanionBuilder = BoolsCompanion Function({
  Value<String> id,
  Value<bool?> b,
  Value<int> rowid,
});

class $$BoolsTableTableManager extends RootTableManager<
    _$ClientDatabase,
    $BoolsTable,
    Bool,
    $$BoolsTableFilterComposer,
    $$BoolsTableOrderingComposer,
    $$BoolsTableCreateCompanionBuilder,
    $$BoolsTableUpdateCompanionBuilder> {
  $$BoolsTableTableManager(_$ClientDatabase db, $BoolsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$BoolsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$BoolsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<bool?> b = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BoolsCompanion(
            id: id,
            b: b,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<bool?> b = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BoolsCompanion.insert(
            id: id,
            b: b,
            rowid: rowid,
          ),
        ));
}

class $$BoolsTableFilterComposer
    extends FilterComposer<_$ClientDatabase, $BoolsTable> {
  $$BoolsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get b => $state.composableBuilder(
      column: $state.table.b,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$BoolsTableOrderingComposer
    extends OrderingComposer<_$ClientDatabase, $BoolsTable> {
  $$BoolsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get b => $state.composableBuilder(
      column: $state.table.b,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$DatetimesTableCreateCompanionBuilder = DatetimesCompanion Function({
  required String id,
  required DateTime d,
  required DateTime t,
  Value<int> rowid,
});
typedef $$DatetimesTableUpdateCompanionBuilder = DatetimesCompanion Function({
  Value<String> id,
  Value<DateTime> d,
  Value<DateTime> t,
  Value<int> rowid,
});

class $$DatetimesTableTableManager extends RootTableManager<
    _$ClientDatabase,
    $DatetimesTable,
    Datetime,
    $$DatetimesTableFilterComposer,
    $$DatetimesTableOrderingComposer,
    $$DatetimesTableCreateCompanionBuilder,
    $$DatetimesTableUpdateCompanionBuilder> {
  $$DatetimesTableTableManager(_$ClientDatabase db, $DatetimesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$DatetimesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$DatetimesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> d = const Value.absent(),
            Value<DateTime> t = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DatetimesCompanion(
            id: id,
            d: d,
            t: t,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime d,
            required DateTime t,
            Value<int> rowid = const Value.absent(),
          }) =>
              DatetimesCompanion.insert(
            id: id,
            d: d,
            t: t,
            rowid: rowid,
          ),
        ));
}

class $$DatetimesTableFilterComposer
    extends FilterComposer<_$ClientDatabase, $DatetimesTable> {
  $$DatetimesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get d => $state.composableBuilder(
      column: $state.table.d,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get t => $state.composableBuilder(
      column: $state.table.t,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$DatetimesTableOrderingComposer
    extends OrderingComposer<_$ClientDatabase, $DatetimesTable> {
  $$DatetimesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get d => $state.composableBuilder(
      column: $state.table.d,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get t => $state.composableBuilder(
      column: $state.table.t,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$EnumsTableCreateCompanionBuilder = EnumsCompanion Function({
  required String id,
  Value<DbColor?> c,
  Value<int> rowid,
});
typedef $$EnumsTableUpdateCompanionBuilder = EnumsCompanion Function({
  Value<String> id,
  Value<DbColor?> c,
  Value<int> rowid,
});

class $$EnumsTableTableManager extends RootTableManager<
    _$ClientDatabase,
    $EnumsTable,
    Enum,
    $$EnumsTableFilterComposer,
    $$EnumsTableOrderingComposer,
    $$EnumsTableCreateCompanionBuilder,
    $$EnumsTableUpdateCompanionBuilder> {
  $$EnumsTableTableManager(_$ClientDatabase db, $EnumsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$EnumsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$EnumsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DbColor?> c = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EnumsCompanion(
            id: id,
            c: c,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<DbColor?> c = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              EnumsCompanion.insert(
            id: id,
            c: c,
            rowid: rowid,
          ),
        ));
}

class $$EnumsTableFilterComposer
    extends FilterComposer<_$ClientDatabase, $EnumsTable> {
  $$EnumsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DbColor> get c => $state.composableBuilder(
      column: $state.table.c,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$EnumsTableOrderingComposer
    extends OrderingComposer<_$ClientDatabase, $EnumsTable> {
  $$EnumsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DbColor> get c => $state.composableBuilder(
      column: $state.table.c,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$FloatsTableCreateCompanionBuilder = FloatsCompanion Function({
  required String id,
  Value<double?> f4,
  Value<double?> f8,
  Value<int> rowid,
});
typedef $$FloatsTableUpdateCompanionBuilder = FloatsCompanion Function({
  Value<String> id,
  Value<double?> f4,
  Value<double?> f8,
  Value<int> rowid,
});

class $$FloatsTableTableManager extends RootTableManager<
    _$ClientDatabase,
    $FloatsTable,
    Float,
    $$FloatsTableFilterComposer,
    $$FloatsTableOrderingComposer,
    $$FloatsTableCreateCompanionBuilder,
    $$FloatsTableUpdateCompanionBuilder> {
  $$FloatsTableTableManager(_$ClientDatabase db, $FloatsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$FloatsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$FloatsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<double?> f4 = const Value.absent(),
            Value<double?> f8 = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FloatsCompanion(
            id: id,
            f4: f4,
            f8: f8,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<double?> f4 = const Value.absent(),
            Value<double?> f8 = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FloatsCompanion.insert(
            id: id,
            f4: f4,
            f8: f8,
            rowid: rowid,
          ),
        ));
}

class $$FloatsTableFilterComposer
    extends FilterComposer<_$ClientDatabase, $FloatsTable> {
  $$FloatsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get f4 => $state.composableBuilder(
      column: $state.table.f4,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<double> get f8 => $state.composableBuilder(
      column: $state.table.f8,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$FloatsTableOrderingComposer
    extends OrderingComposer<_$ClientDatabase, $FloatsTable> {
  $$FloatsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get f4 => $state.composableBuilder(
      column: $state.table.f4,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<double> get f8 => $state.composableBuilder(
      column: $state.table.f8,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$IntsTableCreateCompanionBuilder = IntsCompanion Function({
  required String id,
  Value<int?> i2,
  Value<int?> i4,
  Value<BigInt?> i8,
  Value<int> rowid,
});
typedef $$IntsTableUpdateCompanionBuilder = IntsCompanion Function({
  Value<String> id,
  Value<int?> i2,
  Value<int?> i4,
  Value<BigInt?> i8,
  Value<int> rowid,
});

class $$IntsTableTableManager extends RootTableManager<
    _$ClientDatabase,
    $IntsTable,
    Int,
    $$IntsTableFilterComposer,
    $$IntsTableOrderingComposer,
    $$IntsTableCreateCompanionBuilder,
    $$IntsTableUpdateCompanionBuilder> {
  $$IntsTableTableManager(_$ClientDatabase db, $IntsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$IntsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$IntsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int?> i2 = const Value.absent(),
            Value<int?> i4 = const Value.absent(),
            Value<BigInt?> i8 = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              IntsCompanion(
            id: id,
            i2: i2,
            i4: i4,
            i8: i8,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<int?> i2 = const Value.absent(),
            Value<int?> i4 = const Value.absent(),
            Value<BigInt?> i8 = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              IntsCompanion.insert(
            id: id,
            i2: i2,
            i4: i4,
            i8: i8,
            rowid: rowid,
          ),
        ));
}

class $$IntsTableFilterComposer
    extends FilterComposer<_$ClientDatabase, $IntsTable> {
  $$IntsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get i2 => $state.composableBuilder(
      column: $state.table.i2,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get i4 => $state.composableBuilder(
      column: $state.table.i4,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<BigInt> get i8 => $state.composableBuilder(
      column: $state.table.i8,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$IntsTableOrderingComposer
    extends OrderingComposer<_$ClientDatabase, $IntsTable> {
  $$IntsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get i2 => $state.composableBuilder(
      column: $state.table.i2,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get i4 => $state.composableBuilder(
      column: $state.table.i4,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<BigInt> get i8 => $state.composableBuilder(
      column: $state.table.i8,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$ItemsTableCreateCompanionBuilder = ItemsCompanion Function({
  required String id,
  required String content,
  Value<String?> contentTextNull,
  Value<String?> contentTextNullDefault,
  Value<int?> intvalueNull,
  Value<int?> intvalueNullDefault,
  Value<int> rowid,
});
typedef $$ItemsTableUpdateCompanionBuilder = ItemsCompanion Function({
  Value<String> id,
  Value<String> content,
  Value<String?> contentTextNull,
  Value<String?> contentTextNullDefault,
  Value<int?> intvalueNull,
  Value<int?> intvalueNullDefault,
  Value<int> rowid,
});

class $$ItemsTableTableManager extends RootTableManager<
    _$ClientDatabase,
    $ItemsTable,
    Item,
    $$ItemsTableFilterComposer,
    $$ItemsTableOrderingComposer,
    $$ItemsTableCreateCompanionBuilder,
    $$ItemsTableUpdateCompanionBuilder> {
  $$ItemsTableTableManager(_$ClientDatabase db, $ItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$ItemsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$ItemsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String?> contentTextNull = const Value.absent(),
            Value<String?> contentTextNullDefault = const Value.absent(),
            Value<int?> intvalueNull = const Value.absent(),
            Value<int?> intvalueNullDefault = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemsCompanion(
            id: id,
            content: content,
            contentTextNull: contentTextNull,
            contentTextNullDefault: contentTextNullDefault,
            intvalueNull: intvalueNull,
            intvalueNullDefault: intvalueNullDefault,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String content,
            Value<String?> contentTextNull = const Value.absent(),
            Value<String?> contentTextNullDefault = const Value.absent(),
            Value<int?> intvalueNull = const Value.absent(),
            Value<int?> intvalueNullDefault = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ItemsCompanion.insert(
            id: id,
            content: content,
            contentTextNull: contentTextNull,
            contentTextNullDefault: contentTextNullDefault,
            intvalueNull: intvalueNull,
            intvalueNullDefault: intvalueNullDefault,
            rowid: rowid,
          ),
        ));
}

class $$ItemsTableFilterComposer
    extends FilterComposer<_$ClientDatabase, $ItemsTable> {
  $$ItemsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get contentTextNull => $state.composableBuilder(
      column: $state.table.contentTextNull,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get contentTextNullDefault => $state.composableBuilder(
      column: $state.table.contentTextNullDefault,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get intvalueNull => $state.composableBuilder(
      column: $state.table.intvalueNull,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get intvalueNullDefault => $state.composableBuilder(
      column: $state.table.intvalueNullDefault,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$ItemsTableOrderingComposer
    extends OrderingComposer<_$ClientDatabase, $ItemsTable> {
  $$ItemsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get contentTextNull => $state.composableBuilder(
      column: $state.table.contentTextNull,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get contentTextNullDefault =>
      $state.composableBuilder(
          column: $state.table.contentTextNullDefault,
          builder: (column, joinBuilders) =>
              ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get intvalueNull => $state.composableBuilder(
      column: $state.table.intvalueNull,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get intvalueNullDefault => $state.composableBuilder(
      column: $state.table.intvalueNullDefault,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$JsonsTableCreateCompanionBuilder = JsonsCompanion Function({
  required String id,
  Value<Object?> jsb,
  Value<int> rowid,
});
typedef $$JsonsTableUpdateCompanionBuilder = JsonsCompanion Function({
  Value<String> id,
  Value<Object?> jsb,
  Value<int> rowid,
});

class $$JsonsTableTableManager extends RootTableManager<
    _$ClientDatabase,
    $JsonsTable,
    Json,
    $$JsonsTableFilterComposer,
    $$JsonsTableOrderingComposer,
    $$JsonsTableCreateCompanionBuilder,
    $$JsonsTableUpdateCompanionBuilder> {
  $$JsonsTableTableManager(_$ClientDatabase db, $JsonsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$JsonsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$JsonsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<Object?> jsb = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              JsonsCompanion(
            id: id,
            jsb: jsb,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<Object?> jsb = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              JsonsCompanion.insert(
            id: id,
            jsb: jsb,
            rowid: rowid,
          ),
        ));
}

class $$JsonsTableFilterComposer
    extends FilterComposer<_$ClientDatabase, $JsonsTable> {
  $$JsonsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<Object> get jsb => $state.composableBuilder(
      column: $state.table.jsb,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$JsonsTableOrderingComposer
    extends OrderingComposer<_$ClientDatabase, $JsonsTable> {
  $$JsonsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<Object> get jsb => $state.composableBuilder(
      column: $state.table.jsb,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$OtherItemsTableCreateCompanionBuilder = OtherItemsCompanion Function({
  required String id,
  required String content,
  Value<String?> itemId,
  Value<int> rowid,
});
typedef $$OtherItemsTableUpdateCompanionBuilder = OtherItemsCompanion Function({
  Value<String> id,
  Value<String> content,
  Value<String?> itemId,
  Value<int> rowid,
});

class $$OtherItemsTableTableManager extends RootTableManager<
    _$ClientDatabase,
    $OtherItemsTable,
    OtherItem,
    $$OtherItemsTableFilterComposer,
    $$OtherItemsTableOrderingComposer,
    $$OtherItemsTableCreateCompanionBuilder,
    $$OtherItemsTableUpdateCompanionBuilder> {
  $$OtherItemsTableTableManager(_$ClientDatabase db, $OtherItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$OtherItemsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$OtherItemsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String?> itemId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OtherItemsCompanion(
            id: id,
            content: content,
            itemId: itemId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String content,
            Value<String?> itemId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OtherItemsCompanion.insert(
            id: id,
            content: content,
            itemId: itemId,
            rowid: rowid,
          ),
        ));
}

class $$OtherItemsTableFilterComposer
    extends FilterComposer<_$ClientDatabase, $OtherItemsTable> {
  $$OtherItemsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get itemId => $state.composableBuilder(
      column: $state.table.itemId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$OtherItemsTableOrderingComposer
    extends OrderingComposer<_$ClientDatabase, $OtherItemsTable> {
  $$OtherItemsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get content => $state.composableBuilder(
      column: $state.table.content,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get itemId => $state.composableBuilder(
      column: $state.table.itemId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$TimestampsTableCreateCompanionBuilder = TimestampsCompanion Function({
  required String id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$TimestampsTableUpdateCompanionBuilder = TimestampsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$TimestampsTableTableManager extends RootTableManager<
    _$ClientDatabase,
    $TimestampsTable,
    Timestamp,
    $$TimestampsTableFilterComposer,
    $$TimestampsTableOrderingComposer,
    $$TimestampsTableCreateCompanionBuilder,
    $$TimestampsTableUpdateCompanionBuilder> {
  $$TimestampsTableTableManager(_$ClientDatabase db, $TimestampsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TimestampsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$TimestampsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TimestampsCompanion(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              TimestampsCompanion.insert(
            id: id,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
        ));
}

class $$TimestampsTableFilterComposer
    extends FilterComposer<_$ClientDatabase, $TimestampsTable> {
  $$TimestampsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$TimestampsTableOrderingComposer
    extends OrderingComposer<_$ClientDatabase, $TimestampsTable> {
  $$TimestampsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get updatedAt => $state.composableBuilder(
      column: $state.table.updatedAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$UuidsTableCreateCompanionBuilder = UuidsCompanion Function({
  required String id,
  Value<int> rowid,
});
typedef $$UuidsTableUpdateCompanionBuilder = UuidsCompanion Function({
  Value<String> id,
  Value<int> rowid,
});

class $$UuidsTableTableManager extends RootTableManager<
    _$ClientDatabase,
    $UuidsTable,
    Uuid,
    $$UuidsTableFilterComposer,
    $$UuidsTableOrderingComposer,
    $$UuidsTableCreateCompanionBuilder,
    $$UuidsTableUpdateCompanionBuilder> {
  $$UuidsTableTableManager(_$ClientDatabase db, $UuidsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$UuidsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$UuidsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UuidsCompanion(
            id: id,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<int> rowid = const Value.absent(),
          }) =>
              UuidsCompanion.insert(
            id: id,
            rowid: rowid,
          ),
        ));
}

class $$UuidsTableFilterComposer
    extends FilterComposer<_$ClientDatabase, $UuidsTable> {
  $$UuidsTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$UuidsTableOrderingComposer
    extends OrderingComposer<_$ClientDatabase, $UuidsTable> {
  $$UuidsTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $ClientDatabaseManager {
  final _$ClientDatabase _db;
  $ClientDatabaseManager(this._db);
  $$BlobsTableTableManager get blobs =>
      $$BlobsTableTableManager(_db, _db.blobs);
  $$BoolsTableTableManager get bools =>
      $$BoolsTableTableManager(_db, _db.bools);
  $$DatetimesTableTableManager get datetimes =>
      $$DatetimesTableTableManager(_db, _db.datetimes);
  $$EnumsTableTableManager get enums =>
      $$EnumsTableTableManager(_db, _db.enums);
  $$FloatsTableTableManager get floats =>
      $$FloatsTableTableManager(_db, _db.floats);
  $$IntsTableTableManager get ints => $$IntsTableTableManager(_db, _db.ints);
  $$ItemsTableTableManager get items =>
      $$ItemsTableTableManager(_db, _db.items);
  $$JsonsTableTableManager get jsons =>
      $$JsonsTableTableManager(_db, _db.jsons);
  $$OtherItemsTableTableManager get otherItems =>
      $$OtherItemsTableTableManager(_db, _db.otherItems);
  $$TimestampsTableTableManager get timestamps =>
      $$TimestampsTableTableManager(_db, _db.timestamps);
  $$UuidsTableTableManager get uuids =>
      $$UuidsTableTableManager(_db, _db.uuids);
}
