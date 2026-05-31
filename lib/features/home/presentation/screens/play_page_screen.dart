import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/fallback_state_view.dart';
import '../../../decks/presentation/providers/deck_providers.dart';
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
  static const _carouselViewportFraction = 0.78;
  static const _cardWidthFactor = 0.84;
  static const _activeCardHeight = 456.0;
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

    final deckCount = ref.read(playableDecksProvider).asData?.value.length ?? 0;
    if (deckCount == 0) {
      return;
    }

    final page = _pageController.page ?? _activeIndex.toDouble();
    final nextIndex = page.round().clamp(0, deckCount - 1);
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
    final playableDecksAsync = ref.watch(playableDecksProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) {
            if (playableDecksAsync.hasError) {
              return const FallbackStateView.error(
                message: 'Unable to load your decks.',
              );
            }
            if (playableDecksAsync.isLoading) {
              return const FallbackStateView.loading();
            }

            final decks = playableDecksAsync.requireValue;
            if (decks.isEmpty) {
              return const FallbackStateView.error(
                message: 'Create a deck to start playing.',
              );
            }

            final name = profile?.displayName ?? 'Spiller';

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 393),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cardWidth = math.min(
                      332.0,
                      constraints.maxWidth * _cardWidthFactor,
                    );
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
                                    itemCount: decks.length,
                                    itemBuilder: (context, index) {
                                      final deck = decks[index];
                                      final delta = (_currentPage - index)
                                          .abs();
                                      final activation = (1 - delta).clamp(
                                        0.0,
                                        1.0,
                                      );
                                      final scale = (1 - (delta * 0.14)).clamp(
                                        0.88,
                                        1.0,
                                      );
                                      final opacity = (1 - (delta * 0.22))
                                          .clamp(0.68, 1.0);
                                      final verticalInset = ui.lerpDouble(
                                        _inactiveVerticalInset,
                                        0,
                                        activation,
                                      )!;

                                      return Padding(
                                        padding: EdgeInsets.only(
                                          top: verticalInset,
                                          bottom: verticalInset,
                                        ),
                                        child: Transform.scale(
                                          scale: scale,
                                          child: Opacity(
                                            opacity: opacity,
                                            child: _DeckCard(
                                              deck: deck,
                                              isActive: index == _activeIndex,
                                              activation: activation,
                                              width: cardWidth,
                                              onPlay: () {
                                                context.go(
                                                  '${AppRoutes.preparation}/${deck.id}',
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 26),
                              ),
                            ],
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
    required this.activation,
    required this.width,
    required this.onPlay,
  });

  final SpillrDeck deck;
  final bool isActive;
  final double activation;
  final double width;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPlay = deck.questions.isNotEmpty;
    final titleWords = _deckTitleWords(deck.title);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxHeight < 340;
        final titleSize = _deckTitleFontSize(
          wordCount: titleWords.length,
          titleLength: deck.title.trim().length,
          activation: activation,
          isCompact: isCompact,
        );
        final detailOpacity = Curves.easeOutCubic.transform(
          _normalizedProgress(activation, start: 0.34, end: 1),
        );
        final buttonOpacity = Curves.easeOutCubic.transform(
          _normalizedProgress(activation, start: 0.72, end: 1),
        );
        final extraTitleLines = math.max(0, titleWords.length - 2);
        final activeDetailLift =
            ui.lerpDouble(0, isCompact ? 34 : 38, activation)! +
            (extraTitleLines * (isCompact ? 24.0 : 28.0) * activation);
        final topArcHeight = ui.lerpDouble(
          54,
          isCompact ? 58 : 70,
          activation,
        )!;
        final topArcHiddenTop = -(topArcHeight + 12);
        final topArcTop = ui.lerpDouble(-14, topArcHiddenTop, activation)!;
        final topArcOpacity =
            1 -
            Curves.easeInCubic.transform(
              _normalizedProgress(activation, start: 0.46, end: 1),
            );
        final bottomArcHeight = ui.lerpDouble(
          88,
          isCompact ? 128 : 148,
          activation,
        )!;
        final bottomArcBottom = ui.lerpDouble(-34, -10, activation)!;
        final badgeSize = ui.lerpDouble(48, isCompact ? 58 : 64, activation)!;
        final activeBadgeBottom =
            bottomArcBottom + bottomArcHeight - (badgeSize / 2);
        final badgeBottom = ui.lerpDouble(18, activeBadgeBottom, activation)!;
        final bottomArcColor = Color.lerp(
          AppColors.white.withValues(alpha: 0.96),
          deck.badgeColor,
          Curves.easeOutCubic.transform(activation),
        )!;
        final activeTextColor = Color.lerp(
          AppColors.white.withValues(alpha: 0.8),
          AppColors.white,
          detailOpacity,
        )!;
        final maxTitleWidth = math.max(0.0, width - 48);

        return Container(
          key: ValueKey('play-deck-shell-${deck.id}'),
          width: width,
          decoration: BoxDecoration(
            color: deck.backgroundColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: deck.borderColor, width: 2),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              children: [
                Positioned(
                  top: topArcTop,
                  left: 8,
                  right: 8,
                  child: Opacity(
                    opacity: topArcOpacity,
                    child: DecoratedBox(
                      key: ValueKey('play-deck-top-arc-${deck.id}'),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.elliptical(width, topArcHeight),
                        ),
                      ),
                      child: SizedBox(height: topArcHeight),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: bottomArcBottom,
                  child: DecoratedBox(
                    key: ValueKey('play-deck-bottom-arc-${deck.id}'),
                    decoration: BoxDecoration(
                      color: bottomArcColor,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.elliptical(240, 132),
                      ),
                    ),
                    child: SizedBox(height: bottomArcHeight),
                  ),
                ),
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      isCompact ? 18 : 22,
                      isCompact ? 22 : 28,
                      isCompact ? 18 : 22,
                      isCompact ? 18 : 22,
                    ),
                    child: Align(
                      key: ValueKey('play-deck-card-main-center-${deck.id}'),
                      alignment: const Alignment(0, -0.08),
                      child: Opacity(
                        key: ValueKey('play-deck-detail-opacity-${deck.id}'),
                        opacity: detailOpacity,
                        child: Transform.translate(
                          offset: Offset(
                            0,
                            ui.lerpDouble(
                              18,
                              -activeDetailLift,
                              detailOpacity,
                            )!,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: maxTitleWidth,
                                height: titleSize * titleWords.length * 1.08,
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.center,
                                  child: Text(
                                    _deckDisplayTitle(deck.title),
                                    textAlign: TextAlign.center,
                                    maxLines: titleWords.length,
                                    softWrap: true,
                                    style: theme.textTheme.headlineLarge
                                        ?.copyWith(
                                          color: activeTextColor,
                                          fontSize: titleSize,
                                          height: 1.0,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                              ),
                              SizedBox(height: isCompact ? 12 : 18),
                              Container(
                                key: ValueKey(
                                  'play-deck-count-pill-${deck.id}',
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  'x${deck.questions.length} Cards',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: deck.iconColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: badgeBottom,
                  child: Center(
                    child: Container(
                      key: ValueKey('play-deck-bottom-icon-badge-${deck.id}'),
                      width: badgeSize,
                      height: badgeSize,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: deck.iconColor, width: 2.4),
                      ),
                      child: Center(
                        child: HugeIcon(
                          icon: deck.icon,
                          size: ui.lerpDouble(18, 28, activation)!,
                          color: deck.iconColor,
                          strokeWidth: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                if (isActive)
                  Positioned(
                    left: isCompact ? 18 : 20,
                    right: isCompact ? 18 : 20,
                    bottom: isCompact ? 24 : 28,
                    child: Opacity(
                      opacity: buttonOpacity,
                      child: Transform.translate(
                        offset: Offset(0, ui.lerpDouble(16, 0, buttonOpacity)!),
                        child: SizedBox(
                          width: double.infinity,
                          height: isCompact ? 54 : 56,
                          child: FilledButton(
                            key: ValueKey('play-deck-button-${deck.id}'),
                            onPressed: canPlay ? onPlay : null,
                            style: FilledButton.styleFrom(
                              elevation: 0,
                              backgroundColor: deck.backgroundColor,
                              foregroundColor: AppColors.white,
                              disabledBackgroundColor: deck.backgroundColor
                                  .withValues(alpha: 0.58),
                              disabledForegroundColor: AppColors.white
                                  .withValues(alpha: 0.78),
                              textStyle: const TextStyle(
                                fontSize: 18,
                                height: 1.1,
                                fontWeight: FontWeight.w500,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(22),
                              ),
                            ),
                            child: Text(canPlay ? 'Play' : 'Add Tea First'),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

List<String> _deckTitleWords(String title) {
  final words = title
      .trim()
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);

  return words.isEmpty ? [title] : words;
}

double _deckTitleFontSize({
  required int wordCount,
  required int titleLength,
  required double activation,
  required bool isCompact,
}) {
  final activeBaseSize = isCompact ? 54.0 : 60.0;
  final inactiveBaseSize = isCompact ? 30.0 : 38.0;
  final activeMinimumSize = isCompact ? 24.0 : 28.0;
  final inactiveMinimumSize = isCompact ? 20.0 : 24.0;
  final activeLengthReduction = math.max(0, titleLength - 11) * 1.25;
  final activeWordReduction = math.max(0, wordCount - 2) * 12.0;
  final activeSize = wordCount <= 3
      ? activeBaseSize
      : math.max(activeMinimumSize, activeBaseSize - ((wordCount - 3) * 16.0));
  final inactiveSize = wordCount <= 2
      ? inactiveBaseSize
      : math.max(
          inactiveMinimumSize,
          inactiveBaseSize - ((wordCount - 2) * 8.0),
        );

  final adjustedActiveSize = math.max(
    activeMinimumSize,
    activeSize - activeWordReduction - activeLengthReduction,
  );

  return ui.lerpDouble(inactiveSize, adjustedActiveSize, activation)!;
}

double _normalizedProgress(
  double value, {
  required double start,
  required double end,
}) {
  if (value <= start) {
    return 0;
  }

  if (value >= end) {
    return 1;
  }

  return (value - start) / (end - start);
}

String _deckDisplayTitle(String title) {
  return _deckTitleWords(title).join('\n');
}
