import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spillr/core/database/app_database.dart';
import 'package:spillr/features/profile/data/profile_repository.dart';
import 'package:spillr/features/profile/domain/profile_models.dart';

void main() {
  late AppDatabase database;
  late ProfileRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = ProfileRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('returns zero gameplay stats when no events exist', () async {
    final stats = await repository.fetchProfileStats();

    expect(stats.cardsAnswered, 0);
    expect(stats.cardsPassed, 0);
    expect(stats.cardsPlayed, 0);
  });

  test('aggregates answered and passed gameplay events into profile stats', (
    ) async {
    await repository.recordGameplayCardEvent(
      deckId: 'no-dead-air',
      action: GameplayCardAction.answered,
    );
    await repository.recordGameplayCardEvent(
      deckId: 'no-dead-air',
      action: GameplayCardAction.passed,
    );
    await repository.recordGameplayCardEvent(
      deckId: 'chaos-mode',
      action: GameplayCardAction.answered,
    );

    final stats = await repository.fetchProfileStats();

    expect(stats.cardsAnswered, 2);
    expect(stats.cardsPassed, 1);
    expect(stats.cardsPlayed, 3);
  });
}
