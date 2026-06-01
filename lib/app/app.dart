import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/audio/app_audio_route_coordinator.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class SpillrApp extends ConsumerWidget {
  const SpillrApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return AppAudioRouteCoordinator(
      router: router,
      child: MaterialApp.router(
        title: 'Spillr',
        theme: AppTheme.light(),
        routerConfig: router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
