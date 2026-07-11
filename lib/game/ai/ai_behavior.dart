// ai_behavior.dart - Behavior Tree nodes untuk AI

import 'package:flame_behavior_tree/flame_behavior_tree.dart';
import 'ai_blackboard.dart';
import 'ai_perception.dart';
import 'ai_steering.dart';
import 'ai_controller.dart';

// ===== CONDITION: Is enemy detected? =====
class IsEnemyDetected extends ConditionNode {
  @override
  bool check(AIContext context) {
    return context.perception.isInDanger;
  }
}

// ===== CONDITION: Is HP low? =====
class IsHPLow extends ConditionNode {
  final double threshold;
  IsHPLow(this.threshold);
  @override
  bool check(AIContext context) {
    return context.hp / context.maxHp < threshold;
  }
}

// ===== CONDITION: Has ammo? =====
class HasAmmo extends ConditionNode {
  @override
  bool check(AIContext context) {
    return context.ammo > 0;
  }
}

// ===== CONDITION: Enemy HP low? =====
class EnemyHPLow extends ConditionNode {
  final double threshold;
  EnemyHPLow(this.threshold);
  @override
  bool check(AIContext context) {
    final enemy = context.perception.nearestEnemy;
    return enemy != null && enemy.hpRatio < threshold;
  }
}

// ===== CONDITION: Is retreating? =====
class IsRetreating extends ConditionNode {
  @override
  bool check(AIContext context) {
    return AIBlackboard().isRetreating;
  }
}

// ===== CONDITION: Has special weapon? =====
class HasSpecialWeapon extends ConditionNode {
  final String weaponType;
  HasSpecialWeapon(this.weaponType);
  @override
  bool check(AIContext context) {
    if (weaponType == 'nuke') return context.nukeAvailable;
    if (weaponType == 'torpedo') return context.torpedoAvailable;
    return false;
  }
}

// ===== ACTION: Retreat =====
class RetreatAction extends ActionNode {
  @override
  Future<NodeState> run(AIContext context) async {
    context.currentAction = AIAction.retreat;
    AIBlackboard().isRetreating = true;
    return NodeState.success;
  }
}

// ===== ACTION: Engage =====
class EngageAction extends ActionNode {
  @override
  Future<NodeState> run(AIContext context) async {
    context.currentAction = AIAction.engage;
    AIBlackboard().isRetreating = false;
    return NodeState.success;
  }
}

// ===== ACTION: Shoot =====
class ShootAction extends ActionNode {
  @override
  Future<NodeState> run(AIContext context) async {
    context.currentAction = AIAction.shoot;
    return NodeState.success;
  }
}

// ===== ACTION: Flank =====
class FlankAction extends ActionNode {
  @override
  Future<NodeState> run(AIContext context) async {
    context.currentAction = AIAction.flank;
    return NodeState.success;
  }
}

// ===== ACTION: Patrol =====
class PatrolAction extends ActionNode {
  @override
  Future<NodeState> run(AIContext context) async {
    context.currentAction = AIAction.patrol;
    AIBlackboard().isRetreating = false;
    return NodeState.success;
  }
}

// ===== ACTION: Use Nuke =====
class UseNukeAction extends ActionNode {
  @override
  Future<NodeState> run(AIContext context) async {
    context.currentAction = AIAction.useNuke;
    context.nukeAvailable = false;
    return NodeState.success;
  }
}

// ===== ACTION: Use Torpedo =====
class UseTorpedoAction extends ActionNode {
  @override
  Future<NodeState> run(AIContext context) async {
    context.currentAction = AIAction.useTorpedo;
    context.torpedoAvailable = false;
    return NodeState.success;
  }
}

// ===== ACTION: Launch Aircraft =====
class LaunchAircraftAction extends ActionNode {
  @override
  Future<NodeState> run(AIContext context) async {
    context.currentAction = AIAction.launchAircraft;
    return NodeState.success;
  }
}

// ===== CONDITION: Has aircraft stock? =====
class HasAircraftStock extends ConditionNode {
  @override
  bool check(AIContext context) {
    return context.aircraftStock > 0 && context.launchCooldown <= 0;
  }
}

// ===== ACTION: Set formation =====
class SetFormationAction extends ActionNode {
  final String formation;
  SetFormationAction(this.formation);
  @override
  Future<NodeState> run(AIContext context) async {
    AIBlackboard().teamFormation = formation;
    return NodeState.success;
  }
}
