import 'package:test/test.dart';

import 'package:spillr/core/audio/audio_asset_catalog.dart';
import 'package:spillr/core/audio/spillr_app_audio_controller.dart';

void main() {
  late _FakeTrackRotator trackRotator;

  setUp(() {
    trackRotator = _FakeTrackRotator();
  });

  test(
    'keeps one lobby track per launch and alternates it on the next launch',
    () async {
      final firstEngine = _FakeAppAudioEngine();
      final firstController = SpillrAppAudioController(
        trackRotator: trackRotator,
        audioEngine: firstEngine,
      );

      await firstController.syncRoute('/home');
      await firstController.syncRoute('/decks');
      await firstController.syncRoute('/questions/custom-1');
      await firstController.syncRoute('/ending');
      await firstController.syncRoute('/home');

      expect(firstEngine.bgmEvents, [
        AppAudioAssetCatalog.lobbyBgmTracks[0],
        AppAudioAssetCatalog.lobbyBgmTracks[0],
      ]);
      expect(firstEngine.stopCount, 1);

      await firstController.dispose();

      final secondEngine = _FakeAppAudioEngine();
      final secondController = SpillrAppAudioController(
        trackRotator: trackRotator,
        audioEngine: secondEngine,
      );

      await secondController.syncRoute('/onboarding');

      expect(secondEngine.bgmEvents, [AppAudioAssetCatalog.lobbyBgmTracks[1]]);

      await secondController.dispose();
    },
  );

  test('alternates the in-game bgm each time a new game starts', () async {
    final engine = _FakeAppAudioEngine();
    final controller = SpillrAppAudioController(
      trackRotator: trackRotator,
      audioEngine: engine,
    );

    await controller.syncRoute('/home');
    await controller.syncRoute('/game/no-dead-air');
    await controller.syncRoute('/game/no-dead-air');
    await controller.syncRoute('/decks');
    await controller.syncRoute('/game/hot-seat');
    await controller.syncRoute('/ending');

    expect(engine.bgmEvents, [
      AppAudioAssetCatalog.lobbyBgmTracks[0],
      AppAudioAssetCatalog.inGameBgmTracks[0],
      AppAudioAssetCatalog.lobbyBgmTracks[0],
      AppAudioAssetCatalog.inGameBgmTracks[1],
    ]);
    expect(engine.stopCount, 1);

    await controller.dispose();
  });

  test('maps every audio cue to the expected asset', () async {
    final engine = _FakeAppAudioEngine();
    final controller = SpillrAppAudioController(
      trackRotator: trackRotator,
      audioEngine: engine,
    );

    await controller.playDialogSfx();
    await controller.playFlipSfx();
    await controller.playAnsweredSfx();
    await controller.playPassSfx();
    await controller.playEndingSfx();

    expect(engine.sfxEvents, [
      AppAudioAssetCatalog.confirmationDialogSfx,
      AppAudioAssetCatalog.flippingCardSfx,
      AppAudioAssetCatalog.cardAnsweredSfx,
      AppAudioAssetCatalog.cardPassSfx,
      AppAudioAssetCatalog.endingScreenSfx,
    ]);

    await controller.dispose();
  });
}

class _FakeAppAudioEngine implements AppAudioEngine {
  final List<String> bgmEvents = <String>[];
  final List<String> sfxEvents = <String>[];
  int stopCount = 0;

  @override
  Future<void> dispose() async {}

  @override
  Future<void> playBgm(String assetPath) async {
    bgmEvents.add(assetPath);
  }

  @override
  Future<void> playSfx(String assetPath, {double volume = 1.0}) async {
    sfxEvents.add(assetPath);
  }

  @override
  Future<void> stopBgm() async {
    stopCount += 1;
  }

  @override
  Future<void> setBgmVolume(double volume) async {}

  @override
  Future<void> fadeBgmVolumeTo(double target, Duration duration) async {}
}

class _FakeTrackRotator implements AppAudioTrackRotator {
  int _nextLobbyTrackIndex = 0;
  int _nextGameTrackIndex = 0;

  @override
  Future<int> reserveNextGameTrackIndex({required int trackCount}) async {
    final selectedIndex = _nextGameTrackIndex % trackCount;
    _nextGameTrackIndex = (selectedIndex + 1) % trackCount;
    return selectedIndex;
  }

  @override
  Future<int> reserveNextLobbyTrackIndex({required int trackCount}) async {
    final selectedIndex = _nextLobbyTrackIndex % trackCount;
    _nextLobbyTrackIndex = (selectedIndex + 1) % trackCount;
    return selectedIndex;
  }
}
