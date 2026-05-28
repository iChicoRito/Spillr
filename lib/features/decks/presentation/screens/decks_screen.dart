import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/fallback_state_view.dart';
import '../../../../shared/widgets/spillr_bottom_navigation.dart';
import '../../domain/deck_catalog.dart';
import '../providers/deck_providers.dart';

class DecksScreen extends ConsumerWidget {
  const DecksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedFilter = ref.watch(deckFilterProvider);
    final deckListAsync = ref.watch(deckListProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 393),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    slivers: [
                      const SliverToBoxAdapter(child: SizedBox(height: 28)),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverToBoxAdapter(
                          child: _DecksHeader(selectedFilter: selectedFilter),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                        sliver: deckListAsync.when(
                          data: (items) => SliverList.separated(
                            itemCount: items.length,
                            itemBuilder: (context, index) =>
                                _DeckRow(item: items[index]),
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 16),
                          ),
                          loading: () => const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.only(top: 64),
                              child: FallbackStateView.loading(),
                            ),
                          ),
                          error: (error, stackTrace) =>
                              const SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.only(top: 64),
                                  child: FallbackStateView.error(
                                    message: 'Unable to load your decks.',
                                  ),
                                ),
                              ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 220)),
                    ],
                  ),
                ),
                Positioned(
                  right: 16,
                  bottom: 108,
                  child: FilledButton.icon(
                    key: const ValueKey('decks-open-create-sheet-button'),
                    onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      barrierColor: AppColors.black.withValues(alpha: 0.38),
                      builder: (context) => const _CreateDeckSheet(),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.teal500,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 20,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        height: 1.1,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    icon: const HugeIcon(
                      icon: HugeIcons.strokeRoundedAdd01,
                      color: AppColors.white,
                      size: 24,
                      strokeWidth: 1.8,
                    ),
                    label: const Text('Create Deck'),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 10,
                  child: SpillrBottomNavigation(
                    selectedTab: SpillrBottomNavTab.decks,
                    onDecksTap: () {},
                    onPlayTap: () => context.go(AppRoutes.home),
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

class _DecksHeader extends ConsumerWidget {
  const _DecksHeader({required this.selectedFilter});

  final DeckFilter selectedFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Create your',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 28,
                height: 1.15,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral700,
              ),
            ),
            Text(
              'Custom Deck',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 28,
                height: 1.15,
                fontWeight: FontWeight.w700,
                color: AppColors.teal500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: DeckFilter.values
                .map(
                  (filter) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: _DeckFilterChip(
                      filter: filter,
                      selected: filter == selectedFilter,
                      onTap: () =>
                          ref.read(deckFilterProvider.notifier).select(filter),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ],
    );
  }
}

class _DeckFilterChip extends StatelessWidget {
  const _DeckFilterChip({
    required this.filter,
    required this.selected,
    required this.onTap,
  });

  final DeckFilter filter;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: ValueKey(
        filter == DeckFilter.all
            ? 'decks-filter-all'
            : 'decks-filter-${filter.builtInDeckId}',
      ),
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
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
            color: selected ? AppColors.white : AppColors.neutral400,
          ),
        ),
      ),
    );
  }
}

class _DeckRow extends StatelessWidget {
  const _DeckRow({required this.item});

  final DeckListItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.neutral100),
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: item.avatarColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: HugeIcon(
                icon: item.icon,
                color: AppColors.white,
                size: 34,
                strokeWidth: 1.8,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 18,
                    color: AppColors.neutral700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'x${item.cardCount} Cards',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: AppColors.neutral400,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton<_DeckMenuAction>(
            key: ValueKey('decks-row-menu-${item.id}'),
            tooltip: '',
            color: AppColors.white,
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onSelected: (_) {},
            itemBuilder: (context) => [
              PopupMenuItem<_DeckMenuAction>(
                value: _DeckMenuAction.edit,
                child: Text(
                  'Edit Deck',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.neutral700),
                ),
              ),
              PopupMenuItem<_DeckMenuAction>(
                value: _DeckMenuAction.delete,
                child: Text(
                  'Delete',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.red500),
                ),
              ),
            ],
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: HugeIcon(
                icon: HugeIcons.strokeRoundedArrowRight01,
                color: AppColors.neutral400,
                size: 22,
                strokeWidth: 1.8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _DeckMenuAction { edit, delete }

class _CreateDeckSheet extends ConsumerStatefulWidget {
  const _CreateDeckSheet();

  @override
  ConsumerState<_CreateDeckSheet> createState() => _CreateDeckSheetState();
}

class _CreateDeckSheetState extends ConsumerState<_CreateDeckSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  CustomDeckIconKey _selectedIcon = CustomDeckIconKey.leaf;
  CustomDeckColorKey _selectedColor = CustomDeckColorKey.teal;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    await ref
        .read(deckCreationControllerProvider.notifier)
        .createDeck(
          rawName: _nameController.text,
          iconKey: _selectedIcon,
          colorKey: _selectedColor,
        );

    final state = ref.read(deckCreationControllerProvider);
    if (mounted && !state.hasError) {
      ref.read(deckFilterProvider.notifier).select(DeckFilter.all);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final creationState = ref.watch(deckCreationControllerProvider);
    final isSaving = creationState.isLoading;

    return Padding(
      padding: EdgeInsets.only(
        top: 80,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: ColoredBox(
          color: AppColors.white,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 116,
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.neutral200,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Create Deck',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppColors.neutral700,
                            ),
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Deck Name',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.neutral700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        key: const ValueKey('decks-sheet-name-field'),
                        controller: _nameController,
                        enabled: !isSaving,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a deck name.';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          hintText: 'e.g Weird Humor',
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Icon',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.neutral700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          const crossAxisCount = 7;
                          const spacing = 8.0;
                          final itemSize =
                              (constraints.maxWidth -
                                      (spacing * (crossAxisCount - 1))) /
                                  crossAxisCount;

                          return Wrap(
                            spacing: spacing,
                            runSpacing: spacing,
                            children: CustomDeckIconKey.values
                                .map(
                                  (iconKey) => SizedBox(
                                    width: itemSize,
                                    height: itemSize,
                                    child: _SelectableIconButton(
                                      iconKey: iconKey,
                                      selected: iconKey == _selectedIcon,
                                      selectedColor: _selectedColor.color,
                                      onTap: isSaving
                                          ? null
                                          : () => setState(
                                              () => _selectedIcon = iconKey,
                                            ),
                                    ),
                                  ),
                                )
                                .toList(growable: false),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Color Selection',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.neutral700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: CustomDeckColorKey.values
                            .map(
                              (colorKey) => _SelectableColorButton(
                                colorKey: colorKey,
                                selected: colorKey == _selectedColor,
                                onTap: isSaving
                                    ? null
                                    : () => setState(
                                        () => _selectedColor = colorKey,
                                      ),
                              ),
                            )
                            .toList(growable: false),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 62,
                        child: FilledButton(
                          key: const ValueKey('decks-sheet-submit-button'),
                          onPressed: isSaving ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.teal500,
                            foregroundColor: AppColors.white,
                            disabledBackgroundColor: AppColors.teal500
                                .withValues(alpha: 0.45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 18,
                              height: 1.1,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          child: isSaving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.white,
                                    ),
                                  ),
                                )
                              : const Text('Create Deck'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectableIconButton extends StatelessWidget {
  const _SelectableIconButton({
    required this.iconKey,
    required this.selected,
    required this.selectedColor,
    this.onTap,
  });

  final CustomDeckIconKey iconKey;
  final bool selected;
  final Color selectedColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: selected ? selectedColor : AppColors.neutral100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.neutral100),
        ),
        child: Center(
          child: HugeIcon(
            icon: iconKey.icon,
            color: selected ? AppColors.white : AppColors.neutral400,
            size: 24,
            strokeWidth: 1.7,
          ),
        ),
      ),
    );
  }
}

class _SelectableColorButton extends StatelessWidget {
  const _SelectableColorButton({
    required this.colorKey,
    required this.selected,
    this.onTap,
  });

  final CustomDeckColorKey colorKey;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: colorKey.color,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white, width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: selected
            ? const Center(
                child: Text(
                  '✓',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
