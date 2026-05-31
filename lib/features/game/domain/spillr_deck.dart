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
    required this.icon,
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
  final List<List<dynamic>> icon;
  final Color cardBorderColor;

  SpillrDeck copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? questions,
    Color? backgroundColor,
    Color? borderColor,
    Color? badgeColor,
    Color? badgeTextColor,
    Color? iconColor,
    List<List<dynamic>>? icon,
    Color? cardBorderColor,
  }) {
    return SpillrDeck(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      questions: questions ?? this.questions,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      badgeColor: badgeColor ?? this.badgeColor,
      badgeTextColor: badgeTextColor ?? this.badgeTextColor,
      iconColor: iconColor ?? this.iconColor,
      icon: icon ?? this.icon,
      cardBorderColor: cardBorderColor ?? this.cardBorderColor,
    );
  }
}
