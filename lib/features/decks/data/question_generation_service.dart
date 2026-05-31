import '../../game/domain/spillr_deck.dart';

const _prototypeResponseDelay = Duration(milliseconds: 240);
const _genericCustomDeckDescription = 'Your custom tea set';

const _prototypeQuestionTemplates = <String>[
  'What is one story that perfectly fits the {theme} vibe?',
  'What moment in your life feels most like {theme}?',
  'What is something you would only admit in a {theme} conversation?',
  'What is your most specific {theme} opinion?',
  'What {theme} moment would your friends instantly remember?',
  'What is a {theme} take you would defend for no good reason?',
  'What is the funniest {theme} thing that happened to you recently?',
  'What is a {theme} habit you secretly understand?',
  'What {theme} situation would make you laugh first and explain later?',
  'What is the weirdest {theme} story you can tell without naming names?',
  'What is one {theme} memory that still lives rent free in your head?',
  'What would be your signature move in a {theme} situation?',
  'What is the most harmless {theme} confession you can make?',
  'What is a {theme} scenario you hope never happens again?',
  'What is the most oddly specific {theme} memory you have?',
  'What is one {theme} question you would rather answer than ask?',
];

const _fallbackQuestionTemplates = <String>[
  'What is the most unexpected thing about {theme}?',
  'What is one {theme} detail people would notice first?',
  'What would make a {theme} night instantly chaotic?',
  'What is the most relatable {theme} problem you have?',
  'What is one {theme} story you wish existed?',
  'What is the best {theme} thing you could hear tonight?',
  'What is the most forgettable-but-funny {theme} moment?',
  'What is a {theme} answer that would surprise your friends?',
];

abstract class QuestionGenerationService {
  Future<String> generateQuestion({
    required SpillrDeck deck,
    List<String> excludedQuestions = const [],
  });
}

class PrototypeQuestionGenerationService implements QuestionGenerationService {
  const PrototypeQuestionGenerationService({
    this.responseDelay = _prototypeResponseDelay,
  });

  final Duration responseDelay;

  @override
  Future<String> generateQuestion({
    required SpillrDeck deck,
    List<String> excludedQuestions = const [],
  }) async {
    if (responseDelay > Duration.zero) {
      await Future.delayed(responseDelay);
    }

    final blockedQuestions = <String>{
      ...deck.questions.map(_normalizeQuestion),
      ...excludedQuestions.map(_normalizeQuestion),
    };
    final theme = _deckTheme(deck);
    final candidates = <String>[
      ..._buildQuestions(
        _prototypeQuestionTemplates,
        theme: theme,
        seed: excludedQuestions.length,
      ),
      ..._buildQuestions(
        _fallbackQuestionTemplates,
        theme: theme,
        seed: excludedQuestions.length + _prototypeQuestionTemplates.length,
      ),
    ];

    for (final candidate in candidates) {
      if (!_isBlocked(candidate, blockedQuestions)) {
        return candidate;
      }
    }

    return 'What is one {theme} story you have not told yet?'
        .replaceAll('{theme}', theme);
  }
}

List<String> _buildQuestions(
  List<String> templates, {
  required String theme,
  required int seed,
}) {
  if (templates.isEmpty) {
    return const [];
  }

  final offset = seed % templates.length;
  final rotatedTemplates = <String>[
    ...templates.skip(offset),
    ...templates.take(offset),
  ];

  return rotatedTemplates
      .map((template) => template.replaceAll('{theme}', theme))
      .toList(growable: false);
}

String _deckTheme(SpillrDeck deck) {
  final title = _cleanText(deck.title);
  if (title.isNotEmpty) {
    return title;
  }

  final description = _cleanText(deck.description);
  if (description.isNotEmpty &&
      !_isGenericCustomDeckDescription(description)) {
    return description;
  }

  return 'this deck';
}

String _cleanText(String input) {
  return input.trim().replaceAll(RegExp(r'\s+'), ' ');
}

String _normalizeQuestion(String question) {
  return _cleanText(question).toLowerCase();
}

bool _isBlocked(String candidate, Set<String> blockedQuestions) {
  return blockedQuestions.contains(_normalizeQuestion(candidate));
}

bool _isGenericCustomDeckDescription(String description) {
  return description.toLowerCase() == _genericCustomDeckDescription.toLowerCase();
}

class QuestionGenerationException implements Exception {
  const QuestionGenerationException(this.message);

  final String message;

  @override
  String toString() => message;
}
