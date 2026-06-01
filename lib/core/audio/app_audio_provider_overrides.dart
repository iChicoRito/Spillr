import 'dart:async';

import 'app_audio_controller.dart';
import 'app_audio_preferences_repository.dart';
import 'audioplayers_app_audio_engine.dart';
import 'spillr_app_audio_controller.dart';

final appAudioProviderOverrides = [
  appAudioControllerProvider.overrideWith((ref) {
    final controller = SpillrAppAudioController(
      trackRotator: ref.watch(appAudioPreferencesRepositoryProvider),
      audioEngine: AudioplayersAppAudioEngine(),
    );
    ref.onDispose(() => unawaited(controller.dispose()));
    return controller;
  }),
];
