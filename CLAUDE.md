# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Run the app (choose a connected device/emulator)
flutter run

# Build for Android debug
flutter build apk --debug

# Analyze / lint
flutter analyze

# Run tests
flutter test

# Run a single test file
flutter test test/path/to/file_test.dart

# Regenerate Drift DB code after schema changes
dart run build_runner build --delete-conflicting-outputs
```

## Architecture

**Stack:** Flutter + Riverpod (state) + GoRouter (navigation) + Drift/SQLite (persistence) + Groq API (AI question generation).

### Feature structure

Code lives under `lib/` organized by layer inside each feature:

```
lib/
  app/           # App bootstrap, theme, router, tab shell
  core/          # Cross-cutting: audio, database, theme
  features/
    decks/       # Deck catalog, custom decks, question CRUD, AI generation
    game/        # Game session state, preparation, gameplay, ending
    home/        # Play page (deck picker)
    onboarding/  # First-run flow
    profile/     # User profile & avatar selection
    startup/     # StartupGateScreen — redirects to onboarding or home
  shared/        # Reusable widgets
```

Each feature follows `domain / data / presentation` layers (domain = pure models, data = repositories/services, presentation = screens/providers/widgets).

### Routing

`AppRoutes` constants and the `appRouterProvider` (`GoRouter`) live in `lib/app/router/app_router.dart`. The three tab destinations (home `/home`, decks `/decks`, profile `/profile`) are wrapped in a `StatefulShellRoute`; game flow routes (`/preparation/:deckId`, `/game/:deckId`, `/ending`) are top-level and sit outside the shell.

### State management

All state is Riverpod. Key providers:
- `appDatabaseProvider` — singleton `AppDatabase` (Drift)
- `deckRepositoryProvider` — deck/question CRUD
- `questionGenerationServiceProvider` — wraps the Groq API client; rate-limited to 15 attempts per cooldown window
- `appAudioControllerProvider` — default is `NoopAppAudioController`; overridden at app startup via `appAudioProviderOverrides` with `SpillrAppAudioController` (audioplayers)

### Database

Drift database at `lib/core/database/app_database.dart`. Schema version is **6**. After any table/column change, run `dart run build_runner build --delete-conflicting-outputs` to regenerate `app_database.g.dart`. Migrations are additive `if (from < N)` blocks in `MigrationStrategy.onUpgrade`.

### Decks

Built-in decks are hardcoded in `lib/features/game/data/spillr_decks.dart` as `SpillrDeck` objects. Custom decks live in the `CustomDecks` table and are merged with built-ins by `DeckRepository.buildDeckList`. The `wildcard-tea` deck is special — it pools questions from all decks.

### AI question generation

`GroqQuestionGenerationService` (`lib/features/decks/data/question_generation_service.dart`) calls the Groq API (`llama-3.3-70b-versatile`). The API key is hardcoded in `lib/features/decks/presentation/providers/deck_providers.dart` (`_groqApiKey`). Usage is tracked in the `QuestionGenerationUsageEntries` table (cap: 15 attempts per cooldown).

### Audio

`AppAudioController` is an interface with a `NoopAppAudioController` default. The real implementation (`SpillrAppAudioController`) is injected at startup. `AppAudioRouteCoordinator.syncRoute` maps routes to BGM tracks and SFX.
