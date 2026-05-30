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
<<<<<<< HEAD
                        child: const Text("Let's Get Started"),
=======
                        child: Text(
                          canStart ? "Let's Get Started" : 'Add Tea First',
                        ),
>>>>>>> ae7d8bc393346ef4e96598ee5e7e84c321f12025
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
<<<<<<< HEAD
        AppColors.blue500,
        AppColors.violet500,
        AppColors.teal500,
        AppColors.red500,
        AppColors.pink500,
      ],
=======
      AppColors.blue500,
      AppColors.violet500,
      AppColors.teal500,
      AppColors.red500,
      AppColors.pink500,
    ],
>>>>>>> ae7d8bc393346ef4e96598ee5e7e84c321f12025
    _ => null,
  };
}

<<<<<<< HEAD
class _PreparationAnimatedMessage extends StatefulWidget {
=======
class _PreparationAnimatedMessage extends StatelessWidget {
>>>>>>> ae7d8bc393346ef4e96598ee5e7e84c321f12025
  const _PreparationAnimatedMessage({
    required this.titleLines,
    required this.deckTitleColor,
    required this.titleLetterColors,
  });

  final List<String> titleLines;
  final Color deckTitleColor;
  final List<Color>? titleLetterColors;
<<<<<<< HEAD

  @override
  State<_PreparationAnimatedMessage> createState() =>
      _PreparationAnimatedMessageState();
}

class _PreparationAnimatedMessageState
    extends State<_PreparationAnimatedMessage>
    with SingleTickerProviderStateMixin {
  static const _letterStagger = Duration(milliseconds: 55);
  static const _letterDuration = Duration(milliseconds: 260);

  late final AnimationController _controller;

  List<_PreparationLineSpec> get _messageLines => [
    const _PreparationLineSpec(
      key: ValueKey('preparation-intro-line-one'),
      text: 'You are about',
      color: AppColors.neutral700,
    ),
    const _PreparationLineSpec(
      key: ValueKey('preparation-intro-line-two'),
      text: 'to play the',
      color: AppColors.neutral700,
    ),
    for (final (index, titleLine) in widget.titleLines.indexed)
      _PreparationLineSpec(
        key: ValueKey('preparation-intro-deck-line-$index'),
        text: titleLine,
        color: widget.deckTitleColor,
        letterColors: widget.titleLetterColors,
      ),
  ];

  int get _visibleLetterCount =>
      _messageLines.fold(0, (count, line) => count + line.visibleLetterCount);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _updateControllerDuration();
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _PreparationAnimatedMessage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.titleLines.join('\n') != widget.titleLines.join('\n')) {
      _updateControllerDuration();
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateControllerDuration() {
    final letterCount = _visibleLetterCount;
    final staggeredDuration = letterCount > 0
        ? (letterCount - 1) * _letterStagger.inMilliseconds
        : 0;
    _controller.duration = Duration(
      milliseconds: staggeredDuration + _letterDuration.inMilliseconds,
    );
  }
=======
>>>>>>> ae7d8bc393346ef4e96598ee5e7e84c321f12025

  @override
  Widget build(BuildContext context) {
    const introStyle = TextStyle(
      color: AppColors.neutral700,
      fontSize: 50,
      height: 1,
      fontWeight: FontWeight.w800,
    );
    final deckStyle = introStyle.copyWith(color: deckTitleColor);

<<<<<<< HEAD
    _PreparationAnimatedTextLine buildLine(_PreparationLineSpec line) {
      final animatedLine = _PreparationAnimatedTextLine(
        lineKey: line.key,
        text: line.text,
        color: line.color,
        letterColors: line.letterColors,
        controller: _controller,
        firstVisibleLetterIndex: nextVisibleLetterIndex,
      );
      nextVisibleLetterIndex += line.visibleLetterCount;
      return animatedLine;
    }

    final firstIntroLine = _messageLines[0];
    final secondIntroLine = _messageLines[1];
    final deckTitleLines = _messageLines.skip(2).toList();

    return Column(
=======
    return SequentialTextReveal(
>>>>>>> ae7d8bc393346ef4e96598ee5e7e84c321f12025
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

<<<<<<< HEAD
class _PreparationLineSpec {
  const _PreparationLineSpec({
    required this.key,
    required this.text,
    required this.color,
    this.letterColors,
  });

  final Key key;
  final String text;
  final Color color;
  final List<Color>? letterColors;

  int get visibleLetterCount =>
      text.split('').where((character) => character.trim().isNotEmpty).length;
}

class _PreparationAnimatedTextLine extends StatelessWidget {
  const _PreparationAnimatedTextLine({
    required this.lineKey,
    required this.text,
    required this.color,
    required this.letterColors,
    required this.controller,
    required this.firstVisibleLetterIndex,
  });

  final Key lineKey;
  final String text;
  final Color color;
  final List<Color>? letterColors;
  final AnimationController controller;
  final int firstVisibleLetterIndex;

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      color: color,
      fontSize: 50,
      height: 1,
      fontWeight: FontWeight.w800,
    );
    var visibleLetterIndex = firstVisibleLetterIndex;

    final characters = text.split('').map<Widget>((character) {
      if (character.trim().isEmpty) {
        return const SizedBox.shrink();
      }

      final letterColor = letterColors == null
          ? color
          : letterColors![visibleLetterIndex % letterColors!.length];
      final characterWidget = _PreparationAnimatedLetter(
        characterKey: ValueKey('preparation-letter-$visibleLetterIndex'),
        character: character,
        textStyle: textStyle.copyWith(color: letterColor),
        controller: controller,
        letterIndex: visibleLetterIndex,
      );
      visibleLetterIndex++;
      return characterWidget;
    }).toList();

    return Semantics(
      key: lineKey,
      label: text,
      child: ExcludeSemantics(
        child: Flow(
          delegate: _PreparationTextFlowDelegate(text: text, style: textStyle),
          children: characters,
        ),
      ),
    );
  }
}

class _PreparationAnimatedLetter extends StatelessWidget {
  const _PreparationAnimatedLetter({
    required this.characterKey,
    required this.character,
    required this.textStyle,
    required this.controller,
    required this.letterIndex,
  });

  static const _letterStagger = Duration(milliseconds: 55);
  static const _letterDuration = Duration(milliseconds: 260);

  final Key characterKey;
  final String character;
  final TextStyle textStyle;
  final AnimationController controller;
  final int letterIndex;

  @override
  Widget build(BuildContext context) {
    final totalDuration = controller.duration ?? _letterDuration;
    final startMilliseconds = letterIndex * _letterStagger.inMilliseconds;
    final endMilliseconds = startMilliseconds + _letterDuration.inMilliseconds;
    final start = startMilliseconds / totalDuration.inMilliseconds;
    final end = endMilliseconds / totalDuration.inMilliseconds;
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(
        start.clamp(0, 1).toDouble(),
        end.clamp(0, 1).toDouble(),
        curve: Curves.easeInOut,
      ),
    );

    return AnimatedBuilder(
      animation: animation,
      child: Text(
        character,
        style: textStyle,
        maxLines: 1,
        overflow: TextOverflow.visible,
        softWrap: false,
      ),
      builder: (context, child) {
        final progress = animation.value.clamp(0, 1).toDouble();
        return Opacity(
          key: characterKey,
          opacity: progress,
          child: Transform.scale(
            scale: 0.84 + (progress * 0.16),
            alignment: Alignment.bottomCenter,
            child: child,
          ),
        );
      },
    );
  }
}

class _PreparationTextFlowDelegate extends FlowDelegate {
  const _PreparationTextFlowDelegate({required this.text, required this.style});

  static const double _glyphTightness = 0.90;

  final String text;
  final TextStyle style;

  @override
  Size getSize(BoxConstraints constraints) {
    return constraints.constrain(_measureText(text));
=======
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
>>>>>>> ae7d8bc393346ef4e96598ee5e7e84c321f12025
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
