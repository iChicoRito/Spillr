import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:spillr/app/app.dart';
import 'package:spillr/core/database/app_database.dart';
import 'package:spillr/features/game/data/spillr_decks.dart';
import 'package:spillr/features/game/domain/game_result.dart';
import 'package:spillr/features/game/domain/game_session_state.dart';
import 'package:spillr/features/game/presentation/screens/ending_page_screen.dart';
import 'package:spillr/features/game/presentation/providers/game_providers.dart';
import 'package:spillr/features/onboarding/presentation/providers/onboarding_providers.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          gameRandomProvider.overrideWithValue(Random(1)),
        ],
        child: const SpillrApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> advanceToNameInput(WidgetTester tester) async {
    await tester.tap(find.text('Okay'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('It sounds fun'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start Spilling'));
    await tester.pumpAndSettle();
  }

  Future<void> seedProfileAndOpenPlayPage(WidgetTester tester) async {
    await database.saveProfile('Chico');
    await pumpApp(tester);
  }

  Future<void> openDeckFromPlayPage(
    WidgetTester tester, {
    required String label,
  }) async {
    const deckIndexes = {
      'Play Deep Spill': 0,
      'Play No Dead Air': 1,
      'Play Chaos Mode': 2,
      'Play Hot Seat': 3,
      'Play Date Mode': 4,
    };
    final pageView = tester.widget<PageView>(find.byType(PageView));
    final targetIndex = deckIndexes[label];
    if (targetIndex != null) {
      pageView.controller!.jumpToPage(targetIndex);
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(find.text(label));
    await tester.tap(find.text(label));
    await tester.pumpAndSettle();
  }

  Future<void> flipCard(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('game-flip-card')));
    await tester.pumpAndSettle();
  }

  Future<void> answerCurrentCard(
    WidgetTester tester, {
    bool finalCard = false,
  }) async {
    await flipCard(tester);
    await tester.tap(find.byKey(const ValueKey('game-next-card-button')));
    if (finalCard) {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
    } else {
      await tester.pumpAndSettle();
    }
  }

  Future<void> passCurrentCard(
    WidgetTester tester, {
    bool finalCard = false,
  }) async {
    await flipCard(tester);
    await tester.tap(find.byKey(const ValueKey('game-pass-button')));
    if (finalCard) {
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1200));
    } else {
      await tester.pumpAndSettle();
    }
  }

  String currentQuestionText(WidgetTester tester) {
    return tester.widget<Text>(
      find.byKey(const ValueKey('game-question-text')),
    ).data!;
  }

  testWidgets('renders the first onboarding screen', (tester) async {
    await pumpApp(tester);

    expect(find.text('Vibe Check'), findsOneWidget);
    expect(find.text('Okay'), findsOneWidget);
  });

  testWidgets('progresses through the onboarding intro screens', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Okay'));
    await tester.pumpAndSettle();
    expect(find.text('Tea Time'), findsOneWidget);

    await tester.tap(find.text('It sounds fun'));
    await tester.pumpAndSettle();
    expect(find.text('Main Character'), findsOneWidget);

    await tester.tap(find.text('Start Spilling'));
    await tester.pumpAndSettle();
    expect(find.text('What should we call you?'), findsOneWidget);
  });

  testWidgets('blocks empty name submission', (tester) async {
    await pumpApp(tester);

    await advanceToNameInput(tester);

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your name.'), findsOneWidget);
  });

  testWidgets('submitting a valid name shows confirmation', (tester) async {
    await pumpApp(tester);

    await advanceToNameInput(tester);

    await tester.enterText(find.byType(TextFormField), 'Chico');
    await tester.tap(find.text('Submit'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining("Let's Start"), findsOneWidget);
    expect(find.textContaining('Chico'), findsOneWidget);
    expect(find.text("Let's Go!"), findsOneWidget);
  });

  testWidgets('lets the user reach the play page after onboarding', (
    tester,
  ) async {
    await pumpApp(tester);

    await advanceToNameInput(tester);
    await tester.enterText(find.byType(TextFormField), 'Chico');
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    await tester.tap(find.text("Let's Go!"));
    await tester.pumpAndSettle();

    expect(find.text('Hey, Chico'), findsOneWidget);
    expect(find.text('Ready to Spill?'), findsOneWidget);
    expect(find.text('Choose Your Deck'), findsOneWidget);
    expect(find.text('No\nDead\nAir'), findsOneWidget);
    expect(find.text('Pull a random deck'), findsOneWidget);
    expect(find.text('Play Cards'), findsOneWidget);
  });

  testWidgets(
    'skips onboarding when a saved profile exists and shows play page',
    (tester) async {
      await seedProfileAndOpenPlayPage(tester);

      expect(find.text('Hey, Chico'), findsOneWidget);
      expect(find.text('Ready to Spill?'), findsOneWidget);
      expect(find.text('Choose Your Deck'), findsOneWidget);
      expect(find.text('No\nDead\nAir'), findsOneWidget);
      expect(find.text('Pull a random deck'), findsOneWidget);
      expect(find.text('Play Cards'), findsOneWidget);
      expect(find.text('Vibe Check'), findsNothing);
    },
  );

  testWidgets('uses the figma title typography for the active deck card', (
    tester,
  ) async {
    await database.saveProfile('Chico');

    await pumpApp(tester);

    final title = tester.widget<Text>(find.text('No\nDead\nAir'));

    expect(title.style?.fontSize, 50);
    expect(title.style?.fontWeight, FontWeight.w600);
  });

  testWidgets('renders the active deck card without a shadow', (tester) async {
    await database.saveProfile('Chico');

    await pumpApp(tester);

    final decorated = tester.widget<DecoratedBox>(
      find
          .ancestor(
            of: find.text('No\nDead\nAir'),
            matching: find.byType(DecoratedBox),
          )
          .first,
    );

    final decoration = decorated.decoration as BoxDecoration;

    expect(decoration.boxShadow, isNull);
  });

  testWidgets('updates the active deck label when the carousel moves', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    expect(find.text('Play No Dead Air'), findsOneWidget);

    final pageView = tester.widget<PageView>(find.byType(PageView));
    pageView.controller!.jumpToPage(2);
    await tester.pumpAndSettle();

    expect(find.text('Play Chaos Mode'), findsOneWidget);
  });

  testWidgets('starts each game with shuffled questions', (tester) async {
    final deck = spillrDecks.firstWhere((deck) => deck.id == 'no-dead-air');
    final session = GameSessionState.start(deck, random: Random(1));

    expect(session.currentQuestion, isNot(deck.questions.first));
    expect(session.questions, isNot(equals(deck.questions)));
    expect(session.questions, containsAll(deck.questions));
  });

  testWidgets('opens the game page from the active deck button', (tester) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');

    expect(find.byKey(const ValueKey('game-flip-card')), findsOneWidget);
    expect(find.text('Question'), findsOneWidget);
    expect(find.text('No. 1'), findsOneWidget);
    expect(find.text('1 of 20'), findsOneWidget);
    expect(find.text('Tap to flip'), findsOneWidget);
  });

  testWidgets('pins the tap to flip prompt to the bottom of the front card', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');

    final promptPositioned = tester.widget<Positioned>(
      find.byKey(const ValueKey('game-tap-to-flip-positioned')),
    );

    expect(promptPositioned.bottom, 20);
  });

  testWidgets('shows a progress bar below the card', (tester) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('animates the progress bar when advancing to the next card', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
    await flipCard(tester);

    final progressBarBefore = tester.widget<LinearProgressIndicator>(
      find.byKey(const ValueKey('game-progress-bar')),
    );
    expect(progressBarBefore.value, closeTo(1 / 20, 0.0001));

    await tester.tap(find.byKey(const ValueKey('game-next-card-button')));
    await tester.pump(const Duration(milliseconds: 420));
    await tester.pump(const Duration(milliseconds: 16));

    final progressBarDuring = tester.widget<LinearProgressIndicator>(
      find.byKey(const ValueKey('game-progress-bar')),
    );
    expect(progressBarDuring.value!, greaterThan(1 / 20));
    expect(progressBarDuring.value!, lessThan(2 / 20));

    await tester.pump(const Duration(milliseconds: 280));

    final progressBarAfter = tester.widget<LinearProgressIndicator>(
      find.byKey(const ValueKey('game-progress-bar')),
    );
    expect(progressBarAfter.value, closeTo(2 / 20, 0.0001));
  });

  testWidgets('shows done im cooked on the last card action button', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');

    for (var i = 0; i < 19; i++) {
      await answerCurrentCard(tester);
    }

    await flipCard(tester);

    expect(find.text("Done, I'm cooked"), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('hides the deck selector while flipping', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
    await flipCard(tester);

    expect(find.byKey(const ValueKey('game-deck-selector')), findsNothing);
  });

  testWidgets('keeps the deck selector hidden after the first flip', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
    await flipCard(tester);
    await tester.tap(find.byKey(const ValueKey('game-next-card-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('game-deck-selector')), findsNothing);
  });

  testWidgets('keeps the badge and question centered on the front card', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');

    final centerBlock = tester.widget<Align>(
      find.byKey(const ValueKey('game-front-main-center')),
    );

    expect(centerBlock.alignment, Alignment.center);
  });

  testWidgets('uses a smaller badge on the unflipped card', (tester) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');

    final badgeText = tester.widget<Text>(
      find.descendant(
        of: find.byKey(const ValueKey('game-front-badge')),
        matching: find.text('No Dead Air'),
      ),
    );

    expect(badgeText.style?.fontSize, 14);
  });

  testWidgets('flips the card and advances to the next question', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
    await flipCard(tester);

    final firstQuestion = currentQuestionText(tester);
    expect(firstQuestion, isNotEmpty);
    expect(find.byKey(const ValueKey('game-next-card-button')), findsOneWidget);
    expect(find.byKey(const ValueKey('game-pass-button')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('game-next-card-button')));
    await tester.pumpAndSettle();

    expect(find.text('No. 2'), findsOneWidget);
    expect(find.text('2 of 20'), findsOneWidget);
    expect(find.text('Tap to flip'), findsOneWidget);

    await flipCard(tester);
    final secondQuestion = currentQuestionText(tester);
    expect(secondQuestion, isNot(equals(firstQuestion)));
  });

  testWidgets('animates the card with a transform while flipping', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');

    final initialTransform = tester.widget<Transform>(
      find.byKey(const ValueKey('game-flip-transform')),
    );
    final initialStorage = List<double>.from(initialTransform.transform.storage);

    await tester.tap(find.byKey(const ValueKey('game-flip-card')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final animatedTransform = tester.widget<Transform>(
      find.byKey(const ValueKey('game-flip-transform')),
    );
    expect(
      animatedTransform.transform.storage,
      isNot(equals(initialStorage)),
    );
  });

  testWidgets('does not show a badge on the flipped card', (tester) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play Chaos Mode');
    await flipCard(tester);

    expect(
      find.descendant(
        of: find.byKey(const ValueKey('back-face')),
        matching: find.byType(DecoratedBox),
      ),
      findsNothing,
    );
  });

  testWidgets('keeps the flipped question centered in the middle of the card', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play Date Mode');
    await flipCard(tester);

    final questionCenter = tester.widget<Align>(
      find.byKey(const ValueKey('game-question-center')),
    );

    expect(questionCenter.alignment, Alignment.center);
  });

  testWidgets('does not flash the next question while closing the flipped card', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
    await flipCard(tester);

    final firstQuestion = currentQuestionText(tester);
    expect(firstQuestion, isNotEmpty);

    await tester.tap(find.byKey(const ValueKey('game-next-card-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(currentQuestionText(tester), equals(firstQuestion));

    await tester.pumpAndSettle();
    await flipCard(tester);
    expect(currentQuestionText(tester), isNot(equals(firstQuestion)));
  });

  testWidgets('passing every card shows the certified dodger ending', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play Chaos Mode');

    for (var i = 0; i < 20; i++) {
      await passCurrentCard(tester, finalCard: i == 19);
    }

    expect(find.text('Certified\nDodger, Chico'), findsOneWidget);
    expect(
      find.text("You passed every question. Suspicious, but we'll allow it."),
      findsOneWidget,
    );
    expect(find.text('Explore Decks'), findsOneWidget);
  });

  testWidgets('answering every card shows the spilled everything ending', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');

    for (var i = 0; i < 20; i++) {
      await answerCurrentCard(tester, finalCard: i == 19);
    }

    expect(find.text('You Spilled\nEverything,\nChico'), findsOneWidget);
    expect(
      find.text('You survived the questions. Honestly, iconic behavior.'),
      findsOneWidget,
    );
  });

  testWidgets('mixing answers and passes shows the almost spilled ending', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play Hot Seat');

    await answerCurrentCard(tester);
    for (var i = 0; i < 19; i++) {
      await passCurrentCard(tester, finalCard: i == 18);
    }

    expect(find.text('Almost Spilled\nEverything,\nChico'), findsOneWidget);
    expect(
      find.text('You finished the deck, but some tea stayed unspilled.'),
      findsOneWidget,
    );
  });

  testWidgets('shows confetti on the ending screen', (tester) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EndingPageScreen(
            deck: spillrDecks.firstWhere((deck) => deck.id == 'chaos-mode'),
            result: const GameResult(
              title: 'Certified\nDodger, Chico',
              subtitle:
                  "You passed every question. Suspicious, but we'll allow it.",
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.byType(ConfettiWidget), findsOneWidget);
  });

  testWidgets('switching categories before the first flip updates the deck', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');

    await tester.tap(find.byKey(const ValueKey('game-deck-selector')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Chaos Mode').last);
    await tester.pumpAndSettle();

    expect(find.text('No. 1'), findsOneWidget);
    expect(find.text('1 of 20'), findsOneWidget);
    expect(find.text('Tap to flip'), findsOneWidget);

    await flipCard(tester);
    final chaosQuestion = currentQuestionText(tester);
    expect(chaosQuestion, isNotEmpty);
    expect(
      spillrDecks
          .firstWhere((deck) => deck.id == 'chaos-mode')
          .questions
          .contains(chaosQuestion.replaceAll('"', '')),
      isTrue,
    );
  });
}
