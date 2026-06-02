import '../../../core/database/app_database.dart';
import '../domain/profile_models.dart';

class ProfileRepository {
  ProfileRepository(this._database);

  final AppDatabase _database;

  Future<void> updateProfile({
    required String displayName,
    required ProfileAvatarAsset avatarAsset,
    required ProfileAvatarColorKey avatarColor,
  }) {
    return _database.saveProfile(
      displayName,
      avatarAssetPath: avatarAsset.assetPath,
      avatarColorKey: avatarColor.value,
    );
  }

  Future<void> recordGameplayCardEvent({
    required String deckId,
    required GameplayCardAction action,
  }) {
    return _database.insertGameplayCardEvent(
      deckId: deckId,
      action: action.value,
    );
  }

  Future<ProfileStats> fetchProfileStats() async {
    final rows = await _database.select(_database.gameplayCardEvents).get();
    return _aggregateStats(rows);
  }

  Stream<ProfileStats> watchProfileStats() {
    return _database.select(_database.gameplayCardEvents).watch().map(
      _aggregateStats,
    );
  }

  ProfileStats _aggregateStats(List<GameplayCardEvent> rows) {
    var answered = 0;
    var passed = 0;

    for (final row in rows) {
      switch (row.action) {
        case 'answered':
          answered += 1;
          break;
        case 'passed':
          passed += 1;
          break;
      }
    }

    return ProfileStats(
      cardsAnswered: answered,
      cardsPassed: passed,
    );
  }
}
