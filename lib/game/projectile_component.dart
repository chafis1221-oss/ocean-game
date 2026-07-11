// projectile_component.dart - Rudal dengan painter 3D

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'painters/projectile_painter.dart';

enum ProjectileType { missile, rocket, bomb, torpedo, nuke }

class ProjectileComponent extends PositionComponent {
  final ProjectileType type;
  final bool isFriendly;
  final double damage;
  final double speed;
  final double? aoeRadius;
  final String targetId;
  double lifeTime = 3.0;
  bool isActive = true;
  bool hasExploded = false;
  Vector2 velocity = Vector2.zero();
  List<Vector2> _trailPoints = [];
  int _maxTrailPoints = 20;
  Vector2? targetPosition;
  bool isHoming = false;

  ProjectileComponent({
    required this.type,
    required this.isFriendly,
    required this.damage,
    required this.speed,
    required this.targetId,
    Vector2? position,
    Vector2? direction,
    this.aoeRadius,
    this.targetPosition,
    this.isHoming = false,
  }) : super(position: position) {
    if (direction != null) velocity = direction.normalized() * speed;
    else velocity = Vector2(0, -speed);
    switch (type) {
      case ProjectileType.missile: size = Vector2(12, 24); lifeTime = 4.0; break;
      case ProjectileType.rocket: size = Vector2(6, 12); lifeTime = 3.0; break;
      case ProjectileType.bomb: size = Vector2(16, 16); lifeTime = 2.5; break;
      case ProjectileType.torpedo: size = Vector2(8, 28); lifeTime = 5.0; break;
      case ProjectileType.nuke: size = Vector2(30, 40); lifeTime = 6.0; break;
    }
  }

  @override
  void render(Canvas canvas) {
    final color = isFriendly ? Colors.blue : Colors.red;
    final isNuke = type == ProjectileType.nuke;
    ProjectilePainter.paintProjectile(
      canvas,
      size,
      color,
      angle,
      isNuke,
      _trailPoints,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isActive) return;

    if (isHoming && targetPosition != null) {
      final targetDir = (targetPosition! - position).normalized();
      final currentDir = velocity.normalized();
      final newDir = currentDir.lerp(targetDir, 0.05);
      velocity = newDir * speed;
    }

    position += velocity * dt;
    _trailPoints.add(Vector2(position.x, position.y));
    if (_trailPoints.length > _maxTrailPoints) _trailPoints.removeAt(0);

    lifeTime -= dt;
    if (lifeTime <= 0) {
      isActive = false;
      if (!hasExploded) explode();
    }
    if (velocity.length > 1) angle = velocity.angle();
  }

  void explode() {
    if (hasExploded) return;
    hasExploded = true;
    isActive = false;
    print('💥 ${type} explosion at ${position.x}, ${position.y}');
  }
}
