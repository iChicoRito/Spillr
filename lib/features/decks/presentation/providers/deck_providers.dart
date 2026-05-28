import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/app_database.dart';
import '../../../game/data/spillr_decks.dart';
import '../../../game/domain/spillr_deck.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';
import '../../domain/deck_catalog.dart';

final deckFilterProvider = NotifierProvider<DeckFilterNotifier, DeckFilter>(
  DeckFilterNotifier.new,
);

final customDecksProvider = StreamProvider((ref) {
  final database = ref.watch(appDatabaseProvider);
  return database.watchCustomDecks();
});

final deckListProvider = Provider<AsyncValue<List<DeckListItem>>>((ref) {
  final filter = ref.watch(deckFilterProvider);
  final customDecksAsync = ref.watch(customDecksProvider);

  return customDecksAsync.whenData((customDecks) {
    final filteredBuiltInDecks = filter == DeckFilter.all
        ? spillrDecks
        : spillrDecks
              .where((deck) => deck.id == filter.builtInDeckId)
              .toList(growable: false);

    final builtInItems = filteredBuiltInDecks
        .map(DeckListItemFactory.fromSpillrDeck)
        .toList(growable: false);
    final customItems = filter == DeckFilter.all
        ? customDecks
              .map(DeckListItemFactory.fromCustomDeck)
              .toList(growable: false)
        : const <DeckListItem>[];

    return <DeckListItem>[...customItems, ...builtInItems];
  });
});

final deckCreationControllerProvider =
    AsyncNotifierProvider<DeckCreationController, void>(
      DeckCreationController.new,
    );

class DeckFilterNotifier extends Notifier<DeckFilter> {
  @override
  DeckFilter build() => DeckFilter.all;

  void select(DeckFilter filter) {
    state = filter;
  }
}

class DeckCreationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> createDeck({
    required String rawName,
    required CustomDeckIconKey iconKey,
    required CustomDeckColorKey colorKey,
  }) async {
    final name = rawName.trim();

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final database = ref.read(appDatabaseProvider);
      await database.insertCustomDeck(
        name: name,
        iconKey: iconKey.value,
        colorKey: colorKey.value,
      );
    });
  }
}

abstract final class DeckListItemFactory {
  static DeckListItem fromSpillrDeck(SpillrDeck deck) {
    return DeckListItem(
      id: deck.id,
      title: deck.title,
      cardCount: deck.questions.length,
      icon: CustomDeckIconKey.cards.icon,
      avatarColor: deck.backgroundColor,
      isBuiltIn: true,
    );
  }

  static DeckListItem fromCustomDeck(CustomDeck deck) {
    return DeckListItem(
      id: 'custom-${deck.id}',
      title: deck.name,
      cardCount: 0,
      icon: CustomDeckIconKey.fromValue(deck.iconKey).icon,
      avatarColor: CustomDeckColorKey.fromValue(deck.colorKey).color,
      isBuiltIn: false,
    );
  }
}
