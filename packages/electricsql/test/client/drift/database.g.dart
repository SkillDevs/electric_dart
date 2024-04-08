// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class TableFromDriftFile extends Table
    with TableInfo<TableFromDriftFile, TableFromDriftFileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  TableFromDriftFile(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL PRIMARY KEY');
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: ElectricTypes.timestampTZ,
      requiredDuringInsert: true,
      $customConstraints: 'NOT NULL');
  @override
  List<GeneratedColumn> get $columns => [id, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'table_from_drift_file';
  @override
  VerificationContext validateIntegrity(
      Insertable<TableFromDriftFileData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TableFromDriftFileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TableFromDriftFileData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      timestamp: attachedDatabase.typeMapping.read(
          ElectricTypes.timestampTZ, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  TableFromDriftFile createAlias(String alias) {
    return TableFromDriftFile(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class TableFromDriftFileData extends DataClass
    implements Insertable<TableFromDriftFileData> {
  final String id;
  final DateTime timestamp;
  const TableFromDriftFileData({required this.id, required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['timestamp'] = Variable<DateTime>(timestamp, ElectricTypes.timestampTZ);
    return map;
  }

  TableFromDriftFileCompanion toCompanion(bool nullToAbsent) {
    return TableFromDriftFileCompanion(
      id: Value(id),
      timestamp: Value(timestamp),
    );
  }

  factory TableFromDriftFileData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TableFromDriftFileData(
      id: serializer.fromJson<String>(json['id']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  TableFromDriftFileData copyWith({String? id, DateTime? timestamp}) =>
      TableFromDriftFileData(
        id: id ?? this.id,
        timestamp: timestamp ?? this.timestamp,
      );
  @override
  String toString() {
    return (StringBuffer('TableFromDriftFileData(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TableFromDriftFileData &&
          other.id == this.id &&
          other.timestamp == this.timestamp);
}

class TableFromDriftFileCompanion
    extends UpdateCompanion<TableFromDriftFileData> {
  final Value<String> id;
  final Value<DateTime> timestamp;
  final Value<int> rowid;
  const TableFromDriftFileCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TableFromDriftFileCompanion.insert({
    required String id,
    required DateTime timestamp,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        timestamp = Value(timestamp);
  static Insertable<TableFromDriftFileData> custom({
    Expression<String>? id,
    Expression<DateTime>? timestamp,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TableFromDriftFileCompanion copyWith(
      {Value<String>? id, Value<DateTime>? timestamp, Value<int>? rowid}) {
    return TableFromDriftFileCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (timestamp.present) {
      map['timestamp'] =
          Variable<DateTime>(timestamp.value, ElectricTypes.timestampTZ);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TableFromDriftFileCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp, ')
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
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nbrMeta = const VerificationMeta('nbr');
  @override
  late final GeneratedColumn<int> nbr = GeneratedColumn<int>(
      'nbr', aliasedName, true,
      type: ElectricTypes.int4, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [value, nbr];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'Items';
  @override
  VerificationContext validateIntegrity(Insertable<Item> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('nbr')) {
      context.handle(
          _nbrMeta, nbr.isAcceptableOrUnknown(data['nbr']!, _nbrMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {value};
  @override
  Item map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Item(
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      nbr: attachedDatabase.typeMapping
          .read(ElectricTypes.int4, data['${effectivePrefix}nbr']),
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
}

class Item extends DataClass implements Insertable<Item> {
  final String value;
  final int? nbr;
  const Item({required this.value, this.nbr});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['value'] = Variable<String>(value);
    if (!nullToAbsent || nbr != null) {
      map['nbr'] = Variable<int>(nbr, ElectricTypes.int4);
    }
    return map;
  }

  ItemsCompanion toCompanion(bool nullToAbsent) {
    return ItemsCompanion(
      value: Value(value),
      nbr: nbr == null && nullToAbsent ? const Value.absent() : Value(nbr),
    );
  }

  factory Item.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Item(
      value: serializer.fromJson<String>(json['value']),
      nbr: serializer.fromJson<int?>(json['nbr']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'value': serializer.toJson<String>(value),
      'nbr': serializer.toJson<int?>(nbr),
    };
  }

  Item copyWith({String? value, Value<int?> nbr = const Value.absent()}) =>
      Item(
        value: value ?? this.value,
        nbr: nbr.present ? nbr.value : this.nbr,
      );
  @override
  String toString() {
    return (StringBuffer('Item(')
          ..write('value: $value, ')
          ..write('nbr: $nbr')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(value, nbr);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Item && other.value == this.value && other.nbr == this.nbr);
}

class ItemsCompanion extends UpdateCompanion<Item> {
  final Value<String> value;
  final Value<int?> nbr;
  const ItemsCompanion({
    this.value = const Value.absent(),
    this.nbr = const Value.absent(),
  });
  ItemsCompanion.insert({
    required String value,
    this.nbr = const Value.absent(),
  }) : value = Value(value);
  static Insertable<Item> custom({
    Expression<String>? value,
    Expression<int>? nbr,
  }) {
    return RawValuesInsertable({
      if (value != null) 'value': value,
      if (nbr != null) 'nbr': nbr,
    });
  }

  ItemsCompanion copyWith({Value<String>? value, Value<int?>? nbr}) {
    return ItemsCompanion(
      value: value ?? this.value,
      nbr: nbr ?? this.nbr,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (nbr.present) {
      map['nbr'] = Variable<int>(nbr.value, ElectricTypes.int4);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('value: $value, ')
          ..write('nbr: $nbr')
          ..write(')'))
        .toString();
  }
}

class $UserTable extends User with TableInfo<$UserTable, UserData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: ElectricTypes.int4, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _metaMeta = const VerificationMeta('meta');
  @override
  late final GeneratedColumn<String> meta = GeneratedColumn<String>(
      'meta', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, name, meta];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'User';
  @override
  VerificationContext validateIntegrity(Insertable<UserData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('meta')) {
      context.handle(
          _metaMeta, meta.isAcceptableOrUnknown(data['meta']!, _metaMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserData(
      id: attachedDatabase.typeMapping
          .read(ElectricTypes.int4, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      meta: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}meta']),
    );
  }

  @override
  $UserTable createAlias(String alias) {
    return $UserTable(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
}

class UserData extends DataClass implements Insertable<UserData> {
  final int id;
  final String? name;
  final String? meta;
  const UserData({required this.id, this.name, this.meta});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id, ElectricTypes.int4);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || meta != null) {
      map['meta'] = Variable<String>(meta);
    }
    return map;
  }

  UserCompanion toCompanion(bool nullToAbsent) {
    return UserCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      meta: meta == null && nullToAbsent ? const Value.absent() : Value(meta),
    );
  }

  factory UserData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      meta: serializer.fromJson<String?>(json['meta']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String?>(name),
      'meta': serializer.toJson<String?>(meta),
    };
  }

  UserData copyWith(
          {int? id,
          Value<String?> name = const Value.absent(),
          Value<String?> meta = const Value.absent()}) =>
      UserData(
        id: id ?? this.id,
        name: name.present ? name.value : this.name,
        meta: meta.present ? meta.value : this.meta,
      );
  @override
  String toString() {
    return (StringBuffer('UserData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('meta: $meta')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, meta);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserData &&
          other.id == this.id &&
          other.name == this.name &&
          other.meta == this.meta);
}

class UserCompanion extends UpdateCompanion<UserData> {
  final Value<int> id;
  final Value<String?> name;
  final Value<String?> meta;
  const UserCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.meta = const Value.absent(),
  });
  UserCompanion.insert({
    required int id,
    this.name = const Value.absent(),
    this.meta = const Value.absent(),
  }) : id = Value(id);
  static Insertable<UserData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? meta,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (meta != null) 'meta': meta,
    });
  }

  UserCompanion copyWith(
      {Value<int>? id, Value<String?>? name, Value<String?>? meta}) {
    return UserCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      meta: meta ?? this.meta,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value, ElectricTypes.int4);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (meta.present) {
      map['meta'] = Variable<String>(meta.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('meta: $meta')
          ..write(')'))
        .toString();
  }
}

class $PostTable extends Post with TableInfo<$PostTable, PostData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PostTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: ElectricTypes.int4, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentsMeta =
      const VerificationMeta('contents');
  @override
  late final GeneratedColumn<String> contents = GeneratedColumn<String>(
      'contents', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nbrMeta = const VerificationMeta('nbr');
  @override
  late final GeneratedColumn<int> nbr = GeneratedColumn<int>(
      'nbr', aliasedName, true,
      type: ElectricTypes.int4, requiredDuringInsert: false);
  static const VerificationMeta _authorIdMeta =
      const VerificationMeta('authorId');
  @override
  late final GeneratedColumn<int> authorId = GeneratedColumn<int>(
      'authorId', aliasedName, false,
      type: ElectricTypes.int4, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, title, contents, nbr, authorId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'Post';
  @override
  VerificationContext validateIntegrity(Insertable<PostData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('contents')) {
      context.handle(_contentsMeta,
          contents.isAcceptableOrUnknown(data['contents']!, _contentsMeta));
    } else if (isInserting) {
      context.missing(_contentsMeta);
    }
    if (data.containsKey('nbr')) {
      context.handle(
          _nbrMeta, nbr.isAcceptableOrUnknown(data['nbr']!, _nbrMeta));
    }
    if (data.containsKey('authorId')) {
      context.handle(_authorIdMeta,
          authorId.isAcceptableOrUnknown(data['authorId']!, _authorIdMeta));
    } else if (isInserting) {
      context.missing(_authorIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PostData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PostData(
      id: attachedDatabase.typeMapping
          .read(ElectricTypes.int4, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      contents: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contents'])!,
      nbr: attachedDatabase.typeMapping
          .read(ElectricTypes.int4, data['${effectivePrefix}nbr']),
      authorId: attachedDatabase.typeMapping
          .read(ElectricTypes.int4, data['${effectivePrefix}authorId'])!,
    );
  }

  @override
  $PostTable createAlias(String alias) {
    return $PostTable(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
}

class PostData extends DataClass implements Insertable<PostData> {
  final int id;
  final String title;
  final String contents;
  final int? nbr;
  final int authorId;
  const PostData(
      {required this.id,
      required this.title,
      required this.contents,
      this.nbr,
      required this.authorId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id, ElectricTypes.int4);
    map['title'] = Variable<String>(title);
    map['contents'] = Variable<String>(contents);
    if (!nullToAbsent || nbr != null) {
      map['nbr'] = Variable<int>(nbr, ElectricTypes.int4);
    }
    map['authorId'] = Variable<int>(authorId, ElectricTypes.int4);
    return map;
  }

  PostCompanion toCompanion(bool nullToAbsent) {
    return PostCompanion(
      id: Value(id),
      title: Value(title),
      contents: Value(contents),
      nbr: nbr == null && nullToAbsent ? const Value.absent() : Value(nbr),
      authorId: Value(authorId),
    );
  }

  factory PostData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PostData(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      contents: serializer.fromJson<String>(json['contents']),
      nbr: serializer.fromJson<int?>(json['nbr']),
      authorId: serializer.fromJson<int>(json['authorId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'contents': serializer.toJson<String>(contents),
      'nbr': serializer.toJson<int?>(nbr),
      'authorId': serializer.toJson<int>(authorId),
    };
  }

  PostData copyWith(
          {int? id,
          String? title,
          String? contents,
          Value<int?> nbr = const Value.absent(),
          int? authorId}) =>
      PostData(
        id: id ?? this.id,
        title: title ?? this.title,
        contents: contents ?? this.contents,
        nbr: nbr.present ? nbr.value : this.nbr,
        authorId: authorId ?? this.authorId,
      );
  @override
  String toString() {
    return (StringBuffer('PostData(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('contents: $contents, ')
          ..write('nbr: $nbr, ')
          ..write('authorId: $authorId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, title, contents, nbr, authorId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PostData &&
          other.id == this.id &&
          other.title == this.title &&
          other.contents == this.contents &&
          other.nbr == this.nbr &&
          other.authorId == this.authorId);
}

class PostCompanion extends UpdateCompanion<PostData> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> contents;
  final Value<int?> nbr;
  final Value<int> authorId;
  const PostCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.contents = const Value.absent(),
    this.nbr = const Value.absent(),
    this.authorId = const Value.absent(),
  });
  PostCompanion.insert({
    required int id,
    required String title,
    required String contents,
    this.nbr = const Value.absent(),
    required int authorId,
  })  : id = Value(id),
        title = Value(title),
        contents = Value(contents),
        authorId = Value(authorId);
  static Insertable<PostData> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? contents,
    Expression<int>? nbr,
    Expression<int>? authorId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (contents != null) 'contents': contents,
      if (nbr != null) 'nbr': nbr,
      if (authorId != null) 'authorId': authorId,
    });
  }

  PostCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String>? contents,
      Value<int?>? nbr,
      Value<int>? authorId}) {
    return PostCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      contents: contents ?? this.contents,
      nbr: nbr ?? this.nbr,
      authorId: authorId ?? this.authorId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value, ElectricTypes.int4);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (contents.present) {
      map['contents'] = Variable<String>(contents.value);
    }
    if (nbr.present) {
      map['nbr'] = Variable<int>(nbr.value, ElectricTypes.int4);
    }
    if (authorId.present) {
      map['authorId'] = Variable<int>(authorId.value, ElectricTypes.int4);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PostCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('contents: $contents, ')
          ..write('nbr: $nbr, ')
          ..write('authorId: $authorId')
          ..write(')'))
        .toString();
  }
}

class $ProfileTable extends Profile with TableInfo<$ProfileTable, ProfileData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: ElectricTypes.int4, requiredDuringInsert: true);
  static const VerificationMeta _bioMeta = const VerificationMeta('bio');
  @override
  late final GeneratedColumn<String> bio = GeneratedColumn<String>(
      'bio', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _metaMeta = const VerificationMeta('meta');
  @override
  late final GeneratedColumn<Object> meta = GeneratedColumn<Object>(
      'meta', aliasedName, true,
      type: ElectricTypes.jsonb, requiredDuringInsert: false);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'userId', aliasedName, false,
      type: ElectricTypes.int4, requiredDuringInsert: true);
  static const VerificationMeta _imageIdMeta =
      const VerificationMeta('imageId');
  @override
  late final GeneratedColumn<String> imageId = GeneratedColumn<String>(
      'imageId', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, bio, meta, userId, imageId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'Profile';
  @override
  VerificationContext validateIntegrity(Insertable<ProfileData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('bio')) {
      context.handle(
          _bioMeta, bio.isAcceptableOrUnknown(data['bio']!, _bioMeta));
    } else if (isInserting) {
      context.missing(_bioMeta);
    }
    if (data.containsKey('meta')) {
      context.handle(
          _metaMeta, meta.isAcceptableOrUnknown(data['meta']!, _metaMeta));
    }
    if (data.containsKey('userId')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['userId']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('imageId')) {
      context.handle(_imageIdMeta,
          imageId.isAcceptableOrUnknown(data['imageId']!, _imageIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileData(
      id: attachedDatabase.typeMapping
          .read(ElectricTypes.int4, data['${effectivePrefix}id'])!,
      bio: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bio'])!,
      meta: attachedDatabase.typeMapping
          .read(ElectricTypes.jsonb, data['${effectivePrefix}meta']),
      userId: attachedDatabase.typeMapping
          .read(ElectricTypes.int4, data['${effectivePrefix}userId'])!,
      imageId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}imageId']),
    );
  }

  @override
  $ProfileTable createAlias(String alias) {
    return $ProfileTable(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
}

class ProfileData extends DataClass implements Insertable<ProfileData> {
  final int id;
  final String bio;
  final Object? meta;
  final int userId;
  final String? imageId;
  const ProfileData(
      {required this.id,
      required this.bio,
      this.meta,
      required this.userId,
      this.imageId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id, ElectricTypes.int4);
    map['bio'] = Variable<String>(bio);
    if (!nullToAbsent || meta != null) {
      map['meta'] = Variable<Object>(meta, ElectricTypes.jsonb);
    }
    map['userId'] = Variable<int>(userId, ElectricTypes.int4);
    if (!nullToAbsent || imageId != null) {
      map['imageId'] = Variable<String>(imageId);
    }
    return map;
  }

  ProfileCompanion toCompanion(bool nullToAbsent) {
    return ProfileCompanion(
      id: Value(id),
      bio: Value(bio),
      meta: meta == null && nullToAbsent ? const Value.absent() : Value(meta),
      userId: Value(userId),
      imageId: imageId == null && nullToAbsent
          ? const Value.absent()
          : Value(imageId),
    );
  }

  factory ProfileData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileData(
      id: serializer.fromJson<int>(json['id']),
      bio: serializer.fromJson<String>(json['bio']),
      meta: serializer.fromJson<Object?>(json['meta']),
      userId: serializer.fromJson<int>(json['userId']),
      imageId: serializer.fromJson<String?>(json['imageId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bio': serializer.toJson<String>(bio),
      'meta': serializer.toJson<Object?>(meta),
      'userId': serializer.toJson<int>(userId),
      'imageId': serializer.toJson<String?>(imageId),
    };
  }

  ProfileData copyWith(
          {int? id,
          String? bio,
          Value<Object?> meta = const Value.absent(),
          int? userId,
          Value<String?> imageId = const Value.absent()}) =>
      ProfileData(
        id: id ?? this.id,
        bio: bio ?? this.bio,
        meta: meta.present ? meta.value : this.meta,
        userId: userId ?? this.userId,
        imageId: imageId.present ? imageId.value : this.imageId,
      );
  @override
  String toString() {
    return (StringBuffer('ProfileData(')
          ..write('id: $id, ')
          ..write('bio: $bio, ')
          ..write('meta: $meta, ')
          ..write('userId: $userId, ')
          ..write('imageId: $imageId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bio, meta, userId, imageId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileData &&
          other.id == this.id &&
          other.bio == this.bio &&
          other.meta == this.meta &&
          other.userId == this.userId &&
          other.imageId == this.imageId);
}

class ProfileCompanion extends UpdateCompanion<ProfileData> {
  final Value<int> id;
  final Value<String> bio;
  final Value<Object?> meta;
  final Value<int> userId;
  final Value<String?> imageId;
  const ProfileCompanion({
    this.id = const Value.absent(),
    this.bio = const Value.absent(),
    this.meta = const Value.absent(),
    this.userId = const Value.absent(),
    this.imageId = const Value.absent(),
  });
  ProfileCompanion.insert({
    required int id,
    required String bio,
    this.meta = const Value.absent(),
    required int userId,
    this.imageId = const Value.absent(),
  })  : id = Value(id),
        bio = Value(bio),
        userId = Value(userId);
  static Insertable<ProfileData> custom({
    Expression<int>? id,
    Expression<String>? bio,
    Expression<Object>? meta,
    Expression<int>? userId,
    Expression<String>? imageId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bio != null) 'bio': bio,
      if (meta != null) 'meta': meta,
      if (userId != null) 'userId': userId,
      if (imageId != null) 'imageId': imageId,
    });
  }

  ProfileCompanion copyWith(
      {Value<int>? id,
      Value<String>? bio,
      Value<Object?>? meta,
      Value<int>? userId,
      Value<String?>? imageId}) {
    return ProfileCompanion(
      id: id ?? this.id,
      bio: bio ?? this.bio,
      meta: meta ?? this.meta,
      userId: userId ?? this.userId,
      imageId: imageId ?? this.imageId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value, ElectricTypes.int4);
    }
    if (bio.present) {
      map['bio'] = Variable<String>(bio.value);
    }
    if (meta.present) {
      map['meta'] = Variable<Object>(meta.value, ElectricTypes.jsonb);
    }
    if (userId.present) {
      map['userId'] = Variable<int>(userId.value, ElectricTypes.int4);
    }
    if (imageId.present) {
      map['imageId'] = Variable<String>(imageId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileCompanion(')
          ..write('id: $id, ')
          ..write('bio: $bio, ')
          ..write('meta: $meta, ')
          ..write('userId: $userId, ')
          ..write('imageId: $imageId')
          ..write(')'))
        .toString();
  }
}

class $ProfileImageTable extends ProfileImage
    with TableInfo<$ProfileImageTable, ProfileImageData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileImageTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _imageMeta = const VerificationMeta('image');
  @override
  late final GeneratedColumn<Uint8List> image = GeneratedColumn<Uint8List>(
      'image', aliasedName, false,
      type: DriftSqlType.blob, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, image];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ProfileImage';
  @override
  VerificationContext validateIntegrity(Insertable<ProfileImageData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('image')) {
      context.handle(
          _imageMeta, image.isAcceptableOrUnknown(data['image']!, _imageMeta));
    } else if (isInserting) {
      context.missing(_imageMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProfileImageData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileImageData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      image: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}image'])!,
    );
  }

  @override
  $ProfileImageTable createAlias(String alias) {
    return $ProfileImageTable(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
}

class ProfileImageData extends DataClass
    implements Insertable<ProfileImageData> {
  final String id;
  final Uint8List image;
  const ProfileImageData({required this.id, required this.image});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['image'] = Variable<Uint8List>(image);
    return map;
  }

  ProfileImageCompanion toCompanion(bool nullToAbsent) {
    return ProfileImageCompanion(
      id: Value(id),
      image: Value(image),
    );
  }

  factory ProfileImageData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileImageData(
      id: serializer.fromJson<String>(json['id']),
      image: serializer.fromJson<Uint8List>(json['image']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'image': serializer.toJson<Uint8List>(image),
    };
  }

  ProfileImageData copyWith({String? id, Uint8List? image}) => ProfileImageData(
        id: id ?? this.id,
        image: image ?? this.image,
      );
  @override
  String toString() {
    return (StringBuffer('ProfileImageData(')
          ..write('id: $id, ')
          ..write('image: $image')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, $driftBlobEquality.hash(image));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileImageData &&
          other.id == this.id &&
          $driftBlobEquality.equals(other.image, this.image));
}

class ProfileImageCompanion extends UpdateCompanion<ProfileImageData> {
  final Value<String> id;
  final Value<Uint8List> image;
  const ProfileImageCompanion({
    this.id = const Value.absent(),
    this.image = const Value.absent(),
  });
  ProfileImageCompanion.insert({
    required String id,
    required Uint8List image,
  })  : id = Value(id),
        image = Value(image);
  static Insertable<ProfileImageData> custom({
    Expression<String>? id,
    Expression<Uint8List>? image,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (image != null) 'image': image,
    });
  }

  ProfileImageCompanion copyWith({Value<String>? id, Value<Uint8List>? image}) {
    return ProfileImageCompanion(
      id: id ?? this.id,
      image: image ?? this.image,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (image.present) {
      map['image'] = Variable<Uint8List>(image.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileImageCompanion(')
          ..write('id: $id, ')
          ..write('image: $image')
          ..write(')'))
        .toString();
  }
}

class $DataTypesTable extends DataTypes
    with TableInfo<$DataTypesTable, DataType> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DataTypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: ElectricTypes.int4, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, true,
      type: ElectricTypes.date, requiredDuringInsert: false);
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
      'time', aliasedName, true,
      type: ElectricTypes.time, requiredDuringInsert: false);
  static const VerificationMeta _timetzMeta = const VerificationMeta('timetz');
  @override
  late final GeneratedColumn<DateTime> timetz = GeneratedColumn<DateTime>(
      'timetz', aliasedName, true,
      type: ElectricTypes.timeTZ, requiredDuringInsert: false);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, true,
      type: ElectricTypes.timestamp, requiredDuringInsert: false);
  static const VerificationMeta _timestamptzMeta =
      const VerificationMeta('timestamptz');
  @override
  late final GeneratedColumn<DateTime> timestamptz = GeneratedColumn<DateTime>(
      'timestamptz', aliasedName, true,
      type: ElectricTypes.timestampTZ, requiredDuringInsert: false);
  static const VerificationMeta _bool$Meta = const VerificationMeta('bool\$');
  @override
  late final GeneratedColumn<bool> bool$ = GeneratedColumn<bool>(
      'bool', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("bool" IN (0, 1))'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
      'uuid', aliasedName, true,
      type: ElectricTypes.uuid, requiredDuringInsert: false);
  static const VerificationMeta _int2Meta = const VerificationMeta('int2');
  @override
  late final GeneratedColumn<int> int2 = GeneratedColumn<int>(
      'int2', aliasedName, true,
      type: ElectricTypes.int2, requiredDuringInsert: false);
  static const VerificationMeta _int4Meta = const VerificationMeta('int4');
  @override
  late final GeneratedColumn<int> int4 = GeneratedColumn<int>(
      'int4', aliasedName, true,
      type: ElectricTypes.int4, requiredDuringInsert: false);
  static const VerificationMeta _int8Meta = const VerificationMeta('int8');
  @override
  late final GeneratedColumn<int> int8 = GeneratedColumn<int>(
      'int8', aliasedName, true,
      type: ElectricTypes.int8, requiredDuringInsert: false);
  static const VerificationMeta _float4Meta = const VerificationMeta('float4');
  @override
  late final GeneratedColumn<double> float4 = GeneratedColumn<double>(
      'float4', aliasedName, true,
      type: ElectricTypes.float4, requiredDuringInsert: false);
  static const VerificationMeta _float8Meta = const VerificationMeta('float8');
  @override
  late final GeneratedColumn<double> float8 = GeneratedColumn<double>(
      'float8', aliasedName, true,
      type: ElectricTypes.float8, requiredDuringInsert: false);
  static const VerificationMeta _jsonMeta = const VerificationMeta('json');
  @override
  late final GeneratedColumn<Object> json = GeneratedColumn<Object>(
      'json', aliasedName, true,
      type: ElectricTypes.jsonb, requiredDuringInsert: false);
  static const VerificationMeta _byteaMeta = const VerificationMeta('bytea');
  @override
  late final GeneratedColumn<Uint8List> bytea = GeneratedColumn<Uint8List>(
      'bytea', aliasedName, true,
      type: DriftSqlType.blob, requiredDuringInsert: false);
  static const VerificationMeta _enum$Meta = const VerificationMeta('enum\$');
  @override
  late final GeneratedColumn<DbColor> enum$ = GeneratedColumn<DbColor>(
      'enum', aliasedName, true,
      type: ElectricEnumTypes.color, requiredDuringInsert: false);
  static const VerificationMeta _relatedIdMeta =
      const VerificationMeta('relatedId');
  @override
  late final GeneratedColumn<int> relatedId = GeneratedColumn<int>(
      'relatedId', aliasedName, true,
      type: ElectricTypes.int4, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        date,
        time,
        timetz,
        timestamp,
        timestamptz,
        bool$,
        uuid,
        int2,
        int4,
        int8,
        float4,
        float8,
        json,
        bytea,
        enum$,
        relatedId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'DataTypes';
  @override
  VerificationContext validateIntegrity(Insertable<DataType> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    }
    if (data.containsKey('time')) {
      context.handle(
          _timeMeta, time.isAcceptableOrUnknown(data['time']!, _timeMeta));
    }
    if (data.containsKey('timetz')) {
      context.handle(_timetzMeta,
          timetz.isAcceptableOrUnknown(data['timetz']!, _timetzMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    if (data.containsKey('timestamptz')) {
      context.handle(
          _timestamptzMeta,
          timestamptz.isAcceptableOrUnknown(
              data['timestamptz']!, _timestamptzMeta));
    }
    if (data.containsKey('bool')) {
      context.handle(
          _bool$Meta, bool$.isAcceptableOrUnknown(data['bool']!, _bool$Meta));
    }
    if (data.containsKey('uuid')) {
      context.handle(
          _uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    }
    if (data.containsKey('int2')) {
      context.handle(
          _int2Meta, int2.isAcceptableOrUnknown(data['int2']!, _int2Meta));
    }
    if (data.containsKey('int4')) {
      context.handle(
          _int4Meta, int4.isAcceptableOrUnknown(data['int4']!, _int4Meta));
    }
    if (data.containsKey('int8')) {
      context.handle(
          _int8Meta, int8.isAcceptableOrUnknown(data['int8']!, _int8Meta));
    }
    if (data.containsKey('float4')) {
      context.handle(_float4Meta,
          float4.isAcceptableOrUnknown(data['float4']!, _float4Meta));
    }
    if (data.containsKey('float8')) {
      context.handle(_float8Meta,
          float8.isAcceptableOrUnknown(data['float8']!, _float8Meta));
    }
    if (data.containsKey('json')) {
      context.handle(
          _jsonMeta, json.isAcceptableOrUnknown(data['json']!, _jsonMeta));
    }
    if (data.containsKey('bytea')) {
      context.handle(
          _byteaMeta, bytea.isAcceptableOrUnknown(data['bytea']!, _byteaMeta));
    }
    if (data.containsKey('enum')) {
      context.handle(
          _enum$Meta, enum$.isAcceptableOrUnknown(data['enum']!, _enum$Meta));
    }
    if (data.containsKey('relatedId')) {
      context.handle(_relatedIdMeta,
          relatedId.isAcceptableOrUnknown(data['relatedId']!, _relatedIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DataType map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DataType(
      id: attachedDatabase.typeMapping
          .read(ElectricTypes.int4, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(ElectricTypes.date, data['${effectivePrefix}date']),
      time: attachedDatabase.typeMapping
          .read(ElectricTypes.time, data['${effectivePrefix}time']),
      timetz: attachedDatabase.typeMapping
          .read(ElectricTypes.timeTZ, data['${effectivePrefix}timetz']),
      timestamp: attachedDatabase.typeMapping
          .read(ElectricTypes.timestamp, data['${effectivePrefix}timestamp']),
      timestamptz: attachedDatabase.typeMapping.read(
          ElectricTypes.timestampTZ, data['${effectivePrefix}timestamptz']),
      bool$: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}bool']),
      uuid: attachedDatabase.typeMapping
          .read(ElectricTypes.uuid, data['${effectivePrefix}uuid']),
      int2: attachedDatabase.typeMapping
          .read(ElectricTypes.int2, data['${effectivePrefix}int2']),
      int4: attachedDatabase.typeMapping
          .read(ElectricTypes.int4, data['${effectivePrefix}int4']),
      int8: attachedDatabase.typeMapping
          .read(ElectricTypes.int8, data['${effectivePrefix}int8']),
      float4: attachedDatabase.typeMapping
          .read(ElectricTypes.float4, data['${effectivePrefix}float4']),
      float8: attachedDatabase.typeMapping
          .read(ElectricTypes.float8, data['${effectivePrefix}float8']),
      json: attachedDatabase.typeMapping
          .read(ElectricTypes.jsonb, data['${effectivePrefix}json']),
      bytea: attachedDatabase.typeMapping
          .read(DriftSqlType.blob, data['${effectivePrefix}bytea']),
      enum$: attachedDatabase.typeMapping
          .read(ElectricEnumTypes.color, data['${effectivePrefix}enum']),
      relatedId: attachedDatabase.typeMapping
          .read(ElectricTypes.int4, data['${effectivePrefix}relatedId']),
    );
  }

  @override
  $DataTypesTable createAlias(String alias) {
    return $DataTypesTable(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
}

class DataType extends DataClass implements Insertable<DataType> {
  final int id;
  final DateTime? date;
  final DateTime? time;
  final DateTime? timetz;
  final DateTime? timestamp;
  final DateTime? timestamptz;
  final bool? bool$;
  final String? uuid;
  final int? int2;
  final int? int4;
  final int? int8;
  final double? float4;
  final double? float8;
  final Object? json;
  final Uint8List? bytea;
  final DbColor? enum$;
  final int? relatedId;
  const DataType(
      {required this.id,
      this.date,
      this.time,
      this.timetz,
      this.timestamp,
      this.timestamptz,
      this.bool$,
      this.uuid,
      this.int2,
      this.int4,
      this.int8,
      this.float4,
      this.float8,
      this.json,
      this.bytea,
      this.enum$,
      this.relatedId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id, ElectricTypes.int4);
    if (!nullToAbsent || date != null) {
      map['date'] = Variable<DateTime>(date, ElectricTypes.date);
    }
    if (!nullToAbsent || time != null) {
      map['time'] = Variable<DateTime>(time, ElectricTypes.time);
    }
    if (!nullToAbsent || timetz != null) {
      map['timetz'] = Variable<DateTime>(timetz, ElectricTypes.timeTZ);
    }
    if (!nullToAbsent || timestamp != null) {
      map['timestamp'] = Variable<DateTime>(timestamp, ElectricTypes.timestamp);
    }
    if (!nullToAbsent || timestamptz != null) {
      map['timestamptz'] =
          Variable<DateTime>(timestamptz, ElectricTypes.timestampTZ);
    }
    if (!nullToAbsent || bool$ != null) {
      map['bool'] = Variable<bool>(bool$);
    }
    if (!nullToAbsent || uuid != null) {
      map['uuid'] = Variable<String>(uuid, ElectricTypes.uuid);
    }
    if (!nullToAbsent || int2 != null) {
      map['int2'] = Variable<int>(int2, ElectricTypes.int2);
    }
    if (!nullToAbsent || int4 != null) {
      map['int4'] = Variable<int>(int4, ElectricTypes.int4);
    }
    if (!nullToAbsent || int8 != null) {
      map['int8'] = Variable<int>(int8, ElectricTypes.int8);
    }
    if (!nullToAbsent || float4 != null) {
      map['float4'] = Variable<double>(float4, ElectricTypes.float4);
    }
    if (!nullToAbsent || float8 != null) {
      map['float8'] = Variable<double>(float8, ElectricTypes.float8);
    }
    if (!nullToAbsent || json != null) {
      map['json'] = Variable<Object>(json, ElectricTypes.jsonb);
    }
    if (!nullToAbsent || bytea != null) {
      map['bytea'] = Variable<Uint8List>(bytea);
    }
    if (!nullToAbsent || enum$ != null) {
      map['enum'] = Variable<DbColor>(enum$, ElectricEnumTypes.color);
    }
    if (!nullToAbsent || relatedId != null) {
      map['relatedId'] = Variable<int>(relatedId, ElectricTypes.int4);
    }
    return map;
  }

  DataTypesCompanion toCompanion(bool nullToAbsent) {
    return DataTypesCompanion(
      id: Value(id),
      date: date == null && nullToAbsent ? const Value.absent() : Value(date),
      time: time == null && nullToAbsent ? const Value.absent() : Value(time),
      timetz:
          timetz == null && nullToAbsent ? const Value.absent() : Value(timetz),
      timestamp: timestamp == null && nullToAbsent
          ? const Value.absent()
          : Value(timestamp),
      timestamptz: timestamptz == null && nullToAbsent
          ? const Value.absent()
          : Value(timestamptz),
      bool$:
          bool$ == null && nullToAbsent ? const Value.absent() : Value(bool$),
      uuid: uuid == null && nullToAbsent ? const Value.absent() : Value(uuid),
      int2: int2 == null && nullToAbsent ? const Value.absent() : Value(int2),
      int4: int4 == null && nullToAbsent ? const Value.absent() : Value(int4),
      int8: int8 == null && nullToAbsent ? const Value.absent() : Value(int8),
      float4:
          float4 == null && nullToAbsent ? const Value.absent() : Value(float4),
      float8:
          float8 == null && nullToAbsent ? const Value.absent() : Value(float8),
      json: json == null && nullToAbsent ? const Value.absent() : Value(json),
      bytea:
          bytea == null && nullToAbsent ? const Value.absent() : Value(bytea),
      enum$:
          enum$ == null && nullToAbsent ? const Value.absent() : Value(enum$),
      relatedId: relatedId == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedId),
    );
  }

  factory DataType.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DataType(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime?>(json['date']),
      time: serializer.fromJson<DateTime?>(json['time']),
      timetz: serializer.fromJson<DateTime?>(json['timetz']),
      timestamp: serializer.fromJson<DateTime?>(json['timestamp']),
      timestamptz: serializer.fromJson<DateTime?>(json['timestamptz']),
      bool$: serializer.fromJson<bool?>(json['bool\$']),
      uuid: serializer.fromJson<String?>(json['uuid']),
      int2: serializer.fromJson<int?>(json['int2']),
      int4: serializer.fromJson<int?>(json['int4']),
      int8: serializer.fromJson<int?>(json['int8']),
      float4: serializer.fromJson<double?>(json['float4']),
      float8: serializer.fromJson<double?>(json['float8']),
      json: serializer.fromJson<Object?>(json['json']),
      bytea: serializer.fromJson<Uint8List?>(json['bytea']),
      enum$: serializer.fromJson<DbColor?>(json['enum\$']),
      relatedId: serializer.fromJson<int?>(json['relatedId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime?>(date),
      'time': serializer.toJson<DateTime?>(time),
      'timetz': serializer.toJson<DateTime?>(timetz),
      'timestamp': serializer.toJson<DateTime?>(timestamp),
      'timestamptz': serializer.toJson<DateTime?>(timestamptz),
      'bool\$': serializer.toJson<bool?>(bool$),
      'uuid': serializer.toJson<String?>(uuid),
      'int2': serializer.toJson<int?>(int2),
      'int4': serializer.toJson<int?>(int4),
      'int8': serializer.toJson<int?>(int8),
      'float4': serializer.toJson<double?>(float4),
      'float8': serializer.toJson<double?>(float8),
      'json': serializer.toJson<Object?>(json),
      'bytea': serializer.toJson<Uint8List?>(bytea),
      'enum\$': serializer.toJson<DbColor?>(enum$),
      'relatedId': serializer.toJson<int?>(relatedId),
    };
  }

  DataType copyWith(
          {int? id,
          Value<DateTime?> date = const Value.absent(),
          Value<DateTime?> time = const Value.absent(),
          Value<DateTime?> timetz = const Value.absent(),
          Value<DateTime?> timestamp = const Value.absent(),
          Value<DateTime?> timestamptz = const Value.absent(),
          Value<bool?> bool$ = const Value.absent(),
          Value<String?> uuid = const Value.absent(),
          Value<int?> int2 = const Value.absent(),
          Value<int?> int4 = const Value.absent(),
          Value<int?> int8 = const Value.absent(),
          Value<double?> float4 = const Value.absent(),
          Value<double?> float8 = const Value.absent(),
          Value<Object?> json = const Value.absent(),
          Value<Uint8List?> bytea = const Value.absent(),
          Value<DbColor?> enum$ = const Value.absent(),
          Value<int?> relatedId = const Value.absent()}) =>
      DataType(
        id: id ?? this.id,
        date: date.present ? date.value : this.date,
        time: time.present ? time.value : this.time,
        timetz: timetz.present ? timetz.value : this.timetz,
        timestamp: timestamp.present ? timestamp.value : this.timestamp,
        timestamptz: timestamptz.present ? timestamptz.value : this.timestamptz,
        bool$: bool$.present ? bool$.value : this.bool$,
        uuid: uuid.present ? uuid.value : this.uuid,
        int2: int2.present ? int2.value : this.int2,
        int4: int4.present ? int4.value : this.int4,
        int8: int8.present ? int8.value : this.int8,
        float4: float4.present ? float4.value : this.float4,
        float8: float8.present ? float8.value : this.float8,
        json: json.present ? json.value : this.json,
        bytea: bytea.present ? bytea.value : this.bytea,
        enum$: enum$.present ? enum$.value : this.enum$,
        relatedId: relatedId.present ? relatedId.value : this.relatedId,
      );
  @override
  String toString() {
    return (StringBuffer('DataType(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('time: $time, ')
          ..write('timetz: $timetz, ')
          ..write('timestamp: $timestamp, ')
          ..write('timestamptz: $timestamptz, ')
          ..write('bool\$: ${bool$}, ')
          ..write('uuid: $uuid, ')
          ..write('int2: $int2, ')
          ..write('int4: $int4, ')
          ..write('int8: $int8, ')
          ..write('float4: $float4, ')
          ..write('float8: $float8, ')
          ..write('json: $json, ')
          ..write('bytea: $bytea, ')
          ..write('enum\$: ${enum$}, ')
          ..write('relatedId: $relatedId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      date,
      time,
      timetz,
      timestamp,
      timestamptz,
      bool$,
      uuid,
      int2,
      int4,
      int8,
      float4,
      float8,
      json,
      $driftBlobEquality.hash(bytea),
      enum$,
      relatedId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DataType &&
          other.id == this.id &&
          other.date == this.date &&
          other.time == this.time &&
          other.timetz == this.timetz &&
          other.timestamp == this.timestamp &&
          other.timestamptz == this.timestamptz &&
          other.bool$ == this.bool$ &&
          other.uuid == this.uuid &&
          other.int2 == this.int2 &&
          other.int4 == this.int4 &&
          other.int8 == this.int8 &&
          other.float4 == this.float4 &&
          other.float8 == this.float8 &&
          other.json == this.json &&
          $driftBlobEquality.equals(other.bytea, this.bytea) &&
          other.enum$ == this.enum$ &&
          other.relatedId == this.relatedId);
}

class DataTypesCompanion extends UpdateCompanion<DataType> {
  final Value<int> id;
  final Value<DateTime?> date;
  final Value<DateTime?> time;
  final Value<DateTime?> timetz;
  final Value<DateTime?> timestamp;
  final Value<DateTime?> timestamptz;
  final Value<bool?> bool$;
  final Value<String?> uuid;
  final Value<int?> int2;
  final Value<int?> int4;
  final Value<int?> int8;
  final Value<double?> float4;
  final Value<double?> float8;
  final Value<Object?> json;
  final Value<Uint8List?> bytea;
  final Value<DbColor?> enum$;
  final Value<int?> relatedId;
  const DataTypesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.time = const Value.absent(),
    this.timetz = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.timestamptz = const Value.absent(),
    this.bool$ = const Value.absent(),
    this.uuid = const Value.absent(),
    this.int2 = const Value.absent(),
    this.int4 = const Value.absent(),
    this.int8 = const Value.absent(),
    this.float4 = const Value.absent(),
    this.float8 = const Value.absent(),
    this.json = const Value.absent(),
    this.bytea = const Value.absent(),
    this.enum$ = const Value.absent(),
    this.relatedId = const Value.absent(),
  });
  DataTypesCompanion.insert({
    required int id,
    this.date = const Value.absent(),
    this.time = const Value.absent(),
    this.timetz = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.timestamptz = const Value.absent(),
    this.bool$ = const Value.absent(),
    this.uuid = const Value.absent(),
    this.int2 = const Value.absent(),
    this.int4 = const Value.absent(),
    this.int8 = const Value.absent(),
    this.float4 = const Value.absent(),
    this.float8 = const Value.absent(),
    this.json = const Value.absent(),
    this.bytea = const Value.absent(),
    this.enum$ = const Value.absent(),
    this.relatedId = const Value.absent(),
  }) : id = Value(id);
  static Insertable<DataType> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<DateTime>? time,
    Expression<DateTime>? timetz,
    Expression<DateTime>? timestamp,
    Expression<DateTime>? timestamptz,
    Expression<bool>? bool$,
    Expression<String>? uuid,
    Expression<int>? int2,
    Expression<int>? int4,
    Expression<int>? int8,
    Expression<double>? float4,
    Expression<double>? float8,
    Expression<Object>? json,
    Expression<Uint8List>? bytea,
    Expression<DbColor>? enum$,
    Expression<int>? relatedId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (time != null) 'time': time,
      if (timetz != null) 'timetz': timetz,
      if (timestamp != null) 'timestamp': timestamp,
      if (timestamptz != null) 'timestamptz': timestamptz,
      if (bool$ != null) 'bool': bool$,
      if (uuid != null) 'uuid': uuid,
      if (int2 != null) 'int2': int2,
      if (int4 != null) 'int4': int4,
      if (int8 != null) 'int8': int8,
      if (float4 != null) 'float4': float4,
      if (float8 != null) 'float8': float8,
      if (json != null) 'json': json,
      if (bytea != null) 'bytea': bytea,
      if (enum$ != null) 'enum': enum$,
      if (relatedId != null) 'relatedId': relatedId,
    });
  }

  DataTypesCompanion copyWith(
      {Value<int>? id,
      Value<DateTime?>? date,
      Value<DateTime?>? time,
      Value<DateTime?>? timetz,
      Value<DateTime?>? timestamp,
      Value<DateTime?>? timestamptz,
      Value<bool?>? bool$,
      Value<String?>? uuid,
      Value<int?>? int2,
      Value<int?>? int4,
      Value<int?>? int8,
      Value<double?>? float4,
      Value<double?>? float8,
      Value<Object?>? json,
      Value<Uint8List?>? bytea,
      Value<DbColor?>? enum$,
      Value<int?>? relatedId}) {
    return DataTypesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      timetz: timetz ?? this.timetz,
      timestamp: timestamp ?? this.timestamp,
      timestamptz: timestamptz ?? this.timestamptz,
      bool$: bool$ ?? this.bool$,
      uuid: uuid ?? this.uuid,
      int2: int2 ?? this.int2,
      int4: int4 ?? this.int4,
      int8: int8 ?? this.int8,
      float4: float4 ?? this.float4,
      float8: float8 ?? this.float8,
      json: json ?? this.json,
      bytea: bytea ?? this.bytea,
      enum$: enum$ ?? this.enum$,
      relatedId: relatedId ?? this.relatedId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value, ElectricTypes.int4);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value, ElectricTypes.date);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value, ElectricTypes.time);
    }
    if (timetz.present) {
      map['timetz'] = Variable<DateTime>(timetz.value, ElectricTypes.timeTZ);
    }
    if (timestamp.present) {
      map['timestamp'] =
          Variable<DateTime>(timestamp.value, ElectricTypes.timestamp);
    }
    if (timestamptz.present) {
      map['timestamptz'] =
          Variable<DateTime>(timestamptz.value, ElectricTypes.timestampTZ);
    }
    if (bool$.present) {
      map['bool'] = Variable<bool>(bool$.value);
    }
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value, ElectricTypes.uuid);
    }
    if (int2.present) {
      map['int2'] = Variable<int>(int2.value, ElectricTypes.int2);
    }
    if (int4.present) {
      map['int4'] = Variable<int>(int4.value, ElectricTypes.int4);
    }
    if (int8.present) {
      map['int8'] = Variable<int>(int8.value, ElectricTypes.int8);
    }
    if (float4.present) {
      map['float4'] = Variable<double>(float4.value, ElectricTypes.float4);
    }
    if (float8.present) {
      map['float8'] = Variable<double>(float8.value, ElectricTypes.float8);
    }
    if (json.present) {
      map['json'] = Variable<Object>(json.value, ElectricTypes.jsonb);
    }
    if (bytea.present) {
      map['bytea'] = Variable<Uint8List>(bytea.value);
    }
    if (enum$.present) {
      map['enum'] = Variable<DbColor>(enum$.value, ElectricEnumTypes.color);
    }
    if (relatedId.present) {
      map['relatedId'] = Variable<int>(relatedId.value, ElectricTypes.int4);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DataTypesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('time: $time, ')
          ..write('timetz: $timetz, ')
          ..write('timestamp: $timestamp, ')
          ..write('timestamptz: $timestamptz, ')
          ..write('bool\$: ${bool$}, ')
          ..write('uuid: $uuid, ')
          ..write('int2: $int2, ')
          ..write('int4: $int4, ')
          ..write('int8: $int8, ')
          ..write('float4: $float4, ')
          ..write('float8: $float8, ')
          ..write('json: $json, ')
          ..write('bytea: $bytea, ')
          ..write('enum\$: ${enum$}, ')
          ..write('relatedId: $relatedId')
          ..write(')'))
        .toString();
  }
}

class $DummyTable extends Dummy with TableInfo<$DummyTable, DummyData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DummyTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: ElectricTypes.int4, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, true,
      type: ElectricTypes.timestamp, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, timestamp];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'Dummy';
  @override
  VerificationContext validateIntegrity(Insertable<DummyData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DummyData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DummyData(
      id: attachedDatabase.typeMapping
          .read(ElectricTypes.int4, data['${effectivePrefix}id'])!,
      timestamp: attachedDatabase.typeMapping
          .read(ElectricTypes.timestamp, data['${effectivePrefix}timestamp']),
    );
  }

  @override
  $DummyTable createAlias(String alias) {
    return $DummyTable(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
}

class DummyData extends DataClass implements Insertable<DummyData> {
  final int id;
  final DateTime? timestamp;
  const DummyData({required this.id, this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id, ElectricTypes.int4);
    if (!nullToAbsent || timestamp != null) {
      map['timestamp'] = Variable<DateTime>(timestamp, ElectricTypes.timestamp);
    }
    return map;
  }

  DummyCompanion toCompanion(bool nullToAbsent) {
    return DummyCompanion(
      id: Value(id),
      timestamp: timestamp == null && nullToAbsent
          ? const Value.absent()
          : Value(timestamp),
    );
  }

  factory DummyData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DummyData(
      id: serializer.fromJson<int>(json['id']),
      timestamp: serializer.fromJson<DateTime?>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'timestamp': serializer.toJson<DateTime?>(timestamp),
    };
  }

  DummyData copyWith(
          {int? id, Value<DateTime?> timestamp = const Value.absent()}) =>
      DummyData(
        id: id ?? this.id,
        timestamp: timestamp.present ? timestamp.value : this.timestamp,
      );
  @override
  String toString() {
    return (StringBuffer('DummyData(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DummyData &&
          other.id == this.id &&
          other.timestamp == this.timestamp);
}

class DummyCompanion extends UpdateCompanion<DummyData> {
  final Value<int> id;
  final Value<DateTime?> timestamp;
  const DummyCompanion({
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  DummyCompanion.insert({
    required int id,
    this.timestamp = const Value.absent(),
  }) : id = Value(id);
  static Insertable<DummyData> custom({
    Expression<int>? id,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  DummyCompanion copyWith({Value<int>? id, Value<DateTime?>? timestamp}) {
    return DummyCompanion(
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value, ElectricTypes.int4);
    }
    if (timestamp.present) {
      map['timestamp'] =
          Variable<DateTime>(timestamp.value, ElectricTypes.timestamp);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DummyCompanion(')
          ..write('id: $id, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

class $ExtraTable extends Extra with TableInfo<$ExtraTable, ExtraData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExtraTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _int8BigIntMeta =
      const VerificationMeta('int8BigInt');
  @override
  late final GeneratedColumn<BigInt> int8BigInt = GeneratedColumn<BigInt>(
      'int8_big_int', aliasedName, true,
      type: DriftSqlType.bigInt, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, int8BigInt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'Extra';
  @override
  VerificationContext validateIntegrity(Insertable<ExtraData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('int8_big_int')) {
      context.handle(
          _int8BigIntMeta,
          int8BigInt.isAcceptableOrUnknown(
              data['int8_big_int']!, _int8BigIntMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExtraData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExtraData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      int8BigInt: attachedDatabase.typeMapping
          .read(DriftSqlType.bigInt, data['${effectivePrefix}int8_big_int']),
    );
  }

  @override
  $ExtraTable createAlias(String alias) {
    return $ExtraTable(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
}

class ExtraData extends DataClass implements Insertable<ExtraData> {
  final int id;
  final BigInt? int8BigInt;
  const ExtraData({required this.id, this.int8BigInt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || int8BigInt != null) {
      map['int8_big_int'] = Variable<BigInt>(int8BigInt);
    }
    return map;
  }

  ExtraCompanion toCompanion(bool nullToAbsent) {
    return ExtraCompanion(
      id: Value(id),
      int8BigInt: int8BigInt == null && nullToAbsent
          ? const Value.absent()
          : Value(int8BigInt),
    );
  }

  factory ExtraData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExtraData(
      id: serializer.fromJson<int>(json['id']),
      int8BigInt: serializer.fromJson<BigInt?>(json['int8BigInt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'int8BigInt': serializer.toJson<BigInt?>(int8BigInt),
    };
  }

  ExtraData copyWith(
          {int? id, Value<BigInt?> int8BigInt = const Value.absent()}) =>
      ExtraData(
        id: id ?? this.id,
        int8BigInt: int8BigInt.present ? int8BigInt.value : this.int8BigInt,
      );
  @override
  String toString() {
    return (StringBuffer('ExtraData(')
          ..write('id: $id, ')
          ..write('int8BigInt: $int8BigInt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, int8BigInt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExtraData &&
          other.id == this.id &&
          other.int8BigInt == this.int8BigInt);
}

class ExtraCompanion extends UpdateCompanion<ExtraData> {
  final Value<int> id;
  final Value<BigInt?> int8BigInt;
  const ExtraCompanion({
    this.id = const Value.absent(),
    this.int8BigInt = const Value.absent(),
  });
  ExtraCompanion.insert({
    required int id,
    this.int8BigInt = const Value.absent(),
  }) : id = Value(id);
  static Insertable<ExtraData> custom({
    Expression<int>? id,
    Expression<BigInt>? int8BigInt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (int8BigInt != null) 'int8_big_int': int8BigInt,
    });
  }

  ExtraCompanion copyWith({Value<int>? id, Value<BigInt?>? int8BigInt}) {
    return ExtraCompanion(
      id: id ?? this.id,
      int8BigInt: int8BigInt ?? this.int8BigInt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (int8BigInt.present) {
      map['int8_big_int'] = Variable<BigInt>(int8BigInt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExtraCompanion(')
          ..write('id: $id, ')
          ..write('int8BigInt: $int8BigInt')
          ..write(')'))
        .toString();
  }
}

abstract class _$TestsDatabase extends GeneratedDatabase {
  _$TestsDatabase(QueryExecutor e) : super(e);
  late final TableFromDriftFile tableFromDriftFile = TableFromDriftFile(this);
  late final $ItemsTable items = $ItemsTable(this);
  late final $UserTable user = $UserTable(this);
  late final $PostTable post = $PostTable(this);
  late final $ProfileTable profile = $ProfileTable(this);
  late final $ProfileImageTable profileImage = $ProfileImageTable(this);
  late final $DataTypesTable dataTypes = $DataTypesTable(this);
  late final $DummyTable dummy = $DummyTable(this);
  late final $ExtraTable extra = $ExtraTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        tableFromDriftFile,
        items,
        user,
        post,
        profile,
        profileImage,
        dataTypes,
        dummy,
        extra
      ];
}
