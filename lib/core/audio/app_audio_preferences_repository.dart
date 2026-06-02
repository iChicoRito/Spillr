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

class AudioVolumeSettings {
  const AudioVolumeSettings({
    this.masterVolume = 1.0,
    this.bgmVolume = 1.0,
    this.sfxVolume = 1.0,
  });

  final double masterVolume; // 0.0–1.0
  final double bgmVolume; // 0.0–1.0
  final double sfxVolume; // 0.0–1.0

  double get effectiveBgmVolume => masterVolume * bgmVolume;
  double get effectiveSfxVolume => masterVolume * sfxVolume;
}

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
      masterVolume: 1.0,
      bgmVolume: 1.0,
      sfxVolume: 1.0,
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

  Future<AudioVolumeSettings> fetchVolumeSettings() async {
    final prefs = await _readOrCreatePreferences();
    return AudioVolumeSettings(
      masterVolume: prefs.masterVolume,
      bgmVolume: prefs.bgmVolume,
      sfxVolume: prefs.sfxVolume,
    );
  }

  Future<void> saveVolumeSettings(AudioVolumeSettings settings) {
    return _database
        .into(_database.appAudioPreferences)
        .insertOnConflictUpdate(
          AppAudioPreferencesCompanion(
            id: const Value(1),
            masterVolume: Value(settings.masterVolume.clamp(0.0, 1.0)),
            bgmVolume: Value(settings.bgmVolume.clamp(0.0, 1.0)),
            sfxVolume: Value(settings.sfxVolume.clamp(0.0, 1.0)),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }
}
