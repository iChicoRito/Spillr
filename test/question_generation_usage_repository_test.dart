import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spillr/core/database/app_database.dart';
import 'package:spillr/features/decks/data/question_generation_service.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'resets the usage counter after the one hour cooldown expires',
    () async {
      var now = DateTime(2026, 5, 31, 12, 0);
      final repository = DriftQuestionGenerationUsageRepository(
        database,
        now: () => now,
      );

      final initialState = await repository.readStatus();
      expect(initialState.attemptCount, 0);
      expect(initialState.limitReachedAt, isNull);

      QuestionGenerationUsageState state = initialState;
      for (var index = 0; index < kQuestionGenerationMaxAttempts; index++) {
        state = await repository.reserveAttempt();
      }

      expect(state.attemptCount, kQuestionGenerationMaxAttempts);
      expect(state.limitReachedAt, now);
      expect(state.isBlockedAt(now), isTrue);

      await expectLater(
        repository.reserveAttempt(),
        throwsA(
          isA<QuestionGenerationLimitExceededException>().having(
            (error) => error.retryAt,
            'retryAt',
            now.add(kQuestionGenerationCooldown),
          ),
        ),
      );

      now = now.add(const Duration(hours: 1, minutes: 1));

      final resetState = await repository.readStatus();
      expect(resetState.attemptCount, 0);
      expect(resetState.limitReachedAt, isNull);
      expect(resetState.isBlockedAt(now), isFalse);

      final postResetState = await repository.reserveAttempt();
      expect(postResetState.attemptCount, 1);
      expect(postResetState.limitReachedAt, isNull);
    },
  );
}
