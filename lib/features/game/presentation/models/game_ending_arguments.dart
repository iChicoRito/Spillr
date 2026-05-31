import '../../domain/game_result.dart';
import '../../domain/spillr_deck.dart';

class GameEndingArguments {
  const GameEndingArguments({required this.deck, required this.result});

  final SpillrDeck deck;
  final GameResult result;
}
