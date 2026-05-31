import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/theme/app_colors.dart';

enum SpillrBottomNavTab { decks, play, profile }

class SpillrBottomNavigation extends StatelessWidget {
  const SpillrBottomNavigation({
    required this.selectedTab,
    required this.onDecksTap,
    required this.onPlayTap,
    this.onProfileTap,
    super.key,
  });

  final SpillrBottomNavTab selectedTab;
  final VoidCallback onDecksTap;
  final VoidCallback onPlayTap;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      _BottomNavItemData(
        key: const ValueKey('bottom-nav-decks'),
        tab: SpillrBottomNavTab.decks,
        label: 'Decks',
        icon: HugeIcons.strokeRoundedCards01,
        onTap: onDecksTap,
      ),
      _BottomNavItemData(
        key: const ValueKey('bottom-nav-play'),
        tab: SpillrBottomNavTab.play,
        label: 'Play Cards',
        icon: HugeIcons.strokeRoundedPlay,
        onTap: onPlayTap,
      ),
      _BottomNavItemData(
        key: const ValueKey('bottom-nav-profile'),
        tab: SpillrBottomNavTab.profile,
        label: 'Profile',
        icon: HugeIcons.strokeRoundedUser,
        onTap: onProfileTap,
      ),
    ];
    final currentIndex = tabs.indexWhere((item) => item.tab == selectedTab);

    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = constraints.maxWidth / tabs.length;
          const indicatorWidth = 34.0;
          final indicatorLeft =
              (tabWidth * currentIndex) + (tabWidth / 2) - (indicatorWidth / 2);

          return Container(
            height: 80,
            color: AppColors.white,
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  left: indicatorLeft,
                  top: 6,
                  child: Container(
                    width: indicatorWidth,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppColors.teal500,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (final item in tabs)
                      Expanded(
                        child: _BottomNavItem(
                          key: item.key,
                          label: item.label,
                          icon: item.icon,
                          selected: item.tab == selectedTab,
                          onTap: item.onTap,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _BottomNavItemData {
  const _BottomNavItemData({
    required this.key,
    required this.tab,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final ValueKey<String> key;
  final SpillrBottomNavTab tab;
  final String label;
  final List<List<dynamic>> icon;
  final VoidCallback? onTap;
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.label,
    required this.icon,
    required this.selected,
    this.onTap,
    super.key,
  });

  final String label;
  final List<List<dynamic>> icon;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.teal500 : AppColors.neutral300;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            HugeIcon(icon: icon, size: 26, color: color, strokeWidth: 1.9),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
