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
    await tester.pumpAndSettle();
  }

  Future<void> seedProfileAndOpenPlayPage(WidgetTester tester) async {
    await database.saveProfile('Chico');
    await pumpApp(tester);
  }

  Future<void> openDecksScreen(WidgetTester tester) async {
    await tester.tap(find.byKey(const ValueKey('bottom-nav-decks')));
    await tester.pumpAndSettle();
  }

  Future<void> openCreateSheet(WidgetTester tester) async {
    await openDecksScreen(tester);
    await tester.tap(find.byKey(const ValueKey('decks-open-create-sheet-button')));
    await tester.pumpAndSettle();
  }

  testWidgets('opens the decks route from the play page bottom navigation', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDecksScreen(tester);

    expect(find.text('Create your'), findsOneWidget);
    expect(find.text('Custom Deck'), findsOneWidget);
    expect(find.text('Customize your own decks'), findsOneWidget);
    expect(find.text('Deep Spill'), findsOneWidget);
    expect(find.byKey(const ValueKey('bottom-nav-decks')), findsOneWidget);
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
    expect(find.byKey(const ValueKey('decks-sheet-name-field')), findsOneWidget);
    expect(find.text('Deck Name'), findsOneWidget);
    expect(find.text('Icon'), findsOneWidget);
    expect(find.text('Color Selection'), findsOneWidget);
    expect(find.byKey(const ValueKey('decks-sheet-submit-button')), findsOneWidget);
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

  testWidgets('shows and dismisses the visual deck menu popover', (
    tester,
  ) async {
    await seedProfileAndOpenPlayPage(tester);

    await openDecksScreen(tester);
    await tester.tap(find.byKey(const ValueKey('decks-row-menu-deep-spill')));
    await tester.pumpAndSettle();

    expect(find.text('Edit Deck'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Deck'), findsNothing);
    expect(find.text('Delete'), findsNothing);
  });
}
