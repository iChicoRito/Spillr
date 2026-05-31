import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spillr/features/game/presentation/widgets/deck_pattern_background.dart';

void main() {
  Future<void> pumpBackground(
    WidgetTester tester, {
    bool disableAnimations = false,
    Size size = const Size(393, 852),
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final mediaQueryData = MediaQueryData.fromView(tester.view).copyWith(
      disableAnimations: disableAnimations,
    );

    await tester.pumpWidget(
      MediaQuery(
        data: mediaQueryData,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: const DeckPatternBackground(animateInTests: true),
          ),
        ),
      ),
    );

    await tester.pump();
  }

  testWidgets('moves downward over time', (tester) async {
    await pumpBackground(tester);

    final background = find.byKey(
      const ValueKey('deck-pattern-background-scroll'),
    );

    expect(background, findsOneWidget);

    final initialTopLeft = tester.getTopLeft(background);

    await tester.pump(const Duration(seconds: 6));

    final laterTopLeft = tester.getTopLeft(background);

    expect(laterTopLeft.dy, greaterThan(initialTopLeft.dy));
  });

  testWidgets('returns to the starting position after one full cycle', (
    tester,
  ) async {
    await pumpBackground(tester);

    final background = find.byKey(
      const ValueKey('deck-pattern-background-scroll'),
    );

    expect(background, findsOneWidget);

    final initialTopLeft = tester.getTopLeft(background);

    await tester.pump(const Duration(seconds: 48));

    final cycleTopLeft = tester.getTopLeft(background);

    expect(cycleTopLeft.dy, closeTo(initialTopLeft.dy, 0.5));
  });

  testWidgets('stays static when animations are disabled', (tester) async {
    await pumpBackground(tester, disableAnimations: true);

    final background = find.byKey(
      const ValueKey('deck-pattern-background-scroll'),
    );

    expect(background, findsOneWidget);

    final initialTopLeft = tester.getTopLeft(background);

    await tester.pump(const Duration(seconds: 10));

    final laterTopLeft = tester.getTopLeft(background);

    expect(laterTopLeft.dy, closeTo(initialTopLeft.dy, 0.1));
  });
}
