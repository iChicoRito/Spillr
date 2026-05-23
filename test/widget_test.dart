import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:spillr/app/app.dart';
import 'package:spillr/core/database/app_database.dart';
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
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
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
      await database.saveProfile('Chico');

      await pumpApp(tester);

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
    await database.saveProfile('Chico');

    await pumpApp(tester);

    expect(find.text('Play No Dead Air'), findsOneWidget);

    final pageView = tester.widget<PageView>(find.byType(PageView));
    pageView.controller!.jumpToPage(2);
    await tester.pumpAndSettle();

    expect(find.text('Play Drop Lore'), findsOneWidget);
  });
}
