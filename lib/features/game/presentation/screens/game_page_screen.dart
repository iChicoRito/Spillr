import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../../data/spillr_decks.dart';
import '../../domain/game_session_state.dart';
import '../../domain/spillr_deck.dart';
import '../models/game_ending_arguments.dart';
import '../providers/game_providers.dart';
import '../widgets/deck_pattern_background.dart';

class GamePageScreen extends ConsumerStatefulWidget {
  const GamePageScreen({
    required this.initialDeckId,
    super.key,
  });

  final String initialDeckId;

  @override
  ConsumerState<GamePageScreen> createState() => _GamePageScreenState();
}

class _GamePageScreenState extends ConsumerState<GamePageScreen> {
  late GameSessionState _session;
  _AdvanceAction? _pendingAdvanceAction;
  int _pendingAdvanceToken = 0;
  bool _hideDeckSelector = false;

  @override
  void initState() {
    super.initState();
    _session = GameSessionState.start(
      findDeckById(widget.initialDeckId),
      random: ref.read(gameRandomProvider),
    );
  }

  void _switchDeck(String deckId) {
    setState(() {
      _pendingAdvanceAction = null;
      _pendingAdvanceToken += 1;
      _session = GameSessionState.start(
        findDeckById(deckId),
        random: ref.read(gameRandomProvider),
      );
    });
  }

  void _toggleFlip() {
    setState(() {
      _hideDeckSelector = true;
      _session = _session.flip();
    });
  }

  void _answerCard() {
    final displayName =
        ref.read(onboardingProfileProvider).value?.displayName ?? 'Spiller';
    if (_session.displayIndex == _session.totalQuestions) {
      final result = _session.answeredResult(displayName);
      context.go(
        AppRoutes.ending,
        extra: GameEndingArguments(deck: _session.deck, result: result),
      );
      return;
    }

    _closeCurrentCardThenAdvance(_AdvanceAction.answer);
  }

  void _passCard() {
    final displayName =
        ref.read(onboardingProfileProvider).value?.displayName ?? 'Spiller';
    if (_session.displayIndex == _session.totalQuestions) {
      final result = _session.passedResult(displayName);
      context.go(
        AppRoutes.ending,
        extra: GameEndingArguments(deck: _session.deck, result: result),
      );
      return;
    }

    _closeCurrentCardThenAdvance(_AdvanceAction.pass);
  }

  void _closeCurrentCardThenAdvance(_AdvanceAction action) {
    final token = _pendingAdvanceToken + 1;
    setState(() {
      _pendingAdvanceToken = token;
      _pendingAdvanceAction = action;
      _session = _session.copyWith(isFlipped: false);
    });

    Future<void>.delayed(const Duration(milliseconds: 420), () {
      if (!mounted || token != _pendingAdvanceToken || _pendingAdvanceAction != action) {
        return;
      }

      setState(() {
        _session = switch (action) {
          _AdvanceAction.answer => _session.nextAnswered(),
          _AdvanceAction.pass => _session.nextPassed(),
        };
        _pendingAdvanceAction = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final deck = _session.deck;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        top: false,
        bottom: false,
        child: Column(
          children: [
            SizedBox(height: MediaQuery.paddingOf(context).top),
            Expanded(
              child: Container(
                color: deck.backgroundColor,
                child: Stack(
                  children: [
                    const Positioned.fill(child: DeckPatternBackground()),
                    SafeArea(
                      top: false,
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                        child: Column(
                          children: [
                            _TopBar(
                              onBack: () => context.go(AppRoutes.home),
                            ),
                            const SizedBox(height: 30),
                            if (!_hideDeckSelector &&
                                !_session.isFlipped &&
                                _pendingAdvanceAction == null)
                              _DeckSelector(
                                selectedDeck: deck,
                                onSelected: _switchDeck,
                              )
                            else
                              const SizedBox(height: 52),
                            const SizedBox(height: 26),
                            Expanded(
                              child: GestureDetector(
                                key: const ValueKey('game-flip-card'),
                                onTap: _session.isFlipped || _pendingAdvanceAction != null
                                    ? null
                                    : _toggleFlip,
                                child: _FlipCard(session: _session),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _ProgressIndicator(session: _session),
                            const SizedBox(height: 20),
                            if (_session.isFlipped) ...[
                              TextButton(
                                key: const ValueKey('game-pass-button'),
                                onPressed: _pendingAdvanceAction == null ? _passCard : null,
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.white,
                                ),
                                child: const Text('Pass'),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: FilledButton(
                                  key: const ValueKey('game-next-card-button'),
                                  onPressed: _pendingAdvanceAction == null ? _answerCard : null,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.white,
                                    foregroundColor: deck.badgeTextColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_session.displayIndex == _session.totalQuestions)
                                        Icon(
                                          Icons.check,
                                          size: 20,
                                          color: deck.badgeTextColor,
                                        )
                                      else
                                        HugeIcon(
                                          icon: HugeIcons.strokeRoundedPlay,
                                          size: 20,
                                          color: deck.badgeTextColor,
                                          strokeWidth: 1.8,
                                        ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _session.displayIndex == _session.totalQuestions
                                            ? "Done, I'm cooked"
                                            : 'Next Card',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ] else
                              const SizedBox(height: 102),
                          ],
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

enum _AdvanceAction { answer, pass }

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onBack,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.chevron_left,
                    color: AppColors.white,
                    size: 22,
                  ),
                  SizedBox(width: 2),
                  Text(
                    'Back',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SvgPicture.asset(
            'assets/svg/Spillr.svg',
            width: 58,
            height: 28,
            colorFilter: const ColorFilter.mode(
              AppColors.white,
              BlendMode.srcIn,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeckSelector extends StatelessWidget {
  const _DeckSelector({
    required this.selectedDeck,
    required this.onSelected,
  });

  final SpillrDeck selectedDeck;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            key: const ValueKey('game-deck-selector'),
            value: selectedDeck.id,
            iconEnabledColor: AppColors.neutral700,
            dropdownColor: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            onChanged: (value) {
              if (value != null) {
                onSelected(value);
              }
            },
            items: [
              for (final deck in spillrDecks)
                DropdownMenuItem<String>(
                  value: deck.id,
                  child: Row(
                    children: [
                      HugeIcon(
                        icon: HugeIcons.strokeRoundedCards01,
                        size: 18,
                        color: deck.badgeTextColor,
                        strokeWidth: 1.8,
                      ),
                      const SizedBox(width: 8),
                      Text(deck.title),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlipCard extends StatefulWidget {
  const _FlipCard({required this.session});

  final GameSessionState session;

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
      value: widget.session.isFlipped ? 1 : 0,
    );
  }

  @override
  void didUpdateWidget(covariant _FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.session.isFlipped != oldWidget.session.isFlipped) {
      if (widget.session.isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deck = widget.session.deck;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final easedValue = Curves.easeInOutCubic.transform(_controller.value);
        final angle = easedValue * math.pi;
        final isShowingBack = angle > math.pi / 2;
        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.0012)
          ..rotateY(angle);

        return Transform(
          key: const ValueKey('game-flip-transform'),
          alignment: Alignment.center,
          transform: transform,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: deck.cardBorderColor,
                width: 3,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: isShowingBack
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _BackFace(session: widget.session),
                  )
                : _FrontFace(session: widget.session),
          ),
        );
      },
    );
  }
}

class _BackFace extends StatelessWidget {
  const _BackFace({required this.session});

  final GameSessionState session;

  @override
  Widget build(BuildContext context) {
    return Stack(
      key: const ValueKey('back-face'),
      children: [
        Align(
          key: const ValueKey('game-question-center'),
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 72, 8, 24),
            child: SingleChildScrollView(
              child: Text(
                key: const ValueKey('game-question-text'),
                '"${session.currentQuestion}"',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.neutral700,
                  fontSize: 34,
                  height: 1.18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FrontFace extends StatelessWidget {
  const _FrontFace({required this.session});

  final GameSessionState session;

  @override
  Widget build(BuildContext context) {
    final deck = session.deck;

    return Center(
      key: const ValueKey('front-face'),
      child: Stack(
        children: [
          Align(
            key: const ValueKey('game-front-main-center'),
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _CardBadge(
                    key: const ValueKey('game-front-badge'),
                    title: deck.title,
                    backgroundColor: deck.badgeTextColor,
                    textColor: AppColors.white,
                    compact: true,
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'Question',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.neutral700,
                      fontSize: 60,
                      height: 1.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No. ${session.displayIndex}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.neutral700,
                      fontSize: 28,
                      height: 1.1,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            key: const ValueKey('game-tap-to-flip-positioned'),
            left: 0,
            right: 0,
            bottom: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tap to flip',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: deck.badgeTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Icon(
                  Icons.sync,
                  color: deck.badgeTextColor,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBadge extends StatelessWidget {
  const _CardBadge({
    super.key,
    required this.title,
    required this.backgroundColor,
    required this.textColor,
    this.compact = false,
  });

  final String title;
  final Color backgroundColor;
  final Color textColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: compact ? 8 : 10,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(
              icon: HugeIcons.strokeRoundedCards01,
              size: compact ? 16 : 18,
              color: textColor,
              strokeWidth: 1.8,
            ),
            SizedBox(width: compact ? 6 : 8),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: compact ? 14 : 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressIndicator extends StatelessWidget {
  const _ProgressIndicator({required this.session});

  final GameSessionState session;

  @override
  Widget build(BuildContext context) {
    final progress = session.displayIndex / session.totalQuestions;

    return Column(
      children: [
        SizedBox(
          width: 152,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: progress),
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            builder: (context, animatedProgress, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  key: const ValueKey('game-progress-bar'),
                  value: animatedProgress,
                  minHeight: 6,
                  backgroundColor: AppColors.white.withValues(alpha: 0.28),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.white,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${session.displayIndex} of ${session.totalQuestions}',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
