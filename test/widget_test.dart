import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:spillr/app/app.dart';
import 'package:spillr/core/database/app_database.dart';
import 'package:spillr/core/theme/app_colors.dart';
import 'package:spillr/features/game/data/spillr_decks.dart';
import 'package:spillr/features/game/domain/game_result.dart';
import 'package:spillr/features/game/domain/game_session_state.dart';
import 'package:spillr/features/game/presentation/screens/ending_page_screen.dart';
import 'package:spillr/features/game/presentation/screens/preparation_page_screen.dart';
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
      'Play': 5,
    };
    const deckKeys = {
      'Play Deep Spill': 'deep-spill',
      'Play No Dead Air': 'no-dead-air',
      'Play Chaos Mode': 'chaos-mode',
      'Play Hot Seat': 'hot-seat',
      'Play Date Mode': 'date-mode',
      'Play': 'wildcard-tea',
    };
    final pageView = tester.widget<PageView>(find.byType(PageView));
    final targetIndex = deckIndexes[label];
    final targetKey = deckKeys[label];
    if (targetIndex != null) {
      pageView.controller!.jumpToPage(targetIndex);
      await tester.pumpAndSettle();
    }
    await tester.ensureVisible(find.byKey(ValueKey('play-deck-button-$targetKey')));
    await tester.tap(find.byKey(ValueKey('play-deck-button-$targetKey')));
    await tester.pumpAndSettle();
  }

  Future<void> continueFromPreparation(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('preparation-continue-button')));
    await tester.pumpAndSettle();
  }

  Future<void> flipCard(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('game-flip-card')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
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
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 420));
      await tester.pump(const Duration(milliseconds: 320));
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
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 420));
      await tester.pump(const Duration(milliseconds: 320));
    }
  }

  String currentQuestionText(WidgetTester tester) {
    return tester
        .widget<Text>(find.byKey(const ValueKey('game-question-text')))
        .data!;
  }

  testWidgets('renders the first onboarding screen', (tester) async {
    await pumpApp(tester);

    expect(find.text('Vibe'), findsOneWidget);
    expect(find.text('Check'), findsOneWidget);
    expect(find.text('Okay'), findsOneWidget);
    expect(find.byKey(const ValueKey('onboarding-art-placeholder-0')), findsOneWidget);
  });

  testWidgets('progresses through the onboarding intro screens', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Okay'));
    await tester.pumpAndSettle();
    expect(find.text('Tea'), findsOneWidget);
    expect(find.text('Time'), findsOneWidget);

    await tester.tap(find.text('It sounds fun'));
    await tester.pumpAndSettle();
    expect(find.text('Main'), findsOneWidget);
    expect(find.text('Character'), findsOneWidget);

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
    expect(find.text('Pull a random deck'), findsNothing);
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
      expect(find.text('Pull a random deck'), findsNothing);
      expect(find.text('Play Cards'), findsOneWidget);
      expect(find.text('Vibe'), findsNothing);
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

  testWidgets('lets the play deck carousel bleed to the screen edges', (
    tester,
  ) async {
    await database.saveProfile('Chico');

    await pumpApp(tester);

    final carouselRect = tester.getRect(find.byType(PageView));
    final pageView = tester.widget<PageView>(find.byType(PageView));

    expect(carouselRect.left, 0);
    expect(carouselRect.right, 393);
    expect(pageView.clipBehavior, Clip.none);
    expect(pageView.controller!.viewportFraction, 0.64);
  });

  testWidgets('updates the active deck label when the carousel moves', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    expect(find.text('Play'), findsOneWidget);

    final pageView = tester.widget<PageView>(find.byType(PageView));
    pageView.controller!.jumpToPage(2);
    await tester.pumpAndSettle();

    expect(find.text('Play'), findsOneWidget);
  });

  testWidgets('shows wildcard tea as the final playable deck', (tester) async {
    await seedProfileAndOpenPlayPage(tester);

    final pageView = tester.widget<PageView>(find.byType(PageView));
    pageView.controller!.jumpToPage(5);
    await tester.pumpAndSettle();

    expect(find.text('Just Pull It'), findsOneWidget);
    expect(
      find.text('No category, no rules, just whatever the deck serves'),
      findsOneWidget,
    );
    expect(find.text('Play'), findsOneWidget);

    final playButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('play-deck-button-wildcard-tea')),
    );
    final playButtonRect = tester.getRect(
      find.byKey(const ValueKey('play-deck-button-wildcard-tea')),
    );
    final playButtonStyle = playButton.style!;

    expect(playButtonRect.height, 56);
    expect(
      playButtonStyle.shape?.resolve(const <WidgetState>{}),
      isA<RoundedRectangleBorder>(),
    );
    expect(
      playButtonStyle.backgroundColor?.resolve(const <WidgetState>{}),
      AppColors.white,
    );
    expect(
      playButtonStyle.foregroundColor?.resolve(const <WidgetState>{}),
      AppColors.neutral700,
    );
  });

  testWidgets('cycles Just Pull It letters through deck accent colors', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    final pageView = tester.widget<PageView>(find.byType(PageView));
    pageView.controller!.jumpToPage(5);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('play-deck-button-wildcard-tea')));
    await tester.pumpAndSettle();

    final letterOpacities = find.descendant(
      of: find.byKey(const ValueKey('preparation-intro-deck-line-0')),
      matching: find.byType(Opacity),
    );

    final firstLetter = tester.widget<Opacity>(letterOpacities.at(0));
    final secondLetter = tester.widget<Opacity>(letterOpacities.at(1));
    final thirdLetter = tester.widget<Opacity>(letterOpacities.at(2));

    final firstColor = tester
        .widget<Text>(
          find.descendant(
            of: find.byWidget(firstLetter),
            matching: find.byType(Text),
          ),
        )
        .style!
        .color;
    final secondColor = tester
        .widget<Text>(
          find.descendant(
            of: find.byWidget(secondLetter),
            matching: find.byType(Text),
          ),
        )
        .style!
        .color;
    final thirdColor = tester
        .widget<Text>(
          find.descendant(
            of: find.byWidget(thirdLetter),
            matching: find.byType(Text),
          ),
        )
        .style!
        .color;

    expect(firstColor, AppColors.blue500);
    expect(secondColor, AppColors.violet500);
    expect(thirdColor, AppColors.teal500);
  });

  test('wildcard tea deck aggregates all existing category questions', () {
    final wildcardDeck = spillrDecks.last;
    final sourceDecks = spillrDecks.take(spillrDecks.length - 1).toList();
    final expectedQuestions = sourceDecks
        .expand((deck) => deck.questions)
        .toList();

    expect(wildcardDeck.id, 'wildcard-tea');
    expect(wildcardDeck.title, 'Just Pull It');
    expect(wildcardDeck.backgroundColor, AppColors.neutral700);
    expect(wildcardDeck.questions, expectedQuestions);
  });

  testWidgets('starts each game with shuffled questions', (tester) async {
    final deck = spillrDecks.firstWhere((deck) => deck.id == 'no-dead-air');
    final session = GameSessionState.start(deck, random: Random(1));

    expect(session.currentQuestion, isNot(deck.questions.first));
    expect(session.questions, isNot(equals(deck.questions)));
    expect(session.questions, containsAll(deck.questions));
  });

  testWidgets('opens the game page from the active deck button', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');

    expect(
      find.byKey(const ValueKey('preparation-intro-line-one')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('preparation-intro-line-two')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('preparation-intro-deck')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('preparation-continue-button')),
      findsOneWidget,
    );
  });

  testWidgets('starts the game from the preparation screen', (tester) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
    await continueFromPreparation(tester);

    expect(find.byKey(const ValueKey('game-flip-card')), findsOneWidget);
    expect(find.text('Question'), findsOneWidget);
    expect(find.text('No. 1'), findsOneWidget);
    expect(find.text('1 of 20'), findsOneWidget);
    expect(find.text('Tap to flip'), findsOneWidget);
  });

  testWidgets('animates preparation letters sequentially from first to last', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: PreparationPageScreen(deckId: 'chaos-mode')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    final firstLetter = tester.widget<Opacity>(
      find.byKey(const ValueKey('preparation-letter-0')),
    );
    final lastLetter = tester.widget<Opacity>(
      find.byKey(const ValueKey('preparation-letter-28')),
    );

    expect(firstLetter.opacity, greaterThan(lastLetter.opacity));
    expect(lastLetter.opacity, 0);

    await tester.pumpAndSettle();

    final settledLastLetter = tester.widget<Opacity>(
      find.byKey(const ValueKey('preparation-letter-28')),
    );
    expect(settledLastLetter.opacity, 1);
  });

  testWidgets(
    'keeps multi-word deck title lines stable on preparation screen',
    (tester) async {
      await seedProfileAndOpenPlayPage(tester);

      await openDeckFromPlayPage(tester, label: 'Play No Dead Air');

      final firstDeckLine = tester.widget<Semantics>(
        find.byKey(const ValueKey('preparation-intro-deck-line-0')),
      );
      final secondDeckLine = tester.widget<Semantics>(
        find.byKey(const ValueKey('preparation-intro-deck-line-1')),
      );

      expect(firstDeckLine.properties.label, 'No');
      expect(secondDeckLine.properties.label, 'Dead Air');
      expect(find.text('Air'), findsNothing);
    },
  );

  testWidgets('pins the tap to flip prompt to the bottom of the front card', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
    await continueFromPreparation(tester);

    final promptPositioned = tester.widget<Positioned>(
      find.byKey(const ValueKey('game-tap-to-flip-positioned')),
    );

    expect(promptPositioned.bottom, 20);
  });

  testWidgets('shows a progress bar below the card', (tester) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
    await continueFromPreparation(tester);

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testWidgets('animates the progress bar when advancing to the next card', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
    await continueFromPreparation(tester);
    await flipCard(tester);

    final progressBarBefore = tester.widget<LinearProgressIndicator>(
      find.byKey(const ValueKey('game-progress-bar')),
    );
    expect(progressBarBefore.value, closeTo(1 / 20, 0.0001));

    await tester.tap(find.byKey(const ValueKey('game-next-card-button')));
    await tester.pump(const Duration(milliseconds: 420));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 80));

    final progressBarDuring = tester.widget<LinearProgressIndicator>(
      find.byKey(const ValueKey('game-progress-bar')),
    );
    expect(progressBarDuring.value!, greaterThan(1 / 20));
    expect(progressBarDuring.value!, lessThan(2 / 20));

    await tester.pump(const Duration(milliseconds: 220));

    final progressBarAfter = tester.widget<LinearProgressIndicator>(
      find.byKey(const ValueKey('game-progress-bar')),
    );
    expect(progressBarAfter.value, closeTo(2 / 20, 0.0001));
  });

  testWidgets('shows the three action buttons on the last card', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
    await continueFromPreparation(tester);

    for (var i = 0; i < 19; i++) {
      await answerCurrentCard(tester);
    }

    await flipCard(tester);

    expect(find.text('End'), findsOneWidget);
    expect(find.text('Answered'), findsOneWidget);
    expect(find.text('Pass'), findsOneWidget);
    expect(find.text("Done, I'm cooked"), findsNothing);
  });

  testWidgets('shows end spill and pass actions on the flipped card', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
    await continueFromPreparation(tester);
    await flipCard(tester);

    expect(find.text('End'), findsOneWidget);
    expect(find.text('Answered'), findsOneWidget);
    expect(find.text('Pass'), findsOneWidget);
  });

  testWidgets('uses a larger primary Answered button with hugeicons only', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
    await continueFromPreparation(tester);
    await flipCard(tester);

    final spillButtonSize = tester.getSize(
      find.byKey(const ValueKey('game-spill-button-circle')),
    );
    final endButtonSize = tester.getSize(
      find.byKey(const ValueKey('game-end-button-circle')),
    );
    final passButtonSize = tester.getSize(
      find.byKey(const ValueKey('game-pass-button-circle')),
    );
    final endIcon = tester.widget<HugeIcon>(
      find.descendant(
        of: find.byKey(const ValueKey('game-end-button')),
        matching: find.byType(HugeIcon),
      ),
    );
    final spillIcon = tester.widget<HugeIcon>(
      find.descendant(
        of: find.byKey(const ValueKey('game-next-card-button')),
        matching: find.byType(HugeIcon),
      ),
    );
    final passIcon = tester.widget<HugeIcon>(
      find.descendant(
        of: find.byKey(const ValueKey('game-pass-button')),
        matching: find.byType(HugeIcon),
      ),
    );

    expect(spillButtonSize.width, greaterThan(endButtonSize.width));
    expect(spillButtonSize.width, greaterThan(passButtonSize.width));
    expect(endIcon.icon, HugeIcons.strokeRoundedLogout05);
    expect(spillIcon.icon, HugeIcons.strokeRoundedBulb);
    expect(passIcon.icon, HugeIcons.strokeRoundedNext);
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('game-action-bar')),
        matching: find.byType(HugeIcon),
      ),
      findsNWidgets(3),
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('game-action-bar')),
        matching: find.byType(Icon),
      ),
      findsNothing,
    );
  });

  testWidgets('ends the round immediately when End is tapped', (tester) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
    await continueFromPreparation(tester);
    await flipCard(tester);

    await tester.tap(find.text('End'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));

    expect(find.text('No Spill? Kinda Sus, Chico'), findsOneWidget);
    expect(
      find.text(
        'You ended the round with zero answers. The tea remains untouched.',
      ),
      findsOneWidget,
    );
    expect(find.text('Back to Menu'), findsOneWidget);
  });

  testWidgets('does not show a deck selector on the game screen', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
    await continueFromPreparation(tester);

    expect(find.byKey(const ValueKey('game-deck-selector')), findsNothing);
  });

  testWidgets('shows a 10-second timer only on flipped cards', (tester) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
    await continueFromPreparation(tester);

    expect(find.byKey(const ValueKey('game-flip-timer-chip')), findsNothing);

    await flipCard(tester);

    expect(find.byKey(const ValueKey('game-flip-timer-chip')), findsOneWidget);
    expect(find.text('2:00'), findsOneWidget);
  });

  testWidgets('counts down the flipped-card timer in minute format', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
    await continueFromPreparation(tester);
    await flipCard(tester);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('1:59'), findsOneWidget);
  });

  testWidgets('counts down the flipped-card timer and auto-passes on timeout', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
    await continueFromPreparation(tester);
    await flipCard(tester);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('1:59'), findsOneWidget);

    await tester.pump(const Duration(seconds: 119));
    await tester.pumpAndSettle();

    expect(find.text('No. 2'), findsOneWidget);
    expect(find.text('2 of 20'), findsOneWidget);
    expect(find.text('Tap to flip'), findsOneWidget);
    expect(find.byKey(const ValueKey('game-flip-timer-chip')), findsNothing);
  });

  testWidgets('keeps the badge and question centered on the front card', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
    await continueFromPreparation(tester);

    final centerBlock = tester.widget<Align>(
      find.byKey(const ValueKey('game-front-main-center')),
    );

    expect(centerBlock.alignment, Alignment.center);
  });

  testWidgets('uses a smaller badge on the unflipped card', (tester) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
    await continueFromPreparation(tester);

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
    await continueFromPreparation(tester);
    await flipCard(tester);

    final firstQuestion = currentQuestionText(tester);
    expect(firstQuestion, isNotEmpty);
    expect(find.byKey(const ValueKey('game-next-card-button')), findsOneWidget);
    expect(find.byKey(const ValueKey('game-pass-button')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('game-next-card-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 420));
    await tester.pump(const Duration(milliseconds: 320));

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
    await continueFromPreparation(tester);

    final initialTransform = tester.widget<Transform>(
      find.byKey(const ValueKey('game-flip-transform')),
    );
    final initialStorage = List<double>.from(
      initialTransform.transform.storage,
    );

    await tester.tap(find.byKey(const ValueKey('game-flip-card')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    final animatedTransform = tester.widget<Transform>(
      find.byKey(const ValueKey('game-flip-transform')),
    );
    expect(animatedTransform.transform.storage, isNot(equals(initialStorage)));
  });

  testWidgets('does not show a badge on the flipped card', (tester) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play Chaos Mode');
    await continueFromPreparation(tester);
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
    await continueFromPreparation(tester);
    await flipCard(tester);

    final questionCenter = tester.widget<Align>(
      find.byKey(const ValueKey('game-question-center')),
    );

    expect(questionCenter.alignment, Alignment.center);
  });

  testWidgets('shows flipped questions without added outer quotation marks', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
    await continueFromPreparation(tester);
    await flipCard(tester);

    final question = currentQuestionText(tester);

    expect(question.startsWith('"'), isFalse);
    expect(question.endsWith('"'), isFalse);
  });

  testWidgets(
    'does not flash the next question while closing the flipped card',
    (tester) async {
      await seedProfileAndOpenPlayPage(tester);

      await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
      await continueFromPreparation(tester);
      await flipCard(tester);

      final firstQuestion = currentQuestionText(tester);
      expect(firstQuestion, isNotEmpty);

      await tester.tap(find.byKey(const ValueKey('game-next-card-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(currentQuestionText(tester), equals(firstQuestion));

      await tester.pump(const Duration(milliseconds: 370));
      await tester.pump(const Duration(milliseconds: 320));
      await flipCard(tester);
      expect(currentQuestionText(tester), isNot(equals(firstQuestion)));
    },
  );

  testWidgets('passing every card shows the certified dodger ending', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play Chaos Mode');
    await continueFromPreparation(tester);

    for (var i = 0; i < 20; i++) {
      await passCurrentCard(tester, finalCard: i == 19);
    }

    expect(find.text('Certified\nDodger, Chico'), findsOneWidget);
    expect(
      find.text("You passed every question. Suspicious, but we'll allow it."),
      findsOneWidget,
    );
    expect(find.text('Back to Menu'), findsOneWidget);
  });

  testWidgets('answering every card shows the spilled everything ending', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
    await continueFromPreparation(tester);

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
    await continueFromPreparation(tester);

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
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byType(Confetti), findsWidgets);
  });
}
