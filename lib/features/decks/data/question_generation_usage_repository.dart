import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import 'question_generation_errors.dart';

const int kQuestionGenerationMaxAttempts = 15;
const Duration kQuestionGenerationCooldown = Duration(hours: 1);

abstract class QuestionGenerationUsageStore {
  Future<QuestionGenerationUsageState> readStatus();

  Future<QuestionGenerationUsageState> reserveAttempt();
}

class QuestionGenerationUsageState {
  const QuestionGenerationUsageState({
    required this.attemptCount,
    required this.updatedAt,
    this.limitReachedAt,
  });

  final int attemptCount;
  final DateTime? limitReachedAt;
  final DateTime updatedAt;

  bool get hasReachedLimit =>
      attemptCount >= kQuestionGenerationMaxAttempts && limitReachedAt != null;

  DateTime? get cooldownEndsAt =>
      limitReachedAt?.add(kQuestionGenerationCooldown);

  bool isBlockedAt(DateTime now) {
    final cooldownEndsAtValue = cooldownEndsAt;
    if (cooldownEndsAtValue == null) {
      return false;
    }
    return now.isBefore(cooldownEndsAtValue);
  }

  bool shouldResetAt(DateTime now) {
    final cooldownEndsAtValue = cooldownEndsAt;
    if (cooldownEndsAtValue == null) {
      return false;
    }
    return !now.isBefore(cooldownEndsAtValue);
  }

  Duration? cooldownRemaining(DateTime now) {
    final cooldownEndsAtValue = cooldownEndsAt;
    if (cooldownEndsAtValue == null) {
      return null;
    }

    final remaining = cooldownEndsAtValue.difference(now);
    if (remaining.isNegative || remaining == Duration.zero) {
      return Duration.zero;
    }
    return remaining;
  }
}

class QuestionGenerationLimitExceededException
    extends QuestionGenerationException {
  const QuestionGenerationLimitExceededException({
    required this.retryAt,
    required super.message,
  }) : super(title: 'Generation Limit Reached');

  final DateTime retryAt;
}

class DriftQuestionGenerationUsageRepository
    implements QuestionGenerationUsageStore {
  DriftQuestionGenerationUsageRepository(
    this._database, {
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now;

  final AppDatabase _database;
  final DateTime Function() _now;

  @override
  Future<QuestionGenerationUsageState> readStatus() async {
    return _database.transaction(() async {
      final state = await _readOrCreateState();
      return _normalizeIfNeeded(state);
    });
  }

  @override
  Future<QuestionGenerationUsageState> reserveAttempt() async {
    return _database.transaction(() async {
      final state = await _readOrCreateState();
      final normalizedState = await _normalizeIfNeeded(state);
      final now = _now();

      if (normalizedState.isBlockedAt(now)) {
        throw QuestionGenerationLimitExceededException(
          retryAt: normalizedState.cooldownEndsAt!,
          message: _buildLimitMessage(normalizedState.cooldownRemaining(now)),
        );
      }

      final nextAttemptCount = normalizedState.attemptCount + 1;
      final limitReachedAt = nextAttemptCount >= kQuestionGenerationMaxAttempts
          ? now
          : null;

      await (_database.update(
        _database.questionGenerationUsageEntries,
      )..where((table) => table.id.equals(_usageRowId))).write(
        QuestionGenerationUsageEntriesCompanion(
          attemptCount: Value(nextAttemptCount),
          limitReachedAt: Value<DateTime?>(limitReachedAt),
          updatedAt: Value(now),
        ),
      );

      return QuestionGenerationUsageState(
        attemptCount: nextAttemptCount,
        limitReachedAt: limitReachedAt,
        updatedAt: now,
      );
    });
  }

  Future<QuestionGenerationUsageState> _readOrCreateState() async {
    final row = await (_database.select(
      _database.questionGenerationUsageEntries,
    )..where((table) => table.id.equals(_usageRowId))).getSingleOrNull();

    if (row != null) {
      return _mapRow(row);
    }

    final now = _now();
    await _database
        .into(_database.questionGenerationUsageEntries)
        .insert(
          QuestionGenerationUsageEntriesCompanion.insert(
            id: Value(_usageRowId),
            attemptCount: const Value(0),
            limitReachedAt: const Value<DateTime?>(null),
            updatedAt: now,
          ),
        );

    return QuestionGenerationUsageState(
      attemptCount: 0,
      limitReachedAt: null,
      updatedAt: now,
    );
  }

  Future<QuestionGenerationUsageState> _normalizeIfNeeded(
    QuestionGenerationUsageState state,
  ) async {
    final now = _now();
    if (!state.shouldResetAt(now)) {
      return state;
    }

    await (_database.update(
      _database.questionGenerationUsageEntries,
    )..where((table) => table.id.equals(_usageRowId))).write(
      QuestionGenerationUsageEntriesCompanion(
        attemptCount: const Value(0),
        limitReachedAt: const Value<DateTime?>(null),
        updatedAt: Value(now),
      ),
    );

    return QuestionGenerationUsageState(
      attemptCount: 0,
      limitReachedAt: null,
      updatedAt: now,
    );
  }

  QuestionGenerationUsageState _mapRow(QuestionGenerationUsageEntry row) {
    return QuestionGenerationUsageState(
      attemptCount: row.attemptCount,
      limitReachedAt: row.limitReachedAt,
      updatedAt: row.updatedAt,
    );
  }
}

String _buildLimitMessage(Duration? remaining) {
  final duration = remaining ?? kQuestionGenerationCooldown;
  final label = _formatDuration(duration);
  return 'You have used all 15 AI generations. Try again in $label.';
}

String _formatDuration(Duration duration) {
  if (duration.inHours >= 1) {
    final hours = duration.inHours;
    return hours == 1 ? '1 hour' : '$hours hours';
  }

  final minutes = duration.inMinutes;
  if (minutes >= 1) {
    return minutes == 1 ? '1 minute' : '$minutes minutes';
  }

  return 'less than a minute';
}

const _usageRowId = 1;
