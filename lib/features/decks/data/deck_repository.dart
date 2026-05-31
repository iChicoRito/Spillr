import 'package:drift/drift.dart';
import 'package:flutter/material.dart';

import '../../../core/database/app_database.dart';
import '../../../core/theme/app_colors.dart';
import '../../game/data/spillr_decks.dart';
import '../../game/domain/spillr_deck.dart';
import '../domain/deck_catalog.dart';
import '../domain/deck_question_item.dart';

class DeckRepository {
  DeckRepository(this._database);

  final AppDatabase _database;

  Future<void> ensureBuiltInQuestionsSeeded() async {
    final existingKeys =
        await (_database.selectOnly(_database.deckQuestionEntries)
              ..addColumns([_database.deckQuestionEntries.builtInQuestionKey])
              ..where(_database.deckQuestionEntries.isBuiltIn.equals(true)))
            .map(
              (row) =>
                  row.read(_database.deckQuestionEntries.builtInQuestionKey),
            )
            .get();
    final existingKeySet = existingKeys.whereType<String>().toSet();
    final now = DateTime.now();
    final entries = <DeckQuestionEntriesCompanion>[];

    for (final deck in _seedableBuiltInDecks) {
      for (var index = 0; index < deck.questions.length; index++) {
        final builtInKey = _builtInQuestionKey(deck.id, index);
        if (existingKeySet.contains(builtInKey)) {
          continue;
        }

        entries.add(
          DeckQuestionEntriesCompanion.insert(
            deckId: deck.id,
            builtInQuestionKey: Value(builtInKey),
            questionText: deck.questions[index],
            sortOrder: index,
            isBuiltIn: const Value(true),
            isDeleted: const Value(false),
            createdAt: now,
            updatedAt: now,
          ),
        );
      }
    }

    if (entries.isNotEmpty) {
      await _database.batch(
        (batch) => batch.insertAll(_database.deckQuestionEntries, entries),
      );
    }
  }

  Stream<List<CustomDeck>> watchCustomDecks() => _database.watchCustomDecks();

  Stream<List<DeckQuestionItem>> watchDeckQuestions(String deckId) async* {
    await ensureBuiltInQuestionsSeeded();
    if (deckId == _wildcardDeck.id) {
      yield* watchAllQuestions().map(
        (questions) => questions
            .where((question) => question.deckId != _wildcardDeck.id)
            .toList(),
      );
      return;
    }

    yield* (_database.select(_database.deckQuestionEntries)
          ..where(
            (table) =>
                table.deckId.equals(deckId) & table.isDeleted.equals(false),
          )
          ..orderBy([(table) => OrderingTerm.asc(table.sortOrder)]))
        .watch()
        .map((rows) => rows.map(_mapQuestionItem).toList(growable: false));
  }

  Stream<List<DeckQuestionItem>> watchAllQuestions() async* {
    await ensureBuiltInQuestionsSeeded();
    yield* (_database.select(_database.deckQuestionEntries)
          ..where((table) => table.isDeleted.equals(false))
          ..orderBy([
            (table) => OrderingTerm.asc(table.deckId),
            (table) => OrderingTerm.asc(table.sortOrder),
          ]))
        .watch()
        .map((rows) => rows.map(_mapQuestionItem).toList(growable: false));
  }

  Future<List<DeckQuestionItem>> fetchDeckQuestions(String deckId) async {
    await ensureBuiltInQuestionsSeeded();
    if (deckId == _wildcardDeck.id) {
      final allQuestions = await fetchAllQuestions();
      return allQuestions
          .where((question) => question.deckId != _wildcardDeck.id)
          .toList(growable: false);
    }

    final rows =
        await (_database.select(_database.deckQuestionEntries)
              ..where(
                (table) =>
                    table.deckId.equals(deckId) & table.isDeleted.equals(false),
              )
              ..orderBy([(table) => OrderingTerm.asc(table.sortOrder)]))
            .get();

    return rows.map(_mapQuestionItem).toList(growable: false);
  }

  Future<List<DeckQuestionItem>> fetchAllQuestions() async {
    await ensureBuiltInQuestionsSeeded();
    final rows =
        await (_database.select(_database.deckQuestionEntries)
              ..where((table) => table.isDeleted.equals(false))
              ..orderBy([
                (table) => OrderingTerm.asc(table.deckId),
                (table) => OrderingTerm.asc(table.sortOrder),
              ]))
            .get();
    return rows.map(_mapQuestionItem).toList(growable: false);
  }

  Future<List<DeckListItem>> fetchDeckList() async {
    final customDecks = await _database.watchCustomDecks().first;
    final questions = await fetchAllQuestions();
    return buildDeckList(customDecks: customDecks, questions: questions);
  }

  List<DeckListItem> buildDeckList({
    required List<CustomDeck> customDecks,
    required List<DeckQuestionItem> questions,
  }) {
    final countsByDeck = <String, int>{};
    for (final question in questions) {
      countsByDeck.update(
        question.deckId,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }

    final customItems = customDecks
        .map(
          (deck) => DeckListItem(
            id: _customDeckId(deck.id),
            title: deck.name,
            cardCount: countsByDeck[_customDeckId(deck.id)] ?? 0,
            icon: CustomDeckIconKey.fromValue(deck.iconKey).icon,
            avatarColor: CustomDeckColorKey.fromValue(deck.colorKey).color,
            isBuiltIn: false,
            customIconKey: CustomDeckIconKey.fromValue(deck.iconKey),
            customColorKey: CustomDeckColorKey.fromValue(deck.colorKey),
          ),
        )
        .toList(growable: false);

    final builtInItems = spillrDecks
        .map(
          (deck) => DeckListItem(
            id: deck.id,
            title: deck.title,
            cardCount: deck.id == _wildcardDeck.id
                ? _seedableBuiltInDecks.fold<int>(
                    0,
                    (sum, item) => sum + (countsByDeck[item.id] ?? 0),
                  )
                : countsByDeck[deck.id] ?? 0,
            icon: CustomDeckIconKey.cards.icon,
            avatarColor: deck.backgroundColor,
            isBuiltIn: true,
          ),
        )
        .toList(growable: false);

    return [...customItems, ...builtInItems];
  }

  List<SpillrDeck> buildPlayableDecks({
    required List<CustomDeck> customDecks,
    required List<DeckQuestionItem> questions,
  }) {
    final questionsByDeck = <String, List<String>>{};
    for (final question in questions) {
      questionsByDeck
          .putIfAbsent(question.deckId, () => <String>[])
          .add(question.text);
    }

    final customPlayableDecks = customDecks
        .map(
          (deck) => _buildCustomPlayableDeck(
            deck: deck,
            questions:
                questionsByDeck[_customDeckId(deck.id)] ?? const <String>[],
          ),
        )
        .toList(growable: false);

    final builtInPlayableDecks = spillrDecks
        .map((deck) {
          if (deck.id == _wildcardDeck.id) {
            return deck.copyWith(
              questions: List<String>.unmodifiable(
                _seedableBuiltInDecks.expand(
                  (sourceDeck) =>
                      questionsByDeck[sourceDeck.id] ?? const <String>[],
                ),
              ),
            );
          }

          return deck.copyWith(
            questions: List<String>.unmodifiable(
              questionsByDeck[deck.id] ?? const <String>[],
            ),
          );
        })
        .toList(growable: false);

    return [...customPlayableDecks, ...builtInPlayableDecks];
  }

  Future<String> createCustomDeck({
    required String rawName,
    required CustomDeckIconKey iconKey,
    required CustomDeckColorKey colorKey,
  }) async {
    final name = rawName.trim();
    final id = await _database
        .into(_database.customDecks)
        .insert(
          CustomDecksCompanion.insert(
            name: name,
            iconKey: iconKey.value,
            colorKey: colorKey.value,
            createdAt: DateTime.now(),
          ),
        );
    return _customDeckId(id);
  }

  Future<void> updateCustomDeck({
    required String deckId,
    required String rawName,
    required CustomDeckIconKey iconKey,
    required CustomDeckColorKey colorKey,
  }) async {
    await _database.updateCustomDeck(
      id: _parseCustomDeckDbId(deckId),
      name: rawName.trim(),
      iconKey: iconKey.value,
      colorKey: colorKey.value,
    );
  }

  Future<void> deleteCustomDeck(String deckId) async {
    await (_database.delete(
      _database.deckQuestionEntries,
    )..where((table) => table.deckId.equals(deckId))).go();
    await _database.deleteCustomDeck(_parseCustomDeckDbId(deckId));
  }

  Future<DeckQuestionItem> addQuestion({
    required String deckId,
    required String rawText,
  }) async {
    final nextSortOrder = await _nextSortOrder(deckId);
    final now = DateTime.now();
    final id = await _database
        .into(_database.deckQuestionEntries)
        .insert(
          DeckQuestionEntriesCompanion.insert(
            deckId: deckId,
            builtInQuestionKey: const Value.absent(),
            questionText: rawText.trim(),
            sortOrder: nextSortOrder,
            isBuiltIn: const Value(false),
            isDeleted: const Value(false),
            createdAt: now,
            updatedAt: now,
          ),
        );

    return DeckQuestionItem(
      id: id,
      deckId: deckId,
      text: rawText.trim(),
      sortOrder: nextSortOrder,
      isBuiltIn: false,
    );
  }

  Future<String> updateQuestion({
    required int id,
    required String rawText,
  }) async {
    final deckId = await _deckIdForQuestion(id);
    await (_database.update(
      _database.deckQuestionEntries,
    )..where((table) => table.id.equals(id))).write(
      DeckQuestionEntriesCompanion(
        questionText: Value(rawText.trim()),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return deckId;
  }

  Future<String> deleteQuestion(int id) async {
    final deckId = await _deckIdForQuestion(id);
    await (_database.update(
      _database.deckQuestionEntries,
    )..where((table) => table.id.equals(id))).write(
      DeckQuestionEntriesCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
    return deckId;
  }

  Future<SpillrDeck> resolvePlayableDeck(String deckId) async {
    await ensureBuiltInQuestionsSeeded();
    if (deckId == _wildcardDeck.id) {
      final questions = await fetchDeckQuestions(deckId);
      return _wildcardDeck.copyWith(
        questions: List<String>.unmodifiable(
          questions.map((question) => question.text),
        ),
      );
    }

    final builtInDeck = _builtInDeckById(deckId);
    if (builtInDeck != null) {
      final questions = await fetchDeckQuestions(deckId);
      return builtInDeck.copyWith(
        questions: List<String>.unmodifiable(
          questions.map((question) => question.text),
        ),
      );
    }

    final customDeck = await _fetchCustomDeckById(deckId);
    final questions = await fetchDeckQuestions(deckId);
    return _buildCustomPlayableDeck(
      deck: customDeck,
      questions: questions
          .map((question) => question.text)
          .toList(growable: false),
    );
  }

  Future<CustomDeck> _fetchCustomDeckById(String deckId) async {
    final dbId = _parseCustomDeckDbId(deckId);
    return (_database.select(
      _database.customDecks,
    )..where((table) => table.id.equals(dbId))).getSingle();
  }

  Future<String> _deckIdForQuestion(int id) async {
    final row = await (_database.select(
      _database.deckQuestionEntries,
    )..where((table) => table.id.equals(id))).getSingle();
    return row.deckId;
  }

  Future<int> _nextSortOrder(String deckId) async {
    final row =
        await (_database.selectOnly(_database.deckQuestionEntries)
              ..addColumns([_database.deckQuestionEntries.sortOrder.max()])
              ..where(
                _database.deckQuestionEntries.deckId.equals(deckId) &
                    _database.deckQuestionEntries.isDeleted.equals(false),
              ))
            .getSingle();
    return (row.read(_database.deckQuestionEntries.sortOrder.max()) ?? -1) + 1;
  }

  DeckQuestionItem _mapQuestionItem(DeckQuestionEntry row) {
    return DeckQuestionItem(
      id: row.id,
      deckId: row.deckId,
      text: row.questionText,
      sortOrder: row.sortOrder,
      isBuiltIn: row.isBuiltIn,
    );
  }

  SpillrDeck _buildCustomPlayableDeck({
    required CustomDeck deck,
    required List<String> questions,
  }) {
    final colorKey = CustomDeckColorKey.fromValue(deck.colorKey);
    final palette = _CustomDeckPalette.fromColorKey(colorKey);
    return SpillrDeck(
      id: _customDeckId(deck.id),
      title: deck.name,
      description: 'Your custom tea set',
      questions: List<String>.unmodifiable(questions),
      backgroundColor: colorKey.color,
      borderColor: palette.borderColor,
      badgeColor: palette.badgeColor,
      badgeTextColor: palette.badgeTextColor,
      iconColor: palette.badgeTextColor,
      icon: CustomDeckIconKey.fromValue(deck.iconKey).icon,
      cardBorderColor: palette.borderColor,
    );
  }
}

class _CustomDeckPalette {
  const _CustomDeckPalette({
    required this.borderColor,
    required this.badgeColor,
    required this.badgeTextColor,
  });

  final Color borderColor;
  final Color badgeColor;
  final Color badgeTextColor;

  factory _CustomDeckPalette.fromColorKey(CustomDeckColorKey colorKey) {
    return switch (colorKey) {
      CustomDeckColorKey.blue => const _CustomDeckPalette(
        borderColor: AppColors.blue200,
        badgeColor: AppColors.blue100,
        badgeTextColor: AppColors.blue500,
      ),
      CustomDeckColorKey.amber => const _CustomDeckPalette(
        borderColor: AppColors.amber200,
        badgeColor: AppColors.amber100,
        badgeTextColor: AppColors.amber500,
      ),
      CustomDeckColorKey.teal => const _CustomDeckPalette(
        borderColor: AppColors.teal200,
        badgeColor: AppColors.teal100,
        badgeTextColor: AppColors.teal500,
      ),
      CustomDeckColorKey.red => const _CustomDeckPalette(
        borderColor: AppColors.red200,
        badgeColor: AppColors.red100,
        badgeTextColor: AppColors.red500,
      ),
      CustomDeckColorKey.violet => const _CustomDeckPalette(
        borderColor: AppColors.violet200,
        badgeColor: AppColors.violet100,
        badgeTextColor: AppColors.violet500,
      ),
      CustomDeckColorKey.pink => const _CustomDeckPalette(
        borderColor: AppColors.pink200,
        badgeColor: AppColors.pink100,
        badgeTextColor: AppColors.pink500,
      ),
      CustomDeckColorKey.purple => const _CustomDeckPalette(
        borderColor: AppColors.purple200,
        badgeColor: AppColors.purple100,
        badgeTextColor: AppColors.purple500,
      ),
      CustomDeckColorKey.cyan => const _CustomDeckPalette(
        borderColor: AppColors.cyan200,
        badgeColor: AppColors.cyan100,
        badgeTextColor: AppColors.cyan500,
      ),
    };
  }
}

String _builtInQuestionKey(String deckId, int index) => '$deckId::$index';

String _customDeckId(int dbId) => 'custom-$dbId';

int _parseCustomDeckDbId(String deckId) {
  return int.parse(deckId.replaceFirst('custom-', ''));
}

SpillrDeck? _builtInDeckById(String deckId) {
  for (final deck in spillrDecks) {
    if (deck.id == deckId) {
      return deck;
    }
  }
  return null;
}

final _wildcardDeck = spillrDecks.last;
final _seedableBuiltInDecks = spillrDecks
    .where((deck) => deck.id != _wildcardDeck.id)
    .toList(growable: false);
