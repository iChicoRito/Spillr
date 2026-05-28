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
    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.neutral100),
      ),
      child: Row(
        children: [
          Expanded(
            child: _BottomNavItem(
              key: const ValueKey('bottom-nav-decks'),
              label: 'Decks',
              icon: HugeIcons.strokeRoundedCards01,
              selected: selectedTab == SpillrBottomNavTab.decks,
              onTap: onDecksTap,
            ),
          ),
          Expanded(
            child: _BottomNavItem(
              key: const ValueKey('bottom-nav-play'),
              label: 'Play Cards',
              icon: HugeIcons.strokeRoundedPlay,
              selected: selectedTab == SpillrBottomNavTab.play,
              onTap: onPlayTap,
            ),
          ),
          Expanded(
            child: _BottomNavItem(
              key: const ValueKey('bottom-nav-profile'),
              label: 'Profile',
              icon: HugeIcons.strokeRoundedUser,
              selected: selectedTab == SpillrBottomNavTab.profile,
              onTap: onProfileTap,
            ),
          ),
        ],
      ),
    );
  }
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
      borderRadius: BorderRadius.circular(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          HugeIcon(icon: icon, size: 24, color: color, strokeWidth: 1.9),
          const SizedBox(height: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              color: color,
              fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
