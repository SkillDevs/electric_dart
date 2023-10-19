// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
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
      type: DriftSqlType.int, requiredDuringInsert: false);
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
          .read(DriftSqlType.int, data['${effectivePrefix}nbr']),
    );
  }

  @override
  $ItemsTable createAlias(String alias) {
    return $ItemsTable(attachedDatabase, alias);
  }
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
      map['nbr'] = Variable<int>(nbr);
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
  final Value<int> rowid;
  const ItemsCompanion({
    this.value = const Value.absent(),
    this.nbr = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ItemsCompanion.insert({
    required String value,
    this.nbr = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : value = Value(value);
  static Insertable<Item> custom({
    Expression<String>? value,
    Expression<int>? nbr,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (value != null) 'value': value,
      if (nbr != null) 'nbr': nbr,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ItemsCompanion copyWith(
      {Value<String>? value, Value<int?>? nbr, Value<int>? rowid}) {
    return ItemsCompanion(
      value: value ?? this.value,
      nbr: nbr ?? this.nbr,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (nbr.present) {
      map['nbr'] = Variable<int>(nbr.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItemsCompanion(')
          ..write('value: $value, ')
          ..write('nbr: $nbr, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'User';
  @override
  VerificationContext validateIntegrity(Insertable<User> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final int id;
  final String? name;
  const User({required this.id, this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
    );
  }

  factory User.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String?>(name),
    };
  }

  User copyWith({int? id, Value<String?> name = const Value.absent()}) => User(
        id: id ?? this.id,
        name: name.present ? name.value : this.name,
      );
  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User && other.id == this.id && other.name == this.name);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String?> name;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  UsersCompanion copyWith({Value<int>? id, Value<String?>? name}) {
    return UsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $PostsTable extends Posts with TableInfo<$PostsTable, Post> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
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
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _authorIdMeta =
      const VerificationMeta('authorId');
  @override
  late final GeneratedColumn<int> authorId = GeneratedColumn<int>(
      'authorId', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES User (id)'));
  @override
  List<GeneratedColumn> get $columns => [id, title, contents, nbr, authorId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'Post';
  @override
  VerificationContext validateIntegrity(Insertable<Post> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
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
  Post map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Post(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      contents: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contents'])!,
      nbr: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}nbr']),
      authorId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}authorId'])!,
    );
  }

  @override
  $PostsTable createAlias(String alias) {
    return $PostsTable(attachedDatabase, alias);
  }
}

class Post extends DataClass implements Insertable<Post> {
  final int id;
  final String title;
  final String contents;
  final int? nbr;
  final int authorId;
  const Post(
      {required this.id,
      required this.title,
      required this.contents,
      this.nbr,
      required this.authorId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['contents'] = Variable<String>(contents);
    if (!nullToAbsent || nbr != null) {
      map['nbr'] = Variable<int>(nbr);
    }
    map['authorId'] = Variable<int>(authorId);
    return map;
  }

  PostsCompanion toCompanion(bool nullToAbsent) {
    return PostsCompanion(
      id: Value(id),
      title: Value(title),
      contents: Value(contents),
      nbr: nbr == null && nullToAbsent ? const Value.absent() : Value(nbr),
      authorId: Value(authorId),
    );
  }

  factory Post.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Post(
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

  Post copyWith(
          {int? id,
          String? title,
          String? contents,
          Value<int?> nbr = const Value.absent(),
          int? authorId}) =>
      Post(
        id: id ?? this.id,
        title: title ?? this.title,
        contents: contents ?? this.contents,
        nbr: nbr.present ? nbr.value : this.nbr,
        authorId: authorId ?? this.authorId,
      );
  @override
  String toString() {
    return (StringBuffer('Post(')
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
      (other is Post &&
          other.id == this.id &&
          other.title == this.title &&
          other.contents == this.contents &&
          other.nbr == this.nbr &&
          other.authorId == this.authorId);
}

class PostsCompanion extends UpdateCompanion<Post> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> contents;
  final Value<int?> nbr;
  final Value<int> authorId;
  const PostsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.contents = const Value.absent(),
    this.nbr = const Value.absent(),
    this.authorId = const Value.absent(),
  });
  PostsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String contents,
    this.nbr = const Value.absent(),
    required int authorId,
  })  : title = Value(title),
        contents = Value(contents),
        authorId = Value(authorId);
  static Insertable<Post> custom({
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

  PostsCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String>? contents,
      Value<int?>? nbr,
      Value<int>? authorId}) {
    return PostsCompanion(
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
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (contents.present) {
      map['contents'] = Variable<String>(contents.value);
    }
    if (nbr.present) {
      map['nbr'] = Variable<int>(nbr.value);
    }
    if (authorId.present) {
      map['authorId'] = Variable<int>(authorId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PostsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('contents: $contents, ')
          ..write('nbr: $nbr, ')
          ..write('authorId: $authorId')
          ..write(')'))
        .toString();
  }
}

class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _bioMeta = const VerificationMeta('bio');
  @override
  late final GeneratedColumn<String> bio = GeneratedColumn<String>(
      'bio', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentsMeta =
      const VerificationMeta('contents');
  @override
  late final GeneratedColumn<String> contents = GeneratedColumn<String>(
      'contents', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
      'userId', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('UNIQUE REFERENCES User (id)'));
  @override
  List<GeneratedColumn> get $columns => [id, bio, contents, userId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'Profile';
  @override
  VerificationContext validateIntegrity(Insertable<Profile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('bio')) {
      context.handle(
          _bioMeta, bio.isAcceptableOrUnknown(data['bio']!, _bioMeta));
    } else if (isInserting) {
      context.missing(_bioMeta);
    }
    if (data.containsKey('contents')) {
      context.handle(_contentsMeta,
          contents.isAcceptableOrUnknown(data['contents']!, _contentsMeta));
    } else if (isInserting) {
      context.missing(_contentsMeta);
    }
    if (data.containsKey('userId')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['userId']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      bio: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bio'])!,
      contents: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}contents'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}userId'])!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final int id;
  final String bio;
  final String contents;
  final int userId;
  const Profile(
      {required this.id,
      required this.bio,
      required this.contents,
      required this.userId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['bio'] = Variable<String>(bio);
    map['contents'] = Variable<String>(contents);
    map['userId'] = Variable<int>(userId);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      bio: Value(bio),
      contents: Value(contents),
      userId: Value(userId),
    );
  }

  factory Profile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<int>(json['id']),
      bio: serializer.fromJson<String>(json['bio']),
      contents: serializer.fromJson<String>(json['contents']),
      userId: serializer.fromJson<int>(json['userId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'bio': serializer.toJson<String>(bio),
      'contents': serializer.toJson<String>(contents),
      'userId': serializer.toJson<int>(userId),
    };
  }

  Profile copyWith({int? id, String? bio, String? contents, int? userId}) =>
      Profile(
        id: id ?? this.id,
        bio: bio ?? this.bio,
        contents: contents ?? this.contents,
        userId: userId ?? this.userId,
      );
  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('bio: $bio, ')
          ..write('contents: $contents, ')
          ..write('userId: $userId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, bio, contents, userId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.bio == this.bio &&
          other.contents == this.contents &&
          other.userId == this.userId);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<int> id;
  final Value<String> bio;
  final Value<String> contents;
  final Value<int> userId;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.bio = const Value.absent(),
    this.contents = const Value.absent(),
    this.userId = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String bio,
    required String contents,
    required int userId,
  })  : bio = Value(bio),
        contents = Value(contents),
        userId = Value(userId);
  static Insertable<Profile> custom({
    Expression<int>? id,
    Expression<String>? bio,
    Expression<String>? contents,
    Expression<int>? userId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (bio != null) 'bio': bio,
      if (contents != null) 'contents': contents,
      if (userId != null) 'userId': userId,
    });
  }

  ProfilesCompanion copyWith(
      {Value<int>? id,
      Value<String>? bio,
      Value<String>? contents,
      Value<int>? userId}) {
    return ProfilesCompanion(
      id: id ?? this.id,
      bio: bio ?? this.bio,
      contents: contents ?? this.contents,
      userId: userId ?? this.userId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (bio.present) {
      map['bio'] = Variable<String>(bio.value);
    }
    if (contents.present) {
      map['contents'] = Variable<String>(contents.value);
    }
    if (userId.present) {
      map['userId'] = Variable<int>(userId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('bio: $bio, ')
          ..write('contents: $contents, ')
          ..write('userId: $userId')
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
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> timestamp =
      GeneratedColumn<String>('timestamp', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<DateTime?>($DummyTable.$convertertimestampn);
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
    }
    context.handle(_timestampMeta, const VerificationResult.success());
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DummyData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DummyData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      timestamp: $DummyTable.$convertertimestampn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timestamp'])),
    );
  }

  @override
  $DummyTable createAlias(String alias) {
    return $DummyTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $convertertimestamp =
      const ElectricTimestampConverter();
  static TypeConverter<DateTime?, String?> $convertertimestampn =
      NullAwareTypeConverter.wrap($convertertimestamp);
}

class DummyData extends DataClass implements Insertable<DummyData> {
  final int id;
  final DateTime? timestamp;
  const DummyData({required this.id, this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || timestamp != null) {
      final converter = $DummyTable.$convertertimestampn;
      map['timestamp'] = Variable<String>(converter.toSql(timestamp));
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
    this.id = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  static Insertable<DummyData> custom({
    Expression<int>? id,
    Expression<String>? timestamp,
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
      map['id'] = Variable<int>(id.value);
    }
    if (timestamp.present) {
      final converter = $DummyTable.$convertertimestampn;

      map['timestamp'] = Variable<String>(converter.toSql(timestamp.value));
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
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> date =
      GeneratedColumn<String>('date', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<DateTime?>($DataTypesTable.$converterdaten);
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> time =
      GeneratedColumn<String>('time', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<DateTime?>($DataTypesTable.$convertertimen);
  static const VerificationMeta _timetzMeta = const VerificationMeta('timetz');
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> timetz =
      GeneratedColumn<String>('timetz', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<DateTime?>($DataTypesTable.$convertertimetzn);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> timestamp =
      GeneratedColumn<String>('timestamp', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<DateTime?>($DataTypesTable.$convertertimestampn);
  static const VerificationMeta _timestamptzMeta =
      const VerificationMeta('timestamptz');
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> timestamptz =
      GeneratedColumn<String>('timestamptz', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<DateTime?>($DataTypesTable.$convertertimestamptzn);
  static const VerificationMeta _boolColMeta =
      const VerificationMeta('boolCol');
  @override
  late final GeneratedColumn<bool> boolCol = GeneratedColumn<bool>(
      'bool', aliasedName, true,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("bool" IN (0, 1))'));
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumnWithTypeConverter<String?, String> uuid =
      GeneratedColumn<String>('uuid', aliasedName, true,
              type: DriftSqlType.string, requiredDuringInsert: false)
          .withConverter<String?>($DataTypesTable.$converteruuidn);
  static const VerificationMeta _int2Meta = const VerificationMeta('int2');
  @override
  late final GeneratedColumn<int> int2 = GeneratedColumn<int>(
      'int2', aliasedName, true,
      type: const Int2Type(), requiredDuringInsert: false);
  static const VerificationMeta _int4Meta = const VerificationMeta('int4');
  @override
  late final GeneratedColumnWithTypeConverter<int?, int> int4 =
      GeneratedColumn<int>('int4', aliasedName, true,
              type: DriftSqlType.int, requiredDuringInsert: false)
          .withConverter<int?>($DataTypesTable.$converterint4n);
  static const VerificationMeta _float8Meta = const VerificationMeta('float8');
  @override
  late final GeneratedColumn<double> float8 = GeneratedColumn<double>(
      'float8', aliasedName, true,
      type: const Float8Type(), requiredDuringInsert: false);
  static const VerificationMeta _relatedIdMeta =
      const VerificationMeta('relatedId');
  @override
  late final GeneratedColumn<int> relatedId = GeneratedColumn<int>(
      'relatedId', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES Dummy (id)'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        date,
        time,
        timetz,
        timestamp,
        timestamptz,
        boolCol,
        uuid,
        int2,
        int4,
        float8,
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
    }
    context.handle(_dateMeta, const VerificationResult.success());
    context.handle(_timeMeta, const VerificationResult.success());
    context.handle(_timetzMeta, const VerificationResult.success());
    context.handle(_timestampMeta, const VerificationResult.success());
    context.handle(_timestamptzMeta, const VerificationResult.success());
    if (data.containsKey('bool')) {
      context.handle(_boolColMeta,
          boolCol.isAcceptableOrUnknown(data['bool']!, _boolColMeta));
    }
    context.handle(_uuidMeta, const VerificationResult.success());
    if (data.containsKey('int2')) {
      context.handle(
          _int2Meta, int2.isAcceptableOrUnknown(data['int2']!, _int2Meta));
    }
    context.handle(_int4Meta, const VerificationResult.success());
    if (data.containsKey('float8')) {
      context.handle(_float8Meta,
          float8.isAcceptableOrUnknown(data['float8']!, _float8Meta));
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
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: $DataTypesTable.$converterdaten.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}date'])),
      time: $DataTypesTable.$convertertimen.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}time'])),
      timetz: $DataTypesTable.$convertertimetzn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timetz'])),
      timestamp: $DataTypesTable.$convertertimestampn.fromSql(attachedDatabase
          .typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}timestamp'])),
      timestamptz: $DataTypesTable.$convertertimestamptzn.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.string, data['${effectivePrefix}timestamptz'])),
      boolCol: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}bool']),
      uuid: $DataTypesTable.$converteruuidn.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}uuid'])),
      int2: attachedDatabase.typeMapping
          .read(const Int2Type(), data['${effectivePrefix}int2']),
      int4: $DataTypesTable.$converterint4n.fromSql(attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}int4'])),
      float8: attachedDatabase.typeMapping
          .read(const Float8Type(), data['${effectivePrefix}float8']),
      relatedId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}relatedId']),
    );
  }

  @override
  $DataTypesTable createAlias(String alias) {
    return $DataTypesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterdate =
      const ElectricDateConverter();
  static TypeConverter<DateTime?, String?> $converterdaten =
      NullAwareTypeConverter.wrap($converterdate);
  static TypeConverter<DateTime, String> $convertertime =
      const ElectricTimeConverter();
  static TypeConverter<DateTime?, String?> $convertertimen =
      NullAwareTypeConverter.wrap($convertertime);
  static TypeConverter<DateTime, String> $convertertimetz =
      const ElectricTimeTZConverter();
  static TypeConverter<DateTime?, String?> $convertertimetzn =
      NullAwareTypeConverter.wrap($convertertimetz);
  static TypeConverter<DateTime, String> $convertertimestamp =
      const ElectricTimestampConverter();
  static TypeConverter<DateTime?, String?> $convertertimestampn =
      NullAwareTypeConverter.wrap($convertertimestamp);
  static TypeConverter<DateTime, String> $convertertimestamptz =
      const ElectricTimestampTZConverter();
  static TypeConverter<DateTime?, String?> $convertertimestamptzn =
      NullAwareTypeConverter.wrap($convertertimestamptz);
  static TypeConverter<String, String> $converteruuid =
      const ElectricUUIDConverter();
  static TypeConverter<String?, String?> $converteruuidn =
      NullAwareTypeConverter.wrap($converteruuid);
  static TypeConverter<int, int> $converterint4 = const ElectricInt4Converter();
  static TypeConverter<int?, int?> $converterint4n =
      NullAwareTypeConverter.wrap($converterint4);
}

class DataType extends DataClass implements Insertable<DataType> {
  final int id;
  final DateTime? date;
  final DateTime? time;
  final DateTime? timetz;
  final DateTime? timestamp;
  final DateTime? timestamptz;
  final bool? boolCol;
  final String? uuid;
  final int? int2;
  final int? int4;
  final double? float8;
  final int? relatedId;
  const DataType(
      {required this.id,
      this.date,
      this.time,
      this.timetz,
      this.timestamp,
      this.timestamptz,
      this.boolCol,
      this.uuid,
      this.int2,
      this.int4,
      this.float8,
      this.relatedId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || date != null) {
      final converter = $DataTypesTable.$converterdaten;
      map['date'] = Variable<String>(converter.toSql(date));
    }
    if (!nullToAbsent || time != null) {
      final converter = $DataTypesTable.$convertertimen;
      map['time'] = Variable<String>(converter.toSql(time));
    }
    if (!nullToAbsent || timetz != null) {
      final converter = $DataTypesTable.$convertertimetzn;
      map['timetz'] = Variable<String>(converter.toSql(timetz));
    }
    if (!nullToAbsent || timestamp != null) {
      final converter = $DataTypesTable.$convertertimestampn;
      map['timestamp'] = Variable<String>(converter.toSql(timestamp));
    }
    if (!nullToAbsent || timestamptz != null) {
      final converter = $DataTypesTable.$convertertimestamptzn;
      map['timestamptz'] = Variable<String>(converter.toSql(timestamptz));
    }
    if (!nullToAbsent || boolCol != null) {
      map['bool'] = Variable<bool>(boolCol);
    }
    if (!nullToAbsent || uuid != null) {
      final converter = $DataTypesTable.$converteruuidn;
      map['uuid'] = Variable<String>(converter.toSql(uuid));
    }
    if (!nullToAbsent || int2 != null) {
      map['int2'] = Variable<int>(int2);
    }
    if (!nullToAbsent || int4 != null) {
      final converter = $DataTypesTable.$converterint4n;
      map['int4'] = Variable<int>(converter.toSql(int4));
    }
    if (!nullToAbsent || float8 != null) {
      map['float8'] = Variable<double>(float8);
    }
    if (!nullToAbsent || relatedId != null) {
      map['relatedId'] = Variable<int>(relatedId);
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
      boolCol: boolCol == null && nullToAbsent
          ? const Value.absent()
          : Value(boolCol),
      uuid: uuid == null && nullToAbsent ? const Value.absent() : Value(uuid),
      int2: int2 == null && nullToAbsent ? const Value.absent() : Value(int2),
      int4: int4 == null && nullToAbsent ? const Value.absent() : Value(int4),
      float8:
          float8 == null && nullToAbsent ? const Value.absent() : Value(float8),
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
      boolCol: serializer.fromJson<bool?>(json['boolCol']),
      uuid: serializer.fromJson<String?>(json['uuid']),
      int2: serializer.fromJson<int?>(json['int2']),
      int4: serializer.fromJson<int?>(json['int4']),
      float8: serializer.fromJson<double?>(json['float8']),
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
      'boolCol': serializer.toJson<bool?>(boolCol),
      'uuid': serializer.toJson<String?>(uuid),
      'int2': serializer.toJson<int?>(int2),
      'int4': serializer.toJson<int?>(int4),
      'float8': serializer.toJson<double?>(float8),
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
          Value<bool?> boolCol = const Value.absent(),
          Value<String?> uuid = const Value.absent(),
          Value<int?> int2 = const Value.absent(),
          Value<int?> int4 = const Value.absent(),
          Value<double?> float8 = const Value.absent(),
          Value<int?> relatedId = const Value.absent()}) =>
      DataType(
        id: id ?? this.id,
        date: date.present ? date.value : this.date,
        time: time.present ? time.value : this.time,
        timetz: timetz.present ? timetz.value : this.timetz,
        timestamp: timestamp.present ? timestamp.value : this.timestamp,
        timestamptz: timestamptz.present ? timestamptz.value : this.timestamptz,
        boolCol: boolCol.present ? boolCol.value : this.boolCol,
        uuid: uuid.present ? uuid.value : this.uuid,
        int2: int2.present ? int2.value : this.int2,
        int4: int4.present ? int4.value : this.int4,
        float8: float8.present ? float8.value : this.float8,
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
          ..write('boolCol: $boolCol, ')
          ..write('uuid: $uuid, ')
          ..write('int2: $int2, ')
          ..write('int4: $int4, ')
          ..write('float8: $float8, ')
          ..write('relatedId: $relatedId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, time, timetz, timestamp,
      timestamptz, boolCol, uuid, int2, int4, float8, relatedId);
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
          other.boolCol == this.boolCol &&
          other.uuid == this.uuid &&
          other.int2 == this.int2 &&
          other.int4 == this.int4 &&
          other.float8 == this.float8 &&
          other.relatedId == this.relatedId);
}

class DataTypesCompanion extends UpdateCompanion<DataType> {
  final Value<int> id;
  final Value<DateTime?> date;
  final Value<DateTime?> time;
  final Value<DateTime?> timetz;
  final Value<DateTime?> timestamp;
  final Value<DateTime?> timestamptz;
  final Value<bool?> boolCol;
  final Value<String?> uuid;
  final Value<int?> int2;
  final Value<int?> int4;
  final Value<double?> float8;
  final Value<int?> relatedId;
  const DataTypesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.time = const Value.absent(),
    this.timetz = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.timestamptz = const Value.absent(),
    this.boolCol = const Value.absent(),
    this.uuid = const Value.absent(),
    this.int2 = const Value.absent(),
    this.int4 = const Value.absent(),
    this.float8 = const Value.absent(),
    this.relatedId = const Value.absent(),
  });
  DataTypesCompanion.insert({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.time = const Value.absent(),
    this.timetz = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.timestamptz = const Value.absent(),
    this.boolCol = const Value.absent(),
    this.uuid = const Value.absent(),
    this.int2 = const Value.absent(),
    this.int4 = const Value.absent(),
    this.float8 = const Value.absent(),
    this.relatedId = const Value.absent(),
  });
  static Insertable<DataType> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? time,
    Expression<String>? timetz,
    Expression<String>? timestamp,
    Expression<String>? timestamptz,
    Expression<bool>? boolCol,
    Expression<String>? uuid,
    Expression<int>? int2,
    Expression<int>? int4,
    Expression<double>? float8,
    Expression<int>? relatedId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (time != null) 'time': time,
      if (timetz != null) 'timetz': timetz,
      if (timestamp != null) 'timestamp': timestamp,
      if (timestamptz != null) 'timestamptz': timestamptz,
      if (boolCol != null) 'bool': boolCol,
      if (uuid != null) 'uuid': uuid,
      if (int2 != null) 'int2': int2,
      if (int4 != null) 'int4': int4,
      if (float8 != null) 'float8': float8,
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
      Value<bool?>? boolCol,
      Value<String?>? uuid,
      Value<int?>? int2,
      Value<int?>? int4,
      Value<double?>? float8,
      Value<int?>? relatedId}) {
    return DataTypesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      timetz: timetz ?? this.timetz,
      timestamp: timestamp ?? this.timestamp,
      timestamptz: timestamptz ?? this.timestamptz,
      boolCol: boolCol ?? this.boolCol,
      uuid: uuid ?? this.uuid,
      int2: int2 ?? this.int2,
      int4: int4 ?? this.int4,
      float8: float8 ?? this.float8,
      relatedId: relatedId ?? this.relatedId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      final converter = $DataTypesTable.$converterdaten;

      map['date'] = Variable<String>(converter.toSql(date.value));
    }
    if (time.present) {
      final converter = $DataTypesTable.$convertertimen;

      map['time'] = Variable<String>(converter.toSql(time.value));
    }
    if (timetz.present) {
      final converter = $DataTypesTable.$convertertimetzn;

      map['timetz'] = Variable<String>(converter.toSql(timetz.value));
    }
    if (timestamp.present) {
      final converter = $DataTypesTable.$convertertimestampn;

      map['timestamp'] = Variable<String>(converter.toSql(timestamp.value));
    }
    if (timestamptz.present) {
      final converter = $DataTypesTable.$convertertimestamptzn;

      map['timestamptz'] = Variable<String>(converter.toSql(timestamptz.value));
    }
    if (boolCol.present) {
      map['bool'] = Variable<bool>(boolCol.value);
    }
    if (uuid.present) {
      final converter = $DataTypesTable.$converteruuidn;

      map['uuid'] = Variable<String>(converter.toSql(uuid.value));
    }
    if (int2.present) {
      map['int2'] = Variable<int>(int2.value, const Int2Type());
    }
    if (int4.present) {
      final converter = $DataTypesTable.$converterint4n;

      map['int4'] = Variable<int>(converter.toSql(int4.value));
    }
    if (float8.present) {
      map['float8'] = Variable<double>(float8.value, const Float8Type());
    }
    if (relatedId.present) {
      map['relatedId'] = Variable<int>(relatedId.value);
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
          ..write('boolCol: $boolCol, ')
          ..write('uuid: $uuid, ')
          ..write('int2: $int2, ')
          ..write('int4: $int4, ')
          ..write('float8: $float8, ')
          ..write('relatedId: $relatedId')
          ..write(')'))
        .toString();
  }
}

abstract class _$TestsDatabase extends GeneratedDatabase {
  _$TestsDatabase(QueryExecutor e) : super(e);
  late final $ItemsTable items = $ItemsTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $PostsTable posts = $PostsTable(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $DummyTable dummy = $DummyTable(this);
  late final $DataTypesTable dataTypes = $DataTypesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [items, users, posts, profiles, dummy, dataTypes];
}
