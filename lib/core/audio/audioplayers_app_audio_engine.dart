import 'package:audioplayers/audioplayers.dart';

import 'spillr_app_audio_controller.dart';

typedef AppAudioSfxPoolFactory =
    Future<AppAudioSfxPool> Function(String assetPath);

abstract class AppAudioSfxPool {
  Future<void> play();

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

  @override
  Future<void> dispose() async {
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
  Future<void> playSfx(String assetPath) async {
    await _ensureAudioContext();
    final pool = await _obtainSfxPool(assetPath);
    await pool.play();
  }

  @override
  Future<void> stopBgm() {
    return _bgmPlayer.stop();
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
  Future<void> play() async {
    await _pool.start();
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
    contentType: AndroidContentType.sonification,
    usageType: AndroidUsageType.assistanceSonification,
  ),
  iOS: _globalAudioContext.iOS.copy(),
);
