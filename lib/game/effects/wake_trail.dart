// wake_trail.dart - Jejak air di belakang kapal

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class WakeTrail extends PositionComponent {
  final List<Vector2> _trailPoints = [];
  final int _maxPoints = 20;
  final Vector2 shipPosition;
  final Vector2 shipSize;
  double _life = 0.5;

  WakeTrail({
    required this.shipPosition,
    required this.shipSize,
  }) : super(position: shipPosition);

  @override
  void update(double dt) {
    super.update(dt);
    _life -= dt;
    
    // Tambah titik trail
    _trailPoints.add(Vector2(
      shipPosition.x - shipSize.x * 0.5,
      shipPosition.y,
    ));
    if (_trailPoints.length > _maxPoints) {
      _trailPoints.removeAt(0);
    }
  }

  @override
  void render(Canvas canvas) {
    if (_trailPoints.length < 2) return;
    
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2 * _life)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < _trailPoints.length; i++) {
      final point = _trailPoints[i];
      if (i == 0) path.moveTo(point.x, point.y);
      else path.lineTo(point.x, point.y);
    }
    canvas.drawPath(path, paint);
  }

  bool get isExpired => _life <= 0;
}
