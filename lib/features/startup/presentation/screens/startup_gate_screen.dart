import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../shared/widgets/fallback_state_view.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';

class StartupGateScreen extends ConsumerWidget {
  const StartupGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(onboardingProfileProvider);

    return Scaffold(
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) {
                return;
              }
              context.go(
                profile == null ? AppRoutes.onboarding : AppRoutes.home,
              );
            });
            return const FallbackStateView.loading();
          },
          loading: () => const FallbackStateView.loading(),
          error: (error, stackTrace) => const FallbackStateView.error(
            message: 'Unable to open your local profile.',
          ),
        ),
      ),
    );
  }
}
