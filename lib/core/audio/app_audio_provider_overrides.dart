import 'dart:async';

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
        .then((settings) => controller.updateVolumes(settings));

    ref.onDispose(() => unawaited(controller.dispose()));
    return controller;
  }),
];
