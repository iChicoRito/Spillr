import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import 'spillr_app_audio_controller.dart';

typedef AppAudioSfxPoolFactory =
    Future<AppAudioSfxPool> Function(String assetPath);

abstract class AppAudioSfxPool {
  Future<void> play({double volume = 1.0});

  Future<void> dispose();
}

class AudioplayersAppAudioEngine implements AppAudioEngine {
  AudioplayersAppAudioEngine({
    AudioPlayer? bgmPlayer,
    Map<String, AppAudioSfxPool>? sfxPools,
    AppAudioSfxPoolFactory? sfxPoolFactory,
  }) : _bgmPlayer = bgmPlayer ?? AudioPlayer(playerId: 'spillr-bgm'),
       _sfxPools = sfxPools ?? <String, AppAudioSfxPool>{},
       _sfxPoolFactory = sfxPoolFactory ?? _defaultSfxPoolFactory;

  final AudioPlayer _bgmPlayer;
  final Map<String, AppAudioSfxPool> _sfxPools;
  final Map<String, Future<AppAudioSfxPool>> _pendingSfxPools =
      <String, Future<AppAudioSfxPool>>{};
  final AppAudioSfxPoolFactory _sfxPoolFactory;
  Future<void>? _pendingAudioContextSetup;
  double _currentBgmVolume = 1.0;
  Timer? _fadeTimer;

  @override
  Future<void> dispose() async {
    _fadeTimer?.cancel();
    await _bgmPlayer.dispose();
    for (final pool in _sfxPools.values) {
      await pool.dispose();
    }
  }

  @override
  Future<void> playBgm(String assetPath) async {
    await _ensureAudioContext();
    await _bgmPlayer.setAudioContext(_bgmAudioContext);
    await _bgmPlayer.setPlayerMode(PlayerMode.mediaPlayer);
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.play(AssetSource(assetPath));
  }

  @override
  Future<void> playSfx(String assetPath, {double volume = 1.0}) async {
    await _ensureAudioContext();
    final pool = await _obtainSfxPool(assetPath);
    await pool.play(volume: volume);
  }

  @override
  Future<void> stopBgm() {
    return _bgmPlayer.stop();
  }

  @override
  Future<void> setBgmVolume(double volume) async {
    _fadeTimer?.cancel();
    _fadeTimer = null;
    _currentBgmVolume = volume.clamp(0.0, 1.0);
    await _bgmPlayer.setVolume(_currentBgmVolume);
  }

  @override
  Future<void> fadeBgmVolumeTo(double target, Duration duration) async {
    _fadeTimer?.cancel();
    final clampedTarget = target.clamp(0.0, 1.0);
    final startVolume = _currentBgmVolume;
    const steps = 20;
    final stepDuration = Duration(
      milliseconds: (duration.inMilliseconds / steps).round(),
    );
    var step = 0;

    _fadeTimer = Timer.periodic(stepDuration, (timer) async {
      step++;
      final t = step / steps;
      _currentBgmVolume = startVolume + (clampedTarget - startVolume) * t;
      await _bgmPlayer.setVolume(_currentBgmVolume.clamp(0.0, 1.0));
      if (step >= steps) {
        timer.cancel();
        _fadeTimer = null;
        _currentBgmVolume = clampedTarget;
      }
    });
  }

  Future<AppAudioSfxPool> _obtainSfxPool(String assetPath) {
    final existingPool = _sfxPools[assetPath];
    if (existingPool != null) {
      return Future<AppAudioSfxPool>.value(existingPool);
    }

    final pendingPool = _pendingSfxPools[assetPath];
    if (pendingPool != null) {
      return pendingPool;
    }

    final createdPool = _sfxPoolFactory(assetPath).then((pool) {
      _sfxPools[assetPath] = pool;
      _pendingSfxPools.remove(assetPath);
      return pool;
    }, onError: (Object error, StackTrace stackTrace) {
      _pendingSfxPools.remove(assetPath);
      throw error;
    });
    _pendingSfxPools[assetPath] = createdPool;
    return createdPool;
  }

  Future<void> _ensureAudioContext() {
    final pendingSetup = _pendingAudioContextSetup;
    if (pendingSetup != null) {
      return pendingSetup;
    }

    final setupFuture = AudioPlayer.global
        .setAudioContext(_globalAudioContext)
        .catchError((Object error, StackTrace stackTrace) {
          _pendingAudioContextSetup = null;
          throw error;
        });
    _pendingAudioContextSetup = setupFuture;
    return setupFuture;
  }
}

Future<AppAudioSfxPool> _defaultSfxPoolFactory(String assetPath) async {
  final pool = await AudioPool.create(
    source: AssetSource(assetPath),
    minPlayers: 1,
    maxPlayers: 2,
    playerMode: PlayerMode.lowLatency,
    audioContext: _sfxAudioContext,
  );
  return _AudioplayersSfxPool(pool);
}

class _AudioplayersSfxPool implements AppAudioSfxPool {
  const _AudioplayersSfxPool(this._pool);

  final AudioPool _pool;

  @override
  Future<void> dispose() {
    return _pool.dispose();
  }

  @override
  Future<void> play({double volume = 1.0}) async {
    await _pool.start(volume: volume.clamp(0.0, 1.0));
  }
}

final AudioContext _globalAudioContext = AudioContextConfig(
  focus: AudioContextConfigFocus.mixWithOthers,
).build();

final AudioContext _bgmAudioContext = AudioContext(
  android: _globalAudioContext.android.copy(
    contentType: AndroidContentType.music,
    usageType: AndroidUsageType.game,
  ),
  iOS: _globalAudioContext.iOS.copy(),
);

final AudioContext _sfxAudioContext = AudioContext(
  android: _globalAudioContext.android.copy(
    contentType: AndroidContentType.music,
    usageType: AndroidUsageType.game,
  ),
  iOS: _globalAudioContext.iOS.copy(),
);
