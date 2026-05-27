import 'package:flutter/material.dart';

class SequentialTextReveal extends StatefulWidget {
  const SequentialTextReveal({
    required this.lines,
    this.textAlign = TextAlign.start,
    super.key,
  });

  final List<SequentialTextRevealLine> lines;
  final TextAlign textAlign;

  @override
  State<SequentialTextReveal> createState() => _SequentialTextRevealState();
}

class _SequentialTextRevealState extends State<SequentialTextReveal>
    with SingleTickerProviderStateMixin {
  static const _letterStagger = Duration(milliseconds: 55);
  static const _letterDuration = Duration(milliseconds: 260);

  late final AnimationController _controller;

  int get _visibleLetterCount =>
      widget.lines.fold(0, (count, line) => count + line.visibleLetterCount);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _updateControllerDuration();
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant SequentialTextReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_signatureFor(oldWidget.lines) != _signatureFor(widget.lines)) {
      _updateControllerDuration();
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var nextVisibleLetterIndex = 0;
    final children = <Widget>[];

    for (final line in widget.lines) {
      if (line.gapBefore != 0) {
        children.add(SizedBox(height: line.gapBefore));
      }
      children.add(
        _SequentialTextRevealLineWidget(
          line: line,
          controller: _controller,
          firstVisibleLetterIndex: nextVisibleLetterIndex,
          textAlign: widget.textAlign,
        ),
      );
      nextVisibleLetterIndex += line.visibleLetterCount;
    }

    return Column(mainAxisSize: MainAxisSize.min, children: children);
  }

  String _signatureFor(List<SequentialTextRevealLine> lines) {
    return lines
        .map(
          (line) => '${line.plainText}|${line.spans.length}|${line.gapBefore}',
        )
        .join('||');
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
}

class SequentialTextRevealLine {
  const SequentialTextRevealLine({
    required this.key,
    required this.spans,
    this.gapBefore = 0,
    this.letterKeyBuilder,
  });

  final Key key;
  final List<SequentialTextRevealSpan> spans;
  final double gapBefore;
  final Key Function(int visibleLetterIndex)? letterKeyBuilder;

  String get plainText => spans.map((span) => span.text).join();

  int get visibleLetterCount =>
      spans.fold(0, (count, span) => count + span.visibleLetterCount);
}

class SequentialTextRevealSpan {
  const SequentialTextRevealSpan({required this.text, required this.style});

  final String text;
  final TextStyle style;

  int get visibleLetterCount =>
      text.split('').where((character) => character.trim().isNotEmpty).length;
}

class _SequentialTextRevealLineWidget extends StatelessWidget {
  const _SequentialTextRevealLineWidget({
    required this.line,
    required this.controller,
    required this.firstVisibleLetterIndex,
    required this.textAlign,
  });

  final SequentialTextRevealLine line;
  final AnimationController controller;
  final int firstVisibleLetterIndex;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    var visibleLetterIndex = firstVisibleLetterIndex;

    final children = <InlineSpan>[];
    for (final span in line.spans) {
      for (final character in span.text.split('')) {
        if (character.trim().isEmpty) {
          children.add(TextSpan(text: character, style: span.style));
          continue;
        }

        final letterKey = line.letterKeyBuilder?.call(visibleLetterIndex);
        children.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: _SequentialAnimatedLetter(
              characterKey: letterKey,
              character: character,
              textStyle: span.style,
              controller: controller,
              letterIndex: visibleLetterIndex,
            ),
          ),
        );
        visibleLetterIndex++;
      }
    }

    return Semantics(
      key: line.key,
      label: line.plainText,
      child: ExcludeSemantics(
        child: Text.rich(TextSpan(children: children), textAlign: textAlign),
      ),
    );
  }
}

class _SequentialAnimatedLetter extends StatelessWidget {
  const _SequentialAnimatedLetter({
    required this.character,
    required this.textStyle,
    required this.controller,
    required this.letterIndex,
    this.characterKey,
  });

  static const _letterStagger = Duration(milliseconds: 55);
  static const _letterDuration = Duration(milliseconds: 260);

  final Key? characterKey;
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
      child: Text(character, style: textStyle),
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
