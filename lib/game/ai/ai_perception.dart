// ai_perception.dart - Radar, LOS, obstacle detection

import 'package:forge2d/forge2d.dart';
import 'ai_blackboard.dart';
import 'ai_steering.dart';
import '../../game/physics/physics_world.dart';

class AIPerception {
  final String botId;
  final double radarRange = 500;
  final double scanInterval = 0.5;
  double _lastScan = 0;
  
  List<DetectedEnemy> detectedEnemies = [];
  List<DetectedAlly> detectedAllies = [];
  List<ObstacleInfo> detectedObstacles = [];
  bool isInDanger = false;
  DetectedEnemy? nearestEnemy;
  
  AIPerception(this.botId);

  void scan(
    double dt,
    Vector2 position,
    Map<String, dynamic> allPlayers,
    List<Body> physicsBodies,
    bool isRageMode,
  ) {
    _lastScan += dt;
    if (_lastScan < scanInterval) return;
    _lastScan = 0;
    
    detectedEnemies.clear();
    detectedAllies.clear();
    detectedObstacles = AISteering.getObstacles(physicsBodies);
    
    for (final entry in allPlayers.entries) {
      final id = entry.key;
      final player = entry.value as Map<String, dynamic>;
      if (id == botId) continue;
      
      final playerPos = Vector2(
        (player['position'] as Map)['x'] as double,
        (player['position'] as Map)['y'] as double,
      );
      
      final distance = (playerPos - position).length;
      if (distance > radarRange) continue;
      
      final isEnemy = player['team'] != allPlayers[botId]?['team'];
      final hp = (player['hp'] as double?) ?? 100;
      final maxHp = (player['maxHp'] as double?) ?? 100;
      
      if (isEnemy) {
        final enemy = DetectedEnemy(
          id: id,
          position: playerPos,
          hp: hp,
          maxHp: maxHp,
          distance: distance,
          lastSeen: DateTime.now(),
          shipType: player['shipType'] ?? 'battleship',
        );
        detectedEnemies.add(enemy);
        AIBlackboard().updateEnemyPosition(id, playerPos, hp, maxHp);
      } else {
        detectedAllies.add(DetectedAlly(
          id: id,
          position: playerPos,
          hp: hp,
          maxHp: maxHp,
          distance: distance,
        ));
      }
    }
    
    if (detectedEnemies.isNotEmpty) {
      detectedEnemies.sort((a, b) => a.distance.compareTo(b.distance));
      nearestEnemy = detectedEnemies.first;
      isInDanger = true;
    } else {
      nearestEnemy = null;
      isInDanger = false;
    }
  }

  PerceptionResult getResult() {
    return PerceptionResult(
      enemies: detectedEnemies,
      allies: detectedAllies,
      obstacles: detectedObstacles,
      isInDanger: isInDanger,
      nearestEnemy: nearestEnemy,
      enemyCount: detectedEnemies.length,
      allyCount: detectedAllies.length,
    );
  }
}

class DetectedEnemy {
  final String id;
  final Vector2 position;
  final double hp;
  final double maxHp;
  final double distance;
  final DateTime lastSeen;
  final String shipType;
  
  DetectedEnemy({
    required this.id,
    required this.position,
    required this.hp,
    required this.maxHp,
    required this.distance,
    required this.lastSeen,
    required this.shipType,
  });
  
  double get hpRatio => hp / maxHp;
  bool get isRecent => DateTime.now().difference(lastSeen) < Duration(seconds: 3);
}

class DetectedAlly {
  final String id;
  final Vector2 position;
  final double hp;
  final double maxHp;
  final double distance;
  
  DetectedAlly({
    required this.id,
    required this.position,
    required this.hp,
    required this.maxHp,
    required this.distance,
  });
}

class PerceptionResult {
  final List<DetectedEnemy> enemies;
  final List<DetectedAlly> allies;
  final List<ObstacleInfo> obstacles;
  final bool isInDanger;
  final DetectedEnemy? nearestEnemy;
  final int enemyCount;
  final int allyCount;
  
  PerceptionResult({
    required this.enemies,
    required this.allies,
    required this.obstacles,
    required this.isInDanger,
    this.nearestEnemy,
    required this.enemyCount,
    required this.allyCount,
  });
}
