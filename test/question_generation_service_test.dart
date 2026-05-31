import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spillr/features/decks/data/question_generation_service.dart';
import 'package:spillr/features/game/domain/spillr_deck.dart';

void main() {
  const deck = SpillrDeck(
    id: 'chaos-mode',
    title: 'Chaos Mode',
    description: 'Unhinged party stories and unserious confessions',
    questions: [
      "What's your most chaotic online purchase?",
      "What's your most unserious fear?",
      "Which tiny habit makes you feel like an NPC?",
      "What's the pettiest reason you've judged someone?",
    ],
    backgroundColor: Colors.white,
    borderColor: Colors.black,
    badgeColor: Colors.black,
    badgeTextColor: Colors.white,
    iconColor: Colors.black,
    cardBorderColor: Colors.black,
  );

  const customDeck = SpillrDeck(
    id: 'custom-1',
    title: 'Weird Humor',
    description: 'Your custom tea set',
    questions: [],
    backgroundColor: Colors.white,
    borderColor: Colors.black,
    badgeColor: Colors.black,
    badgeTextColor: Colors.white,
    iconColor: Colors.black,
    cardBorderColor: Colors.black,
  );

  group('PrototypeQuestionGenerationService', () {
    test('generates a question tied to the selected deck title', () async {
      final service = PrototypeQuestionGenerationService(
        responseDelay: Duration.zero,
      );

      final question = await service.generateQuestion(deck: deck);

      expect(question, 'What is one story that perfectly fits the Chaos Mode vibe?');
    });

    test('avoids excluded questions when regenerating', () async {
      final service = PrototypeQuestionGenerationService(
        responseDelay: Duration.zero,
      );

      const blockedQuestion =
          'What is one story that perfectly fits the Chaos Mode vibe?';
      final question = await service.generateQuestion(
        deck: deck,
        excludedQuestions: const [blockedQuestion],
      );

      expect(
        question,
        'What moment in your life feels most like Chaos Mode?',
      );
      expect(question, isNot(blockedQuestion));
    });

    test('keeps the prototype output grounded in the deck title for custom decks', () async {
      final service = PrototypeQuestionGenerationService(
        responseDelay: Duration.zero,
      );

      final question = await service.generateQuestion(deck: customDeck);

      expect(question, contains('Weird Humor'));
      expect(question, isNot(contains('custom tea set')));
    });
  });
}
