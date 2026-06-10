import 'dart:async';

import 'package:flutter/foundation.dart';

import 'app_audio_controller.dart';
import 'app_audio_preferences_repository.dart';
import 'audioplayers_app_audio_engine.dart';
import 'spillr_app_audio_controller.dart';

final appAudioProviderOverrides = [
  appAudioControllerProvider.overrideWith((ref) {
    final repo = ref.watch(appAudioPreferencesRepositoryProvider);
    final controller = SpillrAppAudioController(
      trackRotator: repo,
      audioEngine: AudioplayersAppAudioEngine(),
    );

    // Apply persisted volume settings immediately after controller is created
    repo
        .fetchVolumeSettings()
        .then((settings) => controller.updateVolumes(settings))
        .catchError((Object error, StackTrace stackTrace) {
          FlutterError.reportError(
            FlutterErrorDetails(
              exception: error,
              stack: stackTrace,
              library: 'spillr audio',
              context: ErrorDescription(
                'while applying persisted audio settings',
              ),
            ),
          );
        });

    ref.onDispose(() => unawaited(controller.dispose()));
    return controller;
  }),
];
