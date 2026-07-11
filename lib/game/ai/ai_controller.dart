// ai_controller.dart - Root AI Controller

import 'package:flame_behavior_tree/flame_behavior_tree.dart';
import 'package:forge2d/forge2d.dart';
import 'ai_blackboard.dart';
import 'ai_perception.dart';
import 'ai_steering.dart';
import 'ai_behavior.dart';
import '../../game/physics/physics_world.dart';

enum AIAction { idle, patrol, engage, retreat, flank, shoot, useNuke, useTorpedo, launchAircraft }

class AIContext {
  final String botId;
  final String shipType;
  final String difficulty;
  
  // State
  double hp = 100;
  double maxHp = 100;
  int ammo = 10;
  Vector2 position = Vector2.zero();
  Vector2 velocity = Vector2.zero();
  
  // Ship specific
  bool nukeAvailable = false;
  bool torpedoAvailable = false;
  int aircraftStock = 0;
  double launchCooldown = 0;
  
  // Action result
  AIAction currentAction = AIAction.idle;
  
  // Perception
  late AIPerception perception;
  late PerceptionResult perceptionResult;
  
  // Physics body
  Body? body;
  List<Body>? allPhysicsBodies;
  
  AIContext(this.botId, this.shipType, this.difficulty) {
    perception = AIPerception(botId);
  }
}

class AIController {
  final AIContext context;
  final BehaviorTree behaviorTree;
  
  // Difficulty settings
  double get accuracy => _getAccuracy();
  double get reactionDelay => _getReactionDelay();
  double get decisionInterval => _getDecisionInterval();
  double get retreatThreshold => _getRetreatThreshold();
  
  double _decisionCooldown = 0;
  bool isActive = true;
  
  AIController({
    required String botId,
    required String shipType,
    required String difficulty,
  }) : context = AIContext(botId, shipType, difficulty) {
    behaviorTree = _buildTree(shipType);
  }

  BehaviorTree _buildTree(String shipType) {
    if (shipType == 'carrier') {
      return _buildCarrierTree();
    } else {
      return _buildBattleshipTree();
    }
  }

  BehaviorTree _buildBattleshipTree() {
    final root = SelectorNode([
      // 1. Emergency: Retreat if HP low
      SequenceNode([
        IsHPLow(retreatThreshold),
        RetreatAction(),
      ]),
      
      // 2. Combat: Engage if enemy detected
      SequenceNode([
        IsEnemyDetected(),
        SelectorNode([
          // 2a. Use Nuke if available
          SequenceNode([
            HasSpecialWeapon('nuke'),
            EnemyHPLow(0.6),
            UseNukeAction(),
          ]),
          // 2b. Use Torpedo if close
          SequenceNode([
            HasSpecialWeapon('torpedo'),
            // Distance check (done in action)
            UseTorpedoAction(),
          ]),
          // 2c. Normal shoot
          SequenceNode([
            HasAmmo(),
            ShootAction(),
          ]),
        ]),
        // 2d. Positioning (flank if enemy HP high)
        SelectorNode([
          SequenceNode([
            ConditionNode((c) => c.perceptionResult.nearestEnemy?.hpRatio ?? 1 > 0.7),
            FlankAction(),
          ]),
          EngageAction(),
        ]),
      ]),
      
      // 3. Default: Patrol
      PatrolAction(),
    ]);
    
    return BehaviorTree(root);
  }

  BehaviorTree _buildCarrierTree() {
    final root = SelectorNode([
      // 1. Retreat if HP low
      SequenceNode([
        IsHPLow(retreatThreshold),
        RetreatAction(),
      ]),
      
      // 2. Launch aircraft if enemy detected
      SequenceNode([
        IsEnemyDetected(),
        HasAircraftStock(),
        LaunchAircraftAction(),
        EngageAction(),
      ]),
      
      // 3. Default: Patrol
      PatrolAction(),
    ]);
    
    return BehaviorTree(root);
  }

  // ===== UPDATE AI =====
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
    
    // Update context
    context.position = position;
    context.hp = hp;
    context.maxHp = maxHp;
    context.ammo = ammo;
    context.velocity = velocity;
    context.body = body;
    context.allPhysicsBodies = physicsBodies;
    
    // Scan perception
    context.perception.scan(dt, position, allPlayers, physicsBodies, isRageMode);
    context.perceptionResult = context.perception.getResult();
    
    // Decision cooldown (reaction delay)
    _decisionCooldown -= dt;
    if (_decisionCooldown > 0) return;
    _decisionCooldown = reactionDelay;
    
    // Run Behavior Tree
    final result = behaviorTree.run(context);
    if (result == NodeState.success) {
      // Action decided
      _executeAction(dt);
    }
  }

  // ===== EXECUTE ACTION =====
  void _executeAction(double dt) {
    final action = context.currentAction;
    final body = context.body;
    if (body == null) return;
    
    final pos = context.position;
    final enemy = context.perceptionResult.nearestEnemy;
    
    switch (action) {
      case AIAction.patrol:
        _patrol(body, dt);
        break;
        
      case AIAction.engage:
        if (enemy != null) {
          _seek(body, enemy.position, dt);
        }
        break;
        
      case AIAction.retreat:
        _retreat(body, dt);
        break;
        
      case AIAction.flank:
        if (enemy != null) {
          _flank(body, enemy.position, dt);
        }
        break;
        
      case AIAction.shoot:
        if (enemy != null) {
          _shoot(body, enemy.position);
        }
        break;
        
      case AIAction.useNuke:
        if (enemy != null) {
          _useNuke(body, enemy.position);
        }
        break;
        
      case AIAction.useTorpedo:
        if (enemy != null) {
          _useTorpedo(body, enemy.position);
        }
        break;
        
      case AIAction.launchAircraft:
        _launchAircraft(body);
        break;
        
      default:
        break;
    }
  }

  // ===== STEERING BEHAVIORS =====
  void _seek(Body body, Vector2 target, double dt) {
    final steering = AISteering.seek(context.position, target, 120);
    final force = steering * dt * 50;
    body.applyForceToCenter(force / PhysicsWorld.unitScale);
  }

  void _patrol(Body body, double dt) {
    final randomAngle = DateTime.now().millisecondsSinceEpoch / 1000 * 0.1;
    final target = Vector2(
      300 + 200 * (randomAngle).sin(),
      100 + 200 * (randomAngle * 0.7).cos(),
    );
    _seek(body, target, dt);
  }

  void _retreat(Body body, double dt) {
    final target = Vector2(-400, 0); // Base position
    final steering = AISteering.flee(context.position, target, 120, 300);
    final force = steering * dt * 50;
    body.applyForceToCenter(force / PhysicsWorld.unitScale);
  }

  void _flank(Body body, Vector2 enemyPos, double dt) {
    final flankPos = AISteering.flankPosition(context.position, enemyPos, 60);
    _seek(body, flankPos, dt);
  }

  // ===== OBSTACLE AVOIDANCE (applied every tick) =====
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
    
    final force = steering * 0.01;
    body.applyForceToCenter(force / PhysicsWorld.unitScale);
  }

  // ===== SHOOT =====
  void _shoot(Body body, Vector2 targetPos) {
    // Check accuracy
    final hitRoll = (1 + 2 * (DateTime.now().millisecondsSinceEpoch % 100) / 100) % 1;
    final isHit = hitRoll < accuracy;
    
    if (isHit) {
      // Create projectile
      print('🎯 ${context.botId} shot hit!');
    } else {
      print('💨 ${context.botId} shot missed!');
    }
    
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

  void _launchAircraft(Body body) {
    print('🛩️ ${context.botId} launched AIRCRAFT!');
    context.aircraftStock--;
    context.launchCooldown = 10;
  }

  // ===== DIFFICULTY GETTERS =====
  double _getAccuracy() {
    final map = {'Easy': 0.3, 'Normal': 0.5, 'Hard': 0.7, 'Insane': 0.85};
    return map[context.difficulty] ?? 0.5;
  }

  double _getReactionDelay() {
    final map = {'Easy': 1.5, 'Normal': 0.8, 'Hard': 0.3, 'Insane': 0.1};
    return map[context.difficulty] ?? 0.8;
  }

  double _getDecisionInterval() {
    final map = {'Easy': 2.0, 'Normal': 1.0, 'Hard': 0.5, 'Insane': 0.2};
    return map[context.difficulty] ?? 1.0;
  }

  double _getRetreatThreshold() {
    final map = {'Easy': 0.2, 'Normal': 0.3, 'Hard': 0.4, 'Insane': 0.3};
    return map[context.difficulty] ?? 0.3;
  }
}
