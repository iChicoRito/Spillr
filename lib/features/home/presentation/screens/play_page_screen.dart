import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/fallback_state_view.dart';
import '../../../../shared/widgets/spillr_bottom_navigation.dart';
import '../../../game/data/spillr_decks.dart';
import '../../../game/domain/spillr_deck.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';

class PlayPageScreen extends ConsumerStatefulWidget {
  const PlayPageScreen({super.key});

  @override
  ConsumerState<PlayPageScreen> createState() => _PlayPageScreenState();
}

class _PlayPageScreenState extends ConsumerState<PlayPageScreen> {
  late final PageController _pageController;
  double _currentPage = 1;
  int _activeIndex = 1;
  static const _carouselViewportFraction = 0.64;
  static const _activeCardWidth = 180.0;
  static const _activeCardHeight = 456.0;
  static const _inactiveCardWidth = 188.0;
  static const _inactiveVerticalInset = 48.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _activeIndex,
      viewportFraction: _carouselViewportFraction,
    )..addListener(_handlePageChange);
  }

  @override
  void dispose() {
    _pageController
      ..removeListener(_handlePageChange)
      ..dispose();
    super.dispose();
  }

  void _handlePageChange() {
    if (!_pageController.hasClients) {
      return;
    }

    final page = _pageController.page ?? _activeIndex.toDouble();
    final nextIndex = page.round().clamp(0, _playDecks.length - 1);
    if (page != _currentPage || nextIndex != _activeIndex) {
      setState(() {
        _currentPage = page;
        _activeIndex = nextIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(onboardingProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) {
            final name = profile?.displayName ?? 'Spiller';

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 393),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final carouselHeight = math.min(
                      _activeCardHeight,
                      math.max(404.0, constraints.maxHeight * 0.62),
                    );

                    return Stack(
                      children: [
                        Positioned.fill(
                          child: CustomScrollView(
                            slivers: [
                              const SliverPadding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                sliver: SliverToBoxAdapter(
                                  child: SizedBox(height: 7),
                                ),
                              ),
                              const SliverPadding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                sliver: SliverToBoxAdapter(
                                  child: _PlayPageHeader(),
                                ),
                              ),
                              const SliverPadding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                sliver: SliverToBoxAdapter(
                                  child: SizedBox(height: 27),
                                ),
                              ),
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: _PlayPageGreeting(name: name),
                                  ),
                                ),
                              ),
                              const SliverPadding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                sliver: SliverToBoxAdapter(
                                  child: SizedBox(height: 24),
                                ),
                              ),
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Choose Your Deck',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontSize: 18,
                                            color: AppColors.neutral700,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              const SliverPadding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                sliver: SliverToBoxAdapter(
                                  child: SizedBox(height: 24),
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: SizedBox(
                                  height: carouselHeight,
                                  child: PageView.builder(
                                    controller: _pageController,
                                    clipBehavior: Clip.none,
                                    physics: const BouncingScrollPhysics(),
                                    itemCount: _playDecks.length,
                                    itemBuilder: (context, index) {
                                      final deck = _playDecks[index];
                                      final delta = (_currentPage - index)
                                          .abs();
                                      final scale = (1 - (delta * 0.14)).clamp(
                                        0.88,
                                        1.0,
                                      );
                                      final opacity = (1 - (delta * 0.22))
                                          .clamp(0.68, 1.0);

                                      return AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        curve: Curves.easeOutCubic,
                                        padding: EdgeInsets.only(
                                          top: index == _activeIndex
                                              ? 0
                                              : _inactiveVerticalInset,
                                          bottom: index == _activeIndex
                                              ? 0
                                              : _inactiveVerticalInset,
                                        ),
                                        child: Transform.scale(
                                          scale: scale,
                                          child: Opacity(
                                            opacity: opacity,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 0,
                                                  ),
                                              child: _DeckCard(
                                                deck: deck,
                                                isActive: index == _activeIndex,
                                                onPlay: () {
                                                  context.go(
                                                    '${AppRoutes.preparation}/${deck.id}',
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 106),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          bottom: 10,
                          child: SpillrBottomNavigation(
                            selectedTab: SpillrBottomNavTab.play,
                            onDecksTap: () => context.go(AppRoutes.decks),
                            onPlayTap: () {},
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
          loading: () => const FallbackStateView.loading(),
          error: (error, stackTrace) => const FallbackStateView.error(
            message: 'Unable to load your saved profile.',
          ),
        ),
      ),
    );
  }
}

class _PlayPageHeader extends StatelessWidget {
  const _PlayPageHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: Row(
        children: [
          SvgPicture.asset('assets/svg/Spillr.svg', width: 58, height: 28),
          const Spacer(),
          DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.neutral100),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/svg/streak-icon.svg',
                    width: 14,
                    height: 14,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    '12 Spill Streak',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14,
                      height: 1.2,
                      color: AppColors.neutral700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.teal500,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedUser,
                size: 22,
                color: AppColors.white,
                strokeWidth: 1.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayPageGreeting extends StatelessWidget {
  const _PlayPageGreeting({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: 28,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: AppColors.neutral700,
            ),
            children: [
              const TextSpan(text: 'Hey, '),
              TextSpan(
                text: name,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontSize: 28,
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                  color: AppColors.teal500,
                ),
              ),
            ],
          ),
        ),
        Text(
          'Ready to Spill?',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontSize: 28,
            height: 1.2,
            fontWeight: FontWeight.w700,
            color: AppColors.neutral700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Pick a deck and start the conversation.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.neutral400,
          ),
        ),
      ],
    );
  }
}

class _DeckCard extends StatelessWidget {
  const _DeckCard({
    required this.deck,
    required this.isActive,
    required this.onPlay,
  });

  final SpillrDeck deck;
  final bool isActive;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 340;
        final titleSize = isActive
            ? (isCompact ? 34.0 : 50.0)
            : (isCompact ? 30.0 : 40.0);
        final descriptionSize = isActive
            ? (isCompact ? 12.0 : 16.0)
            : (isCompact ? 8.0 : 14.0);
        final cardIconSize = isActive ? (isCompact ? 16.0 : 18.0) : 14.0;
        final cardIconBoxSize = isActive ? (isCompact ? 34.0 : 40.0) : 34.0;
        final bottomGap = isActive ? (isCompact ? 8.0 : 8.0) : 6.0;
        final contentPadding = isActive
            ? EdgeInsets.fromLTRB(
                isCompact ? 14 : 16,
                isCompact ? 12 : 16,
                isCompact ? 14 : 16,
                isCompact ? 12 : 16,
              )
            : const EdgeInsets.fromLTRB(16, 16, 16, 16);

        return Container(
          width: isActive
              ? _PlayPageScreenState._activeCardWidth
              : _PlayPageScreenState._inactiveCardWidth,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isActive
                  ? [
                      deck.backgroundColor,
                      deck.backgroundColor.withValues(alpha: 0.9),
                    ]
                  : [
                      deck.backgroundColor.withValues(alpha: 0.92),
                      deck.backgroundColor,
                    ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: deck.borderColor, width: 2),
          ),
          child: Stack(
            children: [
              const Positioned.fill(child: _DeckCardPattern()),
              Padding(
                padding: contentPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _deckDisplayTitle(deck.title),
                            style: theme.textTheme.headlineLarge?.copyWith(
                              color: AppColors.white,
                              fontSize: titleSize,
                              height: isActive ? 1.0 : 1.05,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Container(
                            width: cardIconBoxSize,
                            height: cardIconBoxSize,
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: HugeIcon(
                                icon: HugeIcons.strokeRoundedCards01,
                                size: cardIconSize,
                                color: deck.backgroundColor,
                                strokeWidth: isActive ? 1.9 : 1.6,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      _deckDisplayDescription(deck.description),
                      maxLines: isActive ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.78),
                        fontSize: descriptionSize,
                        height: 1.35,
                      ),
                    ),
                    if (isActive) ...[
                      SizedBox(height: bottomGap),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          key: ValueKey('play-deck-button-${deck.id}'),
                          onPressed: onPlay,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.white,
                            foregroundColor: deck.backgroundColor,
                            textStyle: const TextStyle(
                              fontSize: 18,
                              height: 1.1,
                              fontWeight: FontWeight.w500,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('Play'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DeckCardPattern extends StatelessWidget {
  const _DeckCardPattern();

  @override
  Widget build(BuildContext context) {
    final borderColor = AppColors.white.withValues(alpha: 0.12);

    return Stack(
      children: [
        Positioned(
          top: 28,
          left: 90,
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          top: 86,
          right: 44,
          child: Transform.rotate(
            angle: math.pi / 8,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(border: Border.all(color: borderColor)),
            ),
          ),
        ),
        Positioned(
          top: 130,
          left: 30,
          child: Transform.rotate(
            angle: math.pi / 4,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(border: Border.all(color: borderColor)),
            ),
          ),
        ),
        Positioned(
          top: 178,
          right: 30,
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedSparkles,
            size: 16,
            color: AppColors.white.withValues(alpha: 0.16),
            strokeWidth: 1.5,
          ),
        ),
        Positioned(
          top: 218,
          left: 82,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }
}

String _deckDisplayTitle(String title) {
  return switch (title) {
    'Deep Spill' => 'Deep\nSpill',
    'No Dead Air' => 'No\nDead\nAir',
    'Chaos Mode' => 'Chaos\nMode',
    'Hot Seat' => 'Hot\nSeat',
    'Date Mode' => 'Date\nMode',
    _ => title,
  };
}

String _deckDisplayDescription(String description) {
  return switch (description) {
    'More meaningful conversation' => 'More meaningful\nconversation',
    'Easy questions to start the vibe' => 'Easy questions to start the\nvibe',
    'Funny, random, and unhinged questions' =>
      'Funny, random, and\nunhinged questions',
    'Bold questions for brave players' => 'Bold questions for\nbrave players',
    'Getting to know someone better' => 'Getting to know\nsomeone better',
    _ => description,
  };
}

final _playDecks = spillrDecks;
