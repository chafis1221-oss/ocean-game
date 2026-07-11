// repair_zone.dart - Area aman buat repair (di belakang base)

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'resource_manager.dart';

class RepairZone extends PositionComponent {
  final Vector2 center;
  final double radius = 150;
  double _pulse = 0;

  RepairZone({required this.center}) : super(position: center);

  @override
  void onLoad() {
    super.onLoad();
    anchor = Anchor.center;
    size = Vector2(radius * 2, radius * 2);
    
    print('🔧 Repair zone created at (${center.x}, ${center.y})');
  }

  @override
  void update(double dt) {
    super.update(dt);
    _pulse += dt * 2;
  }

  @override
  void render(Canvas canvas) {
    final opacity = 0.15 + 0.1 * _pulse.sin();
    
    // Lingkaran luar (pulsating)
    final outerPaint = Paint()
      ..color = Colors.green.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(Offset.zero, radius, outerPaint);
    
    // Lingkaran dalam (solid)
    final innerPaint = Paint()
      ..color = Colors.green.withOpacity(0.05)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset.zero, radius, innerPaint);
    
    // Icon repair
    final iconPaint = Paint()
      ..color = Colors.green.withOpacity(0.3 + 0.2 * _pulse.sin())
      ..style = PaintingStyle.fill;
    
    final textSpan = TextSpan(
      text: '🔧',
      style: TextStyle(
        fontSize: 24,
        shadows: [
          Shadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
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

  // Cek apakah posisi di dalam repair zone
  bool contains(Vector2 position) {
    final dx = position.x - this.position.x;
    final dy = position.y - this.position.y;
    final dist = (dx*dx + dy*dy).sqrt();
    return dist < radius;
  }
}
