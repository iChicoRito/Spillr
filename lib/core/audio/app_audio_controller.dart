import 'package:riverpod/riverpod.dart';

final appAudioControllerProvider = Provider<AppAudioController>((ref) {
  return const NoopAppAudioController();
});

abstract class AppAudioController {
  Future<void> syncRoute(String location);

  Future<void> playDialogSfx();

  Future<void> playFlipSfx();

  Future<void> playAnsweredSfx();

  Future<void> playPassSfx();

  Future<void> playEndingSfx();

  Future<void> dispose();
}

class NoopAppAudioController implements AppAudioController {
  const NoopAppAudioController();

  @override
  Future<void> dispose() async {}

  @override
  Future<void> playAnsweredSfx() async {}

  @override
  Future<void> playDialogSfx() async {}

  @override
  Future<void> playEndingSfx() async {}

  @override
  Future<void> playFlipSfx() async {}

  @override
  Future<void> playPassSfx() async {}

  @override
  Future<void> syncRoute(String location) async {}
}
