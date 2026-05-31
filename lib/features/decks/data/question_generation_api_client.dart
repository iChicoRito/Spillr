import 'dart:convert';
import 'dart:io';

import 'question_generation_errors.dart';

abstract class QuestionGenerationApiClient {
  Future<String> generateQuestion({
    required String model,
    required List<QuestionGenerationMessage> messages,
  });

  void close();
}

class QuestionGenerationMessage {
  const QuestionGenerationMessage({required this.role, required this.content});

  final String role;
  final String content;

  Map<String, Object?> toJson() => <String, Object?>{
    'role': role,
    'content': content,
  };
}

class GroqQuestionGenerationApiClient implements QuestionGenerationApiClient {
  GroqQuestionGenerationApiClient({
    required String apiKey,
    Uri? baseUri,
    HttpClient? httpClient,
    Duration connectionTimeout = const Duration(seconds: 12),
  }) : _apiKey = apiKey,
       _baseUri = baseUri ?? Uri.parse('https://api.groq.com/openai/v1/'),
       _httpClient = httpClient ?? HttpClient() {
    _httpClient.connectionTimeout = connectionTimeout;
  }

  final String _apiKey;
  final Uri _baseUri;
  final HttpClient _httpClient;

  @override
  Future<String> generateQuestion({
    required String model,
    required List<QuestionGenerationMessage> messages,
  }) async {
    final request = await _httpClient.postUrl(
      _baseUri.resolve('chat/completions'),
    );
    request.headers.contentType = ContentType.json;
    request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $_apiKey');
    request.write(
      jsonEncode(<String, Object?>{
        'model': model,
        'messages': messages.map((message) => message.toJson()).toList(),
        'temperature': 0.7,
      }),
    );

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw const QuestionGenerationApiException(
        message:
            'We could not generate a question right now. Please try again.',
      );
    }

    return _parseGeneratedQuestion(body);
  }

  @override
  void close() {
    _httpClient.close(force: true);
  }

  String _parseGeneratedQuestion(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map) {
        throw const FormatException('Unexpected Groq response.');
      }

      final choices = decoded['choices'];
      if (choices is! List || choices.isEmpty) {
        throw const FormatException('Missing choices.');
      }

      final firstChoice = choices.first;
      if (firstChoice is! Map) {
        throw const FormatException('Missing choice payload.');
      }

      final message = firstChoice['message'];
      if (message is! Map) {
        throw const FormatException('Missing message payload.');
      }

      final content = message['content'];
      if (content is! String) {
        throw const FormatException('Missing content.');
      }

      final question = _sanitizeQuestion(content);
      if (question.isEmpty) {
        throw const FormatException('Empty question.');
      }

      return question;
    } on QuestionGenerationException {
      rethrow;
    } catch (_) {
      throw const QuestionGenerationApiException(
        message:
            'We could not generate a question right now. Please try again.',
      );
    }
  }
}

String _sanitizeQuestion(String content) {
  final lines = content
      .split(RegExp(r'\r?\n'))
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList(growable: false);

  final firstLine = lines.isEmpty ? content.trim() : lines.first;
  final withoutListMarker = firstLine.replaceFirst(
    RegExp(r'^(?:\d+[\).]|[-*•])\s*'),
    '',
  );

  final normalized = withoutListMarker.replaceAll(RegExp(r'\s+'), ' ').trim();
  return _limitQuestionWords(normalized);
}

String _limitQuestionWords(String question, {int maxWords = 15}) {
  final words = question
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList(growable: false);

  if (words.length <= maxWords) {
    return question;
  }

  final truncated = words.take(maxWords).join(' ');
  if (truncated.endsWith('?')) {
    return truncated;
  }

  return '$truncated?';
}
