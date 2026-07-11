// screen_shake.dart - Efek layar bergetar

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class ScreenShake extends Component {
  double intensity = 0;
  double duration = 0;
  double maxIntensity = 20;
  
  final Random _random = Random();

  void shake({double intensity = 10, double duration = 0.3}) {
    this.intensity = intensity.clamp(0, maxIntensity);
    this.duration = duration;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (duration > 0) {
      duration -= dt;
      if (duration < 0) duration = 0;
    }
  }

  Vector2 getOffset() {
    if (duration <= 0 || intensity <= 0) {
      return Vector2.zero();
    }
    
    final shakeX = (_random.nextDouble() - 0.5) * intensity * 2;
    final shakeY = (_random.nextDouble() - 0.5) * intensity * 2;
    return Vector2(shakeX, shakeY);
  }

  bool get isActive => duration > 0;
}
