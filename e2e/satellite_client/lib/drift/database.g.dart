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

  @override
  bool get withoutRowId => true;
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
  const ItemsCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.contentTextNull = const Value.absent(),
    this.contentTextNullDefault = const Value.absent(),
    this.intvalueNull = const Value.absent(),
    this.intvalueNullDefault = const Value.absent(),
  });
  ItemsCompanion.insert({
    required String id,
    required String content,
    this.contentTextNull = const Value.absent(),
    this.contentTextNullDefault = const Value.absent(),
    this.intvalueNull = const Value.absent(),
    this.intvalueNullDefault = const Value.absent(),
  })  : id = Value(id),
        content = Value(content);
  static Insertable<Item> custom({
    Expression<String>? id,
    Expression<String>? content,
    Expression<String>? contentTextNull,
    Expression<String>? contentTextNullDefault,
    Expression<int>? intvalueNull,
    Expression<int>? intvalueNullDefault,
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
    });
  }

  ItemsCompanion copyWith(
      {Value<String>? id,
      Value<String>? content,
      Value<String?>? contentTextNull,
      Value<String?>? contentTextNullDefault,
      Value<int?>? intvalueNull,
      Value<int?>? intvalueNullDefault}) {
    return ItemsCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      contentTextNull: contentTextNull ?? this.contentTextNull,
      contentTextNullDefault:
          contentTextNullDefault ?? this.contentTextNullDefault,
      intvalueNull: intvalueNull ?? this.intvalueNull,
      intvalueNullDefault: intvalueNullDefault ?? this.intvalueNullDefault,
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
          ..write('intvalueNullDefault: $intvalueNullDefault')
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

  @override
  bool get withoutRowId => true;
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
  const OtherItemsCompanion({
    this.id = const Value.absent(),
    this.content = const Value.absent(),
    this.itemId = const Value.absent(),
  });
  OtherItemsCompanion.insert({
    required String id,
    required String content,
    this.itemId = const Value.absent(),
  })  : id = Value(id),
        content = Value(content);
  static Insertable<OtherItem> custom({
    Expression<String>? id,
    Expression<String>? content,
    Expression<String>? itemId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (content != null) 'content': content,
      if (itemId != null) 'item_id': itemId,
    });
  }

  OtherItemsCompanion copyWith(
      {Value<String>? id, Value<String>? content, Value<String?>? itemId}) {
    return OtherItemsCompanion(
      id: id ?? this.id,
      content: content ?? this.content,
      itemId: itemId ?? this.itemId,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OtherItemsCompanion(')
          ..write('id: $id, ')
          ..write('content: $content, ')
          ..write('itemId: $itemId')
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

  @override
  bool get withoutRowId => true;
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
  const TimestampsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TimestampsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
  })  : id = Value(id),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Timestamp> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TimestampsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return TimestampsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimestampsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
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

  @override
  bool get withoutRowId => true;
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
  const DatetimesCompanion({
    this.id = const Value.absent(),
    this.d = const Value.absent(),
    this.t = const Value.absent(),
  });
  DatetimesCompanion.insert({
    required String id,
    required DateTime d,
    required DateTime t,
  })  : id = Value(id),
        d = Value(d),
        t = Value(t);
  static Insertable<Datetime> custom({
    Expression<String>? id,
    Expression<DateTime>? d,
    Expression<DateTime>? t,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (d != null) 'd': d,
      if (t != null) 't': t,
    });
  }

  DatetimesCompanion copyWith(
      {Value<String>? id, Value<DateTime>? d, Value<DateTime>? t}) {
    return DatetimesCompanion(
      id: id ?? this.id,
      d: d ?? this.d,
      t: t ?? this.t,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DatetimesCompanion(')
          ..write('id: $id, ')
          ..write('d: $d, ')
          ..write('t: $t')
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

  @override
  bool get withoutRowId => true;
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
  const BoolsCompanion({
    this.id = const Value.absent(),
    this.b = const Value.absent(),
  });
  BoolsCompanion.insert({
    required String id,
    this.b = const Value.absent(),
  }) : id = Value(id);
  static Insertable<Bool> custom({
    Expression<String>? id,
    Expression<bool>? b,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (b != null) 'b': b,
    });
  }

  BoolsCompanion copyWith({Value<String>? id, Value<bool?>? b}) {
    return BoolsCompanion(
      id: id ?? this.id,
      b: b ?? this.b,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BoolsCompanion(')
          ..write('id: $id, ')
          ..write('b: $b')
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

  @override
  bool get withoutRowId => true;
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
  const UuidsCompanion({
    this.id = const Value.absent(),
  });
  UuidsCompanion.insert({
    required String id,
  }) : id = Value(id);
  static Insertable<Uuid> custom({
    Expression<String>? id,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
    });
  }

  UuidsCompanion copyWith({Value<String>? id}) {
    return UuidsCompanion(
      id: id ?? this.id,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value, ElectricTypes.uuid);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UuidsCompanion(')
          ..write('id: $id')
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

  @override
  bool get withoutRowId => true;
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
  const IntsCompanion({
    this.id = const Value.absent(),
    this.i2 = const Value.absent(),
    this.i4 = const Value.absent(),
    this.i8 = const Value.absent(),
  });
  IntsCompanion.insert({
    required String id,
    this.i2 = const Value.absent(),
    this.i4 = const Value.absent(),
    this.i8 = const Value.absent(),
  }) : id = Value(id);
  static Insertable<Int> custom({
    Expression<String>? id,
    Expression<int>? i2,
    Expression<int>? i4,
    Expression<BigInt>? i8,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (i2 != null) 'i2': i2,
      if (i4 != null) 'i4': i4,
      if (i8 != null) 'i8': i8,
    });
  }

  IntsCompanion copyWith(
      {Value<String>? id,
      Value<int?>? i2,
      Value<int?>? i4,
      Value<BigInt?>? i8}) {
    return IntsCompanion(
      id: id ?? this.id,
      i2: i2 ?? this.i2,
      i4: i4 ?? this.i4,
      i8: i8 ?? this.i8,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IntsCompanion(')
          ..write('id: $id, ')
          ..write('i2: $i2, ')
          ..write('i4: $i4, ')
          ..write('i8: $i8')
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

  @override
  bool get withoutRowId => true;
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
  const FloatsCompanion({
    this.id = const Value.absent(),
    this.f4 = const Value.absent(),
    this.f8 = const Value.absent(),
  });
  FloatsCompanion.insert({
    required String id,
    this.f4 = const Value.absent(),
    this.f8 = const Value.absent(),
  }) : id = Value(id);
  static Insertable<Float> custom({
    Expression<String>? id,
    Expression<double>? f4,
    Expression<double>? f8,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (f4 != null) 'f4': f4,
      if (f8 != null) 'f8': f8,
    });
  }

  FloatsCompanion copyWith(
      {Value<String>? id, Value<double?>? f4, Value<double?>? f8}) {
    return FloatsCompanion(
      id: id ?? this.id,
      f4: f4 ?? this.f4,
      f8: f8 ?? this.f8,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FloatsCompanion(')
          ..write('id: $id, ')
          ..write('f4: $f4, ')
          ..write('f8: $f8')
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
  static const VerificationMeta _jsMeta = const VerificationMeta('js');
  @override
  late final GeneratedColumn<Object> js = GeneratedColumn<Object>(
      'js', aliasedName, true,
      type: ElectricTypes.json, requiredDuringInsert: false);
  static const VerificationMeta _jsbMeta = const VerificationMeta('jsb');
  @override
  late final GeneratedColumn<Object> jsb = GeneratedColumn<Object>(
      'jsb', aliasedName, true,
      type: ElectricTypes.jsonb, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, js, jsb];
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
    if (data.containsKey('js')) {
      context.handle(_jsMeta, js.isAcceptableOrUnknown(data['js']!, _jsMeta));
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
      js: attachedDatabase.typeMapping
          .read(ElectricTypes.json, data['${effectivePrefix}js']),
      jsb: attachedDatabase.typeMapping
          .read(ElectricTypes.jsonb, data['${effectivePrefix}jsb']),
    );
  }

  @override
  $JsonsTable createAlias(String alias) {
    return $JsonsTable(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
}

class Json extends DataClass implements Insertable<Json> {
  final String id;
  final Object? js;
  final Object? jsb;
  const Json({required this.id, this.js, this.jsb});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || js != null) {
      map['js'] = Variable<Object>(js, ElectricTypes.json);
    }
    if (!nullToAbsent || jsb != null) {
      map['jsb'] = Variable<Object>(jsb, ElectricTypes.jsonb);
    }
    return map;
  }

  JsonsCompanion toCompanion(bool nullToAbsent) {
    return JsonsCompanion(
      id: Value(id),
      js: js == null && nullToAbsent ? const Value.absent() : Value(js),
      jsb: jsb == null && nullToAbsent ? const Value.absent() : Value(jsb),
    );
  }

  factory Json.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Json(
      id: serializer.fromJson<String>(json['id']),
      js: serializer.fromJson<Object?>(json['js']),
      jsb: serializer.fromJson<Object?>(json['jsb']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'js': serializer.toJson<Object?>(js),
      'jsb': serializer.toJson<Object?>(jsb),
    };
  }

  Json copyWith(
          {String? id,
          Value<Object?> js = const Value.absent(),
          Value<Object?> jsb = const Value.absent()}) =>
      Json(
        id: id ?? this.id,
        js: js.present ? js.value : this.js,
        jsb: jsb.present ? jsb.value : this.jsb,
      );
  @override
  String toString() {
    return (StringBuffer('Json(')
          ..write('id: $id, ')
          ..write('js: $js, ')
          ..write('jsb: $jsb')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, js, jsb);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Json &&
          other.id == this.id &&
          other.js == this.js &&
          other.jsb == this.jsb);
}

class JsonsCompanion extends UpdateCompanion<Json> {
  final Value<String> id;
  final Value<Object?> js;
  final Value<Object?> jsb;
  const JsonsCompanion({
    this.id = const Value.absent(),
    this.js = const Value.absent(),
    this.jsb = const Value.absent(),
  });
  JsonsCompanion.insert({
    required String id,
    this.js = const Value.absent(),
    this.jsb = const Value.absent(),
  }) : id = Value(id);
  static Insertable<Json> custom({
    Expression<String>? id,
    Expression<Object>? js,
    Expression<Object>? jsb,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (js != null) 'js': js,
      if (jsb != null) 'jsb': jsb,
    });
  }

  JsonsCompanion copyWith(
      {Value<String>? id, Value<Object?>? js, Value<Object?>? jsb}) {
    return JsonsCompanion(
      id: id ?? this.id,
      js: js ?? this.js,
      jsb: jsb ?? this.jsb,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (js.present) {
      map['js'] = Variable<Object>(js.value, ElectricTypes.json);
    }
    if (jsb.present) {
      map['jsb'] = Variable<Object>(jsb.value, ElectricTypes.jsonb);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('JsonsCompanion(')
          ..write('id: $id, ')
          ..write('js: $js, ')
          ..write('jsb: $jsb')
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
  static const String $name = 'Enums';
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

  @override
  bool get withoutRowId => true;
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
  const EnumsCompanion({
    this.id = const Value.absent(),
    this.c = const Value.absent(),
  });
  EnumsCompanion.insert({
    required String id,
    this.c = const Value.absent(),
  }) : id = Value(id);
  static Insertable<Enum> custom({
    Expression<String>? id,
    Expression<DbColor>? c,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (c != null) 'c': c,
    });
  }

  EnumsCompanion copyWith({Value<String>? id, Value<DbColor?>? c}) {
    return EnumsCompanion(
      id: id ?? this.id,
      c: c ?? this.c,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnumsCompanion(')
          ..write('id: $id, ')
          ..write('c: $c')
          ..write(')'))
        .toString();
  }
}

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

  @override
  bool get withoutRowId => true;
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
  const BlobsCompanion({
    this.id = const Value.absent(),
    this.blob$ = const Value.absent(),
  });
  BlobsCompanion.insert({
    required String id,
    this.blob$ = const Value.absent(),
  }) : id = Value(id);
  static Insertable<Blob> custom({
    Expression<String>? id,
    Expression<Uint8List>? blob$,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (blob$ != null) 'blob': blob$,
    });
  }

  BlobsCompanion copyWith({Value<String>? id, Value<Uint8List?>? blob$}) {
    return BlobsCompanion(
      id: id ?? this.id,
      blob$: blob$ ?? this.blob$,
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
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BlobsCompanion(')
          ..write('id: $id, ')
          ..write('blob\$: ${blob$}')
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
  late final $JsonsTable jsons = $JsonsTable(this);
  late final $EnumsTable enums = $EnumsTable(this);
  late final $BlobsTable blobs = $BlobsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        items,
        otherItems,
        timestamps,
        datetimes,
        bools,
        uuids,
        ints,
        floats,
        jsons,
        enums,
        blobs
      ];
}
