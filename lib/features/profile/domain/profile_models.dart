import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

enum GameplayCardAction {
  answered('answered'),
  passed('passed');

  const GameplayCardAction(this.value);

  final String value;
}

enum ProfileAvatarAsset {
  avatar1('assets/svg/avatars/user-avatar (1).svg'),
  avatar2('assets/svg/avatars/user-avatar (2).svg'),
  avatar3('assets/svg/avatars/user-avatar (3).svg'),
  avatar4('assets/svg/avatars/user-avatar (4).svg'),
  avatar5('assets/svg/avatars/user-avatar (5).svg'),
  avatar6('assets/svg/avatars/user-avatar (6).svg'),
  avatar7('assets/svg/avatars/user-avatar (7).svg'),
  avatar8('assets/svg/avatars/user-avatar (8).svg'),
  avatar9('assets/svg/avatars/user-avatar (9).svg'),
  avatar10('assets/svg/avatars/user-avatar (10).svg'),
  avatar11('assets/svg/avatars/user-avatar (11).svg'),
  avatar12('assets/svg/avatars/user-avatar (12).svg');

  const ProfileAvatarAsset(this.assetPath);

  final String assetPath;

  static ProfileAvatarAsset fromAssetPath(String path) {
    return ProfileAvatarAsset.values.firstWhere(
      (candidate) => candidate.assetPath == path,
      orElse: () => ProfileAvatarAsset.avatar1,
    );
  }
}

enum ProfileAvatarColorKey {
  blue('blue', AppColors.blue500),
  amber('amber', AppColors.amber500),
  teal('teal', AppColors.teal500),
  red('red', AppColors.red500),
  violet('violet', AppColors.violet500),
  pink('pink', AppColors.pink500),
  purple('purple', AppColors.purple500),
  cyan('cyan', AppColors.cyan500);

  const ProfileAvatarColorKey(this.value, this.color);

  final String value;
  final Color color;

  static ProfileAvatarColorKey fromValue(String value) {
    return ProfileAvatarColorKey.values.firstWhere(
      (candidate) => candidate.value == value,
      orElse: () => ProfileAvatarColorKey.teal,
    );
  }
}

class ProfileStats {
  const ProfileStats({
    required this.cardsAnswered,
    required this.cardsPassed,
  });

  const ProfileStats.zero()
    : cardsAnswered = 0,
      cardsPassed = 0;

  final int cardsAnswered;
  final int cardsPassed;

  int get cardsPlayed => cardsAnswered + cardsPassed;
}
