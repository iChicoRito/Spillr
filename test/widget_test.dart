import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

import 'package:spillr/app/app.dart';
import 'package:spillr/core/database/app_database.dart';
import 'package:spillr/core/database/app_database_provider.dart';
import 'package:spillr/core/theme/app_colors.dart';
import 'package:spillr/features/game/data/spillr_decks.dart';
import 'package:spillr/features/game/domain/game_outcome.dart';
import 'package:spillr/features/game/domain/game_result.dart';
import 'package:spillr/features/game/domain/game_session_state.dart';
import 'package:spillr/features/game/presentation/screens/ending_page_screen.dart';
import 'package:spillr/features/game/presentation/screens/preparation_page_screen.dart';
import 'package:spillr/features/game/presentation/providers/game_providers.dart';
import 'package:spillr/shared/widgets/spillr_bottom_navigation.dart';

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
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> disposeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 1));
  }

  void testSpillrWidgets(
    String description,
    Future<void> Function(WidgetTester tester) callback,
  ) {
    testWidgets(description, (tester) async {
      try {
        await callback(tester);
      } finally {
        await disposeApp(tester);
      }
    });
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

  Future<void> seedProfileWithCustomDeckAndOpenPlayPage(
    WidgetTester tester, {
    required String deckName,
  }) async {
    final now = DateTime(2026, 5, 31, 12, 0);

    await database.saveProfile('Chico');
    await database
        .into(database.customDecks)
        .insert(
          CustomDecksCompanion.insert(
            name: deckName,
            iconKey: 'leaf',
            colorKey: 'teal',
            createdAt: now,
          ),
        );
    await database
        .into(database.deckQuestionEntries)
        .insert(
          DeckQuestionEntriesCompanion.insert(
            deckId: 'custom-1',
            questionText: 'What joke still makes you laugh?',
            sortOrder: 0,
            createdAt: now,
            updatedAt: now,
          ),
        );

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
    await tester.ensureVisible(
      find.byKey(ValueKey('play-deck-button-$targetKey')),
    );
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

  testSpillrWidgets('renders the first onboarding screen', (tester) async {
    await pumpApp(tester);

    expect(find.text('Vibe'), findsOneWidget);
    expect(find.text('Check'), findsOneWidget);
    expect(find.text('Okay'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('onboarding-art-placeholder-0')),
      findsOneWidget,
    );
  });

  testSpillrWidgets('progresses through the onboarding intro screens', (
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

  testSpillrWidgets('blocks empty name submission', (tester) async {
    await pumpApp(tester);

    await advanceToNameInput(tester);

    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your name.'), findsOneWidget);
  });

  testSpillrWidgets('submitting a valid name shows confirmation', (
    tester,
  ) async {
    await pumpApp(tester);

    await advanceToNameInput(tester);

    await tester.enterText(find.byType(TextFormField), 'Chico');
    await tester.tap(find.text('Submit'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 220));

    expect(
      find.byKey(const ValueKey('onboarding-confirmation-headline-line-0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('onboarding-confirmation-subtitle-line-0')),
      findsOneWidget,
    );
    expect(find.text("Let's Go!"), findsOneWidget);
  });

  testSpillrWidgets(
    'animates final onboarding confirmation text sequentially',
    (tester) async {
      await pumpApp(tester);

      await advanceToNameInput(tester);

      await tester.enterText(find.byType(TextFormField), 'Chico');
      await tester.tap(find.text('Submit'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 220));

      final headlineLetters = find.descendant(
        of: find.byKey(
          const ValueKey('onboarding-confirmation-headline-line-0'),
        ),
        matching: find.byType(Opacity),
      );
      final subtitleLetters = find.descendant(
        of: find.byKey(
          const ValueKey('onboarding-confirmation-subtitle-line-0'),
        ),
        matching: find.byType(Opacity),
      );
      final nameLetters = find.descendant(
        of: find.byKey(
          const ValueKey('onboarding-confirmation-headline-line-2'),
        ),
        matching: find.byType(Opacity),
      );

      final firstHeadlineLetter = tester.widget<Opacity>(headlineLetters.first);
      final firstSubtitleLetter = tester.widget<Opacity>(subtitleLetters.first);
      final firstNameLetter = tester.widget<Opacity>(nameLetters.first);

      final firstNameColor = tester
          .widget<Text>(
            find.descendant(
              of: find.byWidget(firstNameLetter),
              matching: find.byType(Text),
            ),
          )
          .style!
          .color;

      expect(
        firstHeadlineLetter.opacity,
        greaterThan(firstSubtitleLetter.opacity),
      );
      expect(firstSubtitleLetter.opacity, 0);
      expect(firstNameColor, AppColors.teal500);

      await tester.pumpAndSettle();

      final settledSubtitleLetter = tester.widget<Opacity>(
        subtitleLetters.first,
      );
      expect(settledSubtitleLetter.opacity, 1);
    },
  );

  testSpillrWidgets('lets the user reach the play page after onboarding', (
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

  testSpillrWidgets(
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

  testSpillrWidgets('uses the full-width Remindly-style bottom nav shell', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    final navFinder = find.byType(SpillrBottomNavigation);

    expect(navFinder, findsOneWidget);
    expect(tester.getSize(navFinder), const Size(393, 80));
    expect(
      find.descendant(
        of: navFinder,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is AnimatedPositioned &&
              widget.duration == const Duration(milliseconds: 220) &&
              widget.curve == Curves.easeOutCubic,
        ),
      ),
      findsOneWidget,
    );
  });

  testSpillrWidgets(
    'switches tabs instantly while the nav indicator keeps animating',
    (tester) async {
      await seedProfileAndOpenPlayPage(tester);

      final navFinder = find.byType(SpillrBottomNavigation);
      final indicatorFinder = find.descendant(
        of: navFinder,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is AnimatedPositioned &&
              widget.duration == const Duration(milliseconds: 220) &&
              widget.curve == Curves.easeOutCubic,
        ),
      );
      final initialDx = tester.getTopLeft(indicatorFinder).dx;

      await tester.tap(find.byKey(const ValueKey('bottom-nav-decks')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(navFinder, findsOneWidget);

      final midDx = tester.getTopLeft(indicatorFinder).dx;

      expect(find.text('Create your'), findsOneWidget);
      expect(find.text('Ready to Spill?'), findsNothing);

      await tester.pumpAndSettle();

      final finalDx = tester.getTopLeft(indicatorFinder).dx;

      expect(midDx, lessThan(initialDx));
      expect(midDx, greaterThan(finalDx));
    },
  );

  testSpillrWidgets(
    'uses the consistent H1 typography for the active deck card',
    (tester) async {
      await database.saveProfile('Chico');

      await pumpApp(tester);

      final title = tester.widget<Text>(find.text('No\nDead\nAir'));

      expect(title.style?.fontSize, lessThanOrEqualTo(56));
      expect(title.style?.fontWeight, FontWeight.w700);
    },
  );

  testSpillrWidgets(
    'shows the redesigned active card count pill and bottom icon cradle',
    (tester) async {
      await seedProfileAndOpenPlayPage(tester);

      expect(
        find.byKey(const ValueKey('play-deck-count-pill-no-dead-air')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('play-deck-count-pill-no-dead-air')),
          matching: find.text('x20 Cards'),
        ),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('play-deck-bottom-icon-badge-no-dead-air')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('play-deck-bottom-arc-no-dead-air')),
        findsOneWidget,
      );
    },
  );

  testSpillrWidgets(
    'reveals card details only for the active deck as the carousel changes',
    (tester) async {
      await seedProfileAndOpenPlayPage(tester);

      final initialActiveDetails = tester.widget<Opacity>(
        find.byKey(const ValueKey('play-deck-detail-opacity-no-dead-air')),
      );
      final initialInactiveDetails = tester.widget<Opacity>(
        find.byKey(const ValueKey('play-deck-detail-opacity-deep-spill')),
      );

      expect(initialActiveDetails.opacity, 1);
      expect(initialInactiveDetails.opacity, lessThan(0.2));

      final pageView = tester.widget<PageView>(find.byType(PageView));
      pageView.controller!.jumpToPage(0);
      await tester.pump();

      final nextActiveDetails = tester.widget<Opacity>(
        find.byKey(const ValueKey('play-deck-detail-opacity-deep-spill')),
      );
      final nextInactiveDetails = tester.widget<Opacity>(
        find.byKey(const ValueKey('play-deck-detail-opacity-no-dead-air')),
      );

      expect(nextActiveDetails.opacity, 1);
      expect(nextInactiveDetails.opacity, lessThan(0.2));
    },
  );

  testSpillrWidgets(
    'slides the active top arc fully above the card while inactive arcs remain visible',
    (tester) async {
      await seedProfileAndOpenPlayPage(tester);

      final activeCardRect = tester.getRect(
        find.byKey(const ValueKey('play-deck-shell-no-dead-air')),
      );
      final activeTopArcRect = tester.getRect(
        find.byKey(const ValueKey('play-deck-top-arc-no-dead-air')),
      );
      final inactiveCardRect = tester.getRect(
        find.byKey(const ValueKey('play-deck-shell-deep-spill')),
      );
      final inactiveTopArcRect = tester.getRect(
        find.byKey(const ValueKey('play-deck-top-arc-deep-spill')),
      );

      expect(activeTopArcRect.bottom, lessThanOrEqualTo(activeCardRect.top));
      expect(inactiveTopArcRect.bottom, greaterThan(inactiveCardRect.top));
    },
  );

  testSpillrWidgets(
    'keeps the active count pill visible above the bottom badge for tall three-line titles',
    (tester) async {
      await seedProfileWithCustomDeckAndOpenPlayPage(
        tester,
        deckName: 'The Loud Yanner',
      );

      final pageView = tester.widget<PageView>(find.byType(PageView));
      pageView.controller!.jumpToPage(0);
      await tester.pumpAndSettle();

      final countPillRect = tester.getRect(
        find.byKey(const ValueKey('play-deck-count-pill-custom-1')),
      );
      final badgeRect = tester.getRect(
        find.byKey(const ValueKey('play-deck-bottom-icon-badge-custom-1')),
      );

      expect(countPillRect.bottom, lessThan(badgeRect.top - 8));
    },
  );

  testSpillrWidgets('keeps the rounded active icon badge compact', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    final badgeRect = tester.getRect(
      find.byKey(const ValueKey('play-deck-bottom-icon-badge-no-dead-air')),
    );

    expect(badgeRect.width, lessThanOrEqualTo(68));
    expect(badgeRect.height, lessThanOrEqualTo(68));
  });

  testSpillrWidgets(
    'uses a fixed stroke width of 1.5 for the deck badge icons',
    (tester) async {
      await seedProfileAndOpenPlayPage(tester);

      final icon = tester.widget<HugeIcon>(
        find.descendant(
          of: find.byKey(
            const ValueKey('play-deck-bottom-icon-badge-no-dead-air'),
          ),
          matching: find.byType(HugeIcon),
        ),
      );

      expect(icon.strokeWidth, 1.5);
      expect(icon.icon, HugeIcons.strokeRoundedChat);
    },
  );

  testSpillrWidgets(
    'shows the custom deck badge with the same icon it was created with',
    (tester) async {
      await seedProfileWithCustomDeckAndOpenPlayPage(
        tester,
        deckName: 'Tea Lab',
      );

      final icon = tester.widget<HugeIcon>(
        find.descendant(
          of: find.byKey(
            const ValueKey('play-deck-bottom-icon-badge-custom-1'),
          ),
          matching: find.byType(HugeIcon),
        ),
      );

      expect(icon.icon, HugeIcons.strokeRoundedLeaf01);
    },
  );

  testSpillrWidgets(
    'balances No Dead Air title count badge and icon on the active arc',
    (tester) async {
      await seedProfileAndOpenPlayPage(tester);

      final cardRect = tester.getRect(
        find.byKey(const ValueKey('play-deck-shell-no-dead-air')),
      );
      final titleRect = tester.getRect(find.text('No\nDead\nAir'));
      final countPillRect = tester.getRect(
        find.byKey(const ValueKey('play-deck-count-pill-no-dead-air')),
      );
      final bottomArcRect = tester.getRect(
        find.byKey(const ValueKey('play-deck-bottom-arc-no-dead-air')),
      );
      final badgeRect = tester.getRect(
        find.byKey(const ValueKey('play-deck-bottom-icon-badge-no-dead-air')),
      );

      expect(titleRect.top, greaterThan(cardRect.top + 28));
      expect(titleRect.top, lessThan(cardRect.top + 64));
      expect(countPillRect.top, greaterThan(titleRect.bottom + 18));
      expect(countPillRect.bottom, lessThan(badgeRect.top - 20));
      expect(badgeRect.center.dy, closeTo(bottomArcRect.top, 8));
    },
  );

  testSpillrWidgets(
    'shrinks a longer active title so it stays centered with comfortable side margins',
    (tester) async {
      await seedProfileWithCustomDeckAndOpenPlayPage(
        tester,
        deckName: 'The Loud Yapper',
      );

      final pageView = tester.widget<PageView>(find.byType(PageView));
      pageView.controller!.jumpToPage(0);
      await tester.pumpAndSettle();

      final title = tester.widget<Text>(find.text('The\nLoud\nYapper'));

      expect(title.style?.fontSize, lessThan(58));
      expect(title.style?.fontWeight, FontWeight.w700);
    },
  );

  testSpillrWidgets('renders the active deck card without a shadow', (
    tester,
  ) async {
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

  testSpillrWidgets('lets the play deck carousel bleed to the screen edges', (
    tester,
  ) async {
    await database.saveProfile('Chico');

    await pumpApp(tester);

    final carouselRect = tester.getRect(find.byType(PageView));
    final pageView = tester.widget<PageView>(find.byType(PageView));

    expect(carouselRect.left, closeTo(0, 2));
    expect(carouselRect.right, closeTo(393, 2));
    expect(pageView.clipBehavior, Clip.none);
    expect(pageView.controller!.viewportFraction, 0.78);
  });

  testSpillrWidgets('updates the active deck label when the carousel moves', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    expect(find.text('Play'), findsOneWidget);

    final pageView = tester.widget<PageView>(find.byType(PageView));
    pageView.controller!.jumpToPage(2);
    await tester.pumpAndSettle();

    expect(find.text('Play'), findsOneWidget);
  });

  testSpillrWidgets('shows wildcard tea as the final playable deck', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    final pageView = tester.widget<PageView>(find.byType(PageView));
    pageView.controller!.jumpToPage(5);
    await tester.pumpAndSettle();

    expect(find.text('Just\nPull\nIt'), findsOneWidget);
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
      AppColors.neutral700,
    );
    expect(
      playButtonStyle.foregroundColor?.resolve(const <WidgetState>{}),
      AppColors.white,
    );
  });

  testSpillrWidgets(
    'anchors the active deck icon and title block above center',
    (tester) async {
      await seedProfileAndOpenPlayPage(tester);

      final centerBlock = tester.widget<Align>(
        find.byKey(const ValueKey('play-deck-card-main-center-no-dead-air')),
      );
      final alignment = centerBlock.alignment as Alignment;

      expect(alignment.x, 0);
      expect(alignment.y, closeTo(-0.08, 0.01));
    },
  );

  testSpillrWidgets(
    'shrinks long custom play titles while keeping each word on its own line',
    (tester) async {
      await seedProfileWithCustomDeckAndOpenPlayPage(
        tester,
        deckName: 'Very Long Custom Deck Title',
      );

      final pageView = tester.widget<PageView>(find.byType(PageView));
      pageView.controller!.jumpToPage(0);
      await tester.pumpAndSettle();

      final title = tester.widget<Text>(
        find.text('Very\nLong\nCustom\nDeck\nTitle'),
      );

      expect(title.style?.fontSize, isNotNull);
      expect(title.style!.fontSize!, lessThan(64));
      expect(
        find.byKey(const ValueKey('play-deck-button-custom-1')),
        findsOneWidget,
      );
    },
  );

  testSpillrWidgets('cycles Just Pull It letters through deck accent colors', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    final pageView = tester.widget<PageView>(find.byType(PageView));
    pageView.controller!.jumpToPage(5);
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('play-deck-button-wildcard-tea')),
    );
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

  testSpillrWidgets('starts each game with shuffled questions', (tester) async {
    final deck = spillrDecks.firstWhere((deck) => deck.id == 'no-dead-air');
    final session = GameSessionState.start(deck, random: Random(1));

    expect(session.currentQuestion, isNot(deck.questions.first));
    expect(session.questions, isNot(equals(deck.questions)));
    expect(session.questions, containsAll(deck.questions));
  });

  testSpillrWidgets('opens the game page from the active deck button', (
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
      find.byKey(const ValueKey('preparation-intro-deck-line-0')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('preparation-continue-button')),
      findsOneWidget,
    );
  });

  testSpillrWidgets('starts the game from the preparation screen', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
    await continueFromPreparation(tester);

    expect(find.byKey(const ValueKey('game-flip-card')), findsOneWidget);
    expect(find.text('Question'), findsOneWidget);
    expect(find.text('No. 1'), findsOneWidget);
    expect(find.text('1 of 20'), findsOneWidget);
    expect(find.text('Tap to flip'), findsOneWidget);
  });

  testSpillrWidgets(
    'animates preparation letters sequentially from first to last',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(database)],
          child: const MaterialApp(
            home: PreparationPageScreen(deckId: 'chaos-mode'),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
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
    },
  );

  testSpillrWidgets(
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

  testSpillrWidgets(
    'pins the tap to flip prompt to the bottom of the front card',
    (tester) async {
      await seedProfileAndOpenPlayPage(tester);

      await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
      await continueFromPreparation(tester);

      final promptPositioned = tester.widget<Positioned>(
        find.byKey(const ValueKey('game-tap-to-flip-positioned')),
      );

      expect(promptPositioned.bottom, 20);
    },
  );

  testSpillrWidgets('shows a progress bar below the card', (tester) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
    await continueFromPreparation(tester);

    expect(find.byType(LinearProgressIndicator), findsOneWidget);
  });

  testSpillrWidgets(
    'animates the progress bar when advancing to the next card',
    (tester) async {
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
    },
  );

  testSpillrWidgets('shows the three action buttons on the last card', (
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

  testSpillrWidgets('shows end spill and pass actions on the flipped card', (
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

  testSpillrWidgets(
    'uses a larger primary Answered button with hugeicons only',
    (tester) async {
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
    },
  );

  testSpillrWidgets('ends the round immediately when End is tapped', (
    tester,
  ) async {
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

  testSpillrWidgets('does not show a deck selector on the game screen', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
    await continueFromPreparation(tester);

    expect(find.byKey(const ValueKey('game-deck-selector')), findsNothing);
  });

  testSpillrWidgets('shows a 10-second timer only on flipped cards', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
    await continueFromPreparation(tester);

    expect(find.byKey(const ValueKey('game-flip-timer-chip')), findsNothing);

    await flipCard(tester);

    expect(find.byKey(const ValueKey('game-flip-timer-chip')), findsOneWidget);
    expect(find.text('2:00'), findsOneWidget);
  });

  testSpillrWidgets('counts down the flipped-card timer in minute format', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
    await continueFromPreparation(tester);
    await flipCard(tester);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('1:59'), findsOneWidget);
  });

  testSpillrWidgets(
    'counts down the flipped-card timer and auto-passes on timeout',
    (tester) async {
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
    },
  );

  testSpillrWidgets('keeps the badge and question centered on the front card', (
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

  testSpillrWidgets('uses a smaller badge on the unflipped card', (
    tester,
  ) async {
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

  testSpillrWidgets('flips the card and advances to the next question', (
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

  testSpillrWidgets(
    'prompts before leaving the game after at least one card is flipped',
    (tester) async {
      await seedProfileAndOpenPlayPage(tester);

      await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
      await continueFromPreparation(tester);
      await flipCard(tester);

      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('spillr-confirm-dialog')),
        findsOneWidget,
      );
      expect(find.text('Leaving Already?'), findsOneWidget);
      expect(
        find.text(
          "You haven’t spilled all the cards yet. Want to exit anyway?",
        ),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Yes, Exit'), findsOneWidget);
    },
  );

  testSpillrWidgets(
    'exits to the home page when the leave confirmation is accepted',
    (tester) async {
      await seedProfileAndOpenPlayPage(tester);

      await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
      await continueFromPreparation(tester);
      await flipCard(tester);

      await tester.tap(find.text('Back'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('confirm-dialog-confirm')));
      await tester.pumpAndSettle();

      expect(find.text('Hey, Chico'), findsOneWidget);
      expect(find.byKey(const ValueKey('game-flip-card')), findsNothing);
    },
  );

  testSpillrWidgets('animates the card with a transform while flipping', (
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

  testSpillrWidgets('does not show a badge on the flipped card', (
    tester,
  ) async {
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

  testSpillrWidgets(
    'keeps the flipped question centered in the middle of the card',
    (tester) async {
      await seedProfileAndOpenPlayPage(tester);

      await openDeckFromPlayPage(tester, label: 'Play Date Mode');
      await continueFromPreparation(tester);
      await flipCard(tester);

      final questionCenter = tester.widget<Align>(
        find.byKey(const ValueKey('game-question-center')),
      );

      expect(questionCenter.alignment, Alignment.center);
    },
  );

  testSpillrWidgets(
    'shows flipped questions without added outer quotation marks',
    (tester) async {
      await seedProfileAndOpenPlayPage(tester);

      await openDeckFromPlayPage(tester, label: 'Play No Dead Air');
      await continueFromPreparation(tester);
      await flipCard(tester);

      final question = currentQuestionText(tester);

      expect(question.startsWith('"'), isFalse);
      expect(question.endsWith('"'), isFalse);
    },
  );

  testSpillrWidgets(
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

  testSpillrWidgets('passing every card shows the certified dodger ending', (
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

  testSpillrWidgets(
    'answering every card shows the spilled everything ending',
    (tester) async {
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
    },
  );

  testSpillrWidgets(
    'mixing answers and passes shows the almost spilled ending',
    (tester) async {
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
    },
  );

  testSpillrWidgets('shows confetti on the ending screen', (tester) async {
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
              outcome: GameOutcome.certifiedDodger,
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
