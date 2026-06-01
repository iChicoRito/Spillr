import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_audio_controller.dart';

class AppAudioRouteCoordinator extends ConsumerStatefulWidget {
  const AppAudioRouteCoordinator({
    required this.router,
    required this.child,
    super.key,
  });

  final GoRouter router;
  final Widget child;

  @override
  ConsumerState<AppAudioRouteCoordinator> createState() =>
      _AppAudioRouteCoordinatorState();
}

class _AppAudioRouteCoordinatorState
    extends ConsumerState<AppAudioRouteCoordinator> {
  String? _lastLocation;

  @override
  void initState() {
    super.initState();
    widget.router.routeInformationProvider.addListener(_handleRouteChange);
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleRouteChange());
  }

  @override
  void didUpdateWidget(covariant AppAudioRouteCoordinator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.router == widget.router) {
      return;
    }

    oldWidget.router.routeInformationProvider.removeListener(
      _handleRouteChange,
    );
    widget.router.routeInformationProvider.addListener(_handleRouteChange);
    _lastLocation = null;
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleRouteChange());
  }

  @override
  void dispose() {
    widget.router.routeInformationProvider.removeListener(_handleRouteChange);
    super.dispose();
  }

  void _handleRouteChange() {
    final uri = widget.router.routeInformationProvider.value.uri;
    final location = uri.path.isEmpty ? '/' : uri.path;
    if (location == _lastLocation) {
      return;
    }

    _lastLocation = location;
    unawaited(ref.read(appAudioControllerProvider).syncRoute(location));
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
