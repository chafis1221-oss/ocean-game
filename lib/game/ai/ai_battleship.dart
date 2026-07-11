// ai_battleship.dart - Battleship specific AI (extends AI Controller)

import 'ai_controller.dart';

class AIBattleship extends AIController {
  AIBattleship({
    required String botId,
    required String difficulty,
  }) : super(
    botId: botId,
    shipType: 'battleship',
    difficulty: difficulty,
  ) {
    context.nukeAvailable = true;
    context.torpedoAvailable = true;
  }

  // Override untuk nuke usage (lebih agresif di Hard)
  @override
  void _executeAction(double dt) {
    final enemy = context.perceptionResult.nearestEnemy;
    
    // Hard difficulty: nuke lebih agresif
    if (context.difficulty == 'Hard' && context.nukeAvailable && enemy != null) {
      if (enemy.hpRatio < 0.6 || context.perceptionResult.enemyCount > 2) {
        _useNuke(context.body!, enemy.position);
        return;
      }
    }
    
    // Normal behavior
    super._executeAction(dt);
  }
}
