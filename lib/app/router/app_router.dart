import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'spillr_tab_shell.dart';
import '../../features/decks/presentation/screens/decks_screen.dart';
import '../../features/decks/presentation/screens/questions_screen.dart';
import '../../features/game/presentation/models/game_ending_arguments.dart';
import '../../features/game/presentation/screens/ending_page_screen.dart';
import '../../features/game/presentation/screens/game_page_screen.dart';
import '../../features/game/presentation/screens/preparation_page_screen.dart';
import '../../features/home/presentation/screens/play_page_screen.dart';
import '../../features/profile/presentation/screens/play_history_screen.dart';
import '../../features/profile/presentation/screens/profile_page_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_flow_screen.dart';
import '../../features/startup/presentation/screens/startup_gate_screen.dart';

abstract final class AppRoutes {
  static const startup = '/';
  static const onboarding = '/onboarding';
  static const decks = '/decks';
  static const deckQuestions = '/decks/questions';
  static const home = '/home';
  static const profile = '/profile';
  static const preparation = '/preparation';
  static const game = '/game';
  static const ending = '/ending';
  static const playHistory = '/play-history';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.startup,
    routes: [
      GoRoute(
        path: AppRoutes.startup,
        builder: (context, state) => const StartupGateScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingFlowScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => SpillrTabShell(
          navigationShell: navigationShell,
          location: state.matchedLocation,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const PlayPageScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.decks,
                builder: (context, state) => const DecksScreen(),
                routes: [
                  GoRoute(
                    path: ':deckId/questions',
                    builder: (context, state) => QuestionsScreen(
                      deckId: state.pathParameters['deckId'] ?? 'no-dead-air',
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfilePageScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '${AppRoutes.preparation}/:deckId',
        builder: (context, state) => PreparationPageScreen(
          deckId: state.pathParameters['deckId'] ?? 'no-dead-air',
        ),
      ),
      GoRoute(
        path: '${AppRoutes.game}/:deckId',
        builder: (context, state) => GamePageScreen(
          initialDeckId: state.pathParameters['deckId'] ?? 'no-dead-air',
        ),
      ),
      GoRoute(
        path: AppRoutes.ending,
        builder: (context, state) {
          final args = state.extra;
          if (args is! GameEndingArguments) {
            return const PlayPageScreen();
          }

          return EndingPageScreen(deck: args.deck, result: args.result);
        },
      ),
      GoRoute(
        path: AppRoutes.playHistory,
        builder: (context, state) => const PlayHistoryScreen(),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
