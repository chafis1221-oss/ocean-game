// remote_ship.dart - Kapal player lain (sync dari server)

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'painters/ship_painter.dart';

class RemoteShip extends PositionComponent {
  final String playerId;
  final String username;
  final String shipType;
  final Color color;
  bool isAlive = true;
  double hp = 100;
  double maxHp = 100;
  double _currentAngle = 0;

  RemoteShip({
    required this.playerId,
    required this.username,
    required this.shipType,
    required this.color,
    Vector2? position,
  }) : super(position: position) {
    size = shipType == 'carrier' ? Vector2(80, 40) : Vector2(70, 50);
    anchor = Anchor.center;
  }

  @override
  void render(Canvas canvas) {
    if (!isAlive) return;
    final isCarrier = shipType == 'carrier';
    ShipPainter.paintShip(
      canvas,
      size,
      color,
      false, // isPlayer = false
      isCarrier,
      angle,
      hp / maxHp,
    );
    // Label username
    final textSpan = TextSpan(
      text: username,
      style: TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        shadows: [Shadow(color: Colors.black, blurRadius: 4)],
      ),
    );
    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, Offset(-tp.width / 2, -size.y / 2 - 20));
  }

  void updateFromState(Map<String, dynamic> state) {
    position = Vector2(
      (state['x'] as num).toDouble(),
      (state['y'] as num).toDouble(),
    );
    angle = (state['angle'] as num).toDouble();
    hp = (state['hp'] as num).toDouble();
    maxHp = (state['maxHp'] as num).toDouble();
    isAlive = state['isAlive'] ?? true;
  }
}
