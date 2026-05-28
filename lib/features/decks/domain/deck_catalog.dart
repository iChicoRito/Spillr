import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../core/theme/app_colors.dart';

enum DeckFilter {
  all('All', null),
  deepSpill('Deep Spill', 'deep-spill'),
  noDeadAir('No Dead Air', 'no-dead-air'),
  chaosMode('Chaos Mode', 'chaos-mode'),
  hotSeat('Hot Seat', 'hot-seat'),
  dateMode('Date Mode', 'date-mode'),
  justPullIt('Just Pull It', 'wildcard-tea');

  const DeckFilter(this.label, this.builtInDeckId);

  final String label;
  final String? builtInDeckId;
}

enum CustomDeckIconKey {
  user('user', HugeIcons.strokeRoundedUser),
  favourite('favourite', HugeIcons.strokeRoundedFavourite),
  fire('fire', HugeIcons.strokeRoundedFire),
  leaf('leaf', HugeIcons.strokeRoundedLeaf01),
  cards('cards', HugeIcons.strokeRoundedCards01),
  star('star', HugeIcons.strokeRoundedHonourStar),
  mic('mic', HugeIcons.strokeRoundedMic01),
  happy('happy', HugeIcons.strokeRoundedHappy),
  angry('angry', HugeIcons.strokeRoundedAngry),
  sad('sad', HugeIcons.strokeRoundedSad01),
  dizzy('dizzy', HugeIcons.strokeRoundedSadDizzy),
  smile('smile', HugeIcons.strokeRoundedSmile),
  wink('wink', HugeIcons.strokeRoundedWink),
  monster('monster', HugeIcons.strokeRoundedMonster);

  const CustomDeckIconKey(this.value, this.icon);

  final String value;
  final List<List<dynamic>> icon;

  static CustomDeckIconKey fromValue(String value) {
    return CustomDeckIconKey.values.firstWhere(
      (candidate) => candidate.value == value,
      orElse: () => CustomDeckIconKey.leaf,
    );
  }
}

enum CustomDeckColorKey {
  blue('blue', AppColors.blue500),
  amber('amber', AppColors.amber500),
  teal('teal', AppColors.teal500),
  red('red', AppColors.red500),
  violet('violet', AppColors.violet500),
  pink('pink', AppColors.pink500),
  purple('purple', AppColors.purple500),
  cyan('cyan', AppColors.cyan500);

  const CustomDeckColorKey(this.value, this.color);

  final String value;
  final Color color;

  static CustomDeckColorKey fromValue(String value) {
    return CustomDeckColorKey.values.firstWhere(
      (candidate) => candidate.value == value,
      orElse: () => CustomDeckColorKey.teal,
    );
  }
}

class DeckListItem {
  const DeckListItem({
    required this.id,
    required this.title,
    required this.cardCount,
    required this.icon,
    required this.avatarColor,
    required this.isBuiltIn,
  });

  final String id;
  final String title;
  final int cardCount;
  final List<List<dynamic>> icon;
  final Color avatarColor;
  final bool isBuiltIn;
}
