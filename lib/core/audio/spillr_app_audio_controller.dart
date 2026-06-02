import 'dart:async';

import 'app_audio_controller.dart';
import 'app_audio_preferences_repository.dart';
import 'audio_asset_catalog.dart';

abstract class AppAudioTrackRotator {
  Future<int> reserveNextLobbyTrackIndex({required int trackCount});

  Future<int> reserveNextGameTrackIndex({required int trackCount});
}

abstract class AppAudioEngine {
  Future<void> playBgm(String assetPath);

  Future<void> stopBgm();

  Future<void> playSfx(String assetPath, {double volume = 1.0});

  Future<void> setBgmVolume(double volume);

  Future<void> fadeBgmVolumeTo(double target, Duration duration);

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
  AudioVolumeSettings _volumes = const AudioVolumeSettings();
  bool _isBgmPaused = false;
  Timer? _duckRestoreTimer;

  static const double _lobbyFadeFraction = 0.2;
  static const double _sfxDuckFraction = 0.3;

  double get _fullBgmVolume => _volumes.effectiveBgmVolume;
  double get _fadedBgmVolume => _fullBgmVolume * _lobbyFadeFraction;

  @override
  Future<void> updateVolumes(AudioVolumeSettings volumes) async {
    _volumes = volumes;
    await _applyBgmVolumeForCurrentRoute();
  }

  @override
  Future<void> pauseBgm() async {
    if (_isBgmPaused) return;
    _isBgmPaused = true;
    await _audioEngine.stopBgm();
  }

  @override
  Future<void> resumeBgm() async {
    if (!_isBgmPaused) return;
    _isBgmPaused = false;
    final routeKind = _currentRouteKind;
    if (routeKind == _AudioRouteKind.play ||
        routeKind == _AudioRouteKind.lobby) {
      await _playLobbyBgm();
      await _applyBgmVolumeForCurrentRoute();
    } else if (routeKind == _AudioRouteKind.game) {
      final trackIndex = await _trackRotator.reserveNextGameTrackIndex(
        trackCount: AppAudioAssetCatalog.inGameBgmTracks.length,
      );
      await _audioEngine.playBgm(
        AppAudioAssetCatalog.inGameBgmTracks[trackIndex],
      );
      await _audioEngine.setBgmVolume(_fullBgmVolume);
    }
  }

  @override
  Future<void> syncRoute(String location) async {
    final routeKind = _routeKindFor(location);

    switch (routeKind) {
      case _AudioRouteKind.startup:
        await _audioEngine.stopBgm();

      case _AudioRouteKind.ending:
        await _audioEngine.fadeBgmVolumeTo(
          0.0,
          const Duration(milliseconds: 600),
        );
        await Future<void>.delayed(const Duration(milliseconds: 600));
        await _audioEngine.stopBgm();

      case _AudioRouteKind.play:
        if (_currentRouteKind != _AudioRouteKind.play &&
            _currentRouteKind != _AudioRouteKind.lobby) {
          await _playLobbyBgm();
        }
        await _audioEngine.fadeBgmVolumeTo(
          _fullBgmVolume,
          const Duration(milliseconds: 400),
        );

      case _AudioRouteKind.lobby:
        if (_currentRouteKind != _AudioRouteKind.play &&
            _currentRouteKind != _AudioRouteKind.lobby) {
          await _playLobbyBgm();
          await _audioEngine.setBgmVolume(_fullBgmVolume);
        }
        if (_currentRouteKind == _AudioRouteKind.play) {
          await _audioEngine.fadeBgmVolumeTo(
            _fadedBgmVolume,
            const Duration(milliseconds: 500),
          );
        } else {
          await _audioEngine.setBgmVolume(_fadedBgmVolume);
        }

      case _AudioRouteKind.game:
        if (_currentRouteKind == _AudioRouteKind.game) break;
        final trackIndex = await _trackRotator.reserveNextGameTrackIndex(
          trackCount: AppAudioAssetCatalog.inGameBgmTracks.length,
        );
        await _audioEngine.playBgm(
          AppAudioAssetCatalog.inGameBgmTracks[trackIndex],
        );
        await _audioEngine.setBgmVolume(_fullBgmVolume);
    }

    _currentRouteKind = routeKind;
  }

  Future<void> _playLobbyBgm() async {
    _selectedLobbyTrackIndex ??= await _trackRotator.reserveNextLobbyTrackIndex(
      trackCount: AppAudioAssetCatalog.lobbyBgmTracks.length,
    );
    await _audioEngine.playBgm(
      AppAudioAssetCatalog.lobbyBgmTracks[_selectedLobbyTrackIndex!],
    );
  }

  Future<void> _applyBgmVolumeForCurrentRoute() async {
    final routeKind = _currentRouteKind;
    if (routeKind == _AudioRouteKind.play ||
        routeKind == _AudioRouteKind.game) {
      await _audioEngine.setBgmVolume(_fullBgmVolume);
    } else if (routeKind == _AudioRouteKind.lobby) {
      await _audioEngine.setBgmVolume(_fadedBgmVolume);
    }
  }

  Future<void> _duckBgmForSfx() async {
    _duckRestoreTimer?.cancel();
    final currentTarget = _currentRouteKind == _AudioRouteKind.play
        ? _fullBgmVolume
        : _fadedBgmVolume;
    final duckTarget = currentTarget * _sfxDuckFraction;
    await _audioEngine.fadeBgmVolumeTo(
      duckTarget,
      const Duration(milliseconds: 150),
    );
    _duckRestoreTimer = Timer(const Duration(milliseconds: 700), () {
      unawaited(
        _audioEngine.fadeBgmVolumeTo(
          currentTarget,
          const Duration(milliseconds: 400),
        ),
      );
      _duckRestoreTimer = null;
    });
  }

  @override
  Future<void> playAnsweredSfx() {
    unawaited(_duckBgmForSfx());
    return _audioEngine.playSfx(
      AppAudioAssetCatalog.cardAnsweredSfx,
      volume: _volumes.effectiveSfxVolume,
    );
  }

  @override
  Future<void> playDialogSfx() {
    return _audioEngine.playSfx(
      AppAudioAssetCatalog.confirmationDialogSfx,
      volume: _volumes.effectiveSfxVolume,
    );
  }

  @override
  Future<void> playEndingSfx() {
    return _audioEngine.playSfx(
      AppAudioAssetCatalog.endingScreenSfx,
      volume: _volumes.effectiveSfxVolume,
    );
  }

  @override
  Future<void> playFlipSfx() {
    unawaited(_duckBgmForSfx());
    return _audioEngine.playSfx(
      AppAudioAssetCatalog.flippingCardSfx,
      volume: _volumes.effectiveSfxVolume,
    );
  }

  @override
  Future<void> playPassSfx() {
    unawaited(_duckBgmForSfx());
    return _audioEngine.playSfx(
      AppAudioAssetCatalog.cardPassSfx,
      volume: _volumes.effectiveSfxVolume,
    );
  }

  @override
  Future<void> dispose() async {
    _duckRestoreTimer?.cancel();
    return _audioEngine.dispose();
  }

  _AudioRouteKind _routeKindFor(String location) {
    if (location == '/') return _AudioRouteKind.startup;
    if (location == '/home') return _AudioRouteKind.play;
    if (location.startsWith('/game/')) return _AudioRouteKind.game;
    if (location == '/ending') return _AudioRouteKind.ending;
    return _AudioRouteKind.lobby;
  }
}

enum _AudioRouteKind { startup, play, lobby, game, ending }
