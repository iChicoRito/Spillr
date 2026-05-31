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

@DriftDatabase(
  tables: [
    Profiles,
    CustomDecks,
    DeckQuestionEntries,
    QuestionGenerationUsageEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 4;

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
    },
  );

  Future<Profile?> fetchProfile() {
    return select(profiles).getSingleOrNull();
  }

  Future<void> saveProfile(String displayName) {
    return into(profiles).insertOnConflictUpdate(
      ProfilesCompanion.insert(
        id: const Value(1),
        displayName: displayName,
        completedAt: DateTime.now(),
      ),
    );
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
