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

sealed class DeckFilterSelection {
  const DeckFilterSelection();

  const factory DeckFilterSelection.all() = AllDeckFilterSelection;
  const factory DeckFilterSelection.builtIn(DeckFilter filter) =
      BuiltInDeckFilterSelection;
  const factory DeckFilterSelection.custom(String deckId) =
      CustomDeckFilterSelection;
}

class AllDeckFilterSelection extends DeckFilterSelection {
  const AllDeckFilterSelection();
}

class BuiltInDeckFilterSelection extends DeckFilterSelection {
  const BuiltInDeckFilterSelection(this.filter);

  final DeckFilter filter;
}

class CustomDeckFilterSelection extends DeckFilterSelection {
  const CustomDeckFilterSelection(this.deckId);

  final String deckId;
}

sealed class DeckFilterChip {
  const DeckFilterChip({required this.id, required this.label});

  final String id;
  final String label;

  bool get isBuiltIn => false;
}

class BuiltInDeckFilterChip extends DeckFilterChip {
  BuiltInDeckFilterChip({required this.filter})
      : super(
          id: 'built-in-${filter.builtInDeckId ?? "all"}',
          label: filter.label,
        );

  final DeckFilter filter;

  @override
  bool get isBuiltIn => true;
}

class CustomDeckFilterChip extends DeckFilterChip {
  CustomDeckFilterChip({
    required this.deckId,
    required super.label,
  }) : super(id: deckId);

  final String deckId;
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
  sparkles('sparkles', HugeIcons.strokeRoundedSparkles),
  party('party', HugeIcons.strokeRoundedParty),
  starAward('star-award', HugeIcons.strokeRoundedStarAward01),
  gift('gift', HugeIcons.strokeRoundedGift),
  book('book', HugeIcons.strokeRoundedBook01),
  chat('chat', HugeIcons.strokeRoundedChat01),
  camera('camera', HugeIcons.strokeRoundedCamera01),
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
    this.customIconKey,
    this.customColorKey,
  });

  final String id;
  final String title;
  final int cardCount;
  final List<List<dynamic>> icon;
  final Color avatarColor;
  final bool isBuiltIn;
  final CustomDeckIconKey? customIconKey;
  final CustomDeckColorKey? customColorKey;
}
