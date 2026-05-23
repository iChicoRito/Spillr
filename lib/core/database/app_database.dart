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

@DriftDatabase(tables: [Profiles])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

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
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'spillr.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
