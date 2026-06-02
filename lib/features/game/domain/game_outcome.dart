/// The outcome of a completed game, used to persist play history compactly and
/// to drive the timeline indicator on the Play History page.
enum GameOutcome {
  /// All questions answered, none passed.
  spilledEverything('spilled_everything'),

  /// Finished the deck with a mix of answered and passed questions.
  almostSpilled('almost_spilled'),

  /// Every question passed, none answered.
  certifiedDodger('certified_dodger'),

  /// Ended the round early without answering anything.
  noSpill('no_spill');

  const GameOutcome(this.value);

  /// Stable string persisted in the database.
  final String value;

  /// Single-line status label shown in the play history list.
  String statusLabel(String name) {
    switch (this) {
      case GameOutcome.spilledEverything:
        return 'You Spilled Everything, $name';
      case GameOutcome.almostSpilled:
        return 'Almost Spilled Everything, $name';
      case GameOutcome.certifiedDodger:
        return 'Certified Dodger, $name';
      case GameOutcome.noSpill:
        return 'No Spill? Kinda Sus, $name';
    }
  }

  static GameOutcome fromValue(String value) {
    return GameOutcome.values.firstWhere(
      (outcome) => outcome.value == value,
      orElse: () => GameOutcome.almostSpilled,
    );
  }
}
