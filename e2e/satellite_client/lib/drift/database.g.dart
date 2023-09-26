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
  String get aliasedName => _alias ?? 'Items';
  @override
  String get actualTableName => 'Items';
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
  String get aliasedName => _alias ?? 'OtherItems';
  @override
  String get actualTableName => 'OtherItems';
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
  String get aliasedName => _alias ?? 'Timestamps';
  @override
  String get actualTableName => 'Timestamps';
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
  String get aliasedName => _alias ?? 'Datetimes';
  @override
  String get actualTableName => 'Datetimes';
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

abstract class _$ClientDatabase extends GeneratedDatabase {
  _$ClientDatabase(QueryExecutor e) : super(e);
  late final $ItemsTable items = $ItemsTable(this);
  late final $OtherItemsTable otherItems = $OtherItemsTable(this);
  late final $TimestampsTable timestamps = $TimestampsTable(this);
  late final $DatetimesTable datetimes = $DatetimesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [items, otherItems, timestamps, datetimes];
}
