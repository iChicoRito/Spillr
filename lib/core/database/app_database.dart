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

@DriftDatabase(tables: [Profiles, CustomDecks])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(customDecks);
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
    return (select(customDecks)
          ..orderBy([
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
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'spillr.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
