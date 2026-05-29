class DeckQuestionItem {
  const DeckQuestionItem({
    required this.id,
    required this.deckId,
    required this.text,
    required this.sortOrder,
    required this.isBuiltIn,
  });

  final int id;
  final String deckId;
  final String text;
  final int sortOrder;
  final bool isBuiltIn;
}
