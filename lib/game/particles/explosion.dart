// explosion.dart - Ledakan pake flame built-in particles

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class Explosion extends PositionComponent {
  final Vector2 position;
  final double radius;
  final bool isBig;
  final String? killerId;
  final String? victimId;
  final String? victimName;
  
  double _life = 0;
  double _maxLife = 1.5;
  ParticleSystemComponent? _particleSystem;

  Explosion({
    required this.position,
    this.radius = 30,
    this.isBig = false,
    this.killerId,
    this.victimId,
    this.victimName,
  }) : super(position: position) {
    _maxLife = isBig ? 2.0 : 1.5;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    final random = Random();
    final count = isBig ? 150 : 60;
    final particles = <Particle>[];
    
    // 1. FLASH
    particles.add(Particle(
      lifetime: 0.15,
      startColor: Colors.white,
      endColor: Colors.white.withOpacity(0),
      startSize: radius * 2,
      endSize: 0,
    ));
    
    // 2. FIRE
    for (int i = 0; i < count ~/ 3; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = 30 + random.nextDouble() * 100;
      final size = 5 + random.nextDouble() * 15;
      
      particles.add(Particle(
        lifetime: 0.6 + random.nextDouble() * 0.6,
        startColor: Colors.orange,
        endColor: Colors.red.shade900,
        startSize: size,
        endSize: 0,
        velocity: Vector2(cos(angle), sin(angle)) * speed,
        acceleration: Vector2(0, -20),
        drag: 0.8,
      ));
    }
    
    // 3. SMOKE
    for (int i = 0; i < count ~/ 2; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = 20 + random.nextDouble() * 60;
      final size = 15 + random.nextDouble() * 30;
      
      particles.add(Particle(
        lifetime: 1.2 + random.nextDouble() * 0.8,
        startColor: Colors.grey.shade700,
        endColor: Colors.grey.shade300.withOpacity(0),
        startSize: size,
        endSize: size * 3,
        velocity: Vector2(cos(angle), sin(angle)) * speed,
        acceleration: Vector2(0, -10),
        drag: 0.9,
      ));
    }
    
    // 4. SHRAPNEL
    for (int i = 0; i < count ~/ 4; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = 150 + random.nextDouble() * 200;
      final size = 2 + random.nextDouble() * 4;
      
      particles.add(Particle(
        lifetime: 0.5 + random.nextDouble() * 0.3,
        startColor: Colors.orange.shade300,
        endColor: Colors.grey.shade600,
        startSize: size,
        endSize: 0,
        velocity: Vector2(cos(angle), sin(angle)) * speed,
        drag: 0.95,
        acceleration: Vector2(0, -30),
      ));
    }
    
    // 5. SPARKS
    for (int i = 0; i < count ~/ 5; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = 80 + random.nextDouble() * 120;
      final size = 1 + random.nextDouble() * 3;
      
      particles.add(Particle(
        lifetime: 0.3 + random.nextDouble() * 0.3,
        startColor: Colors.yellow,
        endColor: Colors.orange,
        startSize: size,
        endSize: 0,
        velocity: Vector2(cos(angle), sin(angle)) * speed,
        drag: 0.9,
      ));
    }
    
    _particleSystem = ParticleSystemComponent(
      particle: ParticleGroup(
        children: particles,
      ),
    );
    add(_particleSystem!);
    
    // Auto-remove
    await Future.delayed(Duration(milliseconds: (_maxLife * 1000).toInt()));
    removeFromParent();
  }
}
