import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_confetti/flutter_confetti.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/audio/app_audio_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/game_result.dart';
import '../../domain/spillr_deck.dart';
import '../widgets/deck_pattern_background.dart';

double randomInRange(double min, double max) {
  return min + Random().nextDouble() * (max - min);
}

class EndingPageScreen extends ConsumerStatefulWidget {
  const EndingPageScreen({required this.deck, required this.result, super.key});

  final SpillrDeck deck;
  final GameResult result;

  @override
  ConsumerState<EndingPageScreen> createState() => _EndingPageScreenState();
}

class _EndingPageScreenState extends ConsumerState<EndingPageScreen> {
  static const int _confettiTotal = 60;

  final List<ConfettiController> _confettiControllers = [];
  Timer? _confettiTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      unawaited(ref.read(appAudioControllerProvider).playEndingSfx());
      _launchConfettiSequence();
    });
  }

  @override
  void dispose() {
    _confettiTimer?.cancel();
    for (final controller in _confettiControllers) {
      controller.kill();
    }
    super.dispose();
  }

  void _launchConfettiSequence() {
    var progress = 0;

    _confettiTimer = Timer.periodic(const Duration(milliseconds: 250), (timer) {
      progress++;

      if (!mounted || progress >= _confettiTotal) {
        timer.cancel();
        return;
      }

      final count = ((1 - progress / _confettiTotal) * 50).toInt();

      _confettiControllers.add(
        Confetti.launch(
          context,
          options: ConfettiOptions(
            particleCount: count,
            startVelocity: 30,
            spread: 360,
            ticks: 60,
            x: randomInRange(0.1, 0.3),
            y: Random().nextDouble() - 0.2,
          ),
        ),
      );
      _confettiControllers.add(
        Confetti.launch(
          context,
          options: ConfettiOptions(
            particleCount: count,
            startVelocity: 30,
            spread: 360,
            ticks: 60,
            x: randomInRange(0.7, 0.9),
            y: Random().nextDouble() - 0.2,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
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
                color: widget.deck.backgroundColor,
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
                            _EndingTopBar(
                              onBack: () => context.go(AppRoutes.home),
                            ),
                            const Spacer(),
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedCards01,
                                  size: 28,
                                  color: widget.deck.iconColor,
                                  strokeWidth: 1.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _ResultBadge(deck: widget.deck),
                            const SizedBox(height: 18),
                            Text(
                              widget.result.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 42,
                                height: 1.2,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 18),
                            Text(
                              widget.result.subtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 18,
                                height: 1.50,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: FilledButton(
                                onPressed: () => context.go(AppRoutes.home),
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.white,
                                  foregroundColor: widget.deck.badgeTextColor,
                                  textStyle: TextStyle(
                                    fontSize: 18,
                                    height: 1.1,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text('Back to Menu'),
                              ),
                            ),
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

class _EndingTopBar extends StatelessWidget {
  const _EndingTopBar({required this.onBack});

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

class _ResultBadge extends StatelessWidget {
  const _ResultBadge({required this.deck});

  final SpillrDeck deck;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Text(
          deck.title,
          style: TextStyle(
            color: deck.badgeTextColor,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
