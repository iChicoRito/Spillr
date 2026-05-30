import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/spillr_decks.dart';

class PreparationPageScreen extends StatelessWidget {
  const PreparationPageScreen({required this.deckId, super.key});

  final String deckId;

  @override
  Widget build(BuildContext context) {
    final deck = findDeckById(deckId);

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
                        onPressed: () =>
                            context.go('${AppRoutes.game}/${deck.id}'),
                        style: FilledButton.styleFrom(
                          backgroundColor: deck.badgeTextColor,
                          foregroundColor: AppColors.white,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            height: 1.1,
                            fontWeight: FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text("Let's Get Started"),
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

class _PreparationAnimatedMessage extends StatefulWidget {
  const _PreparationAnimatedMessage({
    required this.titleLines,
    required this.deckTitleColor,
    required this.titleLetterColors,
  });

  final List<String> titleLines;
  final Color deckTitleColor;
  final List<Color>? titleLetterColors;

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

  @override
  Widget build(BuildContext context) {
    var nextVisibleLetterIndex = 0;

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
      key: const ValueKey('preparation-message'),
      children: [
        buildLine(firstIntroLine),
        const SizedBox(height: 6),
        buildLine(secondIntroLine),
        const SizedBox(height: 6),
        Column(
          key: const ValueKey('preparation-intro-deck'),
          children: [
            for (final (index, line) in deckTitleLines.indexed) ...[
              if (index > 0) const SizedBox(height: 2),
              buildLine(line),
            ],
          ],
        ),
      ],
    );
  }
}

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
  }

  @override
  BoxConstraints getConstraintsForChild(int i, BoxConstraints constraints) {
    return const BoxConstraints();
  }

  @override
  void paintChildren(FlowPaintingContext context) {
    for (var index = 0; index < context.childCount; index++) {
      final leadingText = text.substring(0, index);
      context.paintChild(
        index,
        transform: Matrix4.translationValues(
          _measureText(leadingText).width * _glyphTightness,
          0,
          0,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PreparationTextFlowDelegate oldDelegate) {
    return oldDelegate.text != text || oldDelegate.style != style;
  }

  Size _measureText(String value) {
    final textPainter = TextPainter(
      text: TextSpan(text: value, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.size;
  }
}
