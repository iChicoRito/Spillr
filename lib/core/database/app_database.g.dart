// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _avatarAssetPathMeta = const VerificationMeta(
    'avatarAssetPath',
  );
  @override
  late final GeneratedColumn<String> avatarAssetPath = GeneratedColumn<String>(
    'avatar_asset_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _avatarColorKeyMeta = const VerificationMeta(
    'avatarColorKey',
  );
  @override
  late final GeneratedColumn<String> avatarColorKey = GeneratedColumn<String>(
    'avatar_color_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    completedAt,
    avatarAssetPath,
    avatarColorKey,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('avatar_asset_path')) {
      context.handle(
        _avatarAssetPathMeta,
        avatarAssetPath.isAcceptableOrUnknown(
          data['avatar_asset_path']!,
          _avatarAssetPathMeta,
        ),
      );
    }
    if (data.containsKey('avatar_color_key')) {
      context.handle(
        _avatarColorKeyMeta,
        avatarColorKey.isAcceptableOrUnknown(
          data['avatar_color_key']!,
          _avatarColorKeyMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      avatarAssetPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_asset_path'],
      ),
      avatarColorKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}avatar_color_key'],
      ),
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final int id;
  final String displayName;
  final DateTime completedAt;
  final String? avatarAssetPath;
  final String? avatarColorKey;
  const Profile({
    required this.id,
    required this.displayName,
    required this.completedAt,
    this.avatarAssetPath,
    this.avatarColorKey,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['display_name'] = Variable<String>(displayName);
    map['completed_at'] = Variable<DateTime>(completedAt);
    if (!nullToAbsent || avatarAssetPath != null) {
      map['avatar_asset_path'] = Variable<String>(avatarAssetPath);
    }
    if (!nullToAbsent || avatarColorKey != null) {
      map['avatar_color_key'] = Variable<String>(avatarColorKey);
    }
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      displayName: Value(displayName),
      completedAt: Value(completedAt),
      avatarAssetPath: avatarAssetPath == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarAssetPath),
      avatarColorKey: avatarColorKey == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarColorKey),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<int>(json['id']),
      displayName: serializer.fromJson<String>(json['displayName']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      avatarAssetPath: serializer.fromJson<String?>(json['avatarAssetPath']),
      avatarColorKey: serializer.fromJson<String?>(json['avatarColorKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'displayName': serializer.toJson<String>(displayName),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'avatarAssetPath': serializer.toJson<String?>(avatarAssetPath),
      'avatarColorKey': serializer.toJson<String?>(avatarColorKey),
    };
  }

  Profile copyWith({
    int? id,
    String? displayName,
    DateTime? completedAt,
    Value<String?> avatarAssetPath = const Value.absent(),
    Value<String?> avatarColorKey = const Value.absent(),
  }) => Profile(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    completedAt: completedAt ?? this.completedAt,
    avatarAssetPath: avatarAssetPath.present
        ? avatarAssetPath.value
        : this.avatarAssetPath,
    avatarColorKey: avatarColorKey.present
        ? avatarColorKey.value
        : this.avatarColorKey,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      avatarAssetPath: data.avatarAssetPath.present
          ? data.avatarAssetPath.value
          : this.avatarAssetPath,
      avatarColorKey: data.avatarColorKey.present
          ? data.avatarColorKey.value
          : this.avatarColorKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('completedAt: $completedAt, ')
          ..write('avatarAssetPath: $avatarAssetPath, ')
          ..write('avatarColorKey: $avatarColorKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    displayName,
    completedAt,
    avatarAssetPath,
    avatarColorKey,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.completedAt == this.completedAt &&
          other.avatarAssetPath == this.avatarAssetPath &&
          other.avatarColorKey == this.avatarColorKey);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<int> id;
  final Value<String> displayName;
  final Value<DateTime> completedAt;
  final Value<String?> avatarAssetPath;
  final Value<String?> avatarColorKey;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.avatarAssetPath = const Value.absent(),
    this.avatarColorKey = const Value.absent(),
  });
  ProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String displayName,
    required DateTime completedAt,
    this.avatarAssetPath = const Value.absent(),
    this.avatarColorKey = const Value.absent(),
  }) : displayName = Value(displayName),
       completedAt = Value(completedAt);
  static Insertable<Profile> custom({
    Expression<int>? id,
    Expression<String>? displayName,
    Expression<DateTime>? completedAt,
    Expression<String>? avatarAssetPath,
    Expression<String>? avatarColorKey,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (completedAt != null) 'completed_at': completedAt,
      if (avatarAssetPath != null) 'avatar_asset_path': avatarAssetPath,
      if (avatarColorKey != null) 'avatar_color_key': avatarColorKey,
    });
  }

  ProfilesCompanion copyWith({
    Value<int>? id,
    Value<String>? displayName,
    Value<DateTime>? completedAt,
    Value<String?>? avatarAssetPath,
    Value<String?>? avatarColorKey,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      completedAt: completedAt ?? this.completedAt,
      avatarAssetPath: avatarAssetPath ?? this.avatarAssetPath,
      avatarColorKey: avatarColorKey ?? this.avatarColorKey,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (avatarAssetPath.present) {
      map['avatar_asset_path'] = Variable<String>(avatarAssetPath.value);
    }
    if (avatarColorKey.present) {
      map['avatar_color_key'] = Variable<String>(avatarColorKey.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('completedAt: $completedAt, ')
          ..write('avatarAssetPath: $avatarAssetPath, ')
          ..write('avatarColorKey: $avatarColorKey')
          ..write(')'))
        .toString();
  }
}

class $CustomDecksTable extends CustomDecks
    with TableInfo<$CustomDecksTable, CustomDeck> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomDecksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconKeyMeta = const VerificationMeta(
    'iconKey',
  );
  @override
  late final GeneratedColumn<String> iconKey = GeneratedColumn<String>(
    'icon_key',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 32,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorKeyMeta = const VerificationMeta(
    'colorKey',
  );
  @override
  late final GeneratedColumn<String> colorKey = GeneratedColumn<String>(
    'color_key',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 32,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    iconKey,
    colorKey,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_decks';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomDeck> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_key')) {
      context.handle(
        _iconKeyMeta,
        iconKey.isAcceptableOrUnknown(data['icon_key']!, _iconKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_iconKeyMeta);
    }
    if (data.containsKey('color_key')) {
      context.handle(
        _colorKeyMeta,
        colorKey.isAcceptableOrUnknown(data['color_key']!, _colorKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_colorKeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomDeck map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomDeck(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      iconKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_key'],
      )!,
      colorKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_key'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CustomDecksTable createAlias(String alias) {
    return $CustomDecksTable(attachedDatabase, alias);
  }
}

class CustomDeck extends DataClass implements Insertable<CustomDeck> {
  final int id;
  final String name;
  final String iconKey;
  final String colorKey;
  final DateTime createdAt;
  const CustomDeck({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.colorKey,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['icon_key'] = Variable<String>(iconKey);
    map['color_key'] = Variable<String>(colorKey);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CustomDecksCompanion toCompanion(bool nullToAbsent) {
    return CustomDecksCompanion(
      id: Value(id),
      name: Value(name),
      iconKey: Value(iconKey),
      colorKey: Value(colorKey),
      createdAt: Value(createdAt),
    );
  }

  factory CustomDeck.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomDeck(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      iconKey: serializer.fromJson<String>(json['iconKey']),
      colorKey: serializer.fromJson<String>(json['colorKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'iconKey': serializer.toJson<String>(iconKey),
      'colorKey': serializer.toJson<String>(colorKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CustomDeck copyWith({
    int? id,
    String? name,
    String? iconKey,
    String? colorKey,
    DateTime? createdAt,
  }) => CustomDeck(
    id: id ?? this.id,
    name: name ?? this.name,
    iconKey: iconKey ?? this.iconKey,
    colorKey: colorKey ?? this.colorKey,
    createdAt: createdAt ?? this.createdAt,
  );
  CustomDeck copyWithCompanion(CustomDecksCompanion data) {
    return CustomDeck(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconKey: data.iconKey.present ? data.iconKey.value : this.iconKey,
      colorKey: data.colorKey.present ? data.colorKey.value : this.colorKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomDeck(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconKey: $iconKey, ')
          ..write('colorKey: $colorKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, iconKey, colorKey, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomDeck &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconKey == this.iconKey &&
          other.colorKey == this.colorKey &&
          other.createdAt == this.createdAt);
}

class CustomDecksCompanion extends UpdateCompanion<CustomDeck> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> iconKey;
  final Value<String> colorKey;
  final Value<DateTime> createdAt;
  const CustomDecksCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconKey = const Value.absent(),
    this.colorKey = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CustomDecksCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String iconKey,
    required String colorKey,
    required DateTime createdAt,
  }) : name = Value(name),
       iconKey = Value(iconKey),
       colorKey = Value(colorKey),
       createdAt = Value(createdAt);
  static Insertable<CustomDeck> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? iconKey,
    Expression<String>? colorKey,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconKey != null) 'icon_key': iconKey,
      if (colorKey != null) 'color_key': colorKey,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CustomDecksCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? iconKey,
    Value<String>? colorKey,
    Value<DateTime>? createdAt,
  }) {
    return CustomDecksCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconKey: iconKey ?? this.iconKey,
      colorKey: colorKey ?? this.colorKey,
      createdAt: createdAt ?? this.createdAt,
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
    if (iconKey.present) {
      map['icon_key'] = Variable<String>(iconKey.value);
    }
    if (colorKey.present) {
      map['color_key'] = Variable<String>(colorKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomDecksCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconKey: $iconKey, ')
          ..write('colorKey: $colorKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $DeckQuestionEntriesTable extends DeckQuestionEntries
    with TableInfo<$DeckQuestionEntriesTable, DeckQuestionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeckQuestionEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<String> deckId = GeneratedColumn<String>(
    'deck_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _builtInQuestionKeyMeta =
      const VerificationMeta('builtInQuestionKey');
  @override
  late final GeneratedColumn<String> builtInQuestionKey =
      GeneratedColumn<String>(
        'built_in_question_key',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _questionTextMeta = const VerificationMeta(
    'questionText',
  );
  @override
  late final GeneratedColumn<String> questionText = GeneratedColumn<String>(
    'question_text',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 280,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isBuiltInMeta = const VerificationMeta(
    'isBuiltIn',
  );
  @override
  late final GeneratedColumn<bool> isBuiltIn = GeneratedColumn<bool>(
    'is_built_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_built_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deckId,
    builtInQuestionKey,
    questionText,
    sortOrder,
    isBuiltIn,
    isDeleted,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deck_question_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeckQuestionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('deck_id')) {
      context.handle(
        _deckIdMeta,
        deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('built_in_question_key')) {
      context.handle(
        _builtInQuestionKeyMeta,
        builtInQuestionKey.isAcceptableOrUnknown(
          data['built_in_question_key']!,
          _builtInQuestionKeyMeta,
        ),
      );
    }
    if (data.containsKey('question_text')) {
      context.handle(
        _questionTextMeta,
        questionText.isAcceptableOrUnknown(
          data['question_text']!,
          _questionTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionTextMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('is_built_in')) {
      context.handle(
        _isBuiltInMeta,
        isBuiltIn.isAcceptableOrUnknown(data['is_built_in']!, _isBuiltInMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeckQuestionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeckQuestionEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deck_id'],
      )!,
      builtInQuestionKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}built_in_question_key'],
      ),
      questionText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_text'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isBuiltIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_built_in'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DeckQuestionEntriesTable createAlias(String alias) {
    return $DeckQuestionEntriesTable(attachedDatabase, alias);
  }
}

class DeckQuestionEntry extends DataClass
    implements Insertable<DeckQuestionEntry> {
  final int id;
  final String deckId;
  final String? builtInQuestionKey;
  final String questionText;
  final int sortOrder;
  final bool isBuiltIn;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DeckQuestionEntry({
    required this.id,
    required this.deckId,
    this.builtInQuestionKey,
    required this.questionText,
    required this.sortOrder,
    required this.isBuiltIn,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['deck_id'] = Variable<String>(deckId);
    if (!nullToAbsent || builtInQuestionKey != null) {
      map['built_in_question_key'] = Variable<String>(builtInQuestionKey);
    }
    map['question_text'] = Variable<String>(questionText);
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_built_in'] = Variable<bool>(isBuiltIn);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DeckQuestionEntriesCompanion toCompanion(bool nullToAbsent) {
    return DeckQuestionEntriesCompanion(
      id: Value(id),
      deckId: Value(deckId),
      builtInQuestionKey: builtInQuestionKey == null && nullToAbsent
          ? const Value.absent()
          : Value(builtInQuestionKey),
      questionText: Value(questionText),
      sortOrder: Value(sortOrder),
      isBuiltIn: Value(isBuiltIn),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DeckQuestionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeckQuestionEntry(
      id: serializer.fromJson<int>(json['id']),
      deckId: serializer.fromJson<String>(json['deckId']),
      builtInQuestionKey: serializer.fromJson<String?>(
        json['builtInQuestionKey'],
      ),
      questionText: serializer.fromJson<String>(json['questionText']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isBuiltIn: serializer.fromJson<bool>(json['isBuiltIn']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deckId': serializer.toJson<String>(deckId),
      'builtInQuestionKey': serializer.toJson<String?>(builtInQuestionKey),
      'questionText': serializer.toJson<String>(questionText),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isBuiltIn': serializer.toJson<bool>(isBuiltIn),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DeckQuestionEntry copyWith({
    int? id,
    String? deckId,
    Value<String?> builtInQuestionKey = const Value.absent(),
    String? questionText,
    int? sortOrder,
    bool? isBuiltIn,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DeckQuestionEntry(
    id: id ?? this.id,
    deckId: deckId ?? this.deckId,
    builtInQuestionKey: builtInQuestionKey.present
        ? builtInQuestionKey.value
        : this.builtInQuestionKey,
    questionText: questionText ?? this.questionText,
    sortOrder: sortOrder ?? this.sortOrder,
    isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DeckQuestionEntry copyWithCompanion(DeckQuestionEntriesCompanion data) {
    return DeckQuestionEntry(
      id: data.id.present ? data.id.value : this.id,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      builtInQuestionKey: data.builtInQuestionKey.present
          ? data.builtInQuestionKey.value
          : this.builtInQuestionKey,
      questionText: data.questionText.present
          ? data.questionText.value
          : this.questionText,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isBuiltIn: data.isBuiltIn.present ? data.isBuiltIn.value : this.isBuiltIn,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeckQuestionEntry(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('builtInQuestionKey: $builtInQuestionKey, ')
          ..write('questionText: $questionText, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deckId,
    builtInQuestionKey,
    questionText,
    sortOrder,
    isBuiltIn,
    isDeleted,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeckQuestionEntry &&
          other.id == this.id &&
          other.deckId == this.deckId &&
          other.builtInQuestionKey == this.builtInQuestionKey &&
          other.questionText == this.questionText &&
          other.sortOrder == this.sortOrder &&
          other.isBuiltIn == this.isBuiltIn &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DeckQuestionEntriesCompanion extends UpdateCompanion<DeckQuestionEntry> {
  final Value<int> id;
  final Value<String> deckId;
  final Value<String?> builtInQuestionKey;
  final Value<String> questionText;
  final Value<int> sortOrder;
  final Value<bool> isBuiltIn;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const DeckQuestionEntriesCompanion({
    this.id = const Value.absent(),
    this.deckId = const Value.absent(),
    this.builtInQuestionKey = const Value.absent(),
    this.questionText = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DeckQuestionEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String deckId,
    this.builtInQuestionKey = const Value.absent(),
    required String questionText,
    required int sortOrder,
    this.isBuiltIn = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : deckId = Value(deckId),
       questionText = Value(questionText),
       sortOrder = Value(sortOrder),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DeckQuestionEntry> custom({
    Expression<int>? id,
    Expression<String>? deckId,
    Expression<String>? builtInQuestionKey,
    Expression<String>? questionText,
    Expression<int>? sortOrder,
    Expression<bool>? isBuiltIn,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deckId != null) 'deck_id': deckId,
      if (builtInQuestionKey != null)
        'built_in_question_key': builtInQuestionKey,
      if (questionText != null) 'question_text': questionText,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isBuiltIn != null) 'is_built_in': isBuiltIn,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DeckQuestionEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? deckId,
    Value<String?>? builtInQuestionKey,
    Value<String>? questionText,
    Value<int>? sortOrder,
    Value<bool>? isBuiltIn,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return DeckQuestionEntriesCompanion(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      builtInQuestionKey: builtInQuestionKey ?? this.builtInQuestionKey,
      questionText: questionText ?? this.questionText,
      sortOrder: sortOrder ?? this.sortOrder,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<String>(deckId.value);
    }
    if (builtInQuestionKey.present) {
      map['built_in_question_key'] = Variable<String>(builtInQuestionKey.value);
    }
    if (questionText.present) {
      map['question_text'] = Variable<String>(questionText.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isBuiltIn.present) {
      map['is_built_in'] = Variable<bool>(isBuiltIn.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeckQuestionEntriesCompanion(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('builtInQuestionKey: $builtInQuestionKey, ')
          ..write('questionText: $questionText, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isBuiltIn: $isBuiltIn, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $QuestionGenerationUsageEntriesTable
    extends QuestionGenerationUsageEntries
    with
        TableInfo<
          $QuestionGenerationUsageEntriesTable,
          QuestionGenerationUsageEntry
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionGenerationUsageEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptCountMeta = const VerificationMeta(
    'attemptCount',
  );
  @override
  late final GeneratedColumn<int> attemptCount = GeneratedColumn<int>(
    'attempt_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _limitReachedAtMeta = const VerificationMeta(
    'limitReachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> limitReachedAt =
      GeneratedColumn<DateTime>(
        'limit_reached_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    attemptCount,
    limitReachedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'question_generation_usage_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuestionGenerationUsageEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('attempt_count')) {
      context.handle(
        _attemptCountMeta,
        attemptCount.isAcceptableOrUnknown(
          data['attempt_count']!,
          _attemptCountMeta,
        ),
      );
    }
    if (data.containsKey('limit_reached_at')) {
      context.handle(
        _limitReachedAtMeta,
        limitReachedAt.isAcceptableOrUnknown(
          data['limit_reached_at']!,
          _limitReachedAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuestionGenerationUsageEntry map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuestionGenerationUsageEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      attemptCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_count'],
      )!,
      limitReachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}limit_reached_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $QuestionGenerationUsageEntriesTable createAlias(String alias) {
    return $QuestionGenerationUsageEntriesTable(attachedDatabase, alias);
  }
}

class QuestionGenerationUsageEntry extends DataClass
    implements Insertable<QuestionGenerationUsageEntry> {
  final int id;
  final int attemptCount;
  final DateTime? limitReachedAt;
  final DateTime updatedAt;
  const QuestionGenerationUsageEntry({
    required this.id,
    required this.attemptCount,
    this.limitReachedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['attempt_count'] = Variable<int>(attemptCount);
    if (!nullToAbsent || limitReachedAt != null) {
      map['limit_reached_at'] = Variable<DateTime>(limitReachedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  QuestionGenerationUsageEntriesCompanion toCompanion(bool nullToAbsent) {
    return QuestionGenerationUsageEntriesCompanion(
      id: Value(id),
      attemptCount: Value(attemptCount),
      limitReachedAt: limitReachedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(limitReachedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory QuestionGenerationUsageEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuestionGenerationUsageEntry(
      id: serializer.fromJson<int>(json['id']),
      attemptCount: serializer.fromJson<int>(json['attemptCount']),
      limitReachedAt: serializer.fromJson<DateTime?>(json['limitReachedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'attemptCount': serializer.toJson<int>(attemptCount),
      'limitReachedAt': serializer.toJson<DateTime?>(limitReachedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  QuestionGenerationUsageEntry copyWith({
    int? id,
    int? attemptCount,
    Value<DateTime?> limitReachedAt = const Value.absent(),
    DateTime? updatedAt,
  }) => QuestionGenerationUsageEntry(
    id: id ?? this.id,
    attemptCount: attemptCount ?? this.attemptCount,
    limitReachedAt: limitReachedAt.present
        ? limitReachedAt.value
        : this.limitReachedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  QuestionGenerationUsageEntry copyWithCompanion(
    QuestionGenerationUsageEntriesCompanion data,
  ) {
    return QuestionGenerationUsageEntry(
      id: data.id.present ? data.id.value : this.id,
      attemptCount: data.attemptCount.present
          ? data.attemptCount.value
          : this.attemptCount,
      limitReachedAt: data.limitReachedAt.present
          ? data.limitReachedAt.value
          : this.limitReachedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuestionGenerationUsageEntry(')
          ..write('id: $id, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('limitReachedAt: $limitReachedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, attemptCount, limitReachedAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuestionGenerationUsageEntry &&
          other.id == this.id &&
          other.attemptCount == this.attemptCount &&
          other.limitReachedAt == this.limitReachedAt &&
          other.updatedAt == this.updatedAt);
}

class QuestionGenerationUsageEntriesCompanion
    extends UpdateCompanion<QuestionGenerationUsageEntry> {
  final Value<int> id;
  final Value<int> attemptCount;
  final Value<DateTime?> limitReachedAt;
  final Value<DateTime> updatedAt;
  const QuestionGenerationUsageEntriesCompanion({
    this.id = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.limitReachedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  QuestionGenerationUsageEntriesCompanion.insert({
    this.id = const Value.absent(),
    this.attemptCount = const Value.absent(),
    this.limitReachedAt = const Value.absent(),
    required DateTime updatedAt,
  }) : updatedAt = Value(updatedAt);
  static Insertable<QuestionGenerationUsageEntry> custom({
    Expression<int>? id,
    Expression<int>? attemptCount,
    Expression<DateTime>? limitReachedAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (attemptCount != null) 'attempt_count': attemptCount,
      if (limitReachedAt != null) 'limit_reached_at': limitReachedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  QuestionGenerationUsageEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? attemptCount,
    Value<DateTime?>? limitReachedAt,
    Value<DateTime>? updatedAt,
  }) {
    return QuestionGenerationUsageEntriesCompanion(
      id: id ?? this.id,
      attemptCount: attemptCount ?? this.attemptCount,
      limitReachedAt: limitReachedAt ?? this.limitReachedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (attemptCount.present) {
      map['attempt_count'] = Variable<int>(attemptCount.value);
    }
    if (limitReachedAt.present) {
      map['limit_reached_at'] = Variable<DateTime>(limitReachedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionGenerationUsageEntriesCompanion(')
          ..write('id: $id, ')
          ..write('attemptCount: $attemptCount, ')
          ..write('limitReachedAt: $limitReachedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AppAudioPreferencesTable extends AppAudioPreferences
    with TableInfo<$AppAudioPreferencesTable, AppAudioPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppAudioPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nextLobbyTrackIndexMeta =
      const VerificationMeta('nextLobbyTrackIndex');
  @override
  late final GeneratedColumn<int> nextLobbyTrackIndex = GeneratedColumn<int>(
    'next_lobby_track_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _nextGameTrackIndexMeta =
      const VerificationMeta('nextGameTrackIndex');
  @override
  late final GeneratedColumn<int> nextGameTrackIndex = GeneratedColumn<int>(
    'next_game_track_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nextLobbyTrackIndex,
    nextGameTrackIndex,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_audio_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppAudioPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('next_lobby_track_index')) {
      context.handle(
        _nextLobbyTrackIndexMeta,
        nextLobbyTrackIndex.isAcceptableOrUnknown(
          data['next_lobby_track_index']!,
          _nextLobbyTrackIndexMeta,
        ),
      );
    }
    if (data.containsKey('next_game_track_index')) {
      context.handle(
        _nextGameTrackIndexMeta,
        nextGameTrackIndex.isAcceptableOrUnknown(
          data['next_game_track_index']!,
          _nextGameTrackIndexMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppAudioPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppAudioPreference(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nextLobbyTrackIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_lobby_track_index'],
      )!,
      nextGameTrackIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}next_game_track_index'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppAudioPreferencesTable createAlias(String alias) {
    return $AppAudioPreferencesTable(attachedDatabase, alias);
  }
}

class AppAudioPreference extends DataClass
    implements Insertable<AppAudioPreference> {
  final int id;
  final int nextLobbyTrackIndex;
  final int nextGameTrackIndex;
  final DateTime updatedAt;
  const AppAudioPreference({
    required this.id,
    required this.nextLobbyTrackIndex,
    required this.nextGameTrackIndex,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['next_lobby_track_index'] = Variable<int>(nextLobbyTrackIndex);
    map['next_game_track_index'] = Variable<int>(nextGameTrackIndex);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppAudioPreferencesCompanion toCompanion(bool nullToAbsent) {
    return AppAudioPreferencesCompanion(
      id: Value(id),
      nextLobbyTrackIndex: Value(nextLobbyTrackIndex),
      nextGameTrackIndex: Value(nextGameTrackIndex),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppAudioPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppAudioPreference(
      id: serializer.fromJson<int>(json['id']),
      nextLobbyTrackIndex: serializer.fromJson<int>(
        json['nextLobbyTrackIndex'],
      ),
      nextGameTrackIndex: serializer.fromJson<int>(json['nextGameTrackIndex']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nextLobbyTrackIndex': serializer.toJson<int>(nextLobbyTrackIndex),
      'nextGameTrackIndex': serializer.toJson<int>(nextGameTrackIndex),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppAudioPreference copyWith({
    int? id,
    int? nextLobbyTrackIndex,
    int? nextGameTrackIndex,
    DateTime? updatedAt,
  }) => AppAudioPreference(
    id: id ?? this.id,
    nextLobbyTrackIndex: nextLobbyTrackIndex ?? this.nextLobbyTrackIndex,
    nextGameTrackIndex: nextGameTrackIndex ?? this.nextGameTrackIndex,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppAudioPreference copyWithCompanion(AppAudioPreferencesCompanion data) {
    return AppAudioPreference(
      id: data.id.present ? data.id.value : this.id,
      nextLobbyTrackIndex: data.nextLobbyTrackIndex.present
          ? data.nextLobbyTrackIndex.value
          : this.nextLobbyTrackIndex,
      nextGameTrackIndex: data.nextGameTrackIndex.present
          ? data.nextGameTrackIndex.value
          : this.nextGameTrackIndex,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppAudioPreference(')
          ..write('id: $id, ')
          ..write('nextLobbyTrackIndex: $nextLobbyTrackIndex, ')
          ..write('nextGameTrackIndex: $nextGameTrackIndex, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nextLobbyTrackIndex, nextGameTrackIndex, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppAudioPreference &&
          other.id == this.id &&
          other.nextLobbyTrackIndex == this.nextLobbyTrackIndex &&
          other.nextGameTrackIndex == this.nextGameTrackIndex &&
          other.updatedAt == this.updatedAt);
}

class AppAudioPreferencesCompanion extends UpdateCompanion<AppAudioPreference> {
  final Value<int> id;
  final Value<int> nextLobbyTrackIndex;
  final Value<int> nextGameTrackIndex;
  final Value<DateTime> updatedAt;
  const AppAudioPreferencesCompanion({
    this.id = const Value.absent(),
    this.nextLobbyTrackIndex = const Value.absent(),
    this.nextGameTrackIndex = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  AppAudioPreferencesCompanion.insert({
    this.id = const Value.absent(),
    this.nextLobbyTrackIndex = const Value.absent(),
    this.nextGameTrackIndex = const Value.absent(),
    required DateTime updatedAt,
  }) : updatedAt = Value(updatedAt);
  static Insertable<AppAudioPreference> custom({
    Expression<int>? id,
    Expression<int>? nextLobbyTrackIndex,
    Expression<int>? nextGameTrackIndex,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nextLobbyTrackIndex != null)
        'next_lobby_track_index': nextLobbyTrackIndex,
      if (nextGameTrackIndex != null)
        'next_game_track_index': nextGameTrackIndex,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  AppAudioPreferencesCompanion copyWith({
    Value<int>? id,
    Value<int>? nextLobbyTrackIndex,
    Value<int>? nextGameTrackIndex,
    Value<DateTime>? updatedAt,
  }) {
    return AppAudioPreferencesCompanion(
      id: id ?? this.id,
      nextLobbyTrackIndex: nextLobbyTrackIndex ?? this.nextLobbyTrackIndex,
      nextGameTrackIndex: nextGameTrackIndex ?? this.nextGameTrackIndex,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nextLobbyTrackIndex.present) {
      map['next_lobby_track_index'] = Variable<int>(nextLobbyTrackIndex.value);
    }
    if (nextGameTrackIndex.present) {
      map['next_game_track_index'] = Variable<int>(nextGameTrackIndex.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppAudioPreferencesCompanion(')
          ..write('id: $id, ')
          ..write('nextLobbyTrackIndex: $nextLobbyTrackIndex, ')
          ..write('nextGameTrackIndex: $nextGameTrackIndex, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $GameplayCardEventsTable extends GameplayCardEvents
    with TableInfo<$GameplayCardEventsTable, GameplayCardEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameplayCardEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<String> deckId = GeneratedColumn<String>(
    'deck_id',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 64,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 24,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, deckId, action, occurredAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gameplay_card_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameplayCardEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('deck_id')) {
      context.handle(
        _deckIdMeta,
        deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameplayCardEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameplayCardEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deck_id'],
      )!,
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
    );
  }

  @override
  $GameplayCardEventsTable createAlias(String alias) {
    return $GameplayCardEventsTable(attachedDatabase, alias);
  }
}

class GameplayCardEvent extends DataClass
    implements Insertable<GameplayCardEvent> {
  final int id;
  final String deckId;
  final String action;
  final DateTime occurredAt;
  const GameplayCardEvent({
    required this.id,
    required this.deckId,
    required this.action,
    required this.occurredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['deck_id'] = Variable<String>(deckId);
    map['action'] = Variable<String>(action);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    return map;
  }

  GameplayCardEventsCompanion toCompanion(bool nullToAbsent) {
    return GameplayCardEventsCompanion(
      id: Value(id),
      deckId: Value(deckId),
      action: Value(action),
      occurredAt: Value(occurredAt),
    );
  }

  factory GameplayCardEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameplayCardEvent(
      id: serializer.fromJson<int>(json['id']),
      deckId: serializer.fromJson<String>(json['deckId']),
      action: serializer.fromJson<String>(json['action']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deckId': serializer.toJson<String>(deckId),
      'action': serializer.toJson<String>(action),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
    };
  }

  GameplayCardEvent copyWith({
    int? id,
    String? deckId,
    String? action,
    DateTime? occurredAt,
  }) => GameplayCardEvent(
    id: id ?? this.id,
    deckId: deckId ?? this.deckId,
    action: action ?? this.action,
    occurredAt: occurredAt ?? this.occurredAt,
  );
  GameplayCardEvent copyWithCompanion(GameplayCardEventsCompanion data) {
    return GameplayCardEvent(
      id: data.id.present ? data.id.value : this.id,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      action: data.action.present ? data.action.value : this.action,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameplayCardEvent(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('action: $action, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, deckId, action, occurredAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameplayCardEvent &&
          other.id == this.id &&
          other.deckId == this.deckId &&
          other.action == this.action &&
          other.occurredAt == this.occurredAt);
}

class GameplayCardEventsCompanion extends UpdateCompanion<GameplayCardEvent> {
  final Value<int> id;
  final Value<String> deckId;
  final Value<String> action;
  final Value<DateTime> occurredAt;
  const GameplayCardEventsCompanion({
    this.id = const Value.absent(),
    this.deckId = const Value.absent(),
    this.action = const Value.absent(),
    this.occurredAt = const Value.absent(),
  });
  GameplayCardEventsCompanion.insert({
    this.id = const Value.absent(),
    required String deckId,
    required String action,
    required DateTime occurredAt,
  }) : deckId = Value(deckId),
       action = Value(action),
       occurredAt = Value(occurredAt);
  static Insertable<GameplayCardEvent> custom({
    Expression<int>? id,
    Expression<String>? deckId,
    Expression<String>? action,
    Expression<DateTime>? occurredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deckId != null) 'deck_id': deckId,
      if (action != null) 'action': action,
      if (occurredAt != null) 'occurred_at': occurredAt,
    });
  }

  GameplayCardEventsCompanion copyWith({
    Value<int>? id,
    Value<String>? deckId,
    Value<String>? action,
    Value<DateTime>? occurredAt,
  }) {
    return GameplayCardEventsCompanion(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      action: action ?? this.action,
      occurredAt: occurredAt ?? this.occurredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<String>(deckId.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameplayCardEventsCompanion(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('action: $action, ')
          ..write('occurredAt: $occurredAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $CustomDecksTable customDecks = $CustomDecksTable(this);
  late final $DeckQuestionEntriesTable deckQuestionEntries =
      $DeckQuestionEntriesTable(this);
  late final $QuestionGenerationUsageEntriesTable
  questionGenerationUsageEntries = $QuestionGenerationUsageEntriesTable(this);
  late final $AppAudioPreferencesTable appAudioPreferences =
      $AppAudioPreferencesTable(this);
  late final $GameplayCardEventsTable gameplayCardEvents =
      $GameplayCardEventsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profiles,
    customDecks,
    deckQuestionEntries,
    questionGenerationUsageEntries,
    appAudioPreferences,
    gameplayCardEvents,
  ];
}

typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      required String displayName,
      required DateTime completedAt,
      Value<String?> avatarAssetPath,
      Value<String?> avatarColorKey,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<int> id,
      Value<String> displayName,
      Value<DateTime> completedAt,
      Value<String?> avatarAssetPath,
      Value<String?> avatarColorKey,
    });

class $$ProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarAssetPath => $composableBuilder(
    column: $table.avatarAssetPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get avatarColorKey => $composableBuilder(
    column: $table.avatarColorKey,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarAssetPath => $composableBuilder(
    column: $table.avatarAssetPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get avatarColorKey => $composableBuilder(
    column: $table.avatarColorKey,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarAssetPath => $composableBuilder(
    column: $table.avatarAssetPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get avatarColorKey => $composableBuilder(
    column: $table.avatarColorKey,
    builder: (column) => column,
  );
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
          Profile,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$AppDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<String?> avatarAssetPath = const Value.absent(),
                Value<String?> avatarColorKey = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                displayName: displayName,
                completedAt: completedAt,
                avatarAssetPath: avatarAssetPath,
                avatarColorKey: avatarColorKey,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String displayName,
                required DateTime completedAt,
                Value<String?> avatarAssetPath = const Value.absent(),
                Value<String?> avatarColorKey = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                displayName: displayName,
                completedAt: completedAt,
                avatarAssetPath: avatarAssetPath,
                avatarColorKey: avatarColorKey,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, BaseReferences<_$AppDatabase, $ProfilesTable, Profile>),
      Profile,
      PrefetchHooks Function()
    >;
typedef $$CustomDecksTableCreateCompanionBuilder =
    CustomDecksCompanion Function({
      Value<int> id,
      required String name,
      required String iconKey,
      required String colorKey,
      required DateTime createdAt,
    });
typedef $$CustomDecksTableUpdateCompanionBuilder =
    CustomDecksCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> iconKey,
      Value<String> colorKey,
      Value<DateTime> createdAt,
    });

class $$CustomDecksTableFilterComposer
    extends Composer<_$AppDatabase, $CustomDecksTable> {
  $$CustomDecksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorKey => $composableBuilder(
    column: $table.colorKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomDecksTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomDecksTable> {
  $$CustomDecksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconKey => $composableBuilder(
    column: $table.iconKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorKey => $composableBuilder(
    column: $table.colorKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomDecksTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomDecksTable> {
  $$CustomDecksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconKey =>
      $composableBuilder(column: $table.iconKey, builder: (column) => column);

  GeneratedColumn<String> get colorKey =>
      $composableBuilder(column: $table.colorKey, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CustomDecksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomDecksTable,
          CustomDeck,
          $$CustomDecksTableFilterComposer,
          $$CustomDecksTableOrderingComposer,
          $$CustomDecksTableAnnotationComposer,
          $$CustomDecksTableCreateCompanionBuilder,
          $$CustomDecksTableUpdateCompanionBuilder,
          (
            CustomDeck,
            BaseReferences<_$AppDatabase, $CustomDecksTable, CustomDeck>,
          ),
          CustomDeck,
          PrefetchHooks Function()
        > {
  $$CustomDecksTableTableManager(_$AppDatabase db, $CustomDecksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomDecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomDecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomDecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> iconKey = const Value.absent(),
                Value<String> colorKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CustomDecksCompanion(
                id: id,
                name: name,
                iconKey: iconKey,
                colorKey: colorKey,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String iconKey,
                required String colorKey,
                required DateTime createdAt,
              }) => CustomDecksCompanion.insert(
                id: id,
                name: name,
                iconKey: iconKey,
                colorKey: colorKey,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomDecksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomDecksTable,
      CustomDeck,
      $$CustomDecksTableFilterComposer,
      $$CustomDecksTableOrderingComposer,
      $$CustomDecksTableAnnotationComposer,
      $$CustomDecksTableCreateCompanionBuilder,
      $$CustomDecksTableUpdateCompanionBuilder,
      (
        CustomDeck,
        BaseReferences<_$AppDatabase, $CustomDecksTable, CustomDeck>,
      ),
      CustomDeck,
      PrefetchHooks Function()
    >;
typedef $$DeckQuestionEntriesTableCreateCompanionBuilder =
    DeckQuestionEntriesCompanion Function({
      Value<int> id,
      required String deckId,
      Value<String?> builtInQuestionKey,
      required String questionText,
      required int sortOrder,
      Value<bool> isBuiltIn,
      Value<bool> isDeleted,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$DeckQuestionEntriesTableUpdateCompanionBuilder =
    DeckQuestionEntriesCompanion Function({
      Value<int> id,
      Value<String> deckId,
      Value<String?> builtInQuestionKey,
      Value<String> questionText,
      Value<int> sortOrder,
      Value<bool> isBuiltIn,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$DeckQuestionEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DeckQuestionEntriesTable> {
  $$DeckQuestionEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deckId => $composableBuilder(
    column: $table.deckId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get builtInQuestionKey => $composableBuilder(
    column: $table.builtInQuestionKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DeckQuestionEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DeckQuestionEntriesTable> {
  $$DeckQuestionEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deckId => $composableBuilder(
    column: $table.deckId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get builtInQuestionKey => $composableBuilder(
    column: $table.builtInQuestionKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DeckQuestionEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeckQuestionEntriesTable> {
  $$DeckQuestionEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deckId =>
      $composableBuilder(column: $table.deckId, builder: (column) => column);

  GeneratedColumn<String> get builtInQuestionKey => $composableBuilder(
    column: $table.builtInQuestionKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get questionText => $composableBuilder(
    column: $table.questionText,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isBuiltIn =>
      $composableBuilder(column: $table.isBuiltIn, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$DeckQuestionEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeckQuestionEntriesTable,
          DeckQuestionEntry,
          $$DeckQuestionEntriesTableFilterComposer,
          $$DeckQuestionEntriesTableOrderingComposer,
          $$DeckQuestionEntriesTableAnnotationComposer,
          $$DeckQuestionEntriesTableCreateCompanionBuilder,
          $$DeckQuestionEntriesTableUpdateCompanionBuilder,
          (
            DeckQuestionEntry,
            BaseReferences<
              _$AppDatabase,
              $DeckQuestionEntriesTable,
              DeckQuestionEntry
            >,
          ),
          DeckQuestionEntry,
          PrefetchHooks Function()
        > {
  $$DeckQuestionEntriesTableTableManager(
    _$AppDatabase db,
    $DeckQuestionEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeckQuestionEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeckQuestionEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DeckQuestionEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deckId = const Value.absent(),
                Value<String?> builtInQuestionKey = const Value.absent(),
                Value<String> questionText = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DeckQuestionEntriesCompanion(
                id: id,
                deckId: deckId,
                builtInQuestionKey: builtInQuestionKey,
                questionText: questionText,
                sortOrder: sortOrder,
                isBuiltIn: isBuiltIn,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deckId,
                Value<String?> builtInQuestionKey = const Value.absent(),
                required String questionText,
                required int sortOrder,
                Value<bool> isBuiltIn = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => DeckQuestionEntriesCompanion.insert(
                id: id,
                deckId: deckId,
                builtInQuestionKey: builtInQuestionKey,
                questionText: questionText,
                sortOrder: sortOrder,
                isBuiltIn: isBuiltIn,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DeckQuestionEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeckQuestionEntriesTable,
      DeckQuestionEntry,
      $$DeckQuestionEntriesTableFilterComposer,
      $$DeckQuestionEntriesTableOrderingComposer,
      $$DeckQuestionEntriesTableAnnotationComposer,
      $$DeckQuestionEntriesTableCreateCompanionBuilder,
      $$DeckQuestionEntriesTableUpdateCompanionBuilder,
      (
        DeckQuestionEntry,
        BaseReferences<
          _$AppDatabase,
          $DeckQuestionEntriesTable,
          DeckQuestionEntry
        >,
      ),
      DeckQuestionEntry,
      PrefetchHooks Function()
    >;
typedef $$QuestionGenerationUsageEntriesTableCreateCompanionBuilder =
    QuestionGenerationUsageEntriesCompanion Function({
      Value<int> id,
      Value<int> attemptCount,
      Value<DateTime?> limitReachedAt,
      required DateTime updatedAt,
    });
typedef $$QuestionGenerationUsageEntriesTableUpdateCompanionBuilder =
    QuestionGenerationUsageEntriesCompanion Function({
      Value<int> id,
      Value<int> attemptCount,
      Value<DateTime?> limitReachedAt,
      Value<DateTime> updatedAt,
    });

class $$QuestionGenerationUsageEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $QuestionGenerationUsageEntriesTable> {
  $$QuestionGenerationUsageEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get limitReachedAt => $composableBuilder(
    column: $table.limitReachedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuestionGenerationUsageEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $QuestionGenerationUsageEntriesTable> {
  $$QuestionGenerationUsageEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get limitReachedAt => $composableBuilder(
    column: $table.limitReachedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuestionGenerationUsageEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuestionGenerationUsageEntriesTable> {
  $$QuestionGenerationUsageEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get attemptCount => $composableBuilder(
    column: $table.attemptCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get limitReachedAt => $composableBuilder(
    column: $table.limitReachedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$QuestionGenerationUsageEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuestionGenerationUsageEntriesTable,
          QuestionGenerationUsageEntry,
          $$QuestionGenerationUsageEntriesTableFilterComposer,
          $$QuestionGenerationUsageEntriesTableOrderingComposer,
          $$QuestionGenerationUsageEntriesTableAnnotationComposer,
          $$QuestionGenerationUsageEntriesTableCreateCompanionBuilder,
          $$QuestionGenerationUsageEntriesTableUpdateCompanionBuilder,
          (
            QuestionGenerationUsageEntry,
            BaseReferences<
              _$AppDatabase,
              $QuestionGenerationUsageEntriesTable,
              QuestionGenerationUsageEntry
            >,
          ),
          QuestionGenerationUsageEntry,
          PrefetchHooks Function()
        > {
  $$QuestionGenerationUsageEntriesTableTableManager(
    _$AppDatabase db,
    $QuestionGenerationUsageEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestionGenerationUsageEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$QuestionGenerationUsageEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$QuestionGenerationUsageEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime?> limitReachedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => QuestionGenerationUsageEntriesCompanion(
                id: id,
                attemptCount: attemptCount,
                limitReachedAt: limitReachedAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> attemptCount = const Value.absent(),
                Value<DateTime?> limitReachedAt = const Value.absent(),
                required DateTime updatedAt,
              }) => QuestionGenerationUsageEntriesCompanion.insert(
                id: id,
                attemptCount: attemptCount,
                limitReachedAt: limitReachedAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuestionGenerationUsageEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuestionGenerationUsageEntriesTable,
      QuestionGenerationUsageEntry,
      $$QuestionGenerationUsageEntriesTableFilterComposer,
      $$QuestionGenerationUsageEntriesTableOrderingComposer,
      $$QuestionGenerationUsageEntriesTableAnnotationComposer,
      $$QuestionGenerationUsageEntriesTableCreateCompanionBuilder,
      $$QuestionGenerationUsageEntriesTableUpdateCompanionBuilder,
      (
        QuestionGenerationUsageEntry,
        BaseReferences<
          _$AppDatabase,
          $QuestionGenerationUsageEntriesTable,
          QuestionGenerationUsageEntry
        >,
      ),
      QuestionGenerationUsageEntry,
      PrefetchHooks Function()
    >;
typedef $$AppAudioPreferencesTableCreateCompanionBuilder =
    AppAudioPreferencesCompanion Function({
      Value<int> id,
      Value<int> nextLobbyTrackIndex,
      Value<int> nextGameTrackIndex,
      required DateTime updatedAt,
    });
typedef $$AppAudioPreferencesTableUpdateCompanionBuilder =
    AppAudioPreferencesCompanion Function({
      Value<int> id,
      Value<int> nextLobbyTrackIndex,
      Value<int> nextGameTrackIndex,
      Value<DateTime> updatedAt,
    });

class $$AppAudioPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $AppAudioPreferencesTable> {
  $$AppAudioPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextLobbyTrackIndex => $composableBuilder(
    column: $table.nextLobbyTrackIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nextGameTrackIndex => $composableBuilder(
    column: $table.nextGameTrackIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppAudioPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $AppAudioPreferencesTable> {
  $$AppAudioPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextLobbyTrackIndex => $composableBuilder(
    column: $table.nextLobbyTrackIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nextGameTrackIndex => $composableBuilder(
    column: $table.nextGameTrackIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppAudioPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppAudioPreferencesTable> {
  $$AppAudioPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get nextLobbyTrackIndex => $composableBuilder(
    column: $table.nextLobbyTrackIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nextGameTrackIndex => $composableBuilder(
    column: $table.nextGameTrackIndex,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppAudioPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppAudioPreferencesTable,
          AppAudioPreference,
          $$AppAudioPreferencesTableFilterComposer,
          $$AppAudioPreferencesTableOrderingComposer,
          $$AppAudioPreferencesTableAnnotationComposer,
          $$AppAudioPreferencesTableCreateCompanionBuilder,
          $$AppAudioPreferencesTableUpdateCompanionBuilder,
          (
            AppAudioPreference,
            BaseReferences<
              _$AppDatabase,
              $AppAudioPreferencesTable,
              AppAudioPreference
            >,
          ),
          AppAudioPreference,
          PrefetchHooks Function()
        > {
  $$AppAudioPreferencesTableTableManager(
    _$AppDatabase db,
    $AppAudioPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppAudioPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppAudioPreferencesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AppAudioPreferencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> nextLobbyTrackIndex = const Value.absent(),
                Value<int> nextGameTrackIndex = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => AppAudioPreferencesCompanion(
                id: id,
                nextLobbyTrackIndex: nextLobbyTrackIndex,
                nextGameTrackIndex: nextGameTrackIndex,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> nextLobbyTrackIndex = const Value.absent(),
                Value<int> nextGameTrackIndex = const Value.absent(),
                required DateTime updatedAt,
              }) => AppAudioPreferencesCompanion.insert(
                id: id,
                nextLobbyTrackIndex: nextLobbyTrackIndex,
                nextGameTrackIndex: nextGameTrackIndex,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppAudioPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppAudioPreferencesTable,
      AppAudioPreference,
      $$AppAudioPreferencesTableFilterComposer,
      $$AppAudioPreferencesTableOrderingComposer,
      $$AppAudioPreferencesTableAnnotationComposer,
      $$AppAudioPreferencesTableCreateCompanionBuilder,
      $$AppAudioPreferencesTableUpdateCompanionBuilder,
      (
        AppAudioPreference,
        BaseReferences<
          _$AppDatabase,
          $AppAudioPreferencesTable,
          AppAudioPreference
        >,
      ),
      AppAudioPreference,
      PrefetchHooks Function()
    >;
typedef $$GameplayCardEventsTableCreateCompanionBuilder =
    GameplayCardEventsCompanion Function({
      Value<int> id,
      required String deckId,
      required String action,
      required DateTime occurredAt,
    });
typedef $$GameplayCardEventsTableUpdateCompanionBuilder =
    GameplayCardEventsCompanion Function({
      Value<int> id,
      Value<String> deckId,
      Value<String> action,
      Value<DateTime> occurredAt,
    });

class $$GameplayCardEventsTableFilterComposer
    extends Composer<_$AppDatabase, $GameplayCardEventsTable> {
  $$GameplayCardEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deckId => $composableBuilder(
    column: $table.deckId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GameplayCardEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $GameplayCardEventsTable> {
  $$GameplayCardEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deckId => $composableBuilder(
    column: $table.deckId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GameplayCardEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameplayCardEventsTable> {
  $$GameplayCardEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deckId =>
      $composableBuilder(column: $table.deckId, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );
}

class $$GameplayCardEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameplayCardEventsTable,
          GameplayCardEvent,
          $$GameplayCardEventsTableFilterComposer,
          $$GameplayCardEventsTableOrderingComposer,
          $$GameplayCardEventsTableAnnotationComposer,
          $$GameplayCardEventsTableCreateCompanionBuilder,
          $$GameplayCardEventsTableUpdateCompanionBuilder,
          (
            GameplayCardEvent,
            BaseReferences<
              _$AppDatabase,
              $GameplayCardEventsTable,
              GameplayCardEvent
            >,
          ),
          GameplayCardEvent,
          PrefetchHooks Function()
        > {
  $$GameplayCardEventsTableTableManager(
    _$AppDatabase db,
    $GameplayCardEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameplayCardEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameplayCardEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameplayCardEventsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deckId = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
              }) => GameplayCardEventsCompanion(
                id: id,
                deckId: deckId,
                action: action,
                occurredAt: occurredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deckId,
                required String action,
                required DateTime occurredAt,
              }) => GameplayCardEventsCompanion.insert(
                id: id,
                deckId: deckId,
                action: action,
                occurredAt: occurredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GameplayCardEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameplayCardEventsTable,
      GameplayCardEvent,
      $$GameplayCardEventsTableFilterComposer,
      $$GameplayCardEventsTableOrderingComposer,
      $$GameplayCardEventsTableAnnotationComposer,
      $$GameplayCardEventsTableCreateCompanionBuilder,
      $$GameplayCardEventsTableUpdateCompanionBuilder,
      (
        GameplayCardEvent,
        BaseReferences<
          _$AppDatabase,
          $GameplayCardEventsTable,
          GameplayCardEvent
        >,
      ),
      GameplayCardEvent,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$CustomDecksTableTableManager get customDecks =>
      $$CustomDecksTableTableManager(_db, _db.customDecks);
  $$DeckQuestionEntriesTableTableManager get deckQuestionEntries =>
      $$DeckQuestionEntriesTableTableManager(_db, _db.deckQuestionEntries);
  $$QuestionGenerationUsageEntriesTableTableManager
  get questionGenerationUsageEntries =>
      $$QuestionGenerationUsageEntriesTableTableManager(
        _db,
        _db.questionGenerationUsageEntries,
      );
  $$AppAudioPreferencesTableTableManager get appAudioPreferences =>
      $$AppAudioPreferencesTableTableManager(_db, _db.appAudioPreferences);
  $$GameplayCardEventsTableTableManager get gameplayCardEvents =>
      $$GameplayCardEventsTableTableManager(_db, _db.gameplayCardEvents);
}
