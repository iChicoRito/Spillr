import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Spillr/core/database/app_database.dart';
import 'package:Spillr/features/decks/data/deck_repository.dart';
import 'package:Spillr/features/decks/domain/deck_catalog.dart';

void main() {
  late AppDatabase database;
  late DeckRepository repository;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    repository = DeckRepository(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('seeds built-in questions once and preserves built-in order', () async {
    await repository.ensureBuiltInQuestionsSeeded();
    await repository.ensureBuiltInQuestionsSeeded();

    final questions = await repository.fetchDeckQuestions('no-dead-air');

    expect(questions, hasLength(20));
    expect(questions.first.text, "What's your go-to comfort food?");
    expect(questions.first.isBuiltIn, isTrue);
    expect(questions.first.sortOrder, 0);
    expect(questions.last.sortOrder, 19);
  });

  test('persists built-in question edits as local overrides', () async {
    await repository.ensureBuiltInQuestionsSeeded();
    final question = (await repository.fetchDeckQuestions('deep-spill')).first;

    await repository.updateQuestion(
      id: question.id,
      rawText: 'What truth are you avoiding right now?',
    );

    final updatedQuestions = await repository.fetchDeckQuestions('deep-spill');

    expect(
      updatedQuestions.first.text,
      'What truth are you avoiding right now?',
    );
    expect(updatedQuestions.first.isBuiltIn, isTrue);
  });

  test(
    'persists built-in question deletes without deleting deck metadata',
    () async {
      await repository.ensureBuiltInQuestionsSeeded();
      final question = (await repository.fetchDeckQuestions(
        'chaos-mode',
      )).first;

      await repository.deleteQuestion(question.id);

      final questions = await repository.fetchDeckQuestions('chaos-mode');
      final deckList = await repository.fetchDeckList();

      expect(questions, hasLength(19));
      expect(questions.map((item) => item.id), isNot(contains(question.id)));
      expect(
        deckList.singleWhere((deck) => deck.id == 'chaos-mode').cardCount,
        19,
      );
    },
  );

  test('adds edits and deletes questions for a custom deck', () async {
    final deckId = await repository.createCustomDeck(
      rawName: 'Weird Humor',
      iconKey: CustomDeckIconKey.sparkles,
      colorKey: CustomDeckColorKey.teal,
    );

    final question = await repository.addQuestion(
      deckId: deckId,
      rawText: 'What joke lives rent free in your head?',
    );
    await repository.updateQuestion(
      id: question.id,
      rawText: 'What joke still makes you laugh?',
    );

    var questions = await repository.fetchDeckQuestions(deckId);
    expect(questions, hasLength(1));
    expect(questions.single.text, 'What joke still makes you laugh?');
    expect(questions.single.isBuiltIn, isFalse);

    await repository.deleteQuestion(question.id);

    questions = await repository.fetchDeckQuestions(deckId);
    expect(questions, isEmpty);
  });

  test('deleting a custom deck cleans up its questions', () async {
    final deckId = await repository.createCustomDeck(
      rawName: 'Late Night',
      iconKey: CustomDeckIconKey.mic,
      colorKey: CustomDeckColorKey.purple,
    );
    await repository.addQuestion(
      deckId: deckId,
      rawText: 'What topic keeps the table awake?',
    );

    await repository.deleteCustomDeck(deckId);

    expect(await repository.fetchDeckQuestions(deckId), isEmpty);
    expect(
      (await repository.fetchDeckList()).map((deck) => deck.id),
      isNot(contains(deckId)),
    );
  });

  test(
    'resolves custom decks into playable decks with visible questions',
    () async {
      final deckId = await repository.createCustomDeck(
        rawName: 'Party Sparks',
        iconKey: CustomDeckIconKey.party,
        colorKey: CustomDeckColorKey.amber,
      );
      await repository.addQuestion(
        deckId: deckId,
        rawText: 'Who started the funniest side quest tonight?',
      );

      final deck = await repository.resolvePlayableDeck(deckId);

      expect(deck.id, deckId);
      expect(deck.title, 'Party Sparks');
      expect(deck.questions, ['Who started the funniest side quest tonight?']);
    },
  );
}
