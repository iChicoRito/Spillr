import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../shared/widgets/spillr_bottom_navigation.dart';
import 'app_router.dart';

class SpillrTabShell extends StatelessWidget {
  const SpillrTabShell({
    required this.navigationShell,
    required this.location,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final String location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: navigationShell,
      bottomNavigationBar: _showsBottomNavigation
          ? SpillrBottomNavigation(
              selectedTab: _selectedTab,
              onDecksTap: () => _switchToBranch(1),
              onPlayTap: () => _switchToBranch(0),
            )
          : null,
    );
  }

  bool get _showsBottomNavigation {
    return location == AppRoutes.home || location == AppRoutes.decks;
  }

  SpillrBottomNavTab get _selectedTab {
    return switch (navigationShell.currentIndex) {
      0 => SpillrBottomNavTab.play,
      1 => SpillrBottomNavTab.decks,
      _ => SpillrBottomNavTab.play,
    };
  }

  void _switchToBranch(int index) {
    if (index == navigationShell.currentIndex) {
      return;
    }

    navigationShell.goBranch(index);
  }
}
