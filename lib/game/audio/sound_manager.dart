// sound_manager.dart - Manager suara dengan flame_audio

import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

enum SoundType {
  explosion,
  shoot,
  nuke,
  torpedo,
  aircraftLaunch,
  hit,
  miss,
  ambient,
  uiClick,
  matchStart,
  matchEnd,
  warning,
  repair,
  reload,
}

class SoundManager {
  static final SoundManager _instance = SoundManager._internal();
  factory SoundManager() => _instance;
  SoundManager._internal();

  bool _isEnabled = true;
  double _volume = 0.7;
  double _musicVolume = 0.3;

  // ===== INIT =====
  Future<void> init() async {
    print('🔊 SoundManager initialized');
    // Preload audio files (opsional)
    // await FlameAudio.audioCache.loadAll([
    //   'explosion.mp3',
    //   'shoot.mp3',
    //   'nuke.mp3',
    // ]);
  }

  // ===== PLAY =====
  void play(SoundType type, {double volume = 1.0}) {
    if (!_isEnabled) return;
    
    final vol = (volume * _volume).clamp(0, 1);
    
    switch (type) {
      case SoundType.explosion:
        _play('explosion.mp3', vol);
        break;
      case SoundType.shoot:
        _play('shoot.mp3', vol);
        break;
      case SoundType.nuke:
        _play('nuke.mp3', vol);
        break;
      case SoundType.torpedo:
        _play('torpedo.mp3', vol);
        break;
      case SoundType.aircraftLaunch:
        _play('aircraft_launch.mp3', vol);
        break;
      case SoundType.hit:
        _play('hit.mp3', vol);
        break;
      case SoundType.miss:
        _play('miss.mp3', vol);
        break;
      case SoundType.ambient:
        _play('ambient.mp3', vol * 0.3);
        break;
      case SoundType.uiClick:
        _play('ui_click.mp3', vol);
        break;
      case SoundType.matchStart:
        _play('match_start.mp3', vol);
        break;
      case SoundType.matchEnd:
        _play('match_end.mp3', vol);
        break;
      case SoundType.warning:
        _play('warning.mp3', vol);
        break;
      case SoundType.repair:
        _play('repair.mp3', vol);
        break;
      case SoundType.reload:
        _play('reload.mp3', vol);
        break;
    }
  }

  // ===== PLAY AUDIO FILE =====
  void _play(String fileName, double volume) {
    try {
      FlameAudio.play(fileName, volume: volume);
    } catch (e) {
      // Kalau file gak ada, pake fallback (diam)
      // print('🔊 Audio file not found: $fileName');
    }
  }

  // ===== BACKGROUND MUSIC =====
  void playBackgroundMusic({double volume = 0.2}) {
    if (!_isEnabled) return;
    try {
      FlameAudio.loop('bg_music.mp3', volume: volume * _musicVolume);
    } catch (e) {
      // print('🎵 Background music not found');
    }
  }

  void stopBackgroundMusic() {
    try {
      FlameAudio.stop('bg_music.mp3');
    } catch (e) {
      // ignore
    }
  }

  // ===== SETTER =====
  void setEnabled(bool enabled) => _isEnabled = enabled;
  void setVolume(double volume) => _volume = volume.clamp(0, 1);
  void setMusicVolume(double volume) => _musicVolume = volume.clamp(0, 1);
  bool get isEnabled => _isEnabled;
}
