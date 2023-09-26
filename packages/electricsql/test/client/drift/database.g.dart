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
  String get aliasedName => _alias ?? 'Items';
  @override
  String get actualTableName => 'Items';
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
  String get aliasedName => _alias ?? 'User';
  @override
  String get actualTableName => 'User';
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
  String get aliasedName => _alias ?? 'Post';
  @override
  String get actualTableName => 'Post';
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
  String get aliasedName => _alias ?? 'Profile';
  @override
  String get actualTableName => 'Profile';
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

abstract class _$TestsDatabase extends GeneratedDatabase {
  _$TestsDatabase(QueryExecutor e) : super(e);
  late final $ItemsTable items = $ItemsTable(this);
  late final $UsersTable users = $UsersTable(this);
  late final $PostsTable posts = $PostsTable(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [items, users, posts, profiles];
}
