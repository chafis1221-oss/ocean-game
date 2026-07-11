// ai_controller.dart - AI Controller (NO flame_behavior_tree)

import 'package:forge2d/forge2d.dart';
import 'ai_blackboard.dart';
import 'ai_perception.dart';
import 'ai_steering.dart';
import '../../game/physics/physics_world.dart';

enum AIAction { idle, patrol, engage, retreat, flank, shoot, useNuke, useTorpedo, launchAircraft }

class AIContext {
  final String botId;
  final String shipType;
  final String difficulty;
  
  double hp = 100;
  double maxHp = 100;
  int ammo = 10;
  Vector2 position = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  
  bool nukeAvailable = false;
  bool torpedoAvailable = false;
  int aircraftStock = 0;
  double launchCooldown = 0;
  
  AIAction currentAction = AIAction.idle;
  late AIPerception perception;
  late PerceptionResult perceptionResult;
  Body? body;
  List<Body>? allPhysicsBodies;
  
  AIContext(this.botId, this.shipType, this.difficulty) {
    perception = AIPerception(botId);
  }
}

class AIController {
  final AIContext context;
  double _decisionCooldown = 0;
  bool isActive = true;

  double get accuracy => _getAccuracy();
  double get reactionDelay => _getReactionDelay();
  double get retreatThreshold => _getRetreatThreshold();

  AIController({
    required String botId,
    required String shipType,
    required String difficulty,
  }) : context = AIContext(botId, shipType, difficulty);

  void update(
    double dt,
    Vector2 position,
    double hp,
    double maxHp,
    int ammo,
    Vector2 velocity,
    Map<String, dynamic> allPlayers,
    List<Body> physicsBodies,
    Body? body,
    bool isRageMode,
  ) {
    if (!isActive) return;
    
    context.position = position;
    context.hp = hp;
    context.maxHp = maxHp;
    context.ammo = ammo;
    context.velocity = velocity;
    context.body = body;
    context.allPhysicsBodies = physicsBodies;
    
    context.perception.scan(dt, position, allPlayers, physicsBodies, isRageMode);
    context.perceptionResult = context.perception.getResult();
    
    _decisionCooldown -= dt;
    if (_decisionCooldown > 0) return;
    _decisionCooldown = reactionDelay;
    
    _decide();
  }

  void _decide() {
    final enemy = context.perceptionResult.nearestEnemy;
    
    if (context.hp / context.maxHp < retreatThreshold) {
      context.currentAction = AIAction.retreat;
      AIBlackboard().isRetreating = true;
      _executeAction();
      return;
    }
    
    if (enemy != null) {
      if (context.nukeAvailable && (enemy.hpRatio < 0.6 || context.perceptionResult.enemyCount > 2)) {
        context.currentAction = AIAction.useNuke;
        context.nukeAvailable = false;
        _executeAction();
        return;
      }
      
      if (context.torpedoAvailable && enemy.distance < 300) {
        context.currentAction = AIAction.useTorpedo;
        context.torpedoAvailable = false;
        _executeAction();
        return;
      }
      
      if (context.ammo > 0) {
        context.currentAction = AIAction.shoot;
        _executeAction();
        return;
      }
      
      if (enemy.hpRatio > 0.7) {
        context.currentAction = AIAction.flank;
        _executeAction();
        return;
      }
      
      context.currentAction = AIAction.engage;
      _executeAction();
      return;
    }
    
    context.currentAction = AIAction.patrol;
    AIBlackboard().isRetreating = false;
    _executeAction();
  }

  void _executeAction() {
    final body = context.body;
    if (body == null) return;
    
    final enemy = context.perceptionResult.nearestEnemy;
    
    switch (context.currentAction) {
      case AIAction.patrol:
        _patrol(body);
        break;
      case AIAction.engage:
        if (enemy != null) _seek(body, enemy.position);
        break;
      case AIAction.retreat:
        _retreat(body);
        break;
      case AIAction.flank:
        if (enemy != null) _flank(body, enemy.position);
        break;
      case AIAction.shoot:
        if (enemy != null) _shoot(body, enemy.position);
        break;
      case AIAction.useNuke:
        if (enemy != null) _useNuke(body, enemy.position);
        break;
      case AIAction.useTorpedo:
        if (enemy != null) _useTorpedo(body, enemy.position);
        break;
      default:
        break;
    }
  }

  void _seek(Body body, Vector2 target) {
    final steering = AISteering.seek(context.position, target, 120);
    body.applyForceToCenter(steering / PhysicsWorld.unitScale);
  }

  void _patrol(Body body) {
    final randomAngle = DateTime.now().millisecondsSinceEpoch / 1000 * 0.1;
    final target = Vector2(
      300 + 200 * (randomAngle).sin(),
      100 + 200 * (randomAngle * 0.7).cos(),
    );
    _seek(body, target);
  }

  void _retreat(Body body) {
    final target = Vector2(-400, 0);
    final steering = AISteering.flee(context.position, target, 120, 300);
    body.applyForceToCenter(steering / PhysicsWorld.unitScale);
  }

  void _flank(Body body, Vector2 enemyPos) {
    final flankPos = AISteering.flankPosition(context.position, enemyPos, 60);
    _seek(body, flankPos);
  }

  void _shoot(Body body, Vector2 targetPos) {
    final hitRoll = (1 + 2 * (DateTime.now().millisecondsSinceEpoch % 100) / 100) % 1;
    final isHit = hitRoll < accuracy;
    print('🎯 ${context.botId} ${isHit ? "hit" : "missed"}!');
    context.ammo--;
  }

  void _useNuke(Body body, Vector2 targetPos) {
    print('💥 ${context.botId} launched NUKE!');
    context.nukeAvailable = false;
  }

  void _useTorpedo(Body body, Vector2 targetPos) {
    print('🔱 ${context.botId} launched TORPEDO!');
    context.torpedoAvailable = false;
  }

  double _getAccuracy() {
    final map = {'Easy': 0.3, 'Normal': 0.5, 'Hard': 0.7, 'Insane': 0.85};
    return map[context.difficulty] ?? 0.5;
  }

  double _getReactionDelay() {
    final map = {'Easy': 1.5, 'Normal': 0.8, 'Hard': 0.3, 'Insane': 0.1};
    return map[context.difficulty] ?? 0.8;
  }

  double _getRetreatThreshold() {
    final map = {'Easy': 0.2, 'Normal': 0.3, 'Hard': 0.4, 'Insane': 0.3};
    return map[context.difficulty] ?? 0.3;
  }

  void applyObstacleAvoidance() {
    final body = context.body;
    if (body == null) return;
    
    final obstacles = context.perceptionResult.obstacles;
    if (obstacles.isEmpty) return;
    
    final steering = AISteering.obstacleAvoidance(
      context.position,
      context.velocity,
      obstacles,
      120,
      150,
    );
    
    body.applyForceToCenter(steering / PhysicsWorld.unitScale);
  }
}
