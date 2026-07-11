// damage_text.dart - Floating damage number

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class DamageText extends PositionComponent {
  final int damage;
  final Color color;
  double _life = 1.0;
  double _speed = 60;
  double _initialY;

  DamageText({
    required Vector2 position,
    required this.damage,
    this.color = Colors.red,
  }) : super(position: position) {
    _initialY = position.y;
    anchor = Anchor.center;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _life -= dt * 0.8;
    
    // Naik perlahan
    position.y = _initialY - (1 - _life) * 80;
    
    // Scale membesar lalu mengecil
    final scale = 1 + (1 - _life) * 0.5;
    size = Vector2(40 * scale, 20 * scale);
    
    if (_life <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final opacity = _life.clamp(0, 1);
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;
    
    final textSpan = TextSpan(
      text: '-$damage',
      style: TextStyle(
        color: color.withOpacity(opacity),
        fontSize: size.x,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 4,
          ),
        ],
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(-textPainter.width / 2, -textPainter.height / 2),
    );
  }
}
