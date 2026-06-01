import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database_provider.dart';
import '../../../game/domain/spillr_deck.dart';
import '../../data/deck_repository.dart';
import '../../data/question_generation_service.dart';
import '../../domain/deck_catalog.dart';
import '../../domain/deck_question_item.dart';

const _groqApiKey = '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';

final deckRepositoryProvider = Provider<DeckRepository>((ref) {
  final database = ref.watch(appDatabaseProvider);
  return DeckRepository(database);
});

final questionGenerationUsageRepositoryProvider =
    Provider<QuestionGenerationUsageStore>((ref) {
      final database = ref.watch(appDatabaseProvider);
      return DriftQuestionGenerationUsageRepository(database);
    });

final questionGenerationUsageProvider =
    FutureProvider<QuestionGenerationUsageState>((ref) {
      final repository = ref.watch(questionGenerationUsageRepositoryProvider);
      return repository.readStatus();
    });

final questionGenerationServiceProvider = Provider<QuestionGenerationService>((
  ref,
) {
  final usageStore = ref.watch(questionGenerationUsageRepositoryProvider);
  final apiClient = GroqQuestionGenerationApiClient(apiKey: _groqApiKey);
  final service = GroqQuestionGenerationService(
    apiClient: apiClient,
    usageStore: usageStore,
    connectivityChecker: const DefaultQuestionGenerationConnectivityChecker(),
  );

  ref.onDispose(apiClient.close);
  return service;
});

final deckFilterProvider =
    NotifierProvider<DeckFilterNotifier, DeckFilterSelection>(
      DeckFilterNotifier.new,
    );

final deckFilterChipsProvider = Provider<List<DeckFilterChip>>((ref) {
  final customDecksAsync = ref.watch(customDecksProvider);

  final chips = <DeckFilterChip>[
    ...DeckFilter.values.map((filter) => BuiltInDeckFilterChip(filter: filter)),
  ];

  if (customDecksAsync.hasValue) {
    chips.addAll(
      customDecksAsync.requireValue.map(
        (deck) =>
            CustomDeckFilterChip(deckId: 'custom-${deck.id}', label: deck.name),
      ),
    );
  }

  return chips;
});

final customDecksProvider = StreamProvider((ref) {
  final repository = ref.watch(deckRepositoryProvider);
  return repository.watchCustomDecks();
});

final allDeckQuestionsProvider = StreamProvider<List<DeckQuestionItem>>((ref) {
  final repository = ref.watch(deckRepositoryProvider);
  return repository.watchAllQuestions();
});

final deckQuestionsProvider =
    StreamProvider.family<List<DeckQuestionItem>, String>((ref, deckId) {
      final repository = ref.watch(deckRepositoryProvider);
      return repository.watchDeckQuestions(deckId);
    });

final resolvedDeckProvider = FutureProvider.family<SpillrDeck, String>((
  ref,
  deckId,
) {
  final repository = ref.watch(deckRepositoryProvider);
  return repository.resolvePlayableDeck(deckId);
});

final deckListProvider = Provider<AsyncValue<List<DeckListItem>>>((ref) {
  final filter = ref.watch(deckFilterProvider);
  final customDecksAsync = ref.watch(customDecksProvider);
  final questionsAsync = ref.watch(allDeckQuestionsProvider);
  final repository = ref.watch(deckRepositoryProvider);

  if (customDecksAsync.hasError) {
    return AsyncValue.error(
      customDecksAsync.error!,
      customDecksAsync.stackTrace!,
    );
  }
  if (questionsAsync.hasError) {
    return AsyncValue.error(questionsAsync.error!, questionsAsync.stackTrace!);
  }
  if (customDecksAsync.isLoading || questionsAsync.isLoading) {
    return const AsyncValue.loading();
  }

  return AsyncValue.data(
    _filterDeckList(
      repository.buildDeckList(
        customDecks: customDecksAsync.requireValue,
        questions: questionsAsync.requireValue,
      ),
      filter,
    ),
  );
});

final playableDecksProvider = Provider<AsyncValue<List<SpillrDeck>>>((ref) {
  final customDecksAsync = ref.watch(customDecksProvider);
  final questionsAsync = ref.watch(allDeckQuestionsProvider);
  final repository = ref.watch(deckRepositoryProvider);

  if (customDecksAsync.hasError) {
    return AsyncValue.error(
      customDecksAsync.error!,
      customDecksAsync.stackTrace!,
    );
  }
  if (questionsAsync.hasError) {
    return AsyncValue.error(questionsAsync.error!, questionsAsync.stackTrace!);
  }
  if (customDecksAsync.isLoading || questionsAsync.isLoading) {
    return const AsyncValue.loading();
  }

  return AsyncValue.data(
    repository.buildPlayableDecks(
      customDecks: customDecksAsync.requireValue,
      questions: questionsAsync.requireValue,
    ),
  );
});

final deckCreationControllerProvider =
    AsyncNotifierProvider<DeckCreationController, void>(
      DeckCreationController.new,
    );

final customDeckMutationControllerProvider =
    AsyncNotifierProvider<CustomDeckMutationController, void>(
      CustomDeckMutationController.new,
    );

final questionMutationControllerProvider =
    AsyncNotifierProvider<QuestionMutationController, void>(
      QuestionMutationController.new,
    );

final questionGenerationControllerProvider =
    AsyncNotifierProvider<QuestionGenerationController, String?>(
      QuestionGenerationController.new,
    );

class DeckFilterNotifier extends Notifier<DeckFilterSelection> {
  @override
  DeckFilterSelection build() => const DeckFilterSelection.all();

  void select(DeckFilterSelection filter) {
    state = filter;
  }
}

class DeckCreationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<String> createDeck({
    required String rawName,
    required CustomDeckIconKey iconKey,
    required CustomDeckColorKey colorKey,
  }) async {
    state = const AsyncLoading();
    late final String deckId;
    state = await AsyncValue.guard(() async {
      final repository = ref.read(deckRepositoryProvider);
      deckId = await repository.createCustomDeck(
        rawName: rawName,
        iconKey: iconKey,
        colorKey: colorKey,
      );
    });
    return deckId;
  }
}

class CustomDeckMutationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> updateDeck({
    required String deckId,
    required String rawName,
    required CustomDeckIconKey iconKey,
    required CustomDeckColorKey colorKey,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(deckRepositoryProvider)
          .updateCustomDeck(
            deckId: deckId,
            rawName: rawName,
            iconKey: iconKey,
            colorKey: colorKey,
          );
    });
  }

  Future<void> deleteDeck(String deckId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(deckRepositoryProvider).deleteCustomDeck(deckId);
    });
  }
}

class QuestionMutationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addQuestion({
    required String deckId,
    required String rawText,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref
          .read(deckRepositoryProvider)
          .addQuestion(deckId: deckId, rawText: rawText);
      _invalidateResolvedDecks(deckId);
    });
  }

  Future<void> updateQuestion({
    required int id,
    required String rawText,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final deckId = await ref
          .read(deckRepositoryProvider)
          .updateQuestion(id: id, rawText: rawText);
      _invalidateResolvedDecks(deckId);
    });
  }

  Future<void> deleteQuestion(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final deckId = await ref.read(deckRepositoryProvider).deleteQuestion(id);
      _invalidateResolvedDecks(deckId);
    });
  }

  void _invalidateResolvedDecks(String deckId) {
    ref.invalidate(resolvedDeckProvider(deckId));
    if (deckId != 'wildcard-tea') {
      ref.invalidate(resolvedDeckProvider('wildcard-tea'));
    }
  }
}

class QuestionGenerationController extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async => null;

  Future<String> generateQuestion({
    required SpillrDeck deck,
    List<String> excludedQuestions = const [],
  }) async {
    state = const AsyncLoading();
    try {
      final question = await ref
          .read(questionGenerationServiceProvider)
          .generateQuestion(deck: deck, excludedQuestions: excludedQuestions);
      state = AsyncData(question);
      return question;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      Error.throwWithStackTrace(error, stackTrace);
    } finally {
      ref.invalidate(questionGenerationUsageProvider);
    }
  }
}

List<DeckListItem> _filterDeckList(
  List<DeckListItem> items,
  DeckFilterSelection filter,
) {
  if (filter is AllDeckFilterSelection) {
    return items;
  }

  if (filter is BuiltInDeckFilterSelection) {
    final builtInDeckId = filter.filter.builtInDeckId;
    if (builtInDeckId == null) {
      return items;
    }
    return items
        .where((item) => item.id == builtInDeckId)
        .toList(growable: false);
  }

  if (filter is CustomDeckFilterSelection) {
    return items
        .where((item) => item.id == filter.deckId)
        .toList(growable: false);
  }

  return items;
}
