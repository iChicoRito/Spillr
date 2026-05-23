import 'package:flutter/material.dart';

class SpillrDeck {
  const SpillrDeck({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    required this.backgroundColor,
    required this.borderColor,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.iconColor,
    required this.cardBorderColor,
  });

  final String id;
  final String title;
  final String description;
  final List<String> questions;
  final Color backgroundColor;
  final Color borderColor;
  final Color badgeColor;
  final Color badgeTextColor;
  final Color iconColor;
  final Color cardBorderColor;
}
