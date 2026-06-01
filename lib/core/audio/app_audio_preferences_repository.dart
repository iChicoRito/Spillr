import 'package:drift/drift.dart';
import 'package:riverpod/riverpod.dart';

import '../database/app_database.dart';
import '../database/app_database_provider.dart';
import 'spillr_app_audio_controller.dart';

final appAudioPreferencesRepositoryProvider =
    Provider<AppAudioPreferencesRepository>((ref) {
      final database = ref.watch(appDatabaseProvider);
      return AppAudioPreferencesRepository(database);
    });

class AppAudioPreferencesRepository implements AppAudioTrackRotator {
  AppAudioPreferencesRepository(this._database);

  final AppDatabase _database;

  @override
  Future<int> reserveNextLobbyTrackIndex({required int trackCount}) async {
    final preferences = await _readOrCreatePreferences();
    final selectedIndex = preferences.nextLobbyTrackIndex % trackCount;
    await _savePreferences(
      nextLobbyTrackIndex: (selectedIndex + 1) % trackCount,
      nextGameTrackIndex: preferences.nextGameTrackIndex,
    );
    return selectedIndex;
  }

  @override
  Future<int> reserveNextGameTrackIndex({required int trackCount}) async {
    final preferences = await _readOrCreatePreferences();
    final selectedIndex = preferences.nextGameTrackIndex % trackCount;
    await _savePreferences(
      nextLobbyTrackIndex: preferences.nextLobbyTrackIndex,
      nextGameTrackIndex: (selectedIndex + 1) % trackCount,
    );
    return selectedIndex;
  }

  Future<AppAudioPreference> _readOrCreatePreferences() async {
    final existing = await (_database.select(
      _database.appAudioPreferences,
    )..where((table) => table.id.equals(1))).getSingleOrNull();

    if (existing != null) {
      return existing;
    }

    final now = DateTime.now();
    await _database
        .into(_database.appAudioPreferences)
        .insert(
          AppAudioPreferencesCompanion.insert(
            id: const Value(1),
            updatedAt: now,
          ),
        );

    return AppAudioPreference(
      id: 1,
      nextLobbyTrackIndex: 0,
      nextGameTrackIndex: 0,
      updatedAt: now,
    );
  }

  Future<void> _savePreferences({
    required int nextLobbyTrackIndex,
    required int nextGameTrackIndex,
  }) {
    return _database
        .into(_database.appAudioPreferences)
        .insertOnConflictUpdate(
          AppAudioPreferencesCompanion(
            id: const Value(1),
            nextLobbyTrackIndex: Value(nextLobbyTrackIndex),
            nextGameTrackIndex: Value(nextGameTrackIndex),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }
}
