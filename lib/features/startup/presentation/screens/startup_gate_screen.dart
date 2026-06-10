import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/app_router.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../shared/widgets/fallback_state_view.dart';
import '../../../onboarding/presentation/providers/onboarding_providers.dart';

class StartupGateScreen extends ConsumerWidget {
  const StartupGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(onboardingProfileProvider);
    final notifications = ref.read(notificationServiceProvider);

    return Scaffold(
      body: SafeArea(
        child: profileAsync.when(
          data: (profile) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!context.mounted) {
                return;
              }
              if (profile != null && profile.notificationsEnabled) {
                unawaited(
                  _topUpNotifications(notifications, profile.displayName),
                );
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

Future<void> _topUpNotifications(
  AppNotificationScheduler notifications,
  String displayName,
) async {
  try {
    await notifications.topUpIfNeeded(displayName: displayName);
  } catch (error, stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'spillr startup',
        context: ErrorDescription('while topping up notifications'),
      ),
    );
  }
}
