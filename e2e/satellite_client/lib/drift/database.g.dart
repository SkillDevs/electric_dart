// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
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
  static const VerificationMeta _intValueNullMeta =
      const VerificationMeta('intValueNull');
  @override
  late final GeneratedColumn<int> intValueNull = GeneratedColumn<int>(
      'intvalue_null', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _intValueNullDefaultMeta =
      const VerificationMeta('intValueNullDefault');
  @override
  late final GeneratedColumn<int> intValueNullDefault = GeneratedColumn<int>(
      'intvalue_null_default', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        content,
        contentTextNull,
        contentTextNullDefault,
        intValueNull,
        intValueNullDefault
      ];
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
          _intValueNullMeta,
          intValueNull.isAcceptableOrUnknown(
              data['intvalue_null']!, _intValueNullMeta));
    }
    if (data.containsKey('intvalue_null_default')) {
      context.handle(
          _intValueNullDefaultMeta,
          intValueNullDefault.isAcceptableOrUnknown(
              data['intvalue_null_default']!, _intValueNullDefaultMeta));
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
      intValueNull: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}intvalue_null']),
      intValueNullDefault: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}intvalue_null_default']),
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
  final int? intValueNull;
  final int? intValueNullDefault;
  const Item(
      {required this.id,
      required this.content,
      this.contentTextNull,
      this.contentTextNullDefault,
      this.intValueNull,
      this.intValueNullDefault});
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
    if (!nullToAbsent || intValueNull != null) {
      map['intvalue_null'] = Variable<int>(intValueNull);
    }
    if (!nullToAbsent || intValueNullDefault != null) {
      map['intvalue_null_default'] = Variable<int>(intValueNullDefault);
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
      intValueNull: intValueNull == null && nullToAbsent
          ? const Value.absent()
          : Value(intValueNull),
      intValueNullDefault: intValueNullDefault == null && nullToAbsent
          ? const Value.absent()
          : Value(intValueNullDefault),
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
      intValueNull: serializer.fromJson<int?>(json['intValueNull']),
      intValueNullDefault:
          serializer.fromJson<int?>(json['intValueNullDefault']),
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
      'intValueNull': serializer.toJson<int?>(intValueNull),
      'intValueNullDefault': serializer.toJson<int?>(intValueNullDefault),
    };
  }

  Item copyWith(
          {String? id,
          String? content,
          Value<String?> contentTextNull = const Value.absent(),
          Value<String?> contentTextNullDefault = const Value.absent(),
          Value<int?> intValueNull = const Value.absent(),
          Value<int?> intValueNullDefault = const Value.absent()}) =>
      Item(
        id: id ?? this.id,
        content: content ?? this.content,
        contentTextNull: contentTextNull.present
            ? contentTextNull.value
            : this.contentTextNull,
        contentTextNullDefault: contentTextNullDefault.present
            ? contentTextNullDefault.value
            : this.contentTextNullDefault,
        intValueNull:
            intValueNull.present ? intValueNull.value : this.intValueNull,
        intValueNullDefault: intValueNullDefault.present
            ? intValueNullDefault.value
            : this.intValueNullDefault,
      );
  @override
  String toString() {
    return (StringBuffer('Item(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('contentTextNull: $contentTextNull, ')
          ..write('contentTextNullDefault: $contentTextNullDefault, ')
          ..write('intValueNull: $intValueNull, ')
          ..write('intValueNullDefault: $intValueNullDefault')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, content, contentTextNull,
      contentTextNullDefault, intValueNull, intValueNullDefault);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Item &&
          other.id == this.id &&
          other.content == this.content &&
          other.contentTextNull == this.contentTextNull &&
          other.contentTextNullDefault == this.contentTextNullDefault &&
          other.intValueNull == this.intValueNull &&
          other.intValueNullDefault == this.intValueNullDefault);
}

class ItemsCompanion extends UpdateCompanion<Item> {
  final Value<String> id;
  final Value<String> content;
  final Value<String?> contentTextNull;
  final Value<String?> contentTextNullDefault;
  final Value<int?> intValueNull;
  final Value<int?> intValueNullDefault;
  final Value<int> rowid;
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.contentTextNull = const Value.absent(),
    this.contentTextNullDefault = const Value.absent(),
    this.intValueNull = const Value.absent(),
    this.intValueNullDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsCompanion.insert({
    required String id,
    required String content,
    this.contentTextNull = const Value.absent(),
    this.contentTextNullDefault = const Value.absent(),
    this.intValueNull = const Value.absent(),
    this.intValueNullDefault = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        content = Value(content);
  static Insertable<Item> custom({
    Expression<String>? id,
    Expression<String>? content,
    Expression<String>? contentTextNull,
    Expression<String>? contentTextNullDefault,
    Expression<int>? intValueNull,
    Expression<int>? intValueNullDefault,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (contentTextNull != null) 'content_text_null': contentTextNull,
      if (contentTextNullDefault != null)
        'content_text_null_default': contentTextNullDefault,
      if (intValueNull != null) 'intvalue_null': intValueNull,
      if (intValueNullDefault != null)
        'intvalue_null_default': intValueNullDefault,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? content,
      Value<String?>? contentTextNull,
      Value<String?>? contentTextNullDefault,
      Value<int?>? intValueNull,
      Value<int?>? intValueNullDefault,
      Value<int>? rowid}) {
    return ItemsCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      contentTextNull: contentTextNull ?? this.contentTextNull,
      contentTextNullDefault:
          contentTextNullDefault ?? this.contentTextNullDefault,
      intValueNull: intValueNull ?? this.intValueNull,
      intValueNullDefault: intValueNullDefault ?? this.intValueNullDefault,
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
    if (intValueNull.present) {
      map['intvalue_null'] = Variable<int>(intValueNull.value);
    }
    if (intValueNullDefault.present) {
      map['intvalue_null_default'] = Variable<int>(intValueNullDefault.value);
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
          ..write('intValueNull: $intValueNull, ')
          ..write('intValueNullDefault: $intValueNullDefault, ')
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
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('UNIQUE REFERENCES Items (id)'));
  @override
  List<GeneratedColumn> get $columns => [id, content, itemId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'OtherItems';
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
  late final GeneratedColumnWithTypeConverter<DateTime, String> createdAt =
      GeneratedColumn<String>('created_at', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<DateTime>($TimestampsTable.$convertercreatedAt);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> updatedAt =
      GeneratedColumn<String>('updated_at', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<DateTime>($TimestampsTable.$converterupdatedAt);
  @override
  List<GeneratedColumn> get $columns => [id, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'Timestamps';
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
    context.handle(_createdAtMeta, const VerificationResult.success());
    context.handle(_updatedAtMeta, const VerificationResult.success());
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
      createdAt: $TimestampsTable.$convertercreatedAt.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!),
      updatedAt: $TimestampsTable.$converterupdatedAt.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!),
    );
  }

  @override
  $TimestampsTable createAlias(String alias) {
    return $TimestampsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertercreatedAt =
      const ElectricTimestampConverter();
  static TypeConverter<DateTime, String> $converterupdatedAt =
      const ElectricTimestampTZConverter();
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
    {
      final converter = $TimestampsTable.$convertercreatedAt;
      map['created_at'] = Variable<String>(converter.toSql(createdAt));
    }
    {
      final converter = $TimestampsTable.$converterupdatedAt;
      map['updated_at'] = Variable<String>(converter.toSql(updatedAt));
    }
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
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
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
      final converter = $TimestampsTable.$convertercreatedAt;

      map['created_at'] = Variable<String>(converter.toSql(createdAt.value));
    }
    if (updatedAt.present) {
      final converter = $TimestampsTable.$converterupdatedAt;

      map['updated_at'] = Variable<String>(converter.toSql(updatedAt.value));
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
  late final GeneratedColumnWithTypeConverter<DateTime, String> d =
      GeneratedColumn<String>('d', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<DateTime>($DatetimesTable.$converterd);
  static const VerificationMeta _tMeta = const VerificationMeta('t');
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> t =
      GeneratedColumn<String>('t', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<DateTime>($DatetimesTable.$convertert);
  @override
  List<GeneratedColumn> get $columns => [id, d, t];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'Datetimes';
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
    context.handle(_dMeta, const VerificationResult.success());
    context.handle(_tMeta, const VerificationResult.success());
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
      d: $DatetimesTable.$converterd.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}d'])!),
      t: $DatetimesTable.$convertert.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}t'])!),
    );
  }

  @override
  $DatetimesTable createAlias(String alias) {
    return $DatetimesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterd =
      const ElectricDateConverter();
  static TypeConverter<DateTime, String> $convertert =
      const ElectricTimeConverter();
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
    {
      final converter = $DatetimesTable.$converterd;
      map['d'] = Variable<String>(converter.toSql(d));
    }
    {
      final converter = $DatetimesTable.$convertert;
      map['t'] = Variable<String>(converter.toSql(t));
    }
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
    Expression<String>? d,
    Expression<String>? t,
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
      final converter = $DatetimesTable.$converterd;

      map['d'] = Variable<String>(converter.toSql(d.value));
    }
    if (t.present) {
      final converter = $DatetimesTable.$convertert;

      map['t'] = Variable<String>(converter.toSql(t.value));
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
  static const String $name = 'Bools';
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

class $UuidsTable extends Uuids with TableInfo<$UuidsTable, Uuid> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UuidsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumnWithTypeConverter<String, String> id =
      GeneratedColumn<String>('id', aliasedName, false,
              type: DriftSqlType.string, requiredDuringInsert: true)
          .withConverter<String>($UuidsTable.$converterid);
  @override
  List<GeneratedColumn> get $columns => [id];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'Uuids';
  @override
  VerificationContext validateIntegrity(Insertable<Uuid> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    context.handle(_idMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Uuid map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Uuid(
      id: $UuidsTable.$converterid.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!),
    );
  }

  @override
  $UuidsTable createAlias(String alias) {
    return $UuidsTable(attachedDatabase, alias);
  }

  static TypeConverter<String, String> $converterid =
      const ElectricUUIDConverter();
}

class Uuid extends DataClass implements Insertable<Uuid> {
  final String id;
  const Uuid({required this.id});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    {
      final converter = $UuidsTable.$converterid;
      map['id'] = Variable<String>(converter.toSql(id));
    }
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
      final converter = $UuidsTable.$converterid;

      map['id'] = Variable<String>(converter.toSql(id.value));
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
  late final GeneratedColumnWithTypeConverter<int?, int> i2 =
      GeneratedColumn<int>('i2', aliasedName, true,
              type: DriftSqlType.int, requiredDuringInsert: false)
          .withConverter<int?>($IntsTable.$converteri2n);
  static const VerificationMeta _i4Meta = const VerificationMeta('i4');
  @override
  late final GeneratedColumnWithTypeConverter<int?, int> i4 =
      GeneratedColumn<int>('i4', aliasedName, true,
              type: DriftSqlType.int, requiredDuringInsert: false)
          .withConverter<int?>($IntsTable.$converteri4n);
  @override
  List<GeneratedColumn> get $columns => [id, i2, i4];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'Ints';
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
    context.handle(_i2Meta, const VerificationResult.success());
    context.handle(_i4Meta, const VerificationResult.success());
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
      i2: $IntsTable.$converteri2n.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}i2'])),
      i4: $IntsTable.$converteri4n.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}i4'])),
    );
  }

  @override
  $IntsTable createAlias(String alias) {
    return $IntsTable(attachedDatabase, alias);
  }

  static TypeConverter<int, int> $converteri2 = const ElectricInt2Converter();
  static TypeConverter<int?, int?> $converteri2n =
      NullAwareTypeConverter.wrap($converteri2);
  static TypeConverter<int, int> $converteri4 = const ElectricInt4Converter();
  static TypeConverter<int?, int?> $converteri4n =
      NullAwareTypeConverter.wrap($converteri4);
}

class Int extends DataClass implements Insertable<Int> {
  final String id;
  final int? i2;
  final int? i4;
  const Int({required this.id, this.i2, this.i4});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || i2 != null) {
      final converter = $IntsTable.$converteri2n;
      map['i2'] = Variable<int>(converter.toSql(i2));
    }
    if (!nullToAbsent || i4 != null) {
      final converter = $IntsTable.$converteri4n;
      map['i4'] = Variable<int>(converter.toSql(i4));
    }
    return map;
  }

  IntsCompanion toCompanion(bool nullToAbsent) {
    return IntsCompanion(
      id: Value(id),
      i2: i2 == null && nullToAbsent ? const Value.absent() : Value(i2),
      i4: i4 == null && nullToAbsent ? const Value.absent() : Value(i4),
    );
  }

  factory Int.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Int(
      id: serializer.fromJson<String>(json['id']),
      i2: serializer.fromJson<int?>(json['i2']),
      i4: serializer.fromJson<int?>(json['i4']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'i2': serializer.toJson<int?>(i2),
      'i4': serializer.toJson<int?>(i4),
    };
  }

  Int copyWith(
          {String? id,
          Value<int?> i2 = const Value.absent(),
          Value<int?> i4 = const Value.absent()}) =>
      Int(
        id: id ?? this.id,
        i2: i2.present ? i2.value : this.i2,
        i4: i4.present ? i4.value : this.i4,
      );
  @override
  String toString() {
    return (StringBuffer('Int(')
          ..write('id: $id, ')
          ..write('i2: $i2, ')
          ..write('i4: $i4')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, i2, i4);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Int &&
          other.id == this.id &&
          other.i2 == this.i2 &&
          other.i4 == this.i4);
}

class IntsCompanion extends UpdateCompanion<Int> {
  final Value<String> id;
  final Value<int?> i2;
  final Value<int?> i4;
  final Value<int> rowid;
  const IntsCompanion({
    this.id = const Value.absent(),
    this.i2 = const Value.absent(),
    this.i4 = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  IntsCompanion.insert({
    required String id,
    this.i2 = const Value.absent(),
    this.i4 = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<Int> custom({
    Expression<String>? id,
    Expression<int>? i2,
    Expression<int>? i4,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (i2 != null) 'i2': i2,
      if (i4 != null) 'i4': i4,
      if (rowid != null) 'rowid': rowid,
    });
  }

  IntsCompanion copyWith(
      {Value<String>? id,
      Value<int?>? i2,
      Value<int?>? i4,
      Value<int>? rowid}) {
    return IntsCompanion(
      id: id ?? this.id,
      i2: i2 ?? this.i2,
      i4: i4 ?? this.i4,
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
      final converter = $IntsTable.$converteri2n;

      map['i2'] = Variable<int>(converter.toSql(i2.value));
    }
    if (i4.present) {
      final converter = $IntsTable.$converteri4n;

      map['i4'] = Variable<int>(converter.toSql(i4.value));
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
  static const VerificationMeta _f8Meta = const VerificationMeta('f8');
  @override
  late final GeneratedColumn<double> f8 = GeneratedColumn<double>(
      'f8', aliasedName, true,
      type: const Float8Type(), requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, f8];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'Floats';
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
      f8: attachedDatabase.typeMapping
          .read(const Float8Type(), data['${effectivePrefix}f8']),
    );
  }

  @override
  $FloatsTable createAlias(String alias) {
    return $FloatsTable(attachedDatabase, alias);
  }
}

class Float extends DataClass implements Insertable<Float> {
  final String id;
  final double? f8;
  const Float({required this.id, this.f8});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || f8 != null) {
      map['f8'] = Variable<double>(f8);
    }
    return map;
  }

  FloatsCompanion toCompanion(bool nullToAbsent) {
    return FloatsCompanion(
      id: Value(id),
      f8: f8 == null && nullToAbsent ? const Value.absent() : Value(f8),
    );
  }

  factory Float.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Float(
      id: serializer.fromJson<String>(json['id']),
      f8: serializer.fromJson<double?>(json['f8']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'f8': serializer.toJson<double?>(f8),
    };
  }

  Float copyWith({String? id, Value<double?> f8 = const Value.absent()}) =>
      Float(
        id: id ?? this.id,
        f8: f8.present ? f8.value : this.f8,
      );
  @override
  String toString() {
    return (StringBuffer('Float(')
          ..write('id: $id, ')
          ..write('f8: $f8')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, f8);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Float && other.id == this.id && other.f8 == this.f8);
}

class FloatsCompanion extends UpdateCompanion<Float> {
  final Value<String> id;
  final Value<double?> f8;
  final Value<int> rowid;
  const FloatsCompanion({
    this.id = const Value.absent(),
    this.f8 = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FloatsCompanion.insert({
    required String id,
    this.f8 = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<Float> custom({
    Expression<String>? id,
    Expression<double>? f8,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (f8 != null) 'f8': f8,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FloatsCompanion copyWith(
      {Value<String>? id, Value<double?>? f8, Value<int>? rowid}) {
    return FloatsCompanion(
      id: id ?? this.id,
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
    if (f8.present) {
      map['f8'] = Variable<double>(f8.value, const Float8Type());
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
          ..write('f8: $f8, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$ClientDatabase extends GeneratedDatabase {
  _$ClientDatabase(QueryExecutor e) : super(e);
  late final $ItemsTable items = $ItemsTable(this);
  late final $OtherItemsTable otherItems = $OtherItemsTable(this);
  late final $TimestampsTable timestamps = $TimestampsTable(this);
  late final $DatetimesTable datetimes = $DatetimesTable(this);
  late final $BoolsTable bools = $BoolsTable(this);
  late final $UuidsTable uuids = $UuidsTable(this);
  late final $IntsTable ints = $IntsTable(this);
  late final $FloatsTable floats = $FloatsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [items, otherItems, timestamps, datetimes, bools, uuids, ints, floats];
}
