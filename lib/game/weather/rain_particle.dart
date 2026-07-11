// rain_particle.dart - Hujan pake flame built-in particles

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class RainParticleSystem extends PositionComponent {
  double _intensity = 0;
  ParticleSystemComponent? _rainSystem;
  final Random _random = Random();

  RainParticleSystem() : super(position: Vector2.zero());

  @override
  void onLoad() {
    super.onLoad();
    size = Vector2(gameRef.size.x, gameRef.size.y);
    _buildRain(0);
  }

  void _buildRain(double intensity) {
    if (_rainSystem != null) {
      remove(_rainSystem!);
    }
    
    final count = (200 * intensity).toInt();
    if (count == 0) {
      _rainSystem = null;
      return;
    }
    
    final particles = <Particle>[];
    for (int i = 0; i < count; i++) {
      final speed = 300 + _random.nextDouble() * 200;
      final length = 10 + _random.nextDouble() * 20;
      final wind = _random.nextDouble() * 50;
      
      particles.add(Particle(
        lifetime: 0.5 + _random.nextDouble() * 0.5,
        position: Vector2(
          _random.nextDouble() * size.x - size.x / 2,
          _random.nextDouble() * size.y - size.y / 2,
        ),
        velocity: Vector2(wind, speed),
        startSize: 1,
        endSize: 0,
        startColor: Colors.white.withOpacity(0.3),
        endColor: Colors.white.withOpacity(0),
      ));
    }
    
    _rainSystem = ParticleSystemComponent(
      particle: ParticleGroup(
        children: particles,
      ),
    );
    add(_rainSystem!);
  }

  void setIntensity(double intensity) {
    _intensity = intensity.clamp(0, 1);
    _buildRain(_intensity);
    if (_rainSystem != null) {
      _rainSystem!.isVisible = _intensity > 0.01;
    }
  }
}
