// explosion.dart - Ledakan 3D

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../painters/explosion_painter.dart';

class Explosion extends PositionComponent {
  final Vector2 position;
  final double radius;
  final bool isBig;
  final String? killerId;
  final String? victimId;
  final String? victimName;
  
  double _life = 0;
  double _maxLife = 1.5;

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
  void render(Canvas canvas) {
    final progress = (_life / _maxLife).clamp(0, 1);
    ExplosionPainter.paintExplosion(
      canvas,
      position,
      radius,
      progress,
      isBig,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _life += dt;
    if (_life > _maxLife) {
      removeFromParent();
    }
  }
}
