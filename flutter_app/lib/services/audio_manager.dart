import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../models/sound_item.dart';

/// 播放状态回调
typedef PlaybackUpdateCallback = void Function(int soundId, bool isPlaying);

/// 多路并发音频管理器
///
/// 维护一个 AudioPlayer 池，按 maxStreams 限制同时播放数。
/// 当播放达到上限时，停止最早开始的播放。
class AudioManager {
  final int maxStreams;

  // 按使用顺序维护的播放器列表
  final List<_PlayerSlot> _pool = [];
  int _nextPlayerId = 0;

  PlaybackUpdateCallback? onPlaybackUpdate;

  AudioManager({this.maxStreams = 3});

  /// 播放音效
  Future<void> play(SoundItem item, {double volume = 1.0}) async {
    try {
      // 如果已达到上限，停止最早的一个
      while (_pool.length >= maxStreams && _pool.isNotEmpty) {
        await _pool.removeAt(0).player.stop();
      }

      final player = AudioPlayer();
      final slot = _PlayerSlot(
        player: player,
        soundId: item.id,
        playerId: _nextPlayerId++,
      );
      _pool.add(slot);

      await player.setVolume(volume);

      // 监听播放状态
      player.onPlayerComplete.listen((_) {
        _notifyPlayback(item.id, false);
        _removePlayer(slot);
      });

      player.onPlayerStateChanged.listen((state) {
        _notifyPlayback(item.id, state == PlayerState.playing);
      });

      _notifyPlayback(item.id, true);

      if (item.isAsset) {
        await player.play(AssetSource(item.assetPath));
      } else {
        await player.play(DeviceFileSource(item.file));
      }
    } catch (e) {
      _notifyPlayback(item.id, false);
      rethrow;
    }
  }

  /// 停止指定音效的所有播放实例
  Future<void> stop(int soundId) async {
    final toRemove = <_PlayerSlot>[];
    for (final slot in _pool) {
      if (slot.soundId == soundId) {
        await slot.player.stop();
        toRemove.add(slot);
      }
    }
    for (final slot in toRemove) {
      _pool.remove(slot);
    }
    _notifyPlayback(soundId, false);
  }

  /// 停止所有播放
  Future<void> stopAll() async {
    for (final slot in _pool) {
      await slot.player.stop();
    }
    for (final item in _pool.toList()) {
      _notifyPlayback(item.soundId, false);
    }
    _pool.clear();
  }

  /// 更新音量（对当前播放中的所有实例生效）
  Future<void> setVolume(double volume) async {
    for (final slot in _pool) {
      await slot.player.setVolume(volume);
    }
  }

  /// 释放所有资源
  Future<void> dispose() async {
    for (final slot in _pool) {
      await slot.player.dispose();
    }
    _pool.clear();
  }

  void _notifyPlayback(int soundId, bool isPlaying) {
    onPlaybackUpdate?.call(soundId, isPlaying);
  }

  void _removePlayer(_PlayerSlot slot) {
    _pool.remove(slot);
  }
}

class _PlayerSlot {
  final AudioPlayer player;
  final int soundId;
  final int playerId;

  _PlayerSlot({
    required this.player,
    required this.soundId,
    required this.playerId,
  });
}
