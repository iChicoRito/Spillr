import 'dart:io';

import '../../game/domain/spillr_deck.dart';
import 'question_generation_errors.dart';
import 'question_generation_api_client.dart';
import 'question_generation_usage_repository.dart';

export 'question_generation_errors.dart';
export 'question_generation_api_client.dart';
export 'question_generation_usage_repository.dart';

const String _groqModel = 'llama-3.3-70b-versatile';
const Duration _internetLookupTimeout = Duration(seconds: 4);

abstract class QuestionGenerationService {
  Future<String> generateQuestion({
    required SpillrDeck deck,
    List<String> excludedQuestions = const [],
  });
}

abstract class QuestionGenerationConnectivityChecker {
  Future<bool> hasConnection();
}

class DefaultQuestionGenerationConnectivityChecker
    implements QuestionGenerationConnectivityChecker {
  const DefaultQuestionGenerationConnectivityChecker({
    this.lookupHost = 'example.com',
    this.timeout = _internetLookupTimeout,
  });

  final String lookupHost;
  final Duration timeout;

  @override
  Future<bool> hasConnection() async {
    try {
      final addresses = await InternetAddress.lookup(
        lookupHost,
      ).timeout(timeout);
      return addresses.isNotEmpty;
    } on Object {
      return false;
    }
  }
}

class GroqQuestionGenerationService implements QuestionGenerationService {
  GroqQuestionGenerationService({
    required QuestionGenerationApiClient apiClient,
    required QuestionGenerationUsageStore usageStore,
    required QuestionGenerationConnectivityChecker connectivityChecker,
    DateTime Function()? now,
  }) : _apiClient = apiClient,
       _usageStore = usageStore,
       _connectivityChecker = connectivityChecker,
       _now = now ?? DateTime.now;

  final QuestionGenerationApiClient _apiClient;
  final QuestionGenerationUsageStore _usageStore;
  final QuestionGenerationConnectivityChecker _connectivityChecker;
  final DateTime Function() _now;

  @override
  Future<String> generateQuestion({
    required SpillrDeck deck,
    List<String> excludedQuestions = const [],
  }) async {
    final currentTime = _now();
    final currentStatus = await _usageStore.readStatus();
    if (currentStatus.isBlockedAt(currentTime)) {
      throw QuestionGenerationLimitExceededException(
        retryAt: currentStatus.cooldownEndsAt!,
        message: _buildLimitMessage(
          currentStatus.cooldownRemaining(currentTime),
        ),
      );
    }

    final hasConnection = await _connectivityChecker.hasConnection();
    if (!hasConnection) {
      throw const QuestionGenerationOfflineException();
    }

    await _usageStore.reserveAttempt();

    try {
      return await _apiClient.generateQuestion(
        model: _groqModel,
        messages: _buildMessages(
          deck: deck,
          excludedQuestions: excludedQuestions,
        ),
      );
    } on QuestionGenerationException {
      rethrow;
    } catch (_) {
      throw const QuestionGenerationApiException(
        message:
            'We could not generate a question right now. Please try again.',
      );
    }
  }

  List<QuestionGenerationMessage> _buildMessages({
    required SpillrDeck deck,
    required List<String> excludedQuestions,
  }) {
    final deckDescription = _cleanText(deck.description);
    final customDeckContext =
        deckDescription.toLowerCase() == 'your custom tea set'
        ? 'This is a custom deck created by the user.'
        : 'Deck description: $deckDescription';

    final existingQuestions = deck.questions
        .map(_cleanText)
        .where((question) {
          return question.isNotEmpty;
        })
        .toList(growable: false);
    final rejectedQuestions = excludedQuestions
        .map(_cleanText)
        .where((question) {
          return question.isNotEmpty;
        })
        .toList(growable: false);

    final systemPrompt = [
      'You write one question for Spillr, a party conversation game.',
      'Return only the question text.',
      'Keep it natural, short, and easy to say out loud.',
      'Keep it to 15 words or fewer.',
      'End with a question mark.',
      'Do not add numbering, quotes, markdown, labels, or explanations.',
      'Make the question fit the deck vibe and avoid repeating existing or rejected questions.',
    ].join(' ');

    final userPrompt = StringBuffer()
      ..writeln('Deck title: ${_cleanText(deck.title)}')
      ..writeln(customDeckContext)
      ..writeln()
      ..writeln('Existing questions:')
      ..writeln(
        existingQuestions.isEmpty
            ? '- None'
            : existingQuestions.map((question) => '- $question').join('\n'),
      )
      ..writeln()
      ..writeln('Avoid these rejected questions:')
      ..writeln(
        rejectedQuestions.isEmpty
            ? '- None'
            : rejectedQuestions.map((question) => '- $question').join('\n'),
      )
      ..writeln()
      ..write('Write one fresh question that belongs in this deck.');

    return <QuestionGenerationMessage>[
      QuestionGenerationMessage(role: 'system', content: systemPrompt),
      QuestionGenerationMessage(role: 'user', content: userPrompt.toString()),
    ];
  }
}

String _buildLimitMessage(Duration? remaining) {
  final duration = remaining ?? kQuestionGenerationCooldown;
  return 'You have used all 15 AI generations. Try again in ${_formatDuration(duration)}.';
}

String _formatDuration(Duration duration) {
  if (duration.inHours >= 1) {
    final hours = duration.inHours;
    return hours == 1 ? '1 hour' : '$hours hours';
  }

  final minutes = duration.inMinutes;
  if (minutes >= 1) {
    return minutes == 1 ? '1 minute' : '$minutes minutes';
  }

  return 'less than a minute';
}

String _cleanText(String input) {
  return input.trim().replaceAll(RegExp(r'\s+'), ' ');
}
