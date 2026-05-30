import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/fallback_state_view.dart';
import '../../../../shared/widgets/sequential_text_reveal.dart';
import '../../../decks/presentation/providers/deck_providers.dart';

class PreparationPageScreen extends ConsumerWidget {
  const PreparationPageScreen({required this.deckId, super.key});

  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deckAsync = ref.watch(resolvedDeckProvider(deckId));

    if (deckAsync.hasError) {
      return const Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: FallbackStateView.error(message: 'Unable to load this deck.'),
        ),
      );
    }
    if (deckAsync.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(child: FallbackStateView.loading()),
      );
    }

    final deck = deckAsync.requireValue;
    final canStart = deck.questions.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            SizedBox(height: MediaQuery.paddingOf(context).top),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  children: [
                    const Spacer(flex: 5),
                    _PreparationAnimatedMessage(
                      titleLines: _preparationDeckTitleLines(deck.title),
                      deckTitleColor: deck.badgeTextColor,
                      titleLetterColors: _preparationDeckLetterColors(deck.id),
                    ),
                    const Spacer(flex: 6),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        key: const ValueKey('preparation-continue-button'),
                        onPressed: canStart
                            ? () => context.go('${AppRoutes.game}/${deck.id}')
                            : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: deck.badgeTextColor,
                          foregroundColor: AppColors.white,
                          disabledBackgroundColor: deck.badgeTextColor
                              .withValues(alpha: 0.4),
                          textStyle: const TextStyle(
                            fontSize: 18,
                            height: 1.1,
                            fontWeight: FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: Text(
                          canStart ? "Let's Get Started" : 'Add Tea First',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.paddingOf(context).bottom),
          ],
        ),
      ),
    );
  }
}

List<String> _preparationDeckTitleLines(String title) {
  return switch (title) {
    'No Dead Air' => ['No', 'Dead Air'],
    'Hot Seat' => ['Hot', 'Seat'],
    _ => [title],
  };
}

List<Color>? _preparationDeckLetterColors(String deckId) {
  return switch (deckId) {
    'wildcard-tea' => const [
      AppColors.blue500,
      AppColors.violet500,
      AppColors.teal500,
      AppColors.red500,
      AppColors.pink500,
    ],
    _ => null,
  };
}

class _PreparationAnimatedMessage extends StatelessWidget {
  const _PreparationAnimatedMessage({
    required this.titleLines,
    required this.deckTitleColor,
    required this.titleLetterColors,
  });

  final List<String> titleLines;
  final Color deckTitleColor;
  final List<Color>? titleLetterColors;

  @override
  Widget build(BuildContext context) {
    const introStyle = TextStyle(
      color: AppColors.neutral700,
      fontSize: 50,
      height: 1,
      fontWeight: FontWeight.w800,
    );
    final deckStyle = introStyle.copyWith(color: deckTitleColor);

    return SequentialTextReveal(
      key: const ValueKey('preparation-message'),
      textAlign: TextAlign.center,
      lines: [
        SequentialTextRevealLine(
          key: const ValueKey('preparation-intro-line-one'),
          spans: const [
            SequentialTextRevealSpan(text: 'You are about', style: introStyle),
          ],
          letterKeyBuilder: _preparationLetterKey,
        ),
        SequentialTextRevealLine(
          key: const ValueKey('preparation-intro-line-two'),
          gapBefore: 6,
          spans: const [
            SequentialTextRevealSpan(text: 'to play the', style: introStyle),
          ],
          letterKeyBuilder: _preparationLetterKey,
        ),
        for (final (index, titleLine) in titleLines.indexed)
          SequentialTextRevealLine(
            key: ValueKey('preparation-intro-deck-line-$index'),
            gapBefore: index == 0 ? 6 : 2,
            spans: _buildPreparationSpans(
              titleLine,
              deckStyle,
              titleLetterColors,
            ),
            letterKeyBuilder: _preparationLetterKey,
          ),
      ],
    );
  }
}

Key _preparationLetterKey(int visibleLetterIndex) {
  return ValueKey('preparation-letter-$visibleLetterIndex');
}

List<SequentialTextRevealSpan> _buildPreparationSpans(
  String text,
  TextStyle baseStyle,
  List<Color>? letterColors,
) {
  if (letterColors == null || letterColors.isEmpty) {
    return [SequentialTextRevealSpan(text: text, style: baseStyle)];
  }

  final spans = <SequentialTextRevealSpan>[];
  var visibleLetterIndex = 0;

  for (final character in text.split('')) {
    if (character.trim().isEmpty) {
      spans.add(SequentialTextRevealSpan(text: character, style: baseStyle));
      continue;
    }

    spans.add(
      SequentialTextRevealSpan(
        text: character,
        style: baseStyle.copyWith(
          color: letterColors[visibleLetterIndex % letterColors.length],
        ),
      ),
    );
    visibleLetterIndex++;
  }

  return spans;
}
