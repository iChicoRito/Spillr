import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/screens/play_page_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_flow_screen.dart';
import '../../features/startup/presentation/screens/startup_gate_screen.dart';

abstract final class AppRoutes {
  static const startup = '/';
  static const onboarding = '/onboarding';
  static const home = '/home';
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
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
