import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/game_result.dart';
import '../../domain/spillr_deck.dart';
import '../widgets/deck_pattern_background.dart';

class EndingPageScreen extends StatefulWidget {
  const EndingPageScreen({
    required this.deck,
    required this.result,
    super.key,
  });

  final SpillrDeck deck;
  final GameResult result;

  @override
  State<EndingPageScreen> createState() => _EndingPageScreenState();
}

class _EndingPageScreenState extends State<EndingPageScreen> {
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 1),
    )..play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
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
                    Positioned.fill(
                      child: IgnorePointer(
                        child: ConfettiWidget(
                          confettiController: _confettiController,
                          blastDirectionality:
                              BlastDirectionality.explosive,
                          shouldLoop: false,
                          emissionFrequency: 0.05,
                          numberOfParticles: 24,
                          gravity: 0.22,
                          colors: const [
                            AppColors.white,
                            Color(0xFFCCFBF1),
                            Color(0xFFD6BCFA),
                            Color(0xFFFECACA),
                          ],
                        ),
                      ),
                    ),
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
                              width: 76,
                              height: 76,
                              decoration: const BoxDecoration(
                                color: AppColors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: HugeIcon(
                                  icon: HugeIcons.strokeRoundedCards01,
                                  size: 32,
                                  color: widget.deck.iconColor,
                                  strokeWidth: 1.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            _ResultBadge(deck: widget.deck),
                            const SizedBox(height: 24),
                            Text(
                              widget.result.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 42,
                                height: 1.06,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 26),
                            Text(
                              widget.result.subtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 16,
                                height: 1.35,
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
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text('Explore Decks'),
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
