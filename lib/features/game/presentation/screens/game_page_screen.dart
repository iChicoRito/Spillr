import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/audio/app_audio_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/fallback_state_view.dart';
import '../../../../shared/widgets/show_spillr_dialog.dart';
import '../../../../shared/widgets/spillr_confirm_dialog.dart';
import '../../../decks/presentation/providers/deck_providers.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../../../profile/domain/profile_models.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../domain/game_result.dart';
import '../../domain/game_session_state.dart';
import '../../domain/spillr_deck.dart';
import '../models/game_ending_arguments.dart';
import '../providers/game_providers.dart';
import '../widgets/deck_pattern_background.dart';

class GamePageScreen extends ConsumerStatefulWidget {
  const GamePageScreen({required this.initialDeckId, super.key});

  final String initialDeckId;

  @override
  ConsumerState<GamePageScreen> createState() => _GamePageScreenState();
}

class _GamePageScreenState extends ConsumerState<GamePageScreen> {
  static const int _flipTimerDurationSeconds = 120;

  GameSessionState? _session;
  _AdvanceAction? _pendingAdvanceAction;
  Timer? _flipTimer;
  int _pendingAdvanceToken = 0;
  int _secondsRemaining = _flipTimerDurationSeconds;
  int _timerRotationTick = 0;

  void _toggleFlip() {
    if (_session == null) {
      return;
    }
    unawaited(ref.read(appAudioControllerProvider).playFlipSfx());
    _cancelFlipTimer();
    setState(() {
      _session = _session!.flip();
      _resetFlipTimer();
    });

    if (_session!.isFlipped) {
      _startFlipTimer();
    }
  }

  void _spillCard() {
    if (_session == null) {
      return;
    }
    unawaited(ref.read(appAudioControllerProvider).playAnsweredSfx());
    _cancelFlipTimer();
    final displayName =
        ref.read(onboardingProfileProvider).value?.displayName ?? 'Spiller';
    if (_session!.displayIndex == _session!.totalQuestions) {
      _recordGameplayEvent(GameplayCardAction.answered);
      final result = _session!.answeredResult(displayName);
      _goToEnding(result);
      return;
    }

    _recordGameplayEvent(GameplayCardAction.answered);
    _closeCurrentCardThenAdvance(_AdvanceAction.spill);
  }

  void _passCard() {
    if (_session == null) {
      return;
    }
    unawaited(ref.read(appAudioControllerProvider).playPassSfx());
    _cancelFlipTimer();
    final displayName =
        ref.read(onboardingProfileProvider).value?.displayName ?? 'Spiller';
    if (_session!.displayIndex == _session!.totalQuestions) {
      _recordGameplayEvent(GameplayCardAction.passed);
      final result = _session!.passedResult(displayName);
      _goToEnding(result);
      return;
    }

    _recordGameplayEvent(GameplayCardAction.passed);
    _closeCurrentCardThenAdvance(_AdvanceAction.pass);
  }

  void _endRound() {
    if (_session == null) {
      return;
    }
    _cancelFlipTimer();
    final displayName =
        ref.read(onboardingProfileProvider).value?.displayName ?? 'Spiller';
    final result = _session!.endedResult(displayName);
    _goToEnding(result);
  }

  Future<bool> _handleBackRequested() async {
    if (_session == null) {
      context.go(AppRoutes.home);
      return false;
    }

    if (!_session!.hasFlippedCard) {
      context.go(AppRoutes.home);
      return false;
    }

    await showSpillrDialog<void>(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.34),
      builder: (dialogContext) {
        return SpillrConfirmDialog(
          title: 'Leaving Already?',
          message:
              'You haven’t spilled all the cards yet. Want to exit anyway?',
          confirmLabel: 'Yes, Exit',
          cancelLabel: 'Cancel',
          onConfirm: () {
            Navigator.of(dialogContext).pop();
            if (mounted) {
              context.go(AppRoutes.home);
            }
          },
        );
      },
    );

    return false;
  }

  void _goToEnding(GameResult result) {
    context.go(
      AppRoutes.ending,
      extra: GameEndingArguments(deck: _session!.deck, result: result),
    );
  }

  void _recordGameplayEvent(GameplayCardAction action) {
    if (_session == null) {
      return;
    }

    unawaited(
      ref.read(profileRepositoryProvider).recordGameplayCardEvent(
        deckId: _session!.deck.id,
        action: action,
      ),
    );
  }

  void _closeCurrentCardThenAdvance(_AdvanceAction action) {
    if (_session == null) {
      return;
    }
    final token = _pendingAdvanceToken + 1;
    _cancelFlipTimer();
    setState(() {
      _pendingAdvanceToken = token;
      _pendingAdvanceAction = action;
      _session = _session!.copyWith(isFlipped: false);
      _resetFlipTimer();
    });

    Future<void>.delayed(const Duration(milliseconds: 420), () {
      if (!mounted ||
          token != _pendingAdvanceToken ||
          _pendingAdvanceAction != action) {
        return;
      }

      setState(() {
        _session = switch (action) {
          _AdvanceAction.spill => _session!.nextAnswered(),
          _AdvanceAction.pass => _session!.nextPassed(),
        };
        _pendingAdvanceAction = null;
      });
    });
  }

  void _startFlipTimer() {
    _flipTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted ||
          _session == null ||
          !_session!.isFlipped ||
          _pendingAdvanceAction != null) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining <= 1) {
        timer.cancel();
        _passCard();
        return;
      }

      setState(() {
        _secondsRemaining -= 1;
        _timerRotationTick += 1;
      });
    });
  }

  void _cancelFlipTimer() {
    _flipTimer?.cancel();
    _flipTimer = null;
  }

  void _resetFlipTimer() {
    _secondsRemaining = _flipTimerDurationSeconds;
    _timerRotationTick = 0;
  }

  @override
  void dispose() {
    _cancelFlipTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deckAsync = ref.watch(resolvedDeckProvider(widget.initialDeckId));

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
    _session ??= GameSessionState.start(
      deck,
      random: ref.read(gameRandomProvider),
    );
    final session = _session!;

    if (session.questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FallbackStateView.error(
                    message: 'This deck has no questions yet.',
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context.go(AppRoutes.decks),
                    child: const Text('Back'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) {
            unawaited(_handleBackRequested());
          }
        },
        child: SafeArea(
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
                                onBack: () {
                                  unawaited(_handleBackRequested());
                                },
                              ),
                              const SizedBox(height: 30),
                              SizedBox(
                                height: 52,
                                child: Center(
                                  child: session.isFlipped
                                      ? _FlipTimerChip(
                                          secondsRemaining: _secondsRemaining,
                                          rotationTick: _timerRotationTick,
                                          accentColor: deck.badgeTextColor,
                                        )
                                      : const SizedBox.shrink(),
                                ),
                              ),
                              const SizedBox(height: 26),
                              Expanded(
                                child: GestureDetector(
                                  key: const ValueKey('game-flip-card'),
                                  onTap:
                                      session.isFlipped ||
                                          _pendingAdvanceAction != null
                                      ? null
                                      : _toggleFlip,
                                  child: _FlipCard(session: session),
                                ),
                              ),
                              const SizedBox(height: 18),
                              _ProgressIndicator(session: session),
                              const SizedBox(height: 20),
                              if (session.isFlipped) ...[
                                _FlipActionBar(
                                  deck: deck,
                                  enabled: _pendingAdvanceAction == null,
                                  onEnd: _endRound,
                                  onSpill: _spillCard,
                                  onPass: _passCard,
                                ),
                              ] else
                                const SizedBox(height: 136),
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
      ),
    );
  }
}

enum _AdvanceAction { spill, pass }

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
                  Icon(Icons.chevron_left, color: AppColors.white, size: 22),
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

class _FlipTimerChip extends StatelessWidget {
  const _FlipTimerChip({
    required this.secondsRemaining,
    required this.rotationTick,
    required this.accentColor,
  });

  final int secondsRemaining;
  final int rotationTick;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const ValueKey('game-flip-timer-chip'),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedRotation(
              key: const ValueKey('game-flip-timer-icon'),
              turns: rotationTick * 0.5,
              duration: const Duration(milliseconds: 380),
              curve: Curves.easeInOutCubic,
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedHourglass,
                size: 18,
                color: accentColor,
                strokeWidth: 1.8,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatDuration(secondsRemaining),
              style: const TextStyle(
                color: AppColors.neutral700,
                fontSize: 16,
                height: 1.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
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
              border: Border.all(color: deck.cardBorderColor, width: 3),
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
                session.currentQuestion,
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
                Icon(Icons.sync, color: deck.badgeTextColor, size: 18),
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

class _FlipActionBar extends StatelessWidget {
  const _FlipActionBar({
    required this.deck,
    required this.enabled,
    required this.onEnd,
    required this.onSpill,
    required this.onPass,
  });

  final SpillrDeck deck;
  final bool enabled;
  final VoidCallback onEnd;
  final VoidCallback onSpill;
  final VoidCallback onPass;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('game-action-bar'),
      height: 136,
      child: Row(
        children: [
          Expanded(
            child: _RoundActionButton(
              buttonKey: const ValueKey('game-end-button'),
              circleKey: const ValueKey('game-end-button-circle'),
              label: 'End',
              icon: HugeIcons.strokeRoundedLogout05,
              iconColor: deck.badgeTextColor,
              buttonDiameter: 64,
              iconSize: 24,
              enabled: enabled,
              onPressed: onEnd,
            ),
          ),
          Expanded(
            child: _RoundActionButton(
              buttonKey: const ValueKey('game-next-card-button'),
              circleKey: const ValueKey('game-spill-button-circle'),
              label: 'Answered',
              icon: HugeIcons.strokeRoundedBulb,
              iconColor: deck.badgeTextColor,
              buttonDiameter: 90,
              iconSize: 36,
              enabled: enabled,
              onPressed: onSpill,
            ),
          ),
          Expanded(
            child: _RoundActionButton(
              buttonKey: const ValueKey('game-pass-button'),
              circleKey: const ValueKey('game-pass-button-circle'),
              label: 'Pass',
              icon: HugeIcons.strokeRoundedNext,
              iconColor: deck.badgeTextColor,
              buttonDiameter: 64,
              iconSize: 24,
              enabled: enabled,
              onPressed: onPass,
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDuration(int totalSeconds) {
  final minutes = totalSeconds ~/ 60;
  final seconds = totalSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({
    required this.buttonKey,
    required this.circleKey,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.buttonDiameter,
    required this.iconSize,
    required this.enabled,
    required this.onPressed,
  });

  final Key buttonKey;
  final Key circleKey;
  final String label;
  final List<List<dynamic>> icon;
  final Color iconColor;
  final double buttonDiameter;
  final double iconSize;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final contentOpacity = enabled ? 1.0 : 0.65;

    return GestureDetector(
      key: buttonKey,
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? onPressed : null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Opacity(
            opacity: contentOpacity,
            child: Material(
              key: circleKey,
              color: AppColors.white,
              shape: const CircleBorder(),
              child: ClipOval(
                child: SizedBox(
                  width: buttonDiameter,
                  height: buttonDiameter,
                  child: Center(
                    child: HugeIcon(
                      icon: icon,
                      color: iconColor,
                      size: iconSize,
                      strokeWidth: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: contentOpacity),
              fontSize: 14,
              height: 1.1,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
