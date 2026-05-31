import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class DeckPatternBackground extends StatefulWidget {
  const DeckPatternBackground({
    super.key,
    this.animateInTests = false,
  });

  final bool animateInTests;

  @override
  State<DeckPatternBackground> createState() => _DeckPatternBackgroundState();
}

class _DeckPatternBackgroundState extends State<DeckPatternBackground>
    with SingleTickerProviderStateMixin {
  static const Duration _scrollDuration = Duration(seconds: 48);
  static const ValueKey<String> _scrollKey = ValueKey<String>(
    'deck-pattern-background-scroll',
  );

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: _scrollDuration,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimationState();
  }

  void _syncAnimationState() {
    final shouldAnimate = _shouldAnimate(context);

    if (shouldAnimate) {
      if (!_controller.isAnimating) {
        _controller.repeat();
      }
      return;
    }

    _controller.stop();
    _controller.value = 0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.white.withValues(alpha: 0.14);
    final shouldAnimate = _shouldAnimate(context);

    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewportHeight = math.max(
            1.0,
            constraints.hasBoundedHeight && constraints.maxHeight > 0
                ? constraints.maxHeight
                : MediaQuery.sizeOf(context).height,
          );

          if (!shouldAnimate) {
            return ClipRect(
              child: SizedBox.expand(
                key: _scrollKey,
                child: _PatternLayer(color: color),
              ),
            );
          }

          return ClipRect(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final offset = _controller.value * viewportHeight;
                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topLeft,
                  children: [
                    Positioned(
                      top: offset,
                      left: 0,
                      right: 0,
                      height: viewportHeight,
                      child: SizedBox.expand(
                        key: _scrollKey,
                        child: _PatternLayer(color: color),
                      ),
                    ),
                    Positioned(
                      top: offset - viewportHeight,
                      left: 0,
                      right: 0,
                      height: viewportHeight,
                      child: _PatternLayer(color: color),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  bool _shouldAnimate(BuildContext context) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) {
      return false;
    }

    final isWidgetTest =
        WidgetsBinding.instance.runtimeType.toString().contains(
          'TestWidgetsFlutterBinding',
        );

    return !isWidgetTest || widget.animateInTests;
  }
}

class _PatternLayer extends StatelessWidget {
  const _PatternLayer({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topLeft,
      children: [
        for (final item in _patternItems)
          Positioned(
            left: item.left,
            top: item.top,
            child: Transform.rotate(
              angle: item.rotation,
              child: _PatternShape(
                kind: item.kind,
                color: color,
                size: item.size,
              ),
            ),
          ),
      ],
    );
  }
}

class _PatternItem {
  const _PatternItem({
    required this.left,
    required this.top,
    required this.size,
    required this.rotation,
    required this.kind,
  });

  final double left;
  final double top;
  final double size;
  final double rotation;
  final _PatternKind kind;
}

enum _PatternKind { circle, square, line, arc, triangle }

class _PatternShape extends StatelessWidget {
  const _PatternShape({
    required this.kind,
    required this.color,
    required this.size,
  });

  final _PatternKind kind;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    switch (kind) {
      case _PatternKind.circle:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.4),
          ),
        );
      case _PatternKind.square:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 1.4),
          ),
        );
      case _PatternKind.line:
        return Container(width: size, height: 1.4, color: color);
      case _PatternKind.arc:
        return CustomPaint(
          size: Size.square(size),
          painter: _ArcPainter(color),
        );
      case _PatternKind.triangle:
        return CustomPaint(
          size: Size.square(size),
          painter: _TrianglePainter(color),
        );
    }
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawArc(rect, math.pi * 0.15, math.pi * 0.7, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TrianglePainter extends CustomPainter {
  const _TrianglePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

const _patternItems = [
  _PatternItem(
    left: 12,
    top: 18,
    size: 10,
    rotation: math.pi / 4,
    kind: _PatternKind.square,
  ),
  _PatternItem(
    left: 40,
    top: 70,
    size: 14,
    rotation: 0,
    kind: _PatternKind.circle,
  ),
  _PatternItem(
    left: 84,
    top: 26,
    size: 12,
    rotation: 0,
    kind: _PatternKind.line,
  ),
  _PatternItem(
    left: 146,
    top: 46,
    size: 10,
    rotation: math.pi / 6,
    kind: _PatternKind.triangle,
  ),
  _PatternItem(
    left: 210,
    top: 22,
    size: 14,
    rotation: 0,
    kind: _PatternKind.arc,
  ),
  _PatternItem(
    left: 286,
    top: 58,
    size: 12,
    rotation: math.pi / 2,
    kind: _PatternKind.line,
  ),
  _PatternItem(
    left: 326,
    top: 18,
    size: 12,
    rotation: 0,
    kind: _PatternKind.circle,
  ),
  _PatternItem(
    left: 22,
    top: 152,
    size: 14,
    rotation: math.pi / 3,
    kind: _PatternKind.triangle,
  ),
  _PatternItem(
    left: 100,
    top: 174,
    size: 18,
    rotation: 0,
    kind: _PatternKind.square,
  ),
  _PatternItem(
    left: 188,
    top: 124,
    size: 12,
    rotation: 0,
    kind: _PatternKind.circle,
  ),
  _PatternItem(
    left: 246,
    top: 164,
    size: 16,
    rotation: math.pi / 4,
    kind: _PatternKind.square,
  ),
  _PatternItem(
    left: 314,
    top: 144,
    size: 13,
    rotation: math.pi / 6,
    kind: _PatternKind.triangle,
  ),
  _PatternItem(
    left: 26,
    top: 236,
    size: 16,
    rotation: 0,
    kind: _PatternKind.line,
  ),
  _PatternItem(
    left: 152,
    top: 244,
    size: 12,
    rotation: 0,
    kind: _PatternKind.line,
  ),
  _PatternItem(
    left: 212,
    top: 274,
    size: 12,
    rotation: math.pi / 3,
    kind: _PatternKind.arc,
  ),
  _PatternItem(
    left: 298,
    top: 228,
    size: 14,
    rotation: math.pi / 2,
    kind: _PatternKind.line,
  ),
  _PatternItem(
    left: 56,
    top: 338,
    size: 12,
    rotation: 0,
    kind: _PatternKind.circle,
  ),
  _PatternItem(
    left: 126,
    top: 396,
    size: 14,
    rotation: math.pi / 8,
    kind: _PatternKind.line,
  ),
  _PatternItem(
    left: 210,
    top: 356,
    size: 12,
    rotation: math.pi / 4,
    kind: _PatternKind.square,
  ),
  _PatternItem(
    left: 300,
    top: 382,
    size: 13,
    rotation: 0,
    kind: _PatternKind.circle,
  ),
  _PatternItem(
    left: 24,
    top: 508,
    size: 14,
    rotation: math.pi / 4,
    kind: _PatternKind.square,
  ),
  _PatternItem(
    left: 104,
    top: 468,
    size: 14,
    rotation: 0,
    kind: _PatternKind.triangle,
  ),
  _PatternItem(
    left: 182,
    top: 530,
    size: 14,
    rotation: 0,
    kind: _PatternKind.circle,
  ),
  _PatternItem(
    left: 282,
    top: 482,
    size: 12,
    rotation: math.pi / 5,
    kind: _PatternKind.line,
  ),
  _PatternItem(
    left: 336,
    top: 534,
    size: 12,
    rotation: 0,
    kind: _PatternKind.arc,
  ),
];
