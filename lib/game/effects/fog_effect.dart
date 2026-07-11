// fog_effect.dart - Efek kabut (visibility turun)

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class FogEffect extends PositionComponent {
  double _density = 0;
  final List<FogPatch> _patches = [];
  final Random _random = Random();

  FogEffect() : super(position: Vector2.zero());

  @override
  void onLoad() {
    super.onLoad();
    size = Vector2(gameRef.size.x, gameRef.size.y);
    
    // Generate fog patches
    for (int i = 0; i < 30; i++) {
      _patches.add(FogPatch(
        x: _random.nextDouble() * size.x,
        y: _random.nextDouble() * size.y,
        radius: 100 + _random.nextDouble() * 200,
        speed: 10 + _random.nextDouble() * 20,
        direction: _random.nextDouble() * 2 * 3.14159,
        opacity: 0.1 + _random.nextDouble() * 0.3,
      ));
    }
  }

  void setDensity(double density) {
    _density = density.clamp(0, 0.6);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_density <= 0) return;
    
    // Gerakkan fog pelan
    for (var patch in _patches) {
      patch.x += patch.speed * cos(patch.direction) * dt;
      patch.y += patch.speed * sin(patch.direction) * dt;
      
      if (patch.x > size.x + 100) patch.x = -100;
      if (patch.x < -100) patch.x = size.x + 100;
      if (patch.y > size.y + 100) patch.y = -100;
      if (patch.y < -100) patch.y = size.y + 100;
    }
  }

  @override
  void render(Canvas canvas) {
    if (_density <= 0) return;
    
    final basePaint = Paint()
      ..color = Colors.white.withOpacity(_density * 0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 50);

    // Gambar patches fog
    for (var patch in _patches) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(patch.opacity * _density * 0.5)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 80);
      
      canvas.drawCircle(
        Offset(patch.x, patch.y),
        patch.radius,
        paint,
      );
    }
  }
}

class FogPatch {
  double x, y;
  double radius;
  double speed;
  double direction;
  double opacity;

  FogPatch({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.direction,
    required this.opacity,
  });
}
