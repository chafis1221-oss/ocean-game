// ai_steering.dart - Obstacle avoidance, seek, flee, flank

import 'package:forge2d/forge2d.dart';
import '../../game/physics/physics_world.dart';

class AISteering {
  static Vector2 obstacleAvoidance(
    Vector2 position,
    Vector2 velocity,
    List<ObstacleInfo> obstacles,
    double maxSpeed,
    double avoidDistance,
  ) {
    Vector2 steering = Vector2.zero();
    final forward = velocity.length > 0.01 ? velocity.normalized() : Vector2(0, -1);
    
    for (final obstacle in obstacles) {
      final toObstacle = obstacle.position - position;
      final distance = toObstacle.length;
      
      final dot = forward.dot(toObstacle.normalized());
      if (dot < 0.3) continue;
      if (distance > avoidDistance) continue;
      
      final perpDist = (forward.dot(toObstacle)).abs();
      if (perpDist > obstacle.radius * 1.5) continue;
      
      final away = (position - obstacle.position).normalized();
      final strength = 1 - (distance / avoidDistance);
      steering += away * strength * maxSpeed * 0.5;
    }
    
    if (steering.length > maxSpeed) {
      steering = steering.normalized() * maxSpeed;
    }
    return steering;
  }

  static Vector2 seek(Vector2 position, Vector2 target, double maxSpeed) {
    final desired = (target - position).normalized() * maxSpeed;
    return desired;
  }

  static Vector2 flee(Vector2 position, Vector2 target, double maxSpeed, double fleeDistance) {
    final distance = (target - position).length;
    if (distance > fleeDistance) return Vector2.zero();
    final desired = (position - target).normalized() * maxSpeed;
    return desired;
  }

  static Vector2 flankPosition(Vector2 position, Vector2 enemyPos, double flankAngle) {
    final dx = enemyPos.x - position.x;
    final dy = enemyPos.y - position.y;
    final angle = Vector2(dx, dy).angle();
    final flankAngleRad = flankAngle * 3.14159 / 180;
    
    final flankX = enemyPos.x - 200 * (angle + flankAngleRad).cos();
    final flankY = enemyPos.y - 200 * (angle + flankAngleRad).sin();
    return Vector2(flankX, flankY);
  }
}

class ObstacleInfo {
  final Vector2 position;
  final double radius;
  final Body body;
  
  ObstacleInfo({
    required this.position,
    required this.radius,
    required this.body,
  });
}
