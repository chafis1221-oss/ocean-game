// explosion_particle.dart - Ledakan particle system

import 'package:flame/components.dart';
import 'package:flame_particles/flame_particles.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class ExplosionParticle extends PositionComponent {
  final Vector2 position;
  final double radius;
  final bool isBig;
  
  ExplosionParticle({
    required this.position,
    this.radius = 40,
    this.isBig = false,
  }) : super(position: position);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    final random = Random();
    final count = isBig ? 150 : 60;
    final particles = <Particle>[];
    
    // ===== 1. FLASH (putih) =====
    final flash = Particle(
      position: Vector2.zero(),
      lifetime: 0.15,
      startColor: Colors.white,
      endColor: Colors.white.withOpacity(0),
      startSize: radius * 2,
      endSize: 0,
    );
    particles.add(flash);
    
    // ===== 2. FIRE CORE (orange - merah) =====
    for (int i = 0; i < count ~/ 3; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = 30 + random.nextDouble() * 100;
      final size = 5 + random.nextDouble() * 15;
      
      final fire = Particle(
        position: Vector2.zero(),
        lifetime: 0.6 + random.nextDouble() * 0.6,
        startColor: Colors.orange,
        endColor: Colors.red.shade900,
        startSize: size,
        endSize: 0,
        velocity: Vector2(cos(angle), sin(angle)) * speed,
        acceleration: Vector2(0, -20),
        drag: 0.8,
      );
      particles.add(fire);
    }
    
    // ===== 3. SMOKE (grey) =====
    for (int i = 0; i < count ~/ 2; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = 20 + random.nextDouble() * 60;
      final size = 15 + random.nextDouble() * 30;
      
      final smoke = Particle(
        position: Vector2.zero(),
        lifetime: 1.2 + random.nextDouble() * 0.8,
        startColor: Colors.grey.shade700,
        endColor: Colors.grey.shade300.withOpacity(0),
        startSize: size,
        endSize: size * 3,
        velocity: Vector2(cos(angle), sin(angle)) * speed,
        acceleration: Vector2(0, -10),
        drag: 0.9,
      );
      particles.add(smoke);
    }
    
    // ===== 4. SHRAPNEL (pecahan) =====
    for (int i = 0; i < count ~/ 4; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = 150 + random.nextDouble() * 200;
      final size = 2 + random.nextDouble() * 4;
      
      final shrapnel = Particle(
        position: Vector2.zero(),
        lifetime: 0.5 + random.nextDouble() * 0.3,
        startColor: Colors.orange.shade300,
        endColor: Colors.grey.shade600,
        startSize: size,
        endSize: 0,
        velocity: Vector2(cos(angle), sin(angle)) * speed,
        drag: 0.95,
        acceleration: Vector2(0, -30),
      );
      particles.add(shrapnel);
    }
    
    // ===== 5. SPARKS (bunga api) =====
    for (int i = 0; i < count ~/ 5; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final speed = 80 + random.nextDouble() * 120;
      final size = 1 + random.nextDouble() * 3;
      
      final spark = Particle(
        position: Vector2.zero(),
        lifetime: 0.3 + random.nextDouble() * 0.3,
        startColor: Colors.yellow,
        endColor: Colors.orange,
        startSize: size,
        endSize: 0,
        velocity: Vector2(cos(angle), sin(angle)) * speed,
        drag: 0.9,
      );
      particles.add(spark);
    }
    
    // Buat ParticleSystemComponent
    final particleSystem = ParticleSystemComponent(
      particle: MultiParticle(particles),
    );
    
    add(particleSystem);
    
    // Auto-remove setelah selesai
    final maxLifetime = isBig ? 2.5 : 1.8;
    await Future.delayed(Duration(milliseconds: (maxLifetime * 1000).toInt()));
    removeFromParent();
  }
}
