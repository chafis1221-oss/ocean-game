// rain_particle.dart - Weather rain (pake VFX)

import 'package:flame/components.dart';
import '../../game/vfx/rain_particle.dart';

class RainWeatherSystem extends PositionComponent {
  RainParticleSystem? _rainSystem;
  double _intensity = 0;

  RainWeatherSystem() : super(position: Vector2.zero());

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _rainSystem = RainParticleSystem();
    await add(_rainSystem!);
    _rainSystem!.setIntensity(0);
  }

  void setIntensity(double intensity) {
    _intensity = intensity.clamp(0, 1);
    if (_rainSystem != null) {
      _rainSystem!.setIntensity(_intensity);
      _rainSystem!.isVisible = _intensity > 0.01;
    }
  }
}
