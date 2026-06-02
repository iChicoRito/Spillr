import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/fallback_state_view.dart';
import '../../../../shared/widgets/show_spillr_dialog.dart';
import '../../../../shared/widgets/spillr_confirm_dialog.dart';
import '../../../decks/presentation/providers/deck_providers.dart';
import '../../../game/domain/game_outcome.dart';
import '../../../game/domain/spillr_deck.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../../domain/profile_models.dart';
import '../providers/profile_providers.dart';

class PlayHistoryScreen extends ConsumerWidget {
  const PlayHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(gameHistoryProvider);
    final decksAsync = ref.watch(playableDecksProvider);
    final displayName =
        ref.watch(onboardingProfileProvider).value?.displayName.trim().isNotEmpty == true
        ? ref.watch(onboardingProfileProvider).value!.displayName
        : 'Spiller';

    final deckLookup = <String, SpillrDeck>{
      if (decksAsync.hasValue)
        for (final deck in decksAsync.requireValue) deck.id: deck,
    };

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 393),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _PlayHistoryHeader(),
                  const SizedBox(height: 24),
                  Expanded(
                    child: historyAsync.when(
                      data: (history) {
                        if (history.isEmpty) {
                          return const _EmptyHistoryView();
                        }
                        return SingleChildScrollView(
                          child: _HistoryCard(
                            history: history,
                            deckLookup: deckLookup,
                            displayName: displayName,
                          ),
                        );
                      },
                      loading: () => const FallbackStateView.loading(),
                      error: (error, stackTrace) => const FallbackStateView.error(
                        message: 'Unable to load your play history.',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ClearHistoryButton(
                    enabled: historyAsync.maybeWhen(
                      data: (history) => history.isNotEmpty,
                      orElse: () => false,
                    ),
                    onClear: () => ref
                        .read(profileControllerProvider.notifier)
                        .clearGameHistory(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayHistoryHeader extends StatelessWidget {
  const _PlayHistoryHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          key: const ValueKey('play-history-back'),
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.profile);
            }
          },
          child: const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(
              Icons.chevron_left,
              color: AppColors.neutral700,
              size: 26,
            ),
          ),
        ),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'Your ',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 22,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral700,
                ),
              ),
              TextSpan(
                text: 'Play History',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 22,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.teal500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.history,
    required this.deckLookup,
    required this.displayName,
  });

  final List<GameHistoryItem> history;
  final Map<String, SpillrDeck> deckLookup;
  final String displayName;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < history.length; index++)
          _HistoryRow(
            item: history[index],
            deck: _resolveDeck(history[index].deckId),
            displayName: displayName,
            isFirst: index == 0,
            isLast: index == history.length - 1,
          ),
      ],
    );
  }

  SpillrDeck _resolveDeck(String deckId) {
    return deckLookup[deckId] ?? _fallbackDeck;
  }
}

const _fallbackDeck = SpillrDeck(
  id: 'deleted',
  title: 'Deleted Deck',
  description: '',
  questions: [],
  backgroundColor: AppColors.neutral700,
  borderColor: AppColors.neutral200,
  badgeColor: AppColors.neutral100,
  badgeTextColor: AppColors.neutral700,
  iconColor: AppColors.neutral700,
  icon: HugeIcons.strokeRoundedCards01,
  cardBorderColor: AppColors.neutral200,
);

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.item,
    required this.deck,
    required this.displayName,
    required this.isFirst,
    required this.isLast,
  });

  final GameHistoryItem item;
  final SpillrDeck deck;
  final String displayName;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isFilled = item.outcome == GameOutcome.spilledEverything;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _TimelineColumn(isFirst: isFirst, isLast: isLast, isFilled: isFilled),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  _DeckIcon(deck: deck),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          deck.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: deck.badgeTextColor,
                            fontSize: 16,
                            height: 1.2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.outcome.statusLabel(displayName),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.neutral400,
                            fontSize: 13,
                            height: 1.2,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _formatTime(item.completedAt),
                    style: const TextStyle(
                      color: AppColors.neutral400,
                      fontSize: 12,
                      height: 1.2,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineColumn extends StatelessWidget {
  const _TimelineColumn({
    required this.isFirst,
    required this.isLast,
    required this.isFilled,
  });

  final bool isFirst;
  final bool isLast;
  final bool isFilled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 16,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Container(
                width: 2,
                color: isFirst ? Colors.transparent : AppColors.teal200,
              ),
            ),
          ),
          _TimelineDot(isFilled: isFilled),
          Expanded(
            child: Center(
              child: Container(
                width: 2,
                color: isLast ? Colors.transparent : AppColors.teal200,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineDot extends StatelessWidget {
  const _TimelineDot({required this.isFilled});

  final bool isFilled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isFilled ? AppColors.teal500 : AppColors.white,
        border: Border.all(color: AppColors.teal500, width: 1),
      ),
    );
  }
}

class _DeckIcon extends StatelessWidget {
  const _DeckIcon({required this.deck});

  final SpillrDeck deck;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: deck.badgeColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: HugeIcon(
          icon: deck.icon,
          color: deck.iconColor,
          size: 20,
          strokeWidth: 1.8,
        ),
      ),
    );
  }
}

class _EmptyHistoryView extends StatelessWidget {
  const _EmptyHistoryView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.teal100,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedClock01,
                  color: AppColors.teal500,
                  size: 28,
                  strokeWidth: 1.8,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No games yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.neutral700,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Play a deck and your finished games will show up here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.neutral400,
                fontSize: 14,
                height: 1.3,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ClearHistoryButton extends StatelessWidget {
  const _ClearHistoryButton({required this.enabled, required this.onClear});

  final bool enabled;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        key: const ValueKey('play-history-clear-button'),
        onPressed: enabled ? () => _confirmClear(context) : null,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.teal500,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.neutral200,
          disabledForegroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        icon: const HugeIcon(
          icon: HugeIcons.strokeRoundedDelete02,
          color: AppColors.white,
          size: 20,
          strokeWidth: 1.8,
        ),
        label: const Text('Clear History'),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) {
    return showSpillrDialog<void>(
      context: context,
      barrierColor: AppColors.black.withValues(alpha: 0.34),
      builder: (dialogContext) {
        return SpillrConfirmDialog(
          title: 'Clear Play History?',
          message:
              'This will permanently remove all of your saved game records.',
          confirmLabel: 'Yes, Clear',
          cancelLabel: 'Cancel',
          onConfirm: () {
            Navigator.of(dialogContext).pop();
            onClear();
          },
        );
      },
    );
  }
}

String _formatTime(DateTime dateTime) {
  final localTime = dateTime.toLocal();
  var hour = localTime.hour % 12;
  if (hour == 0) {
    hour = 12;
  }
  final minute = localTime.minute.toString().padLeft(2, '0');
  final period = localTime.hour < 12 ? 'am' : 'pm';
  return '$hour:$minute$period';
}
