// ai_blackboard.dart - Shared memory untuk semua bot

import 'package:flame/flame.dart';
import 'package:forge2d/forge2d.dart';

class AIBlackboard {
  static final AIBlackboard _instance = AIBlackboard._internal();
  factory AIBlackboard() => _instance;
  AIBlackboard._internal();

  // Team state
  double teamHealth = 1.0;
  bool isRetreating = false;
  String teamFormation = 'default';
  
  // Enemy positions
  Map<String, EnemyInfo> lastKnownEnemyPositions = {};
  
  // Priority target
  String? priorityTargetId;
  double priorityTargetHP = 1.0;
  
  // Danger zones
  List<DangerZone> dangerZones = [];

  // Bot memory
  Map<String, BotMemory> botMemory = {};

  void clear() {
    lastKnownEnemyPositions.clear();
    dangerZones.clear();
    botMemory.clear();
    priorityTargetId = null;
    teamHealth = 1.0;
    isRetreating = false;
  }

  void updateEnemyPosition(String id, Vector2 pos, double hp, double maxHp) {
    lastKnownEnemyPositions[id] = EnemyInfo(
      position: pos,
      hp: hp,
      maxHp: maxHp,
      lastSeen: DateTime.now(),
    );
  }

  void addDangerZone(Vector2 position, double radius, double dangerLevel) {
    dangerZones.add(DangerZone(position, radius, dangerLevel));
  }

  BotMemory getBotMemory(String botId) {
    if (!botMemory.containsKey(botId)) {
      botMemory[botId] = BotMemory();
    }
    return botMemory[botId]!;
  }
}

class EnemyInfo {
  final Vector2 position;
  final double hp;
  final double maxHp;
  final DateTime lastSeen;
  
  EnemyInfo({
    required this.position,
    required this.hp,
    required this.maxHp,
    required this.lastSeen,
  });
  
  bool get isRecent => DateTime.now().difference(lastSeen) < Duration(seconds: 3);
  double get hpRatio => hp / maxHp;
}

class DangerZone {
  final Vector2 position;
  final double radius;
  final double dangerLevel;
  DangerZone(this.position, this.radius, this.dangerLevel);
}

class BotMemory {
  Vector2 lastPosition = Vector2.zero();
  String lastAction = 'idle';
  String? lastTargetId;
  double aggressionLevel = 0.5;
  int stuckCounter = 0;
  DateTime lastDecision = DateTime.now();
}
