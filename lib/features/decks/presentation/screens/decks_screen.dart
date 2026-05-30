import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/fallback_state_view.dart';
import '../../../../shared/widgets/spillr_bottom_navigation.dart';
import '../../../../shared/widgets/spillr_bottom_sheet_scaffold.dart';
import '../../../../shared/widgets/spillr_confirm_dialog.dart';
import '../../domain/deck_catalog.dart';
import '../providers/deck_providers.dart';

class DecksScreen extends ConsumerWidget {
  const DecksScreen({super.key});

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
                          child: _DecksHeader(
                            selectedFilter: selectedFilter,
                            filterChips: filterChips,
                          ),
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
                                const SizedBox(height: 10),
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
  const _DecksHeader({
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
        Wrap(
          spacing: 10,
          runSpacing: 2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Create your',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 24,
                height: 1.15,
                fontWeight: FontWeight.w700,
                color: AppColors.neutral700,
              ),
            ),
            Text(
              'Custom Deck',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 24,
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
            children: filterChips
                .map(
                  (filter) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _DeckFilterChip(
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
      BuiltInDeckFilterSelection(filter: final selectedFilter) =>
        filter is BuiltInDeckFilterChip && filter.filter == selectedFilter,
      CustomDeckFilterSelection(:final deckId) =>
        filter is CustomDeckFilterChip && filter.deckId == deckId,
    };
  }

  DeckFilterSelection _selectionFor(DeckFilterChip filter) {
    return switch (filter) {
      BuiltInDeckFilterChip(:final filter) =>
        DeckFilterSelection.builtIn(filter),
      CustomDeckFilterChip(:final deckId) => DeckFilterSelection.custom(deckId),
    };
  }
}

class _DeckFilterChip extends StatelessWidget {
  const _DeckFilterChip({
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
      key: ValueKey(
        filter.id,
      ),
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

class _DeckRow extends ConsumerWidget {
  const _DeckRow({required this.item});

  final DeckListItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void navigateToQuestions() {
      context.push('${AppRoutes.decks}/${item.id}/questions');
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPressStart: item.isBuiltIn
          ? null
          : (details) => _showDeckContextMenu(
              context: context,
              item: item,
              globalPosition: details.globalPosition,
            ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('decks-row-${item.id}'),
          borderRadius: BorderRadius.circular(24),
          onTap: navigateToQuestions,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.neutral100),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: item.avatarColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: HugeIcon(
                      icon: item.icon,
                      color: AppColors.white,
                      size: 24,
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
                          fontWeight: FontWeight.w600,
                          color: AppColors.neutral700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'x${item.cardCount} Cards',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.neutral400,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: ValueKey('decks-row-arrow-${item.id}'),
                  onPressed: navigateToQuestions,
                  icon: const Icon(
                    Icons.chevron_right,
                    color: AppColors.neutral400,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeckContextMenu({
    required BuildContext context,
    required DeckListItem item,
    required Offset globalPosition,
  }) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(globalPosition, globalPosition),
      Offset.zero & overlay.size,
    );

    final action = await showMenu<_DeckAction>(
      context: context,
      position: position,
      color: AppColors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: [
        const PopupMenuItem<_DeckAction>(
          value: _DeckAction.edit,
          child: Text('Edit Deck'),
        ),
        const PopupMenuItem<_DeckAction>(
          value: _DeckAction.delete,
          child: Text(
            'Delete',
            style: TextStyle(color: AppColors.red500),
          ),
        ),
      ],
    );

    if (action == null || !context.mounted) {
      return;
    }

    if (action == _DeckAction.edit) {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        barrierColor: AppColors.black.withValues(alpha: 0.38),
        builder: (context) => _EditDeckSheet(item: item),
      );
    } else {
      showDialog<void>(
        context: context,
        barrierColor: AppColors.black.withValues(alpha: 0.34),
        builder: (context) => _DeleteDeckDialog(deckId: item.id),
      );
    }
  }
}

enum _DeckAction { edit, delete }

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

    if (mounted && !ref.read(deckCreationControllerProvider).hasError) {
      ref.read(deckFilterProvider.notifier).select(
        const DeckFilterSelection.all(),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final creationState = ref.watch(deckCreationControllerProvider);

    return SpillrBottomSheetScaffold(
      title: 'Create Deck',
      primaryActionLabel: 'Create Deck',
      primaryActionKey: const ValueKey('decks-sheet-submit-button'),
      onPrimaryAction: _submit,
      isPrimaryActionEnabled: !creationState.isLoading,
      isPrimaryActionLoading: creationState.isLoading,
      child: Form(
        key: _formKey,
        child: _DeckFormFields(
          nameController: _nameController,
          selectedIcon: _selectedIcon,
          selectedColor: _selectedColor,
          enabled: !creationState.isLoading,
          onIconSelected: (icon) => setState(() => _selectedIcon = icon),
          onColorSelected: (color) => setState(() => _selectedColor = color),
        ),
      ),
    );
  }
}

class _EditDeckSheet extends ConsumerStatefulWidget {
  const _EditDeckSheet({required this.item});

  final DeckListItem item;

  @override
  ConsumerState<_EditDeckSheet> createState() => _EditDeckSheetState();
}

class _EditDeckSheetState extends ConsumerState<_EditDeckSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late CustomDeckIconKey _selectedIcon;
  late CustomDeckColorKey _selectedColor;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.title);
    _selectedIcon = widget.item.customIconKey ?? CustomDeckIconKey.leaf;
    _selectedColor = widget.item.customColorKey ?? CustomDeckColorKey.teal;
  }

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
        .read(customDeckMutationControllerProvider.notifier)
        .updateDeck(
          deckId: widget.item.id,
          rawName: _nameController.text,
          iconKey: _selectedIcon,
          colorKey: _selectedColor,
        );

    if (mounted && !ref.read(customDeckMutationControllerProvider).hasError) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mutationState = ref.watch(customDeckMutationControllerProvider);

    return SpillrBottomSheetScaffold(
      title: 'Edit Deck',
      primaryActionLabel: 'Save',
      primaryActionKey: const ValueKey('decks-sheet-submit-button'),
      onPrimaryAction: _submit,
      isPrimaryActionEnabled: !mutationState.isLoading,
      isPrimaryActionLoading: mutationState.isLoading,
      child: Form(
        key: _formKey,
        child: _DeckFormFields(
          nameController: _nameController,
          selectedIcon: _selectedIcon,
          selectedColor: _selectedColor,
          enabled: !mutationState.isLoading,
          onIconSelected: (icon) => setState(() => _selectedIcon = icon),
          onColorSelected: (color) => setState(() => _selectedColor = color),
        ),
      ),
    );
  }
}

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

class _DeckFormFields extends StatelessWidget {
  const _DeckFormFields({
    required this.nameController,
    required this.selectedIcon,
    required this.selectedColor,
    required this.enabled,
    required this.onIconSelected,
    required this.onColorSelected,
  });

  final TextEditingController nameController;
  final CustomDeckIconKey selectedIcon;
  final CustomDeckColorKey selectedColor;
  final bool enabled;
  final ValueChanged<CustomDeckIconKey> onIconSelected;
  final ValueChanged<CustomDeckColorKey> onColorSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          controller: nameController,
          enabled: enabled,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a deck name.';
            }
            return null;
          },
          decoration: const InputDecoration(hintText: 'e.g Weird Humor'),
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
                (constraints.maxWidth - (spacing * (crossAxisCount - 1))) /
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
                        selected: iconKey == selectedIcon,
                        selectedColor: selectedColor.color,
                        onTap: enabled ? () => onIconSelected(iconKey) : null,
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
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: CustomDeckColorKey.values
                .map(
                  (colorKey) => Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: _SelectableColorButton(
                        colorKey: colorKey,
                        selected: colorKey == selectedColor,
                        onTap: enabled ? () => onColorSelected(colorKey) : null,
                      ),
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
