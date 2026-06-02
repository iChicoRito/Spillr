import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Profiles extends Table {
  IntColumn get id => integer()();
  TextColumn get displayName => text().withLength(min: 1, max: 64)();
  DateTimeColumn get completedAt => dateTime()();
  TextColumn get avatarAssetPath => text().nullable()();
  TextColumn get avatarColorKey => text().nullable()();
  BoolColumn get notificationsEnabled =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class CustomDecks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 64)();
  TextColumn get iconKey => text().withLength(min: 1, max: 32)();
  TextColumn get colorKey => text().withLength(min: 1, max: 32)();
  DateTimeColumn get createdAt => dateTime()();
}

class DeckQuestionEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deckId => text().withLength(min: 1, max: 64)();
  TextColumn get builtInQuestionKey => text().nullable()();
  TextColumn get questionText => text().withLength(min: 1, max: 280)();
  IntColumn get sortOrder => integer()();
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

class QuestionGenerationUsageEntries extends Table {
  IntColumn get id => integer()();
  IntColumn get attemptCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get limitReachedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class AppAudioPreferences extends Table {
  IntColumn get id => integer()();
  IntColumn get nextLobbyTrackIndex =>
      integer().withDefault(const Constant(0))();
  IntColumn get nextGameTrackIndex =>
      integer().withDefault(const Constant(0))();
  RealColumn get masterVolume => real().withDefault(const Constant(1.0))();
  RealColumn get bgmVolume => real().withDefault(const Constant(1.0))();
  RealColumn get sfxVolume => real().withDefault(const Constant(1.0))();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>>? get primaryKey => {id};
}

class GameplayCardEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deckId => text().withLength(min: 1, max: 64)();
  TextColumn get action => text().withLength(min: 1, max: 24)();
  DateTimeColumn get occurredAt => dateTime()();
}

class GameHistoryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get deckId => text().withLength(min: 1, max: 64)();
  TextColumn get outcome => text().withLength(min: 1, max: 32)();
  DateTimeColumn get completedAt => dateTime()();
}

@DriftDatabase(
  tables: [
    Profiles,
    CustomDecks,
    DeckQuestionEntries,
    QuestionGenerationUsageEntries,
    AppAudioPreferences,
    GameplayCardEvents,
    GameHistoryEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(customDecks);
      }
      if (from < 3) {
        await migrator.createTable(deckQuestionEntries);
      }
      if (from < 4) {
        await migrator.createTable(questionGenerationUsageEntries);
      }
      if (from < 5) {
        await migrator.createTable(appAudioPreferences);
      }
      if (from < 6) {
        await migrator.addColumn(profiles, profiles.avatarAssetPath);
        await migrator.addColumn(profiles, profiles.avatarColorKey);
        await migrator.createTable(gameplayCardEvents);
      }
      if (from < 7) {
        await migrator.createTable(gameHistoryEntries);
      }
      if (from < 8) {
        await customStatement(
          'ALTER TABLE app_audio_preferences ADD COLUMN master_volume REAL NOT NULL DEFAULT 1.0',
        );
        await customStatement(
          'ALTER TABLE app_audio_preferences ADD COLUMN bgm_volume REAL NOT NULL DEFAULT 1.0',
        );
        await customStatement(
          'ALTER TABLE app_audio_preferences ADD COLUMN sfx_volume REAL NOT NULL DEFAULT 1.0',
        );
      }
      if (from < 9) {
        await customStatement(
          'ALTER TABLE profiles ADD COLUMN notifications_enabled INTEGER NOT NULL DEFAULT 0',
        );
      }
    },
  );

  Future<Profile?> fetchProfile() {
    return select(profiles).getSingleOrNull();
  }

  Future<void> saveProfile(
    String displayName, {
    String? avatarAssetPath,
    String? avatarColorKey,
  }) async {
    final existingProfile = await fetchProfile();

    await into(profiles).insertOnConflictUpdate(
      ProfilesCompanion.insert(
        id: const Value(1),
        displayName: displayName,
        completedAt: existingProfile?.completedAt ?? DateTime.now(),
        avatarAssetPath: Value(
          avatarAssetPath ?? existingProfile?.avatarAssetPath,
        ),
        avatarColorKey: Value(
          avatarColorKey ?? existingProfile?.avatarColorKey,
        ),
      ),
    );
  }

  Future<void> updateNotificationsEnabled(bool enabled) {
    return (update(profiles)..where((t) => t.id.equals(1))).write(
      ProfilesCompanion(notificationsEnabled: Value(enabled)),
    );
  }

  Future<void> insertGameplayCardEvent({
    required String deckId,
    required String action,
  }) {
    return into(gameplayCardEvents).insert(
      GameplayCardEventsCompanion.insert(
        deckId: deckId,
        action: action,
        occurredAt: DateTime.now(),
      ),
    );
  }

  Future<void> insertGameHistoryEntry({
    required String deckId,
    required String outcome,
  }) {
    return into(gameHistoryEntries).insert(
      GameHistoryEntriesCompanion.insert(
        deckId: deckId,
        outcome: outcome,
        completedAt: DateTime.now(),
      ),
    );
  }

  Stream<List<GameHistoryEntry>> watchGameHistory() {
    return (select(gameHistoryEntries)..orderBy([
          (table) => OrderingTerm.desc(table.completedAt),
          (table) => OrderingTerm.desc(table.id),
        ]))
        .watch();
  }

  Future<void> clearGameHistory() {
    return delete(gameHistoryEntries).go();
  }

  Stream<List<CustomDeck>> watchCustomDecks() {
    return (select(customDecks)..orderBy([
          (table) => OrderingTerm.desc(table.createdAt),
          (table) => OrderingTerm.desc(table.id),
        ]))
        .watch();
  }

  Future<void> insertCustomDeck({
    required String name,
    required String iconKey,
    required String colorKey,
  }) {
    return into(customDecks).insert(
      CustomDecksCompanion.insert(
        name: name,
        iconKey: iconKey,
        colorKey: colorKey,
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> updateCustomDeck({
    required int id,
    required String name,
    required String iconKey,
    required String colorKey,
  }) {
    return (update(customDecks)..where((table) => table.id.equals(id))).write(
      CustomDecksCompanion(
        name: Value(name),
        iconKey: Value(iconKey),
        colorKey: Value(colorKey),
      ),
    );
  }

  Future<void> deleteCustomDeck(int id) {
    return (delete(customDecks)..where((table) => table.id.equals(id))).go();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'spillr.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
