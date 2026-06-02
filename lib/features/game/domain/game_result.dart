import 'game_outcome.dart';

class GameResult {
  const GameResult({
    required this.title,
    required this.subtitle,
    required this.outcome,
  });

  final String title;
  final String subtitle;
  final GameOutcome outcome;
}
