import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:spillr/shared/widgets/spillr_bottom_sheet_scaffold.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/database/app_database.dart';
import '../../../../shared/widgets/fallback_state_view.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../../domain/profile_models.dart';
import '../providers/profile_providers.dart';
import '../widgets/music_sounds_sheet.dart';

class ProfilePageScreen extends ConsumerStatefulWidget {
  const ProfilePageScreen({super.key});

  @override
  ConsumerState<ProfilePageScreen> createState() => _ProfilePageScreenState();
}

class _ProfilePageScreenState extends ConsumerState<ProfilePageScreen> {
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(onboardingProfileProvider);
    final statsAsync = ref.watch(profileStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) {
            final displayName = profile?.displayName.trim().isNotEmpty == true
                ? profile!.displayName
                : 'Spiller';
            final avatarAsset = profile?.avatarAssetPath == null
                ? null
                : ProfileAvatarAsset.fromAssetPath(profile!.avatarAssetPath!);
            final avatarColor = profile?.avatarColorKey == null
                ? ProfileAvatarColorKey.teal
                : ProfileAvatarColorKey.fromValue(profile!.avatarColorKey!);
            final stats = statsAsync.maybeWhen(
              data: (stats) => stats,
              orElse: () => const ProfileStats.zero(),
            );

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 393),
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ProfileHeader(),
                      const SizedBox(height: 38),
                      Center(
                        child: ProfileAvatarCircle(
                          key: const ValueKey('profile-avatar'),
                          size: 112,
                          avatarAsset: avatarAsset,
                          avatarColor: avatarColor,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: Text(
                          displayName,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.neutral700,
                            fontSize: 24,
                            height: 1.1,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: TextButton.icon(
                          key: const ValueKey('profile-edit-button'),
                          onPressed: () =>
                              _openEditProfileSheet(context, profile: profile),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.neutral400,
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: const TextStyle(
                              fontSize: 14,
                              height: 1.1,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit Profile'),
                        ),
                      ),
                      const SizedBox(height: 36),
                      _StatsRow(stats: stats),
                      if (statsAsync.hasError) ...[
                        const SizedBox(height: 10),
                        const Center(
                          child: Text(
                            'Unable to load game stats right now.',
                            style: TextStyle(
                              color: AppColors.neutral400,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 42),
                      _OptionCard(
                        children: [
                          _ActionOptionRow(
                            key: const ValueKey('profile-option-play-history'),
                            icon: Icons.history,
                            label: 'Play History',
                            onTap: () => context.push(AppRoutes.playHistory),
                          ),
                          _ActionOptionRow(
                            key: const ValueKey('profile-option-decks-and-cards'),
                            icon: Icons.dashboard_outlined,
                            label: 'Decks and Cards',
                            onTap: () => context.push(AppRoutes.deckList),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _OptionCard(
                        children: [
                          _ToggleOptionRow(
                            key: const ValueKey('profile-option-notifications'),
                            icon: Icons.notifications_none_outlined,
                            label: 'Notifications',
                            value: ref
                                .watch(notificationsEnabledProvider)
                                .maybeWhen(
                                  data: (v) => v,
                                  orElse: () => false,
                                ),
                            onChanged: (value) =>
                                _handleNotificationToggle(context, value, profile),
                          ),
                          _ToggleOptionRow(
                            key: const ValueKey('profile-option-dark-mode'),
                            icon: Icons.nights_stay_outlined,
                            label: 'Dark Mode',
                            value: _darkModeEnabled,
                            onChanged: (value) {
                              setState(() => _darkModeEnabled = value);
                            },
                          ),
                          _ActionOptionRow(
                            key: const ValueKey(
                              'profile-option-music-and-sound',
                            ),
                            icon: Icons.volume_up_outlined,
                            label: 'Music & Sound',
                            onTap: () => _openMusicSoundsSheet(context),
                          ),
                        ],
                      ),
                    ],
                  ),
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

  Future<void> _openEditProfileSheet(
    BuildContext context, {
    required Profile? profile,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.black.withValues(alpha: 0.38),
      builder: (sheetContext) => _EditProfileSheet(profile: profile),
    );
  }

  Future<void> _openMusicSoundsSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.black.withValues(alpha: 0.38),
      builder: (sheetContext) => const MusicSoundsSheet(),
    );
  }

  Future<void> _handleNotificationToggle(
    BuildContext context,
    bool value,
    Profile? profile,
  ) async {
    if (value) {
      final granted = await NotificationService.instance.requestPermission();
      if (!granted) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Enable notifications in Settings to receive Spillr reminders.',
            ),
          ),
        );
        return;
      }
    }

    await ref
        .read(profileControllerProvider.notifier)
        .setNotificationsEnabled(enabled: value);

    if (!mounted) return;

    if (value && profile != null) {
      await NotificationService.instance.scheduleAll(
        displayName: profile.displayName,
      );
    } else {
      await NotificationService.instance.cancelAll();
    }
  }
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text.rich(
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
            text: 'Profile',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 22,
              height: 1.15,
              fontWeight: FontWeight.w700,
              color: AppColors.teal500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.stats});

  final ProfileStats stats;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey('profile-stats-row'),
      padding: EdgeInsets.zero,
      child: Row(
        children: [
          Expanded(
            child: _ProfileStatTile(
              key: const ValueKey('profile-stat-cards-played'),
              value: stats.cardsPlayed,
              label: 'Cards Played',
              accentColor: AppColors.teal500,
              accentBackground: AppColors.teal100,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ProfileStatTile(
              key: const ValueKey('profile-stat-cards-answered'),
              value: stats.cardsAnswered,
              label: 'Cards Answered',
              accentColor: AppColors.amber500,
              accentBackground: AppColors.amber100,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ProfileStatTile(
              key: const ValueKey('profile-stat-cards-passed'),
              value: stats.cardsPassed,
              label: 'Cards Passed',
              accentColor: AppColors.red500,
              accentBackground: AppColors.red100,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatTile extends StatelessWidget {
  const _ProfileStatTile({
    required this.value,
    required this.label,
    required this.accentColor,
    required this.accentBackground,
    super.key,
  });

  final int value;
  final String label;
  final Color accentColor;
  final Color accentBackground;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: accentBackground,
            borderRadius: BorderRadius.circular(10),
          ),
          child: SizedBox(
            width: 38,
            height: 32,
            child: Center(
              child: Text(
                value.toString(),
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.0,
                  fontWeight: FontWeight.w700,
                ).copyWith(color: accentColor),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.neutral400,
            fontSize: 12,
            height: 1.2,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.neutral100),
      ),
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0)
              const Divider(
                height: 1,
                thickness: 1,
                color: AppColors.neutral100,
                indent: 16,
                endIndent: 16,
              ),
            children[index],
          ],
        ],
      ),
    );
  }
}

class _ActionOptionRow extends StatelessWidget {
  const _ActionOptionRow({
    required this.icon,
    required this.label,
    this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final row = SizedBox(
      height: 58,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          children: [
            Icon(icon, color: AppColors.neutral700, size: 24, weight: 300),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.neutral700,
                  fontSize: 16,
                  height: 1.15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.neutral400,
              size: 24,
              weight: 300,
            ),
          ],
        ),
      ),
    );

    if (onTap == null) {
      return row;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}

class _ToggleOptionRow extends StatelessWidget {
  const _ToggleOptionRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          children: [
            Icon(icon, color: AppColors.neutral700, size: 24, weight: 300),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.neutral700,
                  fontSize: 16,
                  height: 1.15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeTrackColor: AppColors.teal500,
            ),
          ],
        ),
      ),
    );
  }
}

class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet({required this.profile});

  final Profile? profile;

  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late ProfileAvatarAsset _selectedAvatar;
  late ProfileAvatarColorKey _selectedColor;

  @override
  void initState() {
    super.initState();
    final profile = widget.profile;
    _nameController = TextEditingController(text: profile?.displayName ?? '');
    _selectedAvatar = profile?.avatarAssetPath == null
        ? ProfileAvatarAsset.avatar1
        : ProfileAvatarAsset.fromAssetPath(profile!.avatarAssetPath!);
    _selectedColor = profile?.avatarColorKey == null
        ? ProfileAvatarColorKey.teal
        : ProfileAvatarColorKey.fromValue(profile!.avatarColorKey!);
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
        .read(profileControllerProvider.notifier)
        .updateProfile(
          displayName: _nameController.text.trim(),
          avatarAsset: _selectedAvatar,
          avatarColor: _selectedColor,
        );

    if (mounted && !ref.read(profileControllerProvider).hasError) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);

    return SpillrBottomSheetScaffold(
      title: 'Profile',
      primaryActionLabel: 'Update Profile',
      primaryActionKey: const ValueKey('profile-update-button'),
      onPrimaryAction: _submit,
      isPrimaryActionEnabled: !profileState.isLoading,
      isPrimaryActionLoading: profileState.isLoading,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: ProfileAvatarCircle(
                key: const ValueKey('profile-avatar-preview'),
                size: 96,
                avatarAsset: _selectedAvatar,
                avatarColor: _selectedColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Name',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral700,
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              key: const ValueKey('profile-name-field'),
              controller: _nameController,
              enabled: !profileState.isLoading,
              maxLength: 64,
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return 'Please enter a name.';
                }
                if (trimmed.length > 64) {
                  return 'Name must be 64 characters or less.';
                }
                return null;
              },
              decoration: const InputDecoration(
                hintText: 'Your name',
                counterText: '',
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Avatar',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral700,
              ),
            ),
            const SizedBox(height: 12),
            _AvatarGrid(
              selectedAvatar: _selectedAvatar,
              selectedColor: _selectedColor,
              enabled: !profileState.isLoading,
              onSelected: (avatar) => setState(() => _selectedAvatar = avatar),
            ),
            const SizedBox(height: 20),
            Text(
              'Background Color',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.neutral700,
              ),
            ),
            const SizedBox(height: 12),
            _AvatarColorRow(
              selectedColor: _selectedColor,
              enabled: !profileState.isLoading,
              onSelected: (color) => setState(() => _selectedColor = color),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileAvatarCircle extends StatelessWidget {
  const ProfileAvatarCircle({
    required this.size,
    required this.avatarAsset,
    required this.avatarColor,
    super.key,
  });

  final double size;
  final ProfileAvatarAsset? avatarAsset;
  final ProfileAvatarColorKey avatarColor;

  @override
  Widget build(BuildContext context) {
    final avatarAsset = this.avatarAsset;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: avatarColor.color,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: avatarAsset == null
            ? Center(
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedUser,
                  color: AppColors.white,
                  size: size * 0.46,
                  strokeWidth: 1.6,
                ),
              )
            : Center(
                child: Transform.translate(
                  offset: Offset(0, size * 0.1),
                  child: SizedBox.square(
                    dimension: size * 1.08,
                    child: SvgPicture.asset(
                      avatarAsset.assetPath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _AvatarGrid extends StatelessWidget {
  const _AvatarGrid({
    required this.selectedAvatar,
    required this.selectedColor,
    required this.enabled,
    required this.onSelected,
  });

  final ProfileAvatarAsset selectedAvatar;
  final ProfileAvatarColorKey selectedColor;
  final bool enabled;
  final ValueChanged<ProfileAvatarAsset> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 6,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1,
      children: [
        for (final avatar in ProfileAvatarAsset.values)
          _AvatarTile(
            key: ValueKey('profile-avatar-option-${avatar.index + 1}'),
            avatar: avatar,
            selected: avatar == selectedAvatar,
            selectedColor: selectedColor,
            enabled: enabled,
            onTap: () => onSelected(avatar),
          ),
      ],
    );
  }
}

class _AvatarTile extends StatelessWidget {
  const _AvatarTile({
    required this.avatar,
    required this.selected,
    required this.selectedColor,
    required this.enabled,
    required this.onTap,
    super.key,
  });

  final ProfileAvatarAsset avatar;
  final bool selected;
  final ProfileAvatarColorKey selectedColor;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            color: selected ? selectedColor.color : AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? selectedColor.color : AppColors.neutral200,
              width: 1.2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: SvgPicture.asset(avatar.assetPath, fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}

class _AvatarColorRow extends StatelessWidget {
  const _AvatarColorRow({
    required this.selectedColor,
    required this.enabled,
    required this.onSelected,
  });

  final ProfileAvatarColorKey selectedColor;
  final bool enabled;
  final ValueChanged<ProfileAvatarColorKey> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (
          var index = 0;
          index < ProfileAvatarColorKey.values.length;
          index++
        ) ...[
          if (index > 0) const SizedBox(width: 6),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: _AvatarColorTile(
                key: ValueKey(
                  'profile-color-option-${ProfileAvatarColorKey.values[index].value}',
                ),
                colorKey: ProfileAvatarColorKey.values[index],
                selected: ProfileAvatarColorKey.values[index] == selectedColor,
                enabled: enabled,
                onTap: () => onSelected(ProfileAvatarColorKey.values[index]),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _AvatarColorTile extends StatelessWidget {
  const _AvatarColorTile({
    super.key,
    required this.colorKey,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final ProfileAvatarColorKey colorKey;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          decoration: BoxDecoration(
            color: colorKey.color,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white, width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: selected
              ? const Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: AppColors.white,
                    size: 22,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
