// rain_particle.dart - Hujan particle system

import 'package:flame/components.dart';
import 'package:flame_particles/flame_particles.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class RainParticleSystem extends PositionComponent {
  double _intensity = 0;
  late ParticleSystemComponent _rainSystem;

  RainParticleSystem() : super(position: Vector2.zero());

  @override
  void onLoad() {
    super.onLoad();
    size = Vector2(gameRef.size.x, gameRef.size.y);
    
    _rainSystem = ParticleSystemComponent(
      particle: RainParticle(),
      isRelative: true,
    );
    add(_rainSystem);
  }

  void setIntensity(double intensity) {
    _intensity = intensity.clamp(0, 1);
    _rainSystem.isVisible = _intensity > 0.01;
    
    // Update particle count
    final count = (200 * _intensity).toInt();
    // Rebuild with new count (sederhana)
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Update posisi sistem (follow kamera)
    position = Vector2.zero();
  }
}

class RainParticle extends Particle {
  final Random _random = Random();
  double _xOffset = 0;
  double _yOffset = 0;
  double _speed = 400;
  double _length = 15;
  double _wind = 0;

  RainParticle() {
    _xOffset = _random.nextDouble() * 1000 - 500;
    _yOffset = _random.nextDouble() * 600 - 300;
    _speed = 300 + _random.nextDouble() * 200;
    _length = 10 + _random.nextDouble() * 20;
    _wind = _random.nextDouble() * 50;
  }

  @override
  void render(Canvas canvas, Vector2 position) {
    final opacity = 0.2 + _random.nextDouble() * 0.3;
    final paint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final start = Vector2(_xOffset, _yOffset);
    final end = Vector2(
      _xOffset + _wind,
      _yOffset + _length,
    );
    
    canvas.drawLine(
      Offset(start.x, start.y),
      Offset(end.x, end.y),
      paint,
    );
  }

  @override
  void update(double dt) {
    _yOffset += _speed * dt;
    _xOffset += _wind * dt * 0.2;
    
    // Reset when off screen
    if (_yOffset > 600) {
      _yOffset = -50 - _random.nextDouble() * 50;
      _xOffset = _random.nextDouble() * 1000 - 500;
      _speed = 300 + _random.nextDouble() * 200;
      _wind = _random.nextDouble() * 50;
    }
  }
}
