import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Spillr/features/decks/data/question_generation_service.dart';
import 'package:Spillr/features/game/domain/spillr_deck.dart';

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
  const furParentsDeck = SpillrDeck(
    id: 'custom-1',
    title: 'Fur Parents',
    description: 'Pet-owner stories, chaos, and cute habits',
    questions: [],
    backgroundColor: Colors.white,
    borderColor: Colors.black,
    badgeColor: Colors.black,
    badgeTextColor: Colors.white,
    iconColor: Colors.black,
    cardBorderColor: Colors.black,
  );
  const weirdHumorDeck = SpillrDeck(
    id: 'custom-2',
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

  group('isGeneratedQuestionMeaningfullyDifferent', () {
    test('rejects exact duplicates', () {
      expect(
        isGeneratedQuestionMeaningfullyDifferent(
          "What's your most NPC habit?",
          const ["What's your most NPC habit?"],
        ),
        isFalse,
      );
    });

    test('rejects close rephrasings of the same premise', () {
      expect(
        isGeneratedQuestionMeaningfullyDifferent(
          "What's the most chaotic thing you've bought online?",
          const ["What's your most chaotic online purchase?"],
        ),
        isFalse,
      );
    });

    test('accepts clearly different questions', () {
      expect(
        isGeneratedQuestionMeaningfullyDifferent(
          'Who in the group would survive a reality show the longest?',
          const ["What's your most chaotic online purchase?"],
        ),
        isTrue,
      );
    });
  });

  group('sanitizeGeneratedQuestion', () {
    test('uses a later line when the first line is only an intro', () {
      expect(
        sanitizeGeneratedQuestion(
          'Here is a question:\nWhat joke is too weird to explain normally?',
        ),
        'What joke is too weird to explain normally?',
      );
    });

    test('extracts a question after conversational wrapper text', () {
      expect(
        sanitizeGeneratedQuestion(
          "Sure! What is the strangest joke you've laughed at recently?",
        ),
        "What is the strangest joke you've laughed at recently?",
      );
    });

    test('adds a question mark for question-shaped output', () {
      expect(
        sanitizeGeneratedQuestion(
          'What weird joke would instantly expose your sense of humor',
        ),
        'What weird joke would instantly expose your sense of humor?',
      );
    });
  });

  group('mapGemmaSetupError', () {
    test('treats Android bundled COPY_ERROR failures as missing models', () {
      final error = PlatformException(
        code: 'COPY_ERROR',
        message:
            'open failed: models/gemma3-270m-it-q8.task: No such file or directory',
      );

      expect(
        mapGemmaSetupError(error),
        isA<QuestionGenerationUnavailableException>().having(
          (exception) => exception.message,
          'message',
          missingBundledGemmaModelMessage,
        ),
      );
    });

    test('keeps unknown setup failures on the generic retry message', () {
      expect(
        mapGemmaSetupError(const FormatException('unexpected gemma error')),
        isA<QuestionGenerationUnavailableException>().having(
          (exception) => exception.message,
          'message',
          'Offline AI is not ready on this device yet. Please reopen the app and try again.',
        ),
      );
    });
  });

  group('GemmaQuestionGenerationService', () {
    test(
      'prompts Gemma with selected deck context and sanitizes the result',
      () async {
        final client = _FakeGemmaQuestionClient([
          '1. "What chaotic group chat moment would expose you first?"',
        ]);
        final service = GemmaQuestionGenerationService(client: client);

        final question = await service.generateQuestion(
          deck: deck,
          excludedQuestions: const [
            "What's your most chaotic online purchase?",
          ],
        );

        expect(
          question,
          'What chaotic group chat moment would expose you first?',
        );
        expect(client.prompts, hasLength(1));
        expect(client.prompts.single, contains('Deck title: Chaos Mode'));
        expect(
          client.prompts.single,
          contains('Unhinged party stories and unserious confessions'),
        );
        expect(
          client.prompts.single,
          contains("What's your most unserious fear?"),
        );
        expect(
          client.prompts.single,
          contains("What's your most chaotic online purchase?"),
        );
      },
    );

    test(
      'retries duplicate and off-category responses before returning a match',
      () async {
        final client = _FakeGemmaQuestionClient([
          "What's your most chaotic online purchase?",
          "What's the best tax filing app?",
          'What villain origin story would your group chat never let go?',
        ]);
        final service = GemmaQuestionGenerationService(client: client);

        final question = await service.generateQuestion(deck: deck);

        expect(
          question,
          'What villain origin story would your group chat never let go?',
        );
        expect(client.prompts, hasLength(3));
      },
    );

    test('passes rejected questions to the retry prompt', () async {
      final client = _FakeGemmaQuestionClient([
        'What pet habit secretly controls your whole schedule?',
      ]);
      final service = GemmaQuestionGenerationService(client: client);

      final question = await service.generateQuestion(
        deck: furParentsDeck,
        excludedQuestions: const [
          'What pet voice do you use when nobody is around?',
        ],
      );

      expect(question, 'What pet habit secretly controls your whole schedule?');
      expect(
        client.prompts.single,
        contains('What pet voice do you use when nobody is around?'),
      );
      expect(client.prompts.single, contains('Deck title: Fur Parents'));
    });

    test('accepts a themed question for an empty custom deck', () async {
      final client = _FakeGemmaQuestionClient([
        'What joke would be way too weird to explain to a normal person?',
      ]);
      final service = GemmaQuestionGenerationService(client: client);

      final question = await service.generateQuestion(deck: weirdHumorDeck);

      expect(
        question,
        'What joke would be way too weird to explain to a normal person?',
      );
      expect(
        client.prompts.single,
        contains('Custom conversation category focused on Weird Humor.'),
      );
      expect(
        client.prompts.single,
        contains(
          'For custom or empty decks, infer the vibe directly from the deck title.',
        ),
      );
    });

    test(
      'uses a different generation angle when excluded questions change',
      () async {
        final client = _FakeGemmaQuestionClient([
          'What weird joke would instantly expose your sense of humor?',
        ]);
        final service = GemmaQuestionGenerationService(client: client);

        await service.generateQuestion(
          deck: weirdHumorDeck,
          excludedQuestions: const [
            'What joke would be way too weird to explain to a normal person?',
          ],
        );

        expect(
          client.prompts.single,
          contains('Generation angle: a surprising opinion'),
        );
        expect(
          client.prompts.single,
          contains(
            'What joke would be way too weird to explain to a normal person?',
          ),
        );
      },
    );

    test('falls back after repeated invalid model responses', () async {
      final client = _FakeGemmaQuestionClient([
        'Tell a story about taxes.',
        'This is not a question.',
        "What's your most chaotic online purchase?",
      ]);
      final service = GemmaQuestionGenerationService(
        client: client,
        maxAttempts: 3,
      );

      final question = await service.generateQuestion(deck: deck);

      expect(
        question,
        'What is the funniest Chaos Mode thing that happened to you recently?',
      );
      expect(client.prompts, hasLength(3));
    });

    test('rotates fallback questions away from excluded results', () async {
      final client = _FakeGemmaQuestionClient(['Not a question.']);
      final service = GemmaQuestionGenerationService(
        client: client,
        maxAttempts: 1,
      );

      final question = await service.generateQuestion(
        deck: weirdHumorDeck,
        excludedQuestions: const [
          'What is one story that perfectly fits the Weird Humor vibe?',
          'What moment in your life feels most like Weird Humor?',
          'What is something you would only admit in a Weird Humor conversation?',
        ],
      );

      expect(
        question,
        'What is your most specific Weird Humor opinion?',
      );
    });

    test('rethrows Gemma availability errors without retrying', () async {
      final client = _FakeGemmaQuestionClient([
        const QuestionGenerationUnavailableException(
          missingBundledGemmaModelMessage,
        ),
      ]);
      final service = GemmaQuestionGenerationService(client: client);

      await expectLater(
        service.generateQuestion(deck: deck),
        throwsA(
          isA<QuestionGenerationUnavailableException>().having(
            (error) => error.message,
            'message',
            missingBundledGemmaModelMessage,
          ),
        ),
      );
      expect(client.prompts, hasLength(1));
    });

    test('rethrows Gemma timeout errors without retrying', () async {
      final client = _FakeGemmaQuestionClient([
        const QuestionGenerationTimeoutException(
          questionGenerationTimeoutMessage,
        ),
      ]);
      final service = GemmaQuestionGenerationService(client: client);

      await expectLater(
        service.generateQuestion(deck: deck),
        throwsA(
          isA<QuestionGenerationTimeoutException>().having(
            (error) => error.message,
            'message',
            questionGenerationTimeoutMessage,
          ),
        ),
      );
      expect(client.prompts, hasLength(1));
    });
  });
}

class _FakeGemmaQuestionClient implements QuestionGemmaClient {
  _FakeGemmaQuestionClient(this._responses);

  final List<Object> _responses;
  final List<String> prompts = <String>[];
  var _index = 0;

  @override
  Future<String> generate(String prompt) async {
    prompts.add(prompt);
    final response = _responses[_index++];
    if (response is Exception) {
      throw response;
    }
    return response as String;
  }
}
