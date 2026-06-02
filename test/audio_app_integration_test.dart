import 'dart:math';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:spillr/app/app.dart';
import 'package:spillr/core/audio/app_audio_controller.dart';
import 'package:spillr/core/database/app_database.dart';
import 'package:spillr/core/database/app_database_provider.dart';
import 'package:spillr/features/game/data/spillr_decks.dart';
import 'package:spillr/features/game/domain/game_outcome.dart';
import 'package:spillr/features/game/domain/game_result.dart';
import 'package:spillr/features/game/presentation/providers/game_providers.dart';
import 'package:spillr/features/game/presentation/screens/ending_page_screen.dart';
import 'package:spillr/features/profile/data/profile_repository.dart';

void main() {
  late AppDatabase database;
  late _FakeAppAudioController audioController;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
    audioController = _FakeAppAudioController();
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
          appAudioControllerProvider.overrideWithValue(audioController),
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

  Future<void> seedProfileAndOpenPlayPage(WidgetTester tester) async {
    await database.saveProfile('Chico');
    await pumpApp(tester);
  }

  Future<void> openDecksScreen(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('bottom-nav-decks')));
    await tester.pumpAndSettle();
  }

  Future<void> openDeckFromPlayPage(
    WidgetTester tester, {
    required String deckId,
  }) async {
    await tester.ensureVisible(
      find.byKey(ValueKey('play-deck-button-$deckId')),
    );
    await tester.tap(find.byKey(ValueKey('play-deck-button-$deckId')));
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

  testWidgets(
    'syncs lobby and game routes through the shared audio controller',
    (tester) async {
      await seedProfileAndOpenPlayPage(tester);

      await openDecksScreen(tester);
      await tester.tap(find.byKey(const ValueKey('decks-row-deep-spill')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.byKey(const ValueKey('questions-back-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('bottom-nav-profile')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('bottom-nav-play')));
      await tester.pumpAndSettle();
      await openDeckFromPlayPage(tester, deckId: 'no-dead-air');
      await continueFromPreparation(tester);

      expect(audioController.routeLocations, [
        '/',
        '/home',
        '/decks',
        '/decks/deep-spill/questions',
        '/decks',
        '/profile',
        '/home',
        '/home',
        '/preparation/no-dead-air',
        '/game/no-dead-air',
      ]);

      await disposeApp(tester);
    },
  );

  testWidgets('keeps bottom sheets silent and plays dialog audio for prompts', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDecksScreen(tester);
    await tester.tap(
      find.byKey(const ValueKey('decks-open-create-sheet-button')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(audioController.dialogCount, 0);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('bottom-nav-play')));
    await tester.pumpAndSettle();
    await openDeckFromPlayPage(tester, deckId: 'no-dead-air');
    await continueFromPreparation(tester);
    await flipCard(tester);
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();

    expect(audioController.dialogCount, 1);
    expect(find.byKey(const ValueKey('spillr-confirm-dialog')), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('plays flip answered and pass audio during game interactions', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, deckId: 'no-dead-air');
    await continueFromPreparation(tester);

    await flipCard(tester);
    await tester.tap(find.byKey(const ValueKey('game-next-card-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 420));
    await tester.pump(const Duration(milliseconds: 320));

    await flipCard(tester);
    await tester.tap(find.byKey(const ValueKey('game-pass-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 420));
    await tester.pump(const Duration(milliseconds: 320));

    expect(audioController.flipCount, 2);
    expect(audioController.answeredCount, 1);
    expect(audioController.passCount, 1);

    await disposeApp(tester);
  });

  testWidgets('records gameplay events that feed the profile stats', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, deckId: 'no-dead-air');
    await continueFromPreparation(tester);

    await flipCard(tester);
    await tester.tap(find.byKey(const ValueKey('game-next-card-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 420));
    await tester.pump(const Duration(milliseconds: 320));

    await flipCard(tester);
    await tester.tap(find.byKey(const ValueKey('game-pass-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 420));
    await tester.pump(const Duration(milliseconds: 320));

    final stats = await ProfileRepository(database).fetchProfileStats();
    expect(stats.cardsAnswered, 1);
    expect(stats.cardsPassed, 1);
    expect(stats.cardsPlayed, 2);

    await disposeApp(tester);
  });

  testWidgets('counts timeout auto-pass as a passed card', (tester) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, deckId: 'no-dead-air');
    await continueFromPreparation(tester);

    await flipCard(tester);
    await tester.pump(const Duration(seconds: 120));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    final stats = await ProfileRepository(database).fetchProfileStats();
    expect(stats.cardsAnswered, 0);
    expect(stats.cardsPassed, 1);
    expect(stats.cardsPlayed, 1);

    await disposeApp(tester);
  });

  testWidgets('does not add a gameplay event when a round ends early', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDeckFromPlayPage(tester, deckId: 'no-dead-air');
    await continueFromPreparation(tester);
    await flipCard(tester);

    await tester.tap(find.text('End'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1200));

    final stats = await ProfileRepository(database).fetchProfileStats();
    expect(stats.cardsAnswered, 0);
    expect(stats.cardsPassed, 0);
    expect(stats.cardsPlayed, 0);

    await disposeApp(tester);
  });

  testWidgets('plays the ending screen audio when the ending screen appears', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appAudioControllerProvider.overrideWithValue(audioController),
        ],
        child: MaterialApp(
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
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(audioController.endingCount, 1);
  });
}

class _FakeAppAudioController implements AppAudioController {
  final List<String> routeLocations = <String>[];
  int dialogCount = 0;
  int flipCount = 0;
  int answeredCount = 0;
  int passCount = 0;
  int endingCount = 0;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> playAnsweredSfx() async {
    answeredCount += 1;
  }

  @override
  Future<void> playDialogSfx() async {
    dialogCount += 1;
  }

  @override
  Future<void> playEndingSfx() async {
    endingCount += 1;
  }

  @override
  Future<void> playFlipSfx() async {
    flipCount += 1;
  }

  @override
  Future<void> playPassSfx() async {
    passCount += 1;
  }

  @override
  Future<void> syncRoute(String location) async {
    routeLocations.add(location);
  }
}
