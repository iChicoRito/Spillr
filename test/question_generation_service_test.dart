import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:spillr/features/decks/data/question_generation_service.dart';
import 'package:spillr/features/game/domain/spillr_deck.dart';

void main() {
  const deck = SpillrDeck(
    id: 'chaos-mode',
    title: 'Chaos Mode',
    description: 'Unhinged party stories and unserious confessions',
    questions: [
      "What's your most chaotic online purchase?",
      "What's your most unserious fear?",
      "Which tiny habit makes you feel like an NPC?",
      "What's the pettiest reason you've judged someone?",
    ],
    backgroundColor: Colors.white,
    borderColor: Colors.black,
    badgeColor: Colors.black,
    badgeTextColor: Colors.white,
    iconColor: Colors.black,
    cardBorderColor: Colors.black,
  );

  group('GroqQuestionGenerationApiClient', () {
    late HttpServer server;
    late Uri baseUri;

    setUp(() async {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      baseUri = Uri.parse('http://127.0.0.1:${server.port}/openai/v1/');
    });

    tearDown(() async {
      await server.close(force: true);
    });

    test('posts the expected request and parses the response', () async {
      final requestHandled = Completer<void>();

      server.listen((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/openai/v1/chat/completions');
        expect(
          request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer test-key',
        );
        expect(request.headers.contentType?.mimeType, 'application/json');

        final body = await utf8.decoder.bind(request).join();
        final payload = jsonDecode(body) as Map<String, dynamic>;
        expect(payload['model'], 'llama-3.3-70b-versatile');
        final messages = payload['messages'] as List<dynamic>;
        expect(messages, hasLength(2));
        expect(messages[0], containsPair('role', 'system'));
        expect(messages[1], containsPair('role', 'user'));

        request.response.statusCode = 200;
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode({
            'choices': [
              {
                'message': {
                  'content': '\n  What snack could start a debate?  \n',
                },
              },
            ],
          }),
        );
        await request.response.close();
        requestHandled.complete();
      });

      final client = GroqQuestionGenerationApiClient(
        apiKey: 'test-key',
        baseUri: baseUri,
        httpClient: HttpClient(),
      );
      addTearDown(client.close);

      final result = await client.generateQuestion(
        model: 'llama-3.3-70b-versatile',
        messages: const [
          QuestionGenerationMessage(role: 'system', content: 'system'),
          QuestionGenerationMessage(role: 'user', content: 'user'),
        ],
      );

      expect(result, 'What snack could start a debate?');
      await requestHandled.future;
    });

    test('turns non-200 responses into friendly failures', () async {
      server.listen((request) async {
        request.response.statusCode = 500;
        request.response.write('server error');
        await request.response.close();
      });

      final client = GroqQuestionGenerationApiClient(
        apiKey: 'test-key',
        baseUri: baseUri,
        httpClient: HttpClient(),
      );
      addTearDown(client.close);

      expect(
        () => client.generateQuestion(
          model: 'llama-3.3-70b-versatile',
          messages: const [
            QuestionGenerationMessage(role: 'system', content: 'system'),
          ],
        ),
        throwsA(
          isA<QuestionGenerationApiException>().having(
            (error) => error.message,
            'message',
            'We could not generate a question right now. Please try again.',
          ),
        ),
      );
    });

    test('truncates overlong questions to 15 words', () async {
      server.listen((request) async {
        request.response.statusCode = 200;
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode({
            'choices': [
              {
                'message': {
                  'content':
                      'What small habit instantly makes a room feel more awkward when someone walks in unexpectedly tonight?',
                },
              },
            ],
          }),
        );
        await request.response.close();
      });

      final client = GroqQuestionGenerationApiClient(
        apiKey: 'test-key',
        baseUri: baseUri,
        httpClient: HttpClient(),
      );
      addTearDown(client.close);

      final result = await client.generateQuestion(
        model: 'llama-3.3-70b-versatile',
        messages: const [
          QuestionGenerationMessage(role: 'system', content: 'system'),
          QuestionGenerationMessage(role: 'user', content: 'user'),
        ],
      );

      expect(
        result,
        'What small habit instantly makes a room feel more awkward when someone walks in unexpectedly?',
      );
      expect(result.split(RegExp(r'\s+')), hasLength(15));
    });
  });

  group('GroqQuestionGenerationService', () {
    test(
      'builds the selected deck prompt and reserves an attempt before calling the API',
      () async {
        final now = DateTime(2026, 5, 31, 12, 0);
        final usageStore = _FakeUsageStore(
          QuestionGenerationUsageState(
            attemptCount: 0,
            limitReachedAt: null,
            updatedAt: now,
          ),
        );
        final apiClient = _RecordingApiClient('What question belongs here?');
        final service = GroqQuestionGenerationService(
          apiClient: apiClient,
          usageStore: usageStore,
          connectivityChecker: const _FakeConnectivityChecker(true),
          now: () => now,
        );

        final result = await service.generateQuestion(
          deck: deck,
          excludedQuestions: const ['What snack could start a debate?'],
        );

        expect(result, 'What question belongs here?');
        expect(usageStore.readCalls, 1);
        expect(usageStore.reserveCalls, 1);
        expect(apiClient.calls, 1);
        expect(apiClient.model, 'llama-3.3-70b-versatile');
        expect(apiClient.messages, isNotNull);
        expect(apiClient.messages, hasLength(2));
        expect(apiClient.messages!.first.role, 'system');
        expect(apiClient.messages!.last.role, 'user');
        expect(
          apiClient.messages!.first.content,
          contains('Keep it to 15 words or fewer.'),
        );
        expect(
          apiClient.messages!.first.content,
          contains('End with a question mark.'),
        );
        expect(
          apiClient.messages!.last.content,
          contains('Deck title: Chaos Mode'),
        );
        expect(
          apiClient.messages!.last.content,
          contains(
            'Deck description: Unhinged party stories and unserious confessions',
          ),
        );
        expect(
          apiClient.messages!.last.content,
          contains("What's your most chaotic online purchase?"),
        );
        expect(
          apiClient.messages!.last.content,
          contains('- What snack could start a debate?'),
        );
      },
    );

    test('stops before the API when offline', () async {
      final now = DateTime(2026, 5, 31, 12, 0);
      final usageStore = _FakeUsageStore(
        QuestionGenerationUsageState(
          attemptCount: 0,
          limitReachedAt: null,
          updatedAt: now,
        ),
      );
      final apiClient = _RecordingApiClient('unused');
      final service = GroqQuestionGenerationService(
        apiClient: apiClient,
        usageStore: usageStore,
        connectivityChecker: const _FakeConnectivityChecker(false),
        now: () => now,
      );

      await expectLater(
        service.generateQuestion(deck: deck),
        throwsA(isA<QuestionGenerationOfflineException>()),
      );
      expect(usageStore.readCalls, 1);
      expect(usageStore.reserveCalls, 0);
      expect(apiClient.calls, 0);
    });

    test('blocks the API when the usage limit is already active', () async {
      final now = DateTime(2026, 5, 31, 12, 0);
      final usageStore = _FakeUsageStore(
        QuestionGenerationUsageState(
          attemptCount: kQuestionGenerationMaxAttempts,
          limitReachedAt: now.subtract(const Duration(minutes: 15)),
          updatedAt: now,
        ),
      );
      final apiClient = _RecordingApiClient('unused');
      final service = GroqQuestionGenerationService(
        apiClient: apiClient,
        usageStore: usageStore,
        connectivityChecker: const _FakeConnectivityChecker(true),
        now: () => now,
      );

      await expectLater(
        service.generateQuestion(deck: deck),
        throwsA(
          isA<QuestionGenerationLimitExceededException>().having(
            (error) => error.retryAt,
            'retryAt',
            now.add(const Duration(minutes: 45)),
          ),
        ),
      );
      expect(usageStore.readCalls, 1);
      expect(usageStore.reserveCalls, 0);
      expect(apiClient.calls, 0);
    });

    test('turns unexpected API failures into friendly errors', () async {
      final now = DateTime(2026, 5, 31, 12, 0);
      final usageStore = _FakeUsageStore(
        QuestionGenerationUsageState(
          attemptCount: 0,
          limitReachedAt: null,
          updatedAt: now,
        ),
      );
      final apiClient = _RecordingApiClient(
        'unused',
        error: StateError('boom'),
      );
      final service = GroqQuestionGenerationService(
        apiClient: apiClient,
        usageStore: usageStore,
        connectivityChecker: const _FakeConnectivityChecker(true),
        now: () => now,
      );

      await expectLater(
        service.generateQuestion(deck: deck),
        throwsA(
          isA<QuestionGenerationApiException>().having(
            (error) => error.message,
            'message',
            'We could not generate a question right now. Please try again.',
          ),
        ),
      );
      expect(usageStore.readCalls, 1);
      expect(usageStore.reserveCalls, 1);
      expect(apiClient.calls, 1);
    });
  });
}

class _FakeConnectivityChecker
    implements QuestionGenerationConnectivityChecker {
  const _FakeConnectivityChecker(this.canConnect);

  final bool canConnect;

  @override
  Future<bool> hasConnection() async => canConnect;
}

class _FakeUsageStore implements QuestionGenerationUsageStore {
  _FakeUsageStore(this._state);

  final QuestionGenerationUsageState _state;
  int readCalls = 0;
  int reserveCalls = 0;

  @override
  Future<QuestionGenerationUsageState> readStatus() async {
    readCalls++;
    return _state;
  }

  @override
  Future<QuestionGenerationUsageState> reserveAttempt() async {
    reserveCalls++;
    return _state;
  }
}

class _RecordingApiClient implements QuestionGenerationApiClient {
  _RecordingApiClient(this.response, {this.error});

  final String response;
  final Object? error;

  int calls = 0;
  String? model;
  List<QuestionGenerationMessage>? messages;

  @override
  Future<String> generateQuestion({
    required String model,
    required List<QuestionGenerationMessage> messages,
  }) async {
    calls++;
    this.model = model;
    this.messages = List<QuestionGenerationMessage>.unmodifiable(messages);

    if (error != null) {
      throw error!;
    }

    return response;
  }

  @override
  void close() {}
}
