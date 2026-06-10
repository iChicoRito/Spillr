import 'package:drift/native.dart';
import 'package:test/test.dart';

import 'package:spillr/core/database/app_database.dart';

void main() {
  test('upgrades a schema 4 database without deleting profile data', () async {
    final database = AppDatabase(
      NativeDatabase.memory(setup: _createSchema4Database),
    );
    addTearDown(database.close);

    final profile = await database.fetchProfile();

    expect(profile, isNotNull);
    expect(profile!.displayName, 'Chico');
    expect(profile.notificationsEnabled, isFalse);
    expect(await _userVersion(database), database.schemaVersion);
  });

  test('upgrades schema 5 audio preferences without duplicate columns', () async {
    final database = AppDatabase(
      NativeDatabase.memory(setup: _createSchema5Database),
    );
    addTearDown(database.close);

    final audioPreferences = await database
        .select(database.appAudioPreferences)
        .getSingle();

    expect(audioPreferences.nextLobbyTrackIndex, 1);
    expect(audioPreferences.nextGameTrackIndex, 0);
    expect(audioPreferences.masterVolume, 1.0);
    expect(audioPreferences.bgmVolume, 1.0);
    expect(audioPreferences.sfxVolume, 1.0);
    expect(await _userVersion(database), database.schemaVersion);
  });
}

void _createSchema4Database(dynamic database) {
  database
    ..execute('''
      CREATE TABLE profiles (
        id INTEGER NOT NULL,
        display_name TEXT NOT NULL,
        completed_at INTEGER NOT NULL,
        PRIMARY KEY (id)
      );
    ''')
    ..execute('''
      CREATE TABLE custom_decks (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon_key TEXT NOT NULL,
        color_key TEXT NOT NULL,
        created_at INTEGER NOT NULL
      );
    ''')
    ..execute('''
      CREATE TABLE deck_question_entries (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        deck_id TEXT NOT NULL,
        built_in_question_key TEXT NULL,
        question_text TEXT NOT NULL,
        sort_order INTEGER NOT NULL,
        is_built_in INTEGER NOT NULL DEFAULT 0 CHECK ("is_built_in" IN (0, 1)),
        is_deleted INTEGER NOT NULL DEFAULT 0 CHECK ("is_deleted" IN (0, 1)),
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      );
    ''')
    ..execute('''
      CREATE TABLE question_generation_usage_entries (
        id INTEGER NOT NULL,
        attempt_count INTEGER NOT NULL DEFAULT 0,
        limit_reached_at INTEGER NULL,
        updated_at INTEGER NOT NULL,
        PRIMARY KEY (id)
      );
    ''')
    ..execute(
      '''
      INSERT INTO profiles (id, display_name, completed_at)
      VALUES (1, 'Chico', ?);
    ''',
      [DateTime(2026, 6, 1, 12).millisecondsSinceEpoch],
    )
    ..execute('PRAGMA user_version = 4;');
}

void _createSchema5Database(dynamic database) {
  _createSchema4Database(database);
  database
    ..execute('''
      CREATE TABLE app_audio_preferences (
        id INTEGER NOT NULL,
        next_lobby_track_index INTEGER NOT NULL DEFAULT 0,
        next_game_track_index INTEGER NOT NULL DEFAULT 0,
        updated_at INTEGER NOT NULL,
        PRIMARY KEY (id)
      );
    ''')
    ..execute(
      '''
      INSERT INTO app_audio_preferences (
        id,
        next_lobby_track_index,
        next_game_track_index,
        updated_at
      )
      VALUES (1, 1, 0, ?);
    ''',
      [DateTime(2026, 6, 1, 13).millisecondsSinceEpoch],
    )
    ..execute('PRAGMA user_version = 5;');
}

Future<int> _userVersion(AppDatabase database) {
  return database.customSelect('PRAGMA user_version').map((row) {
    return row.data.values.single as int;
  }).getSingle();
}
