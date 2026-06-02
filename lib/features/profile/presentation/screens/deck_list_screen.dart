import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/fallback_state_view.dart';
import '../../../../shared/widgets/show_spillr_dialog.dart';
import '../../../../shared/widgets/spillr_confirm_dialog.dart';
import '../../../decks/domain/deck_catalog.dart';
import '../../../decks/presentation/providers/deck_providers.dart';

class DeckListScreen extends ConsumerWidget {
  const DeckListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(deckFilterProvider);
    final filterChips = ref.watch(deckFilterChipsProvider);
    final deckListAsync = ref.watch(deckListProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 393),
            child: CustomScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                    child: _DeckListHeader(
                      selectedFilter: selectedFilter,
                      filterChips: filterChips,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                  sliver: deckListAsync.when(
                    data: (items) => items.isEmpty
                        ? const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 64),
                              child: Center(
                                child: Text(
                                  'No decks yet.',
                                  style: TextStyle(
                                    color: AppColors.neutral400,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : SliverToBoxAdapter(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: AppColors.neutral100,
                                ),
                              ),
                              child: Column(
                                children: [
                                  for (var i = 0; i < items.length; i++) ...[
                                    if (i > 0)
                                      const Divider(
                                        height: 1,
                                        thickness: 1,
                                        color: AppColors.neutral100,
                                        indent: 16,
                                        endIndent: 16,
                                      ),
                                    _DeckListItem(item: items[i]),
                                  ],
                                ],
                              ),
                            ),
                          ),
                    loading: () => const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 64),
                        child: FallbackStateView.loading(),
                      ),
                    ),
                    error: (_, _) => const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 64),
                        child: FallbackStateView.error(
                          message: 'Unable to load your decks.',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Header: back button + two-tone title + horizontal filter chips
// ---------------------------------------------------------------------------

class _DeckListHeader extends ConsumerWidget {
  const _DeckListHeader({
    required this.selectedFilter,
    required this.filterChips,
  });

  final DeckFilterSelection selectedFilter;
  final List<DeckFilterChip> filterChips;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'List of ',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 24,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.neutral700,
                ),
              ),
              TextSpan(
                text: 'Created Decks',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 24,
                  height: 1.15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.teal500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filterChips
                .map(
                  (filter) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _DeckListFilterChip(
                      filter: filter,
                      selected: _isSelected(filter, selectedFilter),
                      onTap: () => ref
                          .read(deckFilterProvider.notifier)
                          .select(_selectionFor(filter)),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ],
    );
  }

  bool _isSelected(DeckFilterChip filter, DeckFilterSelection selected) {
    return switch (selected) {
      AllDeckFilterSelection() =>
        filter is BuiltInDeckFilterChip && filter.filter == DeckFilter.all,
      BuiltInDeckFilterSelection(filter: final f) =>
        filter is BuiltInDeckFilterChip && filter.filter == f,
      CustomDeckFilterSelection(:final deckId) =>
        filter is CustomDeckFilterChip && filter.deckId == deckId,
    };
  }

  DeckFilterSelection _selectionFor(DeckFilterChip filter) {
    return switch (filter) {
      BuiltInDeckFilterChip(:final filter) =>
        DeckFilterSelection.builtIn(filter),
      CustomDeckFilterChip(:final deckId) =>
        DeckFilterSelection.custom(deckId),
    };
  }
}

// ---------------------------------------------------------------------------
// Filter chip — pill shape, teal when active
// ---------------------------------------------------------------------------

class _DeckListFilterChip extends StatelessWidget {
  const _DeckListFilterChip({
    required this.filter,
    required this.selected,
    required this.onTap,
  });

  final DeckFilterChip filter;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey('deck-list-filter-${filter.id}'),
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal500 : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.teal500 : AppColors.neutral100,
          ),
        ),
        child: Text(
          filter.label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: selected ? AppColors.white : AppColors.neutral400,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Deck row — colored title, card count, 3-dot popup menu
// ---------------------------------------------------------------------------

enum _DeckListAction { export, delete }

class _DeckListItem extends ConsumerWidget {
  const _DeckListItem({required this.item});

  final DeckListItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    color: item.avatarColor,
                    fontSize: 18,
                    height: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'x${item.cardCount} Cards',
                  style: const TextStyle(
                    color: AppColors.neutral400,
                    fontSize: 14,
                    height: 1.2,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<_DeckListAction>(
            key: ValueKey('deck-list-menu-${item.id}'),
            color: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onSelected: (action) {
              if (action == _DeckListAction.delete) {
                showSpillrDialog<void>(
                  context: context,
                  barrierColor: AppColors.black.withValues(alpha: 0.34),
                  builder: (ctx) => _DeleteDeckDialog(deckId: item.id),
                );
              }
              // Export is intentionally a no-op
            },
            itemBuilder: (context) => [
              const PopupMenuItem<_DeckListAction>(
                value: _DeckListAction.export,
                child: Text('Export Deck'),
              ),
              if (!item.isBuiltIn)
                const PopupMenuItem<_DeckListAction>(
                  value: _DeckListAction.delete,
                  child: Text(
                    'Delete',
                    style: TextStyle(color: AppColors.red500),
                  ),
                ),
            ],
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Icon(
                Icons.more_vert,
                size: 20,
                color: AppColors.neutral400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Delete confirmation dialog
// ---------------------------------------------------------------------------

class _DeleteDeckDialog extends ConsumerWidget {
  const _DeleteDeckDialog({required this.deckId});

  final String deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SpillrConfirmDialog(
      title: 'Delete This Deck?',
      message: 'This deck and its tea will be removed.',
      onConfirm: () async {
        await ref
            .read(customDeckMutationControllerProvider.notifier)
            .deleteDeck(deckId);
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
    );
  }
}
