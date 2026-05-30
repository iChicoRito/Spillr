import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_gemma/core/api/flutter_gemma.dart';
import 'package:flutter_gemma/core/chat.dart';
import 'package:flutter_gemma/core/message.dart';
import 'package:flutter_gemma/core/model.dart';
import 'package:flutter_gemma/core/model_response.dart';
import 'package:flutter_gemma/flutter_gemma_interface.dart';
import 'package:flutter_gemma/pigeon.g.dart';

import '../../game/domain/spillr_deck.dart';

const gemmaQuestionModelAssetPath = 'assets/models/gemma3-270m-it-q8.task';
const gemmaQuestionModelFallbackAssetPath = 'assets/models/gemma3-270m-it.task';
const gemmaQuestionModelLegacyAssetPath =
    'assets/models/gemma-3-270m-it-q8.task';
const gemmaQuestionModelLegacyFallbackAssetPath =
    'assets/models/gemma-3-270m-it.task';
const gemmaQuestionBundledResourceName = 'gemma3-270m-it-q8.task';
const gemmaQuestionBundledFallbackResourceName = 'gemma3-270m-it.task';
const gemmaQuestionLegacyBundledResourceName = 'gemma-3-270m-it-q8.task';
const gemmaQuestionLegacyBundledFallbackResourceName = 'gemma-3-270m-it.task';
const missingBundledGemmaModelMessage =
    'Offline AI model is missing. Add gemma3-270m-it-q8.task or gemma3-270m-it.task to assets/models/ or android/app/src/main/assets/models/, then rebuild the app.';
const questionGenerationTimeoutMessage =
    'AI question generation is taking longer than expected. Please try again.';
const _genericCustomDeckDescription = 'Your custom tea set';

const _maxGeneratedQuestionLength = 280;
const _defaultGenerationAttempts = 4;
const _modelPreparationTimeout = Duration(seconds: 45);
const _promptSubmissionTimeout = Duration(seconds: 10);
const _questionGenerationTimeout = Duration(seconds: 20);
const _chatCloseTimeout = Duration(seconds: 2);
const _generationAngles = <String>[
  'a funny personal story',
  'a surprising opinion',
  'a quick confession',
  'a group debate',
  'a tiny embarrassing moment',
  'a weird habit',
  'a memorable recent moment',
  'a harmless hot take',
];
const _questionOpeners = <String>{
  'what',
  'when',
  'where',
  'which',
  'who',
  'why',
  'how',
  'would',
  'could',
  'should',
  'do',
  'does',
  'did',
  'is',
  'are',
  'can',
  'if',
};

const _questionSimilarityStopWords = <String>{
  'a',
  'an',
  'and',
  'are',
  'at',
  'be',
  'by',
  'do',
  'did',
  'for',
  'from',
  'have',
  'how',
  'if',
  'in',
  'is',
  'it',
  'of',
  'on',
  'or',
  'that',
  'the',
  'their',
  'this',
  'to',
  'was',
  'what',
  'when',
  'where',
  'which',
  'who',
  'why',
  'with',
  'would',
  'your',
  'you',
  'ever',
  'most',
  'something',
  'thing',
};

const _generatorStopWords = <String>{
  ..._questionSimilarityStopWords,
  'about',
  'after',
  'almost',
  'because',
  'been',
  'being',
  'better',
  'easy',
  'feel',
  'feels',
  'getting',
  'into',
  'just',
  'know',
  'like',
  'make',
  'makes',
  'mode',
  'more',
  'much',
  'often',
  'out',
  'over',
  'really',
  'someone',
  'start',
  'still',
  'than',
  'them',
  'then',
  'there',
  'they',
  'too',
  'used',
  'very',
};

abstract class QuestionGenerationService {
  Future<String> generateQuestion({
    required SpillrDeck deck,
    List<String> excludedQuestions = const [],
  });
}

abstract class QuestionGemmaClient {
  Future<String> generate(String prompt);
}

class FlutterGemmaQuestionClient implements QuestionGemmaClient {
  FlutterGemmaQuestionClient({
    this.assetPath = gemmaQuestionModelAssetPath,
    this.fallbackAssetPath = gemmaQuestionModelFallbackAssetPath,
    this.maxTokens = 192,
    this.preferredBackend = PreferredBackend.cpu,
  });

  final String assetPath;
  final String fallbackAssetPath;
  final int maxTokens;
  final PreferredBackend? preferredBackend;

  Future<void>? _installFuture;
  InferenceModel? _model;

  @override
  Future<String> generate(String prompt) async {
    try {
      debugPrint('[SpillrGemma] Ensuring model is installed');
      await _ensureModelInstalled().timeout(
        _modelPreparationTimeout,
        onTimeout: () => throw const QuestionGenerationTimeoutException(
          questionGenerationTimeoutMessage,
        ),
      );
      debugPrint('[SpillrGemma] Requesting active model');
      final model = _model ??=
          await FlutterGemma.getActiveModel(
            maxTokens: maxTokens,
            preferredBackend: preferredBackend,
          ).timeout(
            _modelPreparationTimeout,
            onTimeout: () => throw const QuestionGenerationTimeoutException(
              questionGenerationTimeoutMessage,
            ),
          );
      debugPrint('[SpillrGemma] Creating chat session');
      final chat = await model
          .createChat(
            temperature: 0.65,
            topK: 8,
            topP: 0.9,
            isThinking: false,
            modelType: ModelType.gemmaIt,
            systemInstruction: _questionSystemInstruction,
          )
          .timeout(
            _modelPreparationTimeout,
            onTimeout: () => throw const QuestionGenerationTimeoutException(
              questionGenerationTimeoutMessage,
            ),
          );
      return _generateFromChat(chat, prompt);
    } on QuestionGenerationException {
      rethrow;
    } catch (error) {
      throw mapGemmaSetupError(error);
    }
  }

  Future<void> _ensureModelInstalled() async {
    final existingInstall = _installFuture;
    if (existingInstall != null) {
      return existingInstall;
    }

    final installFuture = _installFirstAvailableModelSource();
    _installFuture = installFuture;

    try {
      await installFuture;
    } catch (error) {
      if (identical(_installFuture, installFuture)) {
        _installFuture = null;
      }
      rethrow;
    }
  }

  Future<void> _installFirstAvailableModelSource() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final bundledAssets = manifest.listAssets().toSet();
    Object? lastError;

    for (final path in <String>{
      assetPath,
      fallbackAssetPath,
      gemmaQuestionModelLegacyAssetPath,
      gemmaQuestionModelLegacyFallbackAssetPath,
    }) {
      if (bundledAssets.contains(path)) {
        try {
          await FlutterGemma.installModel(
            modelType: ModelType.gemmaIt,
            fileType: ModelFileType.task,
          ).fromAsset(path).install();
          return;
        } catch (error) {
          lastError = error;
        }
      }
    }

    for (final resourceName in <String>{
      gemmaQuestionBundledResourceName,
      gemmaQuestionBundledFallbackResourceName,
      gemmaQuestionLegacyBundledResourceName,
      gemmaQuestionLegacyBundledFallbackResourceName,
    }) {
      try {
        await FlutterGemma.installModel(
          modelType: ModelType.gemmaIt,
          fileType: ModelFileType.task,
        ).fromBundled(resourceName).install();
        return;
      } catch (error) {
        lastError = error;
      }
    }

    if (lastError != null) {
      throw mapGemmaSetupError(lastError);
    }

    throw const QuestionGenerationUnavailableException(
      missingBundledGemmaModelMessage,
    );
  }

  Future<String> _generateFromChat(InferenceChat chat, String prompt) async {
    try {
      debugPrint('[SpillrGemma] Submitting prompt');
      await chat
          .addQueryChunk(Message.text(text: prompt, isUser: true))
          .timeout(
            _promptSubmissionTimeout,
            onTimeout: () => throw const QuestionGenerationTimeoutException(
              questionGenerationTimeoutMessage,
            ),
          );
      debugPrint('[SpillrGemma] Waiting for streamed response');
      return await _collectQuestionFromStream(chat).timeout(
        _questionGenerationTimeout,
        onTimeout: () async {
          await _stopGeneration(chat);
          throw const QuestionGenerationTimeoutException(
            questionGenerationTimeoutMessage,
          );
        },
      );
    } finally {
      await _closeChat(chat);
    }
  }

  Future<String> _collectQuestionFromStream(InferenceChat chat) async {
    final responseBuffer = StringBuffer();

    await for (final response in chat.generateChatResponseAsync()) {
      if (response is! TextResponse || response.token.trim().isEmpty) {
        continue;
      }

      responseBuffer.write(response.token);
      debugPrint(
        '[SpillrGemma] Received token chunk. Buffer length: ${responseBuffer.length}',
      );
      final candidate = _extractCompletedQuestionCandidate(
        responseBuffer.toString(),
      );
      if (candidate != null) {
        debugPrint('[SpillrGemma] Completed question found early');
        await _stopGeneration(chat);
        return candidate;
      }
    }

    debugPrint('[SpillrGemma] Stream ended, sanitizing final buffer');
    return sanitizeGeneratedQuestion(responseBuffer.toString());
  }

  String? _extractCompletedQuestionCandidate(String rawResponse) {
    final questionMarkIndex = rawResponse.indexOf('?');
    if (questionMarkIndex < 0) {
      return null;
    }

    final candidate = rawResponse.substring(0, questionMarkIndex + 1).trim();
    try {
      return sanitizeGeneratedQuestion(candidate);
    } on QuestionGenerationException {
      return null;
    }
  }

  Future<void> _stopGeneration(InferenceChat chat) async {
    try {
      debugPrint('[SpillrGemma] Stopping generation');
      await chat.stopGeneration();
    } catch (_) {
      // Some backends may not support explicit stop; closing the chat still
      // tears down the native session in the caller's finally block.
    }
  }

  Future<void> _closeChat(InferenceChat chat) async {
    try {
      debugPrint('[SpillrGemma] Closing chat session');
      await chat.close().timeout(_chatCloseTimeout);
    } catch (_) {
      debugPrint('[SpillrGemma] Chat close timed out or failed');
    }
  }
}

class GemmaQuestionGenerationService implements QuestionGenerationService {
  GemmaQuestionGenerationService({
    QuestionGemmaClient? client,
    this.maxAttempts = _defaultGenerationAttempts,
  }) : _client = client ?? FlutterGemmaQuestionClient();

  final QuestionGemmaClient _client;
  final int maxAttempts;

  @override
  Future<String> generateQuestion({
    required SpillrDeck deck,
    List<String> excludedQuestions = const [],
  }) async {
    final rejectedQuestions = <String>[];

    for (var attempt = 0; attempt < maxAttempts; attempt++) {
      final disallowedQuestions = <String>[
        ...deck.questions,
        ...excludedQuestions,
        ...rejectedQuestions,
      ];
      final prompt = _buildDeckQuestionPrompt(
        deck: deck,
        disallowedQuestions: disallowedQuestions,
        variationIndex: excludedQuestions.length + rejectedQuestions.length,
      );

      try {
        final generatedQuestion = sanitizeGeneratedQuestion(
          await _client.generate(prompt),
        );
        if (!isGeneratedQuestionMeaningfullyDifferent(
          generatedQuestion,
          disallowedQuestions,
        )) {
          rejectedQuestions.add(generatedQuestion);
          continue;
        }
        if (!_isGeneratedQuestionAlignedWithDeck(generatedQuestion, deck)) {
          rejectedQuestions.add(generatedQuestion);
          continue;
        }
        return generatedQuestion;
      } on QuestionGenerationUnavailableException {
        rethrow;
      } on QuestionGenerationTimeoutException {
        rethrow;
      } on QuestionGenerationException {
        rejectedQuestions.add('Invalid model response attempt ${attempt + 1}');
      }
    }

    return _fallbackQuestionForDeck(
      deck,
      disallowedQuestions: [
        ...deck.questions,
        ...excludedQuestions,
        ...rejectedQuestions,
      ],
    );
  }
}

String _buildDeckQuestionPrompt({
  required SpillrDeck deck,
  required List<String> disallowedQuestions,
  required int variationIndex,
}) {
  final effectiveDescription = _effectiveDeckDescription(deck);
  final hasExamples = deck.questions.any(
    (question) => question.trim().isNotEmpty,
  );
  final examplesText = hasExamples
      ? deck.questions.take(12).map((question) => '- $question').join('\n')
      : '- None yet. Use the title and description as the main theme.';
  final blockedQuestionsText = disallowedQuestions
      .where((question) => question.trim().isNotEmpty)
      .map((question) => '- $question')
      .join('\n');
  final titleCue =
      (!hasExamples || _isGenericCustomDeckDescription(deck.description))
      ? '- Make the theme obvious from the wording. Reuse important title words or close variations when it helps.'
      : '';
  final generationAngle =
      _generationAngles[variationIndex % _generationAngles.length];

  return '''
You generate one fresh Spillr conversation question for the selected deck.

Deck title: ${deck.title}
Deck description: $effectiveDescription
Generation angle: $generationAngle

Deck examples:
$examplesText

Do not repeat or closely rephrase these questions:
${blockedQuestionsText.isEmpty ? '- None yet.' : blockedQuestionsText}

Rules:
- Return exactly one question.
- The question must fit the selected deck title and description.
- The question must sound natural in a casual party conversation.
- For custom or empty decks, infer the vibe directly from the deck title.
- Use the generation angle to make this output distinct from rejected questions.
- Do not add numbering, bullets, labels, quotes, explanations, or markdown.
- The question must end with a question mark.
- Keep the question under $_maxGeneratedQuestionLength characters.
$titleCue
''';
}

const _questionSystemInstruction =
    'You write short, playful, category-specific conversation questions only.';

bool isGeneratedQuestionMeaningfullyDifferent(
  String candidate,
  Iterable<String> existingQuestions,
) {
  final normalizedCandidate = _normalizeQuestion(candidate);
  final candidateFingerprint = _questionFingerprint(candidate);

  for (final existingQuestion in existingQuestions) {
    final normalizedExisting = _normalizeQuestion(existingQuestion);
    if (normalizedExisting.isEmpty) {
      continue;
    }

    if (normalizedCandidate == normalizedExisting) {
      return false;
    }

    final existingFingerprint = _questionFingerprint(existingQuestion);
    if (candidateFingerprint == existingFingerprint) {
      return false;
    }

    final candidateWords = candidateFingerprint.split(' ').where((word) {
      return word.isNotEmpty;
    }).toSet();
    final existingWords = existingFingerprint.split(' ').where((word) {
      return word.isNotEmpty;
    }).toSet();

    if (candidateWords.isEmpty || existingWords.isEmpty) {
      continue;
    }

    final overlap = candidateWords.intersection(existingWords);
    final smallestSize = candidateWords.length < existingWords.length
        ? candidateWords.length
        : existingWords.length;
    final overlapRatio = overlap.length / smallestSize;

    if (overlap.length >= 2 && overlapRatio >= 0.6) {
      return false;
    }
  }

  return true;
}

String sanitizeGeneratedQuestion(String rawQuestion) {
  final normalizedResponse = rawQuestion
      .trim()
      .replaceAll('<end_of_turn>', '')
      .replaceAll(RegExp(r'<[^>]+>'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  for (final candidate in _generatedQuestionCandidates(rawQuestion)) {
    final question = _sanitizeQuestionCandidate(candidate);
    if (_isUsableGeneratedQuestion(question)) {
      return question;
    }
  }

  final question = _sanitizeQuestionCandidate(normalizedResponse);
  if (_isUsableGeneratedQuestion(question)) {
    return question;
  }

  throw const QuestionGenerationException(
    'The generated question was not usable. Please try again.',
  );
}

Iterable<String> _generatedQuestionCandidates(String rawQuestion) sync* {
  final cleaned = rawQuestion.replaceAll('<end_of_turn>', '');
  final lineCandidates = cleaned
      .split(RegExp(r'[\r\n]+'))
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty);

  for (final line in lineCandidates) {
    yield line;
  }

  final questionPattern = RegExp(
    r'((?:what|when|where|which|who|why|how|would|could|should|do|does|did|is|are|can|if)\b[^?]*\?)',
    caseSensitive: false,
  );
  for (final match in questionPattern.allMatches(cleaned)) {
    yield match.group(1) ?? '';
  }

  final openerPattern = RegExp(
    r'\b(what|when|where|which|who|why|how|would|could|should|do|does|did|is|are|can|if)\b',
    caseSensitive: false,
  );
  final openerMatch = openerPattern.firstMatch(cleaned);
  if (openerMatch != null) {
    yield cleaned.substring(openerMatch.start);
  }
}

String _sanitizeQuestionCandidate(String rawCandidate) {
  var question = rawCandidate
      .trim()
      .replaceAll('<end_of_turn>', '')
      .replaceAll(RegExp(r'\s+'), ' ');

  question = question.replaceFirst(RegExp(r'^\s*[-*\u2022]\s*'), '');
  question = question.replaceFirst(RegExp(r'^\s*\d+[\).:-]\s*'), '');
  question = question.replaceFirst(
    RegExp(r'^(Question|Q)\s*[:.-]\s*', caseSensitive: false),
    '',
  );
  question = question.replaceFirst(
    RegExp(
      r"^(Sure|Okay|Here's|Heres|Here is|Generated question|Try this|One idea|Output)\b[^:.\-]*[:.\-]\s*",
      caseSensitive: false,
    ),
    '',
  );
  question = question.trim();

  while (question.length > 1 &&
      ((question.startsWith('"') && question.endsWith('"')) ||
          (question.startsWith("'") && question.endsWith("'")))) {
    question = question.substring(1, question.length - 1).trim();
  }

  final questionMarkIndex = question.indexOf('?');
  if (questionMarkIndex >= 0) {
    question = question.substring(0, questionMarkIndex + 1).trim();
  }

  if (!question.endsWith('?') && _looksLikeQuestionStart(question)) {
    question = question.replaceAll(RegExp(r'[.!:;,\s]+$'), '').trim();
    question = '$question?';
  }

  return question;
}

bool _isUsableGeneratedQuestion(String question) {
  return question.isNotEmpty &&
      question.endsWith('?') &&
      question.length <= _maxGeneratedQuestionLength &&
      _looksLikeQuestionStart(question);
}

bool _looksLikeQuestionStart(String question) {
  final firstWord = RegExp(
    r'''^[\s"'`]*(\w+)''',
    caseSensitive: false,
  ).firstMatch(question);
  if (firstWord == null) {
    return false;
  }
  return _questionOpeners.contains(firstWord.group(1)!.toLowerCase());
}

String _fallbackQuestionForDeck(
  SpillrDeck deck, {
  required List<String> disallowedQuestions,
}) {
  final title = deck.title.trim();
  final candidates = <String>[
    'What is one story that perfectly fits the $title vibe?',
    'What moment in your life feels most like $title?',
    'What is something you would only admit in a $title conversation?',
    'What is the most memorable $title moment you have seen?',
    'What is your most specific $title opinion?',
    'What $title moment would your friends instantly remember?',
    'What is a $title take you would defend for no good reason?',
    'What is the funniest $title thing that happened to you recently?',
    'What is a $title habit you secretly understand?',
    'What $title situation would make you laugh first and explain later?',
    'What is the weirdest $title story you can tell without naming names?',
    'What is one $title moment that still lives rent free in your head?',
    'What would be your signature move in a $title situation?',
    'What is the most harmless $title confession you can make?',
    'What is a $title scenario you hope never happens again?',
    'What is the most oddly specific $title memory you have?',
  ];

  final offset = disallowedQuestions.length % candidates.length;
  final rotatedCandidates = <String>[
    ...candidates.skip(offset),
    ...candidates.take(offset),
  ];

  for (final candidate in rotatedCandidates) {
    if (isGeneratedQuestionMeaningfullyDifferent(
      candidate,
      disallowedQuestions,
    )) {
      return candidate;
    }
  }

  return candidates.first;
}

bool _isGeneratedQuestionAlignedWithDeck(String question, SpillrDeck deck) {
  if (_shouldTrustPromptForAlignment(deck)) {
    return true;
  }

  final deckKeywords = _deckKeywords(deck);
  final questionKeywords = _significantWords(question).toSet();
  if (deckKeywords.isEmpty || questionKeywords.isEmpty) {
    return true;
  }
  return deckKeywords.intersection(questionKeywords).isNotEmpty;
}

Set<String> _deckKeywords(SpillrDeck deck) {
  return {
    ..._keywordsFromText(deck.title),
    ..._keywordsFromText(_effectiveDeckDescription(deck)),
    ..._keywordsFromText(deck.questions.join(' ')),
  };
}

bool _shouldTrustPromptForAlignment(SpillrDeck deck) {
  final hasExamples = deck.questions.any(
    (question) => question.trim().isNotEmpty,
  );
  return !hasExamples && _isGenericCustomDeckDescription(deck.description);
}

bool _isGenericCustomDeckDescription(String description) {
  return description.trim().toLowerCase() ==
      _genericCustomDeckDescription.toLowerCase();
}

String _effectiveDeckDescription(SpillrDeck deck) {
  if (_isGenericCustomDeckDescription(deck.description)) {
    return 'Custom conversation category focused on ${deck.title}.';
  }
  return deck.description;
}

List<String> _keywordsFromText(String text) {
  final sanitized = text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
  return sanitized
      .split(RegExp(r'\s+'))
      .map(_stemWord)
      .where((word) => word.length >= 3 && !_generatorStopWords.contains(word))
      .toList(growable: false);
}

String _normalizeQuestion(String question) {
  return question.trim().toLowerCase();
}

String _questionFingerprint(String question) {
  return _significantWords(question).join(' ');
}

List<String> _significantWords(String question) {
  final sanitized = question.toLowerCase().replaceAll(
    RegExp(r'[^a-z0-9\s]'),
    ' ',
  );
  return sanitized
      .split(RegExp(r'\s+'))
      .map(_stemWord)
      .where((word) {
        return word.length >= 3 && !_questionSimilarityStopWords.contains(word);
      })
      .toList(growable: false);
}

String _stemWord(String word) {
  if (word.endsWith('iest') && word.length > 5) {
    return '${word.substring(0, word.length - 4)}y';
  }
  if (word.endsWith('ier') && word.length > 4) {
    return '${word.substring(0, word.length - 3)}y';
  }
  if (word.endsWith('est') && word.length > 5) {
    return word.substring(0, word.length - 3);
  }
  if (word.endsWith('er') && word.length > 4) {
    return word.substring(0, word.length - 2);
  }
  if (word.endsWith('ies') && word.length > 4) {
    return '${word.substring(0, word.length - 3)}y';
  }
  if (word.endsWith('ing') && word.length > 5) {
    return word.substring(0, word.length - 3);
  }
  if (word.endsWith('ed') && word.length > 4) {
    return word.substring(0, word.length - 2);
  }
  if (word.endsWith('es') && word.length > 4) {
    return word.substring(0, word.length - 2);
  }
  if (word.endsWith('s') && word.length > 3) {
    return word.substring(0, word.length - 1);
  }
  return word;
}

class QuestionGenerationException implements Exception {
  const QuestionGenerationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class QuestionGenerationUnavailableException
    extends QuestionGenerationException {
  const QuestionGenerationUnavailableException(super.message);
}

class QuestionGenerationTimeoutException extends QuestionGenerationException {
  const QuestionGenerationTimeoutException(super.message);
}

QuestionGenerationException mapGemmaSetupError(Object error) {
  if (_isMissingBundledGemmaModelError(error)) {
    return const QuestionGenerationUnavailableException(
      missingBundledGemmaModelMessage,
    );
  }

  return const QuestionGenerationUnavailableException(
    'Offline AI is not ready on this device yet. Please reopen the app and try again.',
  );
}

bool _isMissingBundledGemmaModelError(Object error) {
  final message = error.toString().toLowerCase();

  return message.contains('copy_error') ||
      message.contains('failed to copy asset') ||
      message.contains('failed to copy asset from android assets') ||
      message.contains('failed to load asset') ||
      message.contains('unable to load asset') ||
      message.contains('unable to load the asset') ||
      message.contains('asset does not exist') ||
      message.contains('assetpath') ||
      message.contains('models/gemma') ||
      message.contains('gemma3-270m-it') ||
      message.contains('gemma-3-270m-it') ||
      message.contains('no active inference model set') ||
      message.contains('bundled resource not found') ||
      message.contains('failed to get ios bundled path');
}
