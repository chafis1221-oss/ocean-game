// background_music.dart - Background music looping

import 'package:flame/components.dart';
import 'sound_manager.dart';

class BackgroundMusic extends Component {
  bool _isPlaying = false;
  double _volume = 0.2;

  @override
  void onLoad() {
    super.onLoad();
    _startMusic();
  }

  void _startMusic() {
    if (_isPlaying) return;
    _isPlaying = true;
    SoundManager().playBackgroundMusic(volume: _volume);
  }

  void stop() {
    _isPlaying = false;
    SoundManager().stopBackgroundMusic();
  }

  void setVolume(double volume) {
    _volume = volume.clamp(0, 0.5);
    if (_isPlaying) {
      SoundManager().stopBackgroundMusic();
      SoundManager().playBackgroundMusic(volume: _volume);
    }
  }
}
