import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:Spillr/app/app.dart';
import 'package:Spillr/core/database/app_database.dart';
import 'package:Spillr/features/onboarding/presentation/providers/onboarding_providers.dart';

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
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const SpillrApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> seedProfileAndOpenPlayPage(WidgetTester tester) async {
    await database.saveProfile('Chico');
    await pumpApp(tester);
  }

  Future<void> openDecksScreen(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('bottom-nav-decks')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
  }

  Future<void> openCreateSheet(WidgetTester tester) async {
    await openDecksScreen(tester);
    await tester.tap(
      find.byKey(const ValueKey('decks-open-create-sheet-button')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
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
    expect(find.text('Deep Spill'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.byKey(const ValueKey('bottom-nav-decks')), findsOneWidget);
  });

  testWidgets('uses the consistent typography scale on the decks page', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDecksScreen(tester);

    expectTextTypography(
      tester.widget<Text>(find.text('Create your')).style,
      fontSize: 28,
      fontWeight: FontWeight.w700,
    );
    expectTextTypography(
      tester.widget<Text>(find.text('Custom Deck')).style,
      fontSize: 28,
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
      tester.widget<Text>(find.text('x20 Cards')).style,
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
  });

  testWidgets('filters the deck list by chip and restores it with All', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDecksScreen(tester);
    await tester.tap(find.byKey(const ValueKey('decks-filter-no-dead-air')));
    await tester.pumpAndSettle();

    expect(find.text('No Dead Air'), findsOneWidget);
    expect(find.text('Deep Spill'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('decks-filter-all')));
    await tester.pumpAndSettle();

    expect(find.text('No Dead Air'), findsOneWidget);
    expect(find.text('Deep Spill'), findsOneWidget);
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
  });

  testWidgets('uses the consistent typography scale in the create deck sheet', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openCreateSheet(tester);

    expectTextTypography(
      tester
          .widgetList<Text>(find.text('Create Deck'))
          .firstWhere((text) => text.style?.fontSize == 24)
          .style,
      fontSize: 24,
      fontWeight: FontWeight.w700,
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
      fontSize: 18,
      fontWeight: FontWeight.w500,
    );
  });

  testWidgets('validates an empty custom deck name', (tester) async {
    await seedProfileAndOpenPlayPage(tester);

    await openCreateSheet(tester);
    await tester.tap(find.byKey(const ValueKey('decks-sheet-submit-button')));
    await tester.pumpAndSettle();

    expect(find.text('Please enter a deck name.'), findsOneWidget);
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

    expect(find.text('Weird Humor'), findsOneWidget);
    expect(find.text('x0 Cards'), findsOneWidget);
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
    expect(find.text('Deep Spill has total of 20 Cards'), findsOneWidget);
    expect(
      find.text("What's something you wish people understood about you?"),
      findsOneWidget,
    );
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
    expect(find.text('Deep Spill has total of 19 Cards'), findsOneWidget);
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

    expect(find.text('Weird Humor has total of 1 Cards'), findsOneWidget);
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

    expect(find.text('Weird Humor'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('play-deck-button-custom-1')),
      findsOneWidget,
    );
  });
}
