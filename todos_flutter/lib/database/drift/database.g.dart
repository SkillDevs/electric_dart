// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $TodosTable extends Todos with TableInfo<$TodosTable, Todo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _textColMeta =
      const VerificationMeta('textCol');
  @override
  late final GeneratedColumn<String> textCol = GeneratedColumn<String>(
      'text', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _completedMeta =
      const VerificationMeta('completed');
  @override
  late final GeneratedColumn<bool> completed =
      GeneratedColumn<bool>('completed', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintsDependsOnDialect({
            SqlDialect.sqlite: 'CHECK ("completed" IN (0, 1))',
            SqlDialect.mysql: '',
            SqlDialect.postgres: '',
          }),
          defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [id, listid, textCol, completed];
  @override
  String get aliasedName => _alias ?? 'todo';
  @override
  String get actualTableName => 'todo';
  @override
  VerificationContext validateIntegrity(Insertable<Todo> instance,
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
      context.handle(_textColMeta,
          textCol.isAcceptableOrUnknown(data['text']!, _textColMeta));
    }
    if (data.containsKey('completed')) {
      context.handle(_completedMeta,
          completed.isAcceptableOrUnknown(data['completed']!, _completedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Todo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Todo(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      listid: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}listid']),
      textCol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}text']),
      completed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}completed'])!,
    );
  }

  @override
  $TodosTable createAlias(String alias) {
    return $TodosTable(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
}

class Todo extends DataClass implements Insertable<Todo> {
  final String id;
  final String? listid;
  final String? textCol;
  final bool completed;
  const Todo(
      {required this.id, this.listid, this.textCol, required this.completed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || listid != null) {
      map['listid'] = Variable<String>(listid);
    }
    if (!nullToAbsent || textCol != null) {
      map['text'] = Variable<String>(textCol);
    }
    map['completed'] = Variable<bool>(completed);
    return map;
  }

  TodosCompanion toCompanion(bool nullToAbsent) {
    return TodosCompanion(
      id: Value(id),
      listid:
          listid == null && nullToAbsent ? const Value.absent() : Value(listid),
      textCol: textCol == null && nullToAbsent
          ? const Value.absent()
          : Value(textCol),
      completed: Value(completed),
    );
  }

  factory Todo.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Todo(
      id: serializer.fromJson<String>(json['id']),
      listid: serializer.fromJson<String?>(json['listid']),
      textCol: serializer.fromJson<String?>(json['textCol']),
      completed: serializer.fromJson<bool>(json['completed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'listid': serializer.toJson<String?>(listid),
      'textCol': serializer.toJson<String?>(textCol),
      'completed': serializer.toJson<bool>(completed),
    };
  }

  Todo copyWith(
          {String? id,
          Value<String?> listid = const Value.absent(),
          Value<String?> textCol = const Value.absent(),
          bool? completed}) =>
      Todo(
        id: id ?? this.id,
        listid: listid.present ? listid.value : this.listid,
        textCol: textCol.present ? textCol.value : this.textCol,
        completed: completed ?? this.completed,
      );
  @override
  String toString() {
    return (StringBuffer('Todo(')
          ..write('id: $id, ')
          ..write('listid: $listid, ')
          ..write('textCol: $textCol, ')
          ..write('completed: $completed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, listid, textCol, completed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Todo &&
          other.id == this.id &&
          other.listid == this.listid &&
          other.textCol == this.textCol &&
          other.completed == this.completed);
}

class TodosCompanion extends UpdateCompanion<Todo> {
  final Value<String> id;
  final Value<String?> listid;
  final Value<String?> textCol;
  final Value<bool> completed;
  const TodosCompanion({
    this.id = const Value.absent(),
    this.listid = const Value.absent(),
    this.textCol = const Value.absent(),
    this.completed = const Value.absent(),
  });
  TodosCompanion.insert({
    required String id,
    this.listid = const Value.absent(),
    this.textCol = const Value.absent(),
    this.completed = const Value.absent(),
  }) : id = Value(id);
  static Insertable<Todo> custom({
    Expression<String>? id,
    Expression<String>? listid,
    Expression<String>? textCol,
    Expression<bool>? completed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (listid != null) 'listid': listid,
      if (textCol != null) 'text': textCol,
      if (completed != null) 'completed': completed,
    });
  }

  TodosCompanion copyWith(
      {Value<String>? id,
      Value<String?>? listid,
      Value<String?>? textCol,
      Value<bool>? completed}) {
    return TodosCompanion(
      id: id ?? this.id,
      listid: listid ?? this.listid,
      textCol: textCol ?? this.textCol,
      completed: completed ?? this.completed,
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
    if (textCol.present) {
      map['text'] = Variable<String>(textCol.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TodosCompanion(')
          ..write('id: $id, ')
          ..write('listid: $listid, ')
          ..write('textCol: $textCol, ')
          ..write('completed: $completed')
          ..write(')'))
        .toString();
  }
}

class $TodoListsTable extends TodoLists
    with TableInfo<$TodoListsTable, TodoList> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TodoListsTable(this.attachedDatabase, [this._alias]);
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
  String get aliasedName => _alias ?? 'todolist';
  @override
  String get actualTableName => 'todolist';
  @override
  VerificationContext validateIntegrity(Insertable<TodoList> instance,
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
  TodoList map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TodoList(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      filter: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}filter']),
      editing: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}editing']),
    );
  }

  @override
  $TodoListsTable createAlias(String alias) {
    return $TodoListsTable(attachedDatabase, alias);
  }

  @override
  bool get withoutRowId => true;
}

class TodoList extends DataClass implements Insertable<TodoList> {
  final String id;
  final String? filter;
  final String? editing;
  const TodoList({required this.id, this.filter, this.editing});
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

  TodoListsCompanion toCompanion(bool nullToAbsent) {
    return TodoListsCompanion(
      id: Value(id),
      filter:
          filter == null && nullToAbsent ? const Value.absent() : Value(filter),
      editing: editing == null && nullToAbsent
          ? const Value.absent()
          : Value(editing),
    );
  }

  factory TodoList.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TodoList(
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

  TodoList copyWith(
          {String? id,
          Value<String?> filter = const Value.absent(),
          Value<String?> editing = const Value.absent()}) =>
      TodoList(
        id: id ?? this.id,
        filter: filter.present ? filter.value : this.filter,
        editing: editing.present ? editing.value : this.editing,
      );
  @override
  String toString() {
    return (StringBuffer('TodoList(')
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
      (other is TodoList &&
          other.id == this.id &&
          other.filter == this.filter &&
          other.editing == this.editing);
}

class TodoListsCompanion extends UpdateCompanion<TodoList> {
  final Value<String> id;
  final Value<String?> filter;
  final Value<String?> editing;
  const TodoListsCompanion({
    this.id = const Value.absent(),
    this.filter = const Value.absent(),
    this.editing = const Value.absent(),
  });
  TodoListsCompanion.insert({
    required String id,
    this.filter = const Value.absent(),
    this.editing = const Value.absent(),
  }) : id = Value(id);
  static Insertable<TodoList> custom({
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

  TodoListsCompanion copyWith(
      {Value<String>? id, Value<String?>? filter, Value<String?>? editing}) {
    return TodoListsCompanion(
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
    return (StringBuffer('TodoListsCompanion(')
          ..write('id: $id, ')
          ..write('filter: $filter, ')
          ..write('editing: $editing')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  late final $TodosTable todos = $TodosTable(this);
  late final $TodoListsTable todoLists = $TodoListsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [todos, todoLists];
}
