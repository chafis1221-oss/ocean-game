// night_filter.dart - Filter gelap + efek lampu kapal

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class NightFilter extends PositionComponent {
  double _darkness = 0; // 0 = terang, 1 = gelap total
  List<Vector2> lightSources = [];

  NightFilter() : super(position: Vector2.zero());

  @override
  void onLoad() {
    super.onLoad();
    size = Vector2(gameRef.size.x, gameRef.size.y);
  }

  void setDarkness(double value) {
    _darkness = value.clamp(0, 1);
  }

  void addLightSource(Vector2 position) {
    lightSources.add(position);
  }

  @override
  void render(Canvas canvas) {
    if (_darkness <= 0) return;

    // 1. Background gelap
    final darkPaint = Paint()
      ..color = Color.fromRGBO(0, 0, 0, _darkness * 0.7)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      darkPaint,
    );

    // 2. Efek lampu kapal (lingkaran terang)
    if (lightSources.isNotEmpty) {
      for (var pos in lightSources) {
        final lightPaint = Paint()
          ..color = Colors.yellow.withOpacity(0.15 * _darkness)
          ..style = PaintingStyle.fill
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 40);
        canvas.drawCircle(Offset(pos.x, pos.y), 150, lightPaint);
        
        // Light flare
        final flarePaint = Paint()
          ..color = Colors.orange.withOpacity(0.2 * _darkness)
          ..style = PaintingStyle.fill
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20);
        canvas.drawCircle(Offset(pos.x, pos.y), 80, flarePaint);
      }
    }
  }
}
