// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TodoTable extends Todo with TableInfo<$TodoTable, TodoData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodoTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _listidMeta = const VerificationMeta('listid');
  @override
  late final GeneratedColumn<String> listid = GeneratedColumn<String>(
      'listid', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _text$Meta = const VerificationMeta('text\$');
  @override
  late final GeneratedColumn<String> text$ = GeneratedColumn<String>(
      'text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _completedMeta =
      const VerificationMeta('completed');
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
      'completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("completed" IN (0, 1))'));
  static const VerificationMeta _editedAtMeta =
      const VerificationMeta('editedAt');
  @override
  late final GeneratedColumn<DateTime> editedAt = GeneratedColumn<DateTime>(
      'edited_at', aliasedName, false,
      type: ElectricTypes.timestampTZ, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, listid, text$, completed, editedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todo';
  @override
  VerificationContext validateIntegrity(Insertable<TodoData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('listid')) {
      context.handle(_listidMeta,
          listid.isAcceptableOrUnknown(data['listid']!, _listidMeta));
    }
    if (data.containsKey('text')) {
      context.handle(
          _text$Meta, text$.isAcceptableOrUnknown(data['text']!, _text$Meta));
    }
    if (data.containsKey('completed')) {
      context.handle(_completedMeta,
          completed.isAcceptableOrUnknown(data['completed']!, _completedMeta));
    } else if (isInserting) {
      context.missing(_completedMeta);
    }
    if (data.containsKey('edited_at')) {
      context.handle(_editedAtMeta,
          editedAt.isAcceptableOrUnknown(data['edited_at']!, _editedAtMeta));
    } else if (isInserting) {
      context.missing(_editedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TodoData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TodoData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      listid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}listid']),
      text$: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}text']),
      completed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}completed'])!,
      editedAt: attachedDatabase.typeMapping.read(
          ElectricTypes.timestampTZ, data['${effectivePrefix}edited_at'])!,
    );
  }

  @override
  $TodoTable createAlias(String alias) {
    return $TodoTable(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
}

class TodoData extends DataClass implements Insertable<TodoData> {
  final String id;
  final String? listid;
  final String? text$;
  final bool completed;
  final DateTime editedAt;
  const TodoData(
      {required this.id,
      this.listid,
      this.text$,
      required this.completed,
      required this.editedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || listid != null) {
      map['listid'] = Variable<String>(listid);
    }
    if (!nullToAbsent || text$ != null) {
      map['text'] = Variable<String>(text$);
    }
    map['completed'] = Variable<bool>(completed);
    map['edited_at'] = Variable<DateTime>(editedAt, ElectricTypes.timestampTZ);
    return map;
  }

  TodoCompanion toCompanion(bool nullToAbsent) {
    return TodoCompanion(
      id: Value(id),
      listid:
          listid == null && nullToAbsent ? const Value.absent() : Value(listid),
      text$:
          text$ == null && nullToAbsent ? const Value.absent() : Value(text$),
      completed: Value(completed),
      editedAt: Value(editedAt),
    );
  }

  factory TodoData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TodoData(
      id: serializer.fromJson<String>(json['id']),
      listid: serializer.fromJson<String?>(json['listid']),
      text$: serializer.fromJson<String?>(json['text\$']),
      completed: serializer.fromJson<bool>(json['completed']),
      editedAt: serializer.fromJson<DateTime>(json['editedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'listid': serializer.toJson<String?>(listid),
      'text\$': serializer.toJson<String?>(text$),
      'completed': serializer.toJson<bool>(completed),
      'editedAt': serializer.toJson<DateTime>(editedAt),
    };
  }

  TodoData copyWith(
          {String? id,
          Value<String?> listid = const Value.absent(),
          Value<String?> text$ = const Value.absent(),
          bool? completed,
          DateTime? editedAt}) =>
      TodoData(
        id: id ?? this.id,
        listid: listid.present ? listid.value : this.listid,
        text$: text$.present ? text$.value : this.text$,
        completed: completed ?? this.completed,
        editedAt: editedAt ?? this.editedAt,
      );
  @override
  String toString() {
    return (StringBuffer('TodoData(')
          ..write('id: $id, ')
          ..write('listid: $listid, ')
          ..write('text\$: ${text$}, ')
          ..write('completed: $completed, ')
          ..write('editedAt: $editedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, listid, text$, completed, editedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TodoData &&
          other.id == this.id &&
          other.listid == this.listid &&
          other.text$ == this.text$ &&
          other.completed == this.completed &&
          other.editedAt == this.editedAt);
}

class TodoCompanion extends UpdateCompanion<TodoData> {
  final Value<String> id;
  final Value<String?> listid;
  final Value<String?> text$;
  final Value<bool> completed;
  final Value<DateTime> editedAt;
  const TodoCompanion({
    this.id = const Value.absent(),
    this.listid = const Value.absent(),
    this.text$ = const Value.absent(),
    this.completed = const Value.absent(),
    this.editedAt = const Value.absent(),
  });
  TodoCompanion.insert({
    required String id,
    this.listid = const Value.absent(),
    this.text$ = const Value.absent(),
    required bool completed,
    required DateTime editedAt,
  })  : id = Value(id),
        completed = Value(completed),
        editedAt = Value(editedAt);
  static Insertable<TodoData> custom({
    Expression<String>? id,
    Expression<String>? listid,
    Expression<String>? text$,
    Expression<bool>? completed,
    Expression<DateTime>? editedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listid != null) 'listid': listid,
      if (text$ != null) 'text': text$,
      if (completed != null) 'completed': completed,
      if (editedAt != null) 'edited_at': editedAt,
    });
  }

  TodoCompanion copyWith(
      {Value<String>? id,
      Value<String?>? listid,
      Value<String?>? text$,
      Value<bool>? completed,
      Value<DateTime>? editedAt}) {
    return TodoCompanion(
      id: id ?? this.id,
      listid: listid ?? this.listid,
      text$: text$ ?? this.text$,
      completed: completed ?? this.completed,
      editedAt: editedAt ?? this.editedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (listid.present) {
      map['listid'] = Variable<String>(listid.value);
    }
    if (text$.present) {
      map['text'] = Variable<String>(text$.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (editedAt.present) {
      map['edited_at'] =
          Variable<DateTime>(editedAt.value, ElectricTypes.timestampTZ);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodoCompanion(')
          ..write('id: $id, ')
          ..write('listid: $listid, ')
          ..write('text\$: ${text$}, ')
          ..write('completed: $completed, ')
          ..write('editedAt: $editedAt')
          ..write(')'))
        .toString();
  }
}

class $TodolistTable extends Todolist
    with TableInfo<$TodolistTable, TodolistData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodolistTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _filterMeta = const VerificationMeta('filter');
  @override
  late final GeneratedColumn<String> filter = GeneratedColumn<String>(
      'filter', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _editingMeta =
      const VerificationMeta('editing');
  @override
  late final GeneratedColumn<String> editing = GeneratedColumn<String>(
      'editing', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, filter, editing];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'todolist';
  @override
  VerificationContext validateIntegrity(Insertable<TodolistData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('filter')) {
      context.handle(_filterMeta,
          filter.isAcceptableOrUnknown(data['filter']!, _filterMeta));
    }
    if (data.containsKey('editing')) {
      context.handle(_editingMeta,
          editing.isAcceptableOrUnknown(data['editing']!, _editingMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TodolistData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TodolistData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      filter: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}filter']),
      editing: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}editing']),
    );
  }

  @override
  $TodolistTable createAlias(String alias) {
    return $TodolistTable(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
}

class TodolistData extends DataClass implements Insertable<TodolistData> {
  final String id;
  final String? filter;
  final String? editing;
  const TodolistData({required this.id, this.filter, this.editing});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || filter != null) {
      map['filter'] = Variable<String>(filter);
    }
    if (!nullToAbsent || editing != null) {
      map['editing'] = Variable<String>(editing);
    }
    return map;
  }

  TodolistCompanion toCompanion(bool nullToAbsent) {
    return TodolistCompanion(
      id: Value(id),
      filter:
          filter == null && nullToAbsent ? const Value.absent() : Value(filter),
      editing: editing == null && nullToAbsent
          ? const Value.absent()
          : Value(editing),
    );
  }

  factory TodolistData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TodolistData(
      id: serializer.fromJson<String>(json['id']),
      filter: serializer.fromJson<String?>(json['filter']),
      editing: serializer.fromJson<String?>(json['editing']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'filter': serializer.toJson<String?>(filter),
      'editing': serializer.toJson<String?>(editing),
    };
  }

  TodolistData copyWith(
          {String? id,
          Value<String?> filter = const Value.absent(),
          Value<String?> editing = const Value.absent()}) =>
      TodolistData(
        id: id ?? this.id,
        filter: filter.present ? filter.value : this.filter,
        editing: editing.present ? editing.value : this.editing,
      );
  @override
  String toString() {
    return (StringBuffer('TodolistData(')
          ..write('id: $id, ')
          ..write('filter: $filter, ')
          ..write('editing: $editing')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, filter, editing);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TodolistData &&
          other.id == this.id &&
          other.filter == this.filter &&
          other.editing == this.editing);
}

class TodolistCompanion extends UpdateCompanion<TodolistData> {
  final Value<String> id;
  final Value<String?> filter;
  final Value<String?> editing;
  const TodolistCompanion({
    this.id = const Value.absent(),
    this.filter = const Value.absent(),
    this.editing = const Value.absent(),
  });
  TodolistCompanion.insert({
    required String id,
    this.filter = const Value.absent(),
    this.editing = const Value.absent(),
  }) : id = Value(id);
  static Insertable<TodolistData> custom({
    Expression<String>? id,
    Expression<String>? filter,
    Expression<String>? editing,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (filter != null) 'filter': filter,
      if (editing != null) 'editing': editing,
    });
  }

  TodolistCompanion copyWith(
      {Value<String>? id, Value<String?>? filter, Value<String?>? editing}) {
    return TodolistCompanion(
      id: id ?? this.id,
      filter: filter ?? this.filter,
      editing: editing ?? this.editing,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (filter.present) {
      map['filter'] = Variable<String>(filter.value);
    }
    if (editing.present) {
      map['editing'] = Variable<String>(editing.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodolistCompanion(')
          ..write('id: $id, ')
          ..write('filter: $filter, ')
          ..write('editing: $editing')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $TodoTable todo = $TodoTable(this);
  late final $TodolistTable todolist = $TodolistTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [todo, todolist];
}
