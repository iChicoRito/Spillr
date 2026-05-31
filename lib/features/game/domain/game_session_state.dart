import 'dart:math';

import 'game_result.dart';
import 'spillr_deck.dart';

class GameSessionState {
  const GameSessionState({
    required this.deck,
    required this.questions,
    required this.currentIndex,
    required this.answeredCount,
    required this.passedCount,
    required this.isFlipped,
  });

  factory GameSessionState.start(SpillrDeck deck, {Random? random}) {
    final shuffledQuestions = [...deck.questions]..shuffle(random);

    return GameSessionState(
      deck: deck,
      questions: List.unmodifiable(shuffledQuestions),
      currentIndex: 0,
      answeredCount: 0,
      passedCount: 0,
      isFlipped: false,
    );
  }

  final SpillrDeck deck;
  final List<String> questions;
  final int currentIndex;
  final int answeredCount;
  final int passedCount;
  final bool isFlipped;

  int get totalQuestions => questions.length;
  int get displayIndex => currentIndex + 1;
  String get currentQuestion => questions[currentIndex];

  GameSessionState flip() {
    return copyWith(isFlipped: !isFlipped);
  }

  GameSessionState nextAnswered() {
    return copyWith(
      currentIndex: currentIndex + 1,
      answeredCount: answeredCount + 1,
      isFlipped: false,
    );
  }

  GameSessionState nextPassed() {
    return copyWith(
      currentIndex: currentIndex + 1,
      passedCount: passedCount + 1,
      isFlipped: false,
    );
  }

  GameResult answeredResult(String displayName) {
    return _resultForCounts(
      answered: answeredCount + 1,
      passed: passedCount,
      displayName: displayName,
    );
  }

  GameResult passedResult(String displayName) {
    return _resultForCounts(
      answered: answeredCount,
      passed: passedCount + 1,
      displayName: displayName,
    );
  }

  GameResult endedResult(String displayName) {
    if (answeredCount == 0) {
      return GameResult(
        title: 'No Spill? Kinda Sus, $displayName',
        subtitle:
            'You ended the round with zero answers. The tea remains untouched.',
      );
    }

    return _resultForCounts(
      answered: answeredCount,
      passed: passedCount,
      displayName: displayName,
    );
  }

  GameSessionState copyWith({
    SpillrDeck? deck,
    List<String>? questions,
    int? currentIndex,
    int? answeredCount,
    int? passedCount,
    bool? isFlipped,
  }) {
    return GameSessionState(
      deck: deck ?? this.deck,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answeredCount: answeredCount ?? this.answeredCount,
      passedCount: passedCount ?? this.passedCount,
      isFlipped: isFlipped ?? this.isFlipped,
    );
  }

  GameResult _resultForCounts({
    required int answered,
    required int passed,
    required String displayName,
  }) {
    if (answered == totalQuestions && passed == 0) {
      return GameResult(
        title: 'You Spilled\nEverything,\n$displayName',
        subtitle: 'You survived the questions. Honestly, iconic behavior.',
      );
    }

    if (answered == 0 && passed == totalQuestions) {
      return const GameResult(
        title: 'Certified\nDodger, Chico',
        subtitle: "You passed every question. Suspicious, but we'll allow it.",
      );
    }

    return GameResult(
      title: 'Almost Spilled\nEverything,\n$displayName',
      subtitle: 'You finished the deck, but some tea stayed unspilled.',
    );
  }
}
