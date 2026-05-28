import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/decks/presentation/screens/decks_screen.dart';
import '../../features/game/presentation/models/game_ending_arguments.dart';
import '../../features/game/presentation/screens/ending_page_screen.dart';
import '../../features/game/presentation/screens/game_page_screen.dart';
import '../../features/game/presentation/screens/preparation_page_screen.dart';
import '../../features/home/presentation/screens/play_page_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_flow_screen.dart';
import '../../features/startup/presentation/screens/startup_gate_screen.dart';

abstract final class AppRoutes {
  static const startup = '/';
  static const onboarding = '/onboarding';
  static const decks = '/decks';
  static const home = '/home';
  static const preparation = '/preparation';
  static const game = '/game';
  static const ending = '/ending';
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
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const PlayPageScreen(),
      ),
      GoRoute(
        path: AppRoutes.decks,
        builder: (context, state) => const DecksScreen(),
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

          return EndingPageScreen(
            deck: args.deck,
            result: args.result,
          );
        },
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
