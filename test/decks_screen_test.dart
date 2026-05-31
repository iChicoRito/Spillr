import 'dart:async';
import 'dart:collection';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:spillr/app/app.dart';
import 'package:spillr/core/database/app_database.dart';
import 'package:spillr/core/theme/app_colors.dart';
import 'package:spillr/features/decks/data/question_generation_service.dart';
import 'package:spillr/features/decks/presentation/providers/deck_providers.dart';
import 'package:spillr/features/game/domain/spillr_deck.dart';
import 'package:spillr/features/onboarding/presentation/providers/onboarding_providers.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> pumpApp(
    WidgetTester tester, {
    QuestionGenerationService? questionGenerationService,
    QuestionGenerationUsageStore? questionGenerationUsageStore,
  }) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          if (questionGenerationService != null)
            questionGenerationServiceProvider.overrideWithValue(
              questionGenerationService,
            ),
          if (questionGenerationUsageStore != null)
            questionGenerationUsageRepositoryProvider.overrideWithValue(
              questionGenerationUsageStore,
            ),
        ],
        child: const SpillrApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> seedProfileAndOpenPlayPage(
    WidgetTester tester, {
    QuestionGenerationService? questionGenerationService,
    QuestionGenerationUsageStore? questionGenerationUsageStore,
  }) async {
    await database.saveProfile('Chico');
    await pumpApp(
      tester,
      questionGenerationService: questionGenerationService,
      questionGenerationUsageStore: questionGenerationUsageStore,
    );
  }

  Future<void> openDecksScreen(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('bottom-nav-decks')));
    await tester.pumpAndSettle();
  }

  Future<void> openCreateSheet(WidgetTester tester) async {
    await openDecksScreen(tester);
    await tester.tap(
      find.byKey(const ValueKey('decks-open-create-sheet-button')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> createCustomDeckAndOpenQuestionSheet(
    WidgetTester tester, {
    String deckName = 'Weird Humor',
  }) async {
    await openCreateSheet(tester);
    await tester.enterText(
      find.byKey(const ValueKey('decks-sheet-name-field')),
      deckName,
    );
    await tester.tap(find.byKey(const ValueKey('decks-sheet-submit-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const ValueKey('decks-row-custom-1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('questions-add-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> disposeApp(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump(const Duration(milliseconds: 1));
  }

  void expectTextTypography(
    TextStyle? style, {
    required double fontSize,
    required FontWeight fontWeight,
  }) {
    expect(style?.fontSize, fontSize);
    expect(style?.fontWeight, fontWeight);
  }

  testWidgets('opens the decks route from the play page bottom navigation', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDecksScreen(tester);

    expect(find.text('Create your'), findsOneWidget);
    expect(find.text('Custom Deck'), findsOneWidget);
    expect(find.byKey(const ValueKey('decks-row-deep-spill')), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.byKey(const ValueKey('bottom-nav-decks')), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('uses the consistent typography scale on the decks page', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDecksScreen(tester);

    expectTextTypography(
      tester.widget<Text>(find.text('Create your')).style,
      fontSize: 24,
      fontWeight: FontWeight.w700,
    );
    expectTextTypography(
      tester.widget<Text>(find.text('Custom Deck')).style,
      fontSize: 24,
      fontWeight: FontWeight.w700,
    );
    expectTextTypography(
      tester.widget<Text>(find.text('All')).style,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    );
    expectTextTypography(
      tester
          .widgetList<Text>(find.text('Deep Spill'))
          .firstWhere((text) => text.style?.fontSize == 18)
          .style,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    );
    expectTextTypography(
      tester.widgetList<Text>(find.text('x20 Cards')).first.style,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    );

    final createButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('decks-open-create-sheet-button')),
    );
    expectTextTypography(
      createButton.style?.textStyle?.resolve(const <WidgetState>{}),
      fontSize: 18,
      fontWeight: FontWeight.w500,
    );

    await disposeApp(tester);
  });

  testWidgets('returns to the play page from the decks bottom navigation', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDecksScreen(tester);
    await tester.tap(find.byKey(const ValueKey('bottom-nav-play')));
    await tester.pumpAndSettle();

    expect(find.text('Choose Your Deck'), findsOneWidget);
    expect(find.text('Ready to Spill?'), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('filters the deck list by chip and restores it with All', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDecksScreen(tester);
    await tester.ensureVisible(
      find.byKey(const ValueKey('built-in-no-dead-air')),
    );
    await tester.tap(find.byKey(const ValueKey('built-in-no-dead-air')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('decks-row-no-dead-air')), findsOneWidget);
    expect(find.byKey(const ValueKey('decks-row-deep-spill')), findsNothing);

    await tester.ensureVisible(find.byKey(const ValueKey('built-in-all')));
    await tester.tap(find.byKey(const ValueKey('built-in-all')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('decks-row-no-dead-air')), findsOneWidget);
    expect(find.byKey(const ValueKey('decks-row-deep-spill')), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('opens the create deck bottom sheet with the expected fields', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openCreateSheet(tester);

    expect(find.text('Create Deck'), findsWidgets);
    expect(
      find.byKey(const ValueKey('decks-sheet-name-field')),
      findsOneWidget,
    );
    expect(find.text('Deck Name'), findsOneWidget);
    expect(find.text('Icon'), findsOneWidget);
    expect(find.text('Color Selection'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('decks-sheet-submit-button')),
      findsOneWidget,
    );

    await disposeApp(tester);
  });

  testWidgets('uses the consistent typography scale in the create deck sheet', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openCreateSheet(tester);

    expectTextTypography(
      tester
          .widgetList<Text>(find.text('Create Deck'))
          .firstWhere((text) => text.style?.fontSize == 18)
          .style,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    );
    for (final label in ['Deck Name', 'Icon', 'Color Selection']) {
      expectTextTypography(
        tester.widget<Text>(find.text(label)).style,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      );
    }

    final textFieldContext = tester.element(
      find.byKey(const ValueKey('decks-sheet-name-field')),
    );
    expectTextTypography(
      Theme.of(textFieldContext).inputDecorationTheme.hintStyle,
      fontSize: 16,
      fontWeight: FontWeight.w400,
    );

    final submitButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('decks-sheet-submit-button')),
    );
    expectTextTypography(
      submitButton.style?.textStyle?.resolve(const <WidgetState>{}),
      fontSize: 16,
      fontWeight: FontWeight.w500,
    );

    await disposeApp(tester);
  });

  testWidgets('validates an empty custom deck name', (tester) async {
    await seedProfileAndOpenPlayPage(tester);

    await openCreateSheet(tester);
    await tester.tap(find.byKey(const ValueKey('decks-sheet-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a deck name.'), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('creates a custom deck and shows it as x0 Cards', (tester) async {
    await seedProfileAndOpenPlayPage(tester);

    await openCreateSheet(tester);
    await tester.enterText(
      find.byKey(const ValueKey('decks-sheet-name-field')),
      'Weird Humor',
    );
    await tester.tap(find.byKey(const ValueKey('decks-sheet-submit-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('decks-row-custom-1')), findsOneWidget);
    expect(find.text('x0 Cards'), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('shows the custom deck long-press actions', (tester) async {
    await seedProfileAndOpenPlayPage(tester);

    await openCreateSheet(tester);
    await tester.enterText(
      find.byKey(const ValueKey('decks-sheet-name-field')),
      'Weird Humor',
    );
    await tester.tap(find.byKey(const ValueKey('decks-sheet-submit-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.longPress(find.byKey(const ValueKey('decks-row-custom-1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Edit Deck'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);

    await disposeApp(tester);
  });

  testWidgets('opens a built-in deck questions page from the deck row', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDecksScreen(tester);
    await tester.tap(find.byKey(const ValueKey('decks-row-deep-spill')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const ValueKey('questions-page')), findsOneWidget);
    expect(find.text('Deep Spill'), findsAtLeastNWidgets(1));
    expect(
      find.text("What's something you wish people understood about you?"),
      findsOneWidget,
    );

    await disposeApp(tester);
  });

  testWidgets('edits and deletes a built-in question from its row menu', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDecksScreen(tester);
    await tester.tap(find.byKey(const ValueKey('decks-row-deep-spill')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(
      find.byKey(const ValueKey('questions-row-menu-deep-spill-0')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('View Question'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);

    await tester.tap(find.text('Edit'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(
      find.byKey(const ValueKey('question-sheet-text-field')),
      'What truth are you avoiding right now?',
    );
    await tester.tap(find.byKey(const ValueKey('question-sheet-save-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('What truth are you avoiding right now?'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('questions-row-menu-deep-spill-0')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Delete'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const ValueKey('spillr-confirm-dialog')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('confirm-dialog-confirm')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('What truth are you avoiding right now?'), findsNothing);

    await disposeApp(tester);
  });

  testWidgets('creates a custom deck question and shows it on the play page', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openCreateSheet(tester);
    await tester.enterText(
      find.byKey(const ValueKey('decks-sheet-name-field')),
      'Weird Humor',
    );
    await tester.tap(find.byKey(const ValueKey('decks-sheet-submit-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.tap(find.byKey(const ValueKey('decks-row-custom-1')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.byKey(const ValueKey('questions-add-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(
      find.byKey(const ValueKey('question-sheet-text-field')),
      'What joke still makes you laugh?',
    );
    await tester.tap(find.byKey(const ValueKey('question-sheet-save-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('What joke still makes you laugh?'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('questions-back-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('x1 Cards'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('bottom-nav-play')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final pageView = tester.widget<PageView>(find.byType(PageView));
    pageView.controller!.jumpToPage(0);
    await tester.pumpAndSettle();

    expect(find.text('Weird\nHumor'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('play-deck-button-custom-1')),
      findsOneWidget,
    );

    await disposeApp(tester);
  });

  testWidgets('shows the AI question generator below the create action', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(
      tester,
      questionGenerationUsageStore: _FixedQuestionGenerationUsageStore(
        QuestionGenerationUsageState(
          attemptCount: 0,
          limitReachedAt: null,
          updatedAt: DateTime(2026, 5, 31, 12, 0),
        ),
      ),
    );

    await createCustomDeckAndOpenQuestionSheet(tester);

    expect(
      find.byKey(const ValueKey('question-ai-generate-button')),
      findsOneWidget,
    );
    expect(find.text('Generate with AI'), findsOneWidget);

    final generateButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('question-ai-generate-button')),
    );
    expect(
      generateButton.style?.backgroundColor?.resolve(const <WidgetState>{}),
      AppColors.teal100,
    );
    expect(
      generateButton.style?.foregroundColor?.resolve(const <WidgetState>{}),
      AppColors.teal500,
    );
    expect(
      find.text('You can generate up to 15 times per hour'),
      findsOneWidget,
    );

    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await disposeApp(tester);
  });

  testWidgets('shows a loading label while the AI question is generating', (
    tester,
  ) async {
    final generator = _PendingQuestionGenerationService();
    await seedProfileAndOpenPlayPage(
      tester,
      questionGenerationService: generator,
    );

    await createCustomDeckAndOpenQuestionSheet(tester);
    await tester.tap(find.byKey(const ValueKey('question-ai-generate-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const ValueKey('question-ai-loading-dialog')),
      findsOneWidget,
    );
    expect(find.text('Question Generating...'), findsOneWidget);
    expect(
      find.text(
        'Please be patient while the AI generating the question for Weird Humor',
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('question-sheet-text-field')),
      findsNothing,
    );

    generator.complete('What harmless choice starts your villain era?');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const ValueKey('question-ai-ready-dialog')),
      findsOneWidget,
    );
    expect(find.text('Question Ready!'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('question-ai-accept-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await disposeApp(tester);
  });

  testWidgets('accepting an AI question fills the field without creating it', (
    tester,
  ) async {
    const generatedQuestion = 'What harmless choice starts your villain era?';
    await seedProfileAndOpenPlayPage(
      tester,
      questionGenerationService: _FakeQuestionGenerationService([
        generatedQuestion,
      ]),
    );

    await createCustomDeckAndOpenQuestionSheet(tester);
    await tester.tap(find.byKey(const ValueKey('question-ai-generate-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const ValueKey('question-ai-ready-dialog')),
      findsOneWidget,
    );
    expect(find.text('Question Ready!'), findsOneWidget);
    expect(
      find.text("New question generated. Let's keep the chat moving."),
      findsOneWidget,
    );
    expect(find.text('Question Generated:'), findsOneWidget);
    expect(find.text(generatedQuestion), findsOneWidget);

    final generateAgainButton = tester.widget<OutlinedButton>(
      find.byKey(const ValueKey('question-ai-generate-again-button')),
    );
    final acceptButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('question-ai-accept-button')),
    );
    expect(
      generateAgainButton.style?.foregroundColor?.resolve(
        const <WidgetState>{},
      ),
      AppColors.teal500,
    );
    expect(
      generateAgainButton.style?.side?.resolve(const <WidgetState>{})?.color,
      AppColors.teal500,
    );
    expect(
      acceptButton.style?.backgroundColor?.resolve(const <WidgetState>{}),
      AppColors.teal500,
    );

    await tester.tap(find.byKey(const ValueKey('question-ai-accept-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const ValueKey('question-ai-ready-dialog')),
      findsNothing,
    );
    expect(find.text('Create Question'), findsOneWidget);
    final field = tester.widget<TextFormField>(
      find.byKey(const ValueKey('question-sheet-text-field')),
    );
    expect(field.controller?.text, generatedQuestion);

    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await disposeApp(tester);
  });

  testWidgets(
    'shows the usage count below Generate with AI and in the generated dialog after it has been used',
    (tester) async {
      final usageStore = _MutableQuestionGenerationUsageStore(
        QuestionGenerationUsageState(
          attemptCount: 2,
          limitReachedAt: null,
          updatedAt: DateTime(2026, 5, 31, 12, 0),
        ),
      );
      await seedProfileAndOpenPlayPage(
        tester,
        questionGenerationService: _UsageAwareQuestionGenerationService([
          'What harmless choice starts your villain era?',
        ], usageStore: usageStore),
        questionGenerationUsageStore: usageStore,
      );

      await createCustomDeckAndOpenQuestionSheet(tester);
      expect(
        find.text('You’ve used 2 of 15 requests this hour'),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('question-ai-generate-button')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.byKey(const ValueKey('question-ai-ready-dialog')),
        findsOneWidget,
      );
      expect(find.text('Question Ready!'), findsOneWidget);
      expect(
        find.text('You’ve used 3 of 15 requests this hour'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('question-ai-accept-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text('You’ve used 3 of 15 requests this hour'),
        findsOneWidget,
      );
      expect(find.text('Create Question'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await disposeApp(tester);
    },
  );

  testWidgets(
    'shows the hourly limit message below Generate with AI and in the generated dialog when the cap is hit',
    (tester) async {
      final now = DateTime(2026, 5, 31, 12, 0);
      final usageStore = _MutableQuestionGenerationUsageStore(
        QuestionGenerationUsageState(
          attemptCount: 14,
          limitReachedAt: null,
          updatedAt: now,
        ),
      );
      await seedProfileAndOpenPlayPage(
        tester,
        questionGenerationService: _UsageAwareQuestionGenerationService([
          'What tiny inconvenience ruins your whole vibe?',
        ], usageStore: usageStore),
        questionGenerationUsageStore: usageStore,
      );

      await createCustomDeckAndOpenQuestionSheet(tester);
      expect(
        find.text('You’ve used 14 of 15 requests this hour'),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey('question-ai-generate-button')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.byKey(const ValueKey('question-ai-ready-dialog')),
        findsOneWidget,
      );
      expect(
        find.text(
          "You've hit the 15-request hourly limit. Please wait until your quota resets.",
        ),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('question-ai-accept-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text(
          "You've hit the 15-request hourly limit. Please wait until your quota resets.",
        ),
        findsOneWidget,
      );
      final generateButton = tester.widget<FilledButton>(
        find.byKey(const ValueKey('question-ai-generate-button')),
      );
      expect(generateButton.onPressed, isNull);
      expect(find.text('Create Question'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await disposeApp(tester);
    },
  );

  testWidgets('generate again replaces the reviewed AI question', (
    tester,
  ) async {
    const firstQuestion = 'What tiny inconvenience ruins your whole vibe?';
    const secondQuestion = 'What snack would you defend in court?';
    await seedProfileAndOpenPlayPage(
      tester,
      questionGenerationService: _FakeQuestionGenerationService([
        firstQuestion,
        secondQuestion,
      ]),
    );

    await createCustomDeckAndOpenQuestionSheet(tester);
    await tester.tap(find.byKey(const ValueKey('question-ai-generate-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(firstQuestion), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('question-ai-generate-again-button')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text(firstQuestion), findsNothing);
    expect(find.text(secondQuestion), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('question-ai-accept-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await disposeApp(tester);
  });

  testWidgets(
    'tapping the X closes the generated question dialog without starting another generation',
    (tester) async {
      const firstQuestion = 'What harmless choice starts your villain era?';
      const secondQuestion = 'What snack would you defend in court?';
      final generator = _RecordingQuestionGenerationService([
        firstQuestion,
        secondQuestion,
      ]);
      await seedProfileAndOpenPlayPage(
        tester,
        questionGenerationService: generator,
      );

      await createCustomDeckAndOpenQuestionSheet(tester);
      await tester.tap(
        find.byKey(const ValueKey('question-ai-generate-button')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(firstQuestion), findsOneWidget);
      expect(
        find.byKey(const ValueKey('question-ai-close-button')),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('question-ai-close-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(generator.excludedQuestionsLog, hasLength(1));
      expect(generator.excludedQuestionsLog.first, isEmpty);
      expect(
        find.byKey(const ValueKey('question-ai-loading-dialog')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('question-ai-ready-dialog')),
        findsNothing,
      );
      expect(find.text(secondQuestion), findsNothing);
      expect(find.text('Create Question'), findsNothing);
      expect(
        find.byKey(const ValueKey('questions-add-button')),
        findsOneWidget,
      );

      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await disposeApp(tester);
    },
  );

  testWidgets(
    'pressing back on the generated question dialog exits without starting another generation',
    (tester) async {
      const firstQuestion = 'What tiny inconvenience ruins your whole vibe?';
      const secondQuestion = 'What snack would you defend in court?';
      final generator = _RecordingQuestionGenerationService([
        firstQuestion,
        secondQuestion,
      ]);
      await seedProfileAndOpenPlayPage(
        tester,
        questionGenerationService: generator,
      );

      await createCustomDeckAndOpenQuestionSheet(tester);
      await tester.tap(
        find.byKey(const ValueKey('question-ai-generate-button')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pumpAndSettle();

      expect(generator.excludedQuestionsLog, hasLength(1));
      expect(generator.excludedQuestionsLog.first, isEmpty);
      expect(
        find.byKey(const ValueKey('question-ai-loading-dialog')),
        findsNothing,
      );
      expect(
        find.byKey(const ValueKey('question-ai-ready-dialog')),
        findsNothing,
      );
      expect(find.text(secondQuestion), findsNothing);
      expect(find.text('Create Question'), findsNothing);
      expect(
        find.byKey(const ValueKey('questions-add-button')),
        findsOneWidget,
      );

      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await disposeApp(tester);
    },
  );

  testWidgets(
    're-generating returns to the centered loading dialog before showing the next question',
    (tester) async {
      final generator = _StagedQuestionGenerationService([
        'What harmless choice starts your villain era?',
        Completer<String>(),
      ]);
      await seedProfileAndOpenPlayPage(
        tester,
        questionGenerationService: generator,
      );

      await createCustomDeckAndOpenQuestionSheet(tester);
      await tester.tap(
        find.byKey(const ValueKey('question-ai-generate-button')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(
        find.byKey(const ValueKey('question-ai-generate-again-button')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.byKey(const ValueKey('question-ai-loading-dialog')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('question-ai-ready-dialog')),
        findsNothing,
      );
      expect(find.text('Question Generating...'), findsOneWidget);

      generator.completeNext(
        'Who would accidentally start the group chat war?',
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.byKey(const ValueKey('question-ai-ready-dialog')),
        findsOneWidget,
      );
      expect(
        find.text('Who would accidentally start the group chat war?'),
        findsOneWidget,
      );

      await tester.tap(find.byKey(const ValueKey('question-ai-accept-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await disposeApp(tester);
    },
  );

  testWidgets(
    'generate again asks the service to avoid the previously generated question',
    (tester) async {
      final generator = _RecordingQuestionGenerationService([
        'What tiny inconvenience ruins your whole vibe?',
        'What snack would you defend in court?',
      ]);
      await seedProfileAndOpenPlayPage(
        tester,
        questionGenerationService: generator,
      );

      await createCustomDeckAndOpenQuestionSheet(tester);
      await tester.tap(
        find.byKey(const ValueKey('question-ai-generate-button')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(
        find.byKey(const ValueKey('question-ai-generate-again-button')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.pump(const Duration(milliseconds: 300));

      expect(generator.excludedQuestionsLog, hasLength(2));
      expect(generator.excludedQuestionsLog.first, isEmpty);
      expect(generator.excludedQuestionsLog.last, [
        'What tiny inconvenience ruins your whole vibe?',
      ]);

      await tester.tap(find.byKey(const ValueKey('question-ai-accept-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await disposeApp(tester);
    },
  );

  testWidgets('disables Generate with AI when the usage limit is active', (
    tester,
  ) async {
    final now = DateTime.now();
    await seedProfileAndOpenPlayPage(
      tester,
      questionGenerationUsageStore: _FixedQuestionGenerationUsageStore(
        QuestionGenerationUsageState(
          attemptCount: kQuestionGenerationMaxAttempts,
          limitReachedAt: now.subtract(const Duration(minutes: 10)),
          updatedAt: now,
        ),
      ),
    );

    await createCustomDeckAndOpenQuestionSheet(tester);

    final generateButton = tester.widget<FilledButton>(
      find.byKey(const ValueKey('question-ai-generate-button')),
    );
    expect(generateButton.onPressed, isNull);
    expect(find.text('Generate with AI'), findsOneWidget);
    expect(
      find.text(
        "You've hit the 15-request hourly limit. Please wait until your quota resets.",
      ),
      findsOneWidget,
    );

    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await disposeApp(tester);
  });

  testWidgets(
    'shows an offline dialog when generation cannot reach the network',
    (tester) async {
      await seedProfileAndOpenPlayPage(
        tester,
        questionGenerationService: _FakeQuestionGenerationService([
          const QuestionGenerationOfflineException(),
        ]),
      );

      await createCustomDeckAndOpenQuestionSheet(tester);
      await tester.tap(
        find.byKey(const ValueKey('question-ai-generate-button')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.byKey(const ValueKey('question-ai-error-dialog')),
        findsOneWidget,
      );
      expect(find.text('No Internet Connection'), findsOneWidget);
      expect(
        find.text('You need an internet connection to generate a question.'),
        findsOneWidget,
      );

      await tester.tap(find.text('Okay'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Create Question'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await disposeApp(tester);
    },
  );

  testWidgets('shows a limit dialog when AI generation is exhausted', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(
      tester,
      questionGenerationService: _FakeQuestionGenerationService([
        QuestionGenerationLimitExceededException(
          retryAt: DateTime(2026, 5, 31, 13, 0),
          message: 'You have used all 15 AI generations. Try again in 1 hour.',
        ),
      ]),
    );

    await createCustomDeckAndOpenQuestionSheet(tester);
    await tester.tap(find.byKey(const ValueKey('question-ai-generate-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.byKey(const ValueKey('question-ai-error-dialog')),
      findsOneWidget,
    );
    expect(find.text('Generation Limit Reached'), findsOneWidget);
    expect(
      find.text('You have used all 15 AI generations. Try again in 1 hour.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Okay'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Create Question'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await disposeApp(tester);
  });

  testWidgets(
    'shows a generic dialog when the AI generator fails unexpectedly',
    (tester) async {
      await seedProfileAndOpenPlayPage(
        tester,
        questionGenerationService: _FakeQuestionGenerationService([
          StateError('boom'),
        ]),
      );

      await createCustomDeckAndOpenQuestionSheet(tester);
      await tester.tap(
        find.byKey(const ValueKey('question-ai-generate-button')),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.byKey(const ValueKey('question-ai-error-dialog')),
        findsOneWidget,
      );
      expect(find.text('Unable to Generate Question'), findsOneWidget);
      expect(
        find.text(
          'We could not generate a question right now. Please try again.',
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Okay'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Create Question'), findsOneWidget);

      await tester.binding.handlePopRoute();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await disposeApp(tester);
    },
  );

  testWidgets(
    'preparation screen reflects the first newly added custom deck question in the same session',
    (tester) async {
      await seedProfileAndOpenPlayPage(tester);

      await openCreateSheet(tester);
      await tester.enterText(
        find.byKey(const ValueKey('decks-sheet-name-field')),
        'Fresh Tea',
      );
      await tester.tap(find.text('Create Deck').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byKey(const ValueKey('decks-row-custom-1')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byKey(const ValueKey('questions-add-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.enterText(
        find.byKey(const ValueKey('question-sheet-text-field')),
        'Who changed the vibe tonight?',
      );
      await tester.tap(find.text('Create').last);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byKey(const ValueKey('questions-back-button')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byKey(const ValueKey('bottom-nav-play')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      final pageView = tester.widget<PageView>(find.byType(PageView));
      pageView.controller!.jumpToPage(0);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.byKey(const ValueKey('play-deck-button-custom-1')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text("Let's Get Started"), findsOneWidget);
      expect(find.text('Add Tea First'), findsNothing);

      await disposeApp(tester);
    },
  );
}

class _FakeQuestionGenerationService implements QuestionGenerationService {
  _FakeQuestionGenerationService(List<Object> responses)
    : _responses = Queue<Object>.of(responses);

  final Queue<Object> _responses;

  @override
  Future<String> generateQuestion({
    required SpillrDeck deck,
    List<String> excludedQuestions = const [],
  }) async {
    final response = _responses.removeFirst();
    if (response is String) {
      return response;
    }
    throw response;
  }
}

class _FixedQuestionGenerationUsageStore
    implements QuestionGenerationUsageStore {
  _FixedQuestionGenerationUsageStore(this.state);

  final QuestionGenerationUsageState state;

  @override
  Future<QuestionGenerationUsageState> readStatus() async => state;

  @override
  Future<QuestionGenerationUsageState> reserveAttempt() async => state;
}

class _PendingQuestionGenerationService implements QuestionGenerationService {
  final _completer = Completer<String>();

  @override
  Future<String> generateQuestion({
    required SpillrDeck deck,
    List<String> excludedQuestions = const [],
  }) {
    return _completer.future;
  }

  void complete(String question) {
    _completer.complete(question);
  }
}

class _RecordingQuestionGenerationService implements QuestionGenerationService {
  _RecordingQuestionGenerationService(List<String> responses)
    : _responses = Queue<String>.of(responses);

  final Queue<String> _responses;
  final List<List<String>> excludedQuestionsLog = <List<String>>[];

  @override
  Future<String> generateQuestion({
    required SpillrDeck deck,
    List<String> excludedQuestions = const [],
  }) async {
    excludedQuestionsLog.add(List<String>.from(excludedQuestions));
    return _responses.removeFirst();
  }
}

class _StagedQuestionGenerationService implements QuestionGenerationService {
  _StagedQuestionGenerationService(List<Object> responses)
    : _responses = Queue<Object>.of(responses);

  final Queue<Object> _responses;
  Completer<String>? _activeCompleter;

  @override
  Future<String> generateQuestion({
    required SpillrDeck deck,
    List<String> excludedQuestions = const [],
  }) {
    final response = _responses.removeFirst();
    if (response is Completer<String>) {
      _activeCompleter = response;
      return response.future;
    }
    return Future<String>.value(response as String);
  }

  void completeNext(String question) {
    final completer = _activeCompleter;
    if (completer != null && !completer.isCompleted) {
      completer.complete(question);
    }
  }
}

class _MutableQuestionGenerationUsageStore
    implements QuestionGenerationUsageStore {
  _MutableQuestionGenerationUsageStore(this._state, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  QuestionGenerationUsageState _state;
  final DateTime Function() _now;

  @override
  Future<QuestionGenerationUsageState> readStatus() async {
    final now = _now();
    if (_state.shouldResetAt(now)) {
      _state = QuestionGenerationUsageState(
        attemptCount: 0,
        limitReachedAt: null,
        updatedAt: now,
      );
    }
    return _state;
  }

  @override
  Future<QuestionGenerationUsageState> reserveAttempt() async {
    final now = _now();
    if (_state.isBlockedAt(now)) {
      throw QuestionGenerationLimitExceededException(
        retryAt: _state.cooldownEndsAt!,
        message:
            "You've hit the 15-request hourly limit. Please wait until your quota resets.",
      );
    }

    final nextAttemptCount = _state.attemptCount + 1;
    _state = QuestionGenerationUsageState(
      attemptCount: nextAttemptCount,
      limitReachedAt: nextAttemptCount >= kQuestionGenerationMaxAttempts
          ? now
          : null,
      updatedAt: now,
    );
    return _state;
  }
}

class _UsageAwareQuestionGenerationService
    implements QuestionGenerationService {
  _UsageAwareQuestionGenerationService(
    List<Object> responses, {
    required this.usageStore,
  }) : _responses = Queue<Object>.of(responses);

  final Queue<Object> _responses;
  final QuestionGenerationUsageStore usageStore;

  @override
  Future<String> generateQuestion({
    required SpillrDeck deck,
    List<String> excludedQuestions = const [],
  }) async {
    await usageStore.reserveAttempt();
    final response = _responses.removeFirst();
    if (response is String) {
      return response;
    }
    throw response;
  }
}
