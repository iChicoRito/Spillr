import 'dart:async';

import 'app_audio_controller.dart';
import 'audio_asset_catalog.dart';

abstract class AppAudioTrackRotator {
  Future<int> reserveNextLobbyTrackIndex({required int trackCount});

  Future<int> reserveNextGameTrackIndex({required int trackCount});
}

abstract class AppAudioEngine {
  Future<void> playBgm(String assetPath);

  Future<void> stopBgm();

  Future<void> playSfx(String assetPath);

  Future<void> dispose();
}

class SpillrAppAudioController implements AppAudioController {
  SpillrAppAudioController({
    required AppAudioTrackRotator trackRotator,
    required AppAudioEngine audioEngine,
  }) : _trackRotator = trackRotator,
       _audioEngine = audioEngine;

  final AppAudioTrackRotator _trackRotator;
  final AppAudioEngine _audioEngine;

  _AudioRouteKind? _currentRouteKind;
  int? _selectedLobbyTrackIndex;

  @override
  Future<void> syncRoute(String location) async {
    final routeKind = _routeKindFor(location);

    switch (routeKind) {
      case _AudioRouteKind.startup:
        await _audioEngine.stopBgm();
        break;
      case _AudioRouteKind.ending:
        await _audioEngine.stopBgm();
        break;
      case _AudioRouteKind.lobby:
        if (_currentRouteKind == _AudioRouteKind.lobby) {
          break;
        }

        _selectedLobbyTrackIndex ??= await _trackRotator
            .reserveNextLobbyTrackIndex(
              trackCount: AppAudioAssetCatalog.lobbyBgmTracks.length,
            );
        await _audioEngine.playBgm(
          AppAudioAssetCatalog.lobbyBgmTracks[_selectedLobbyTrackIndex!],
        );
        break;
      case _AudioRouteKind.game:
        if (_currentRouteKind == _AudioRouteKind.game) {
          break;
        }

        final trackIndex = await _trackRotator.reserveNextGameTrackIndex(
          trackCount: AppAudioAssetCatalog.inGameBgmTracks.length,
        );
        await _audioEngine.playBgm(
          AppAudioAssetCatalog.inGameBgmTracks[trackIndex],
        );
        break;
    }

    _currentRouteKind = routeKind;
  }

  @override
  Future<void> playAnsweredSfx() {
    return _audioEngine.playSfx(AppAudioAssetCatalog.cardAnsweredSfx);
  }

  @override
  Future<void> playDialogSfx() {
    return _audioEngine.playSfx(AppAudioAssetCatalog.confirmationDialogSfx);
  }

  @override
  Future<void> playEndingSfx() {
    return _audioEngine.playSfx(AppAudioAssetCatalog.endingScreenSfx);
  }

  @override
  Future<void> playFlipSfx() {
    return _audioEngine.playSfx(AppAudioAssetCatalog.flippingCardSfx);
  }

  @override
  Future<void> playPassSfx() {
    return _audioEngine.playSfx(AppAudioAssetCatalog.cardPassSfx);
  }

  @override
  Future<void> dispose() {
    return _audioEngine.dispose();
  }

  _AudioRouteKind _routeKindFor(String location) {
    if (location == '/') {
      return _AudioRouteKind.startup;
    }
    if (location.startsWith('/game/')) {
      return _AudioRouteKind.game;
    }
    if (location == '/ending') {
      return _AudioRouteKind.ending;
    }
    return _AudioRouteKind.lobby;
  }
}

enum _AudioRouteKind { startup, lobby, game, ending }
