// water_painter.dart - 3D Water with perspective

import 'package:flutter/material.dart';

class WaterPainter {
  static void paintWater(Canvas canvas, Size size, double time) {
    // ===== 1. OCEAN GRADIENT (depth effect) =====
    final gradient = LinearGradient(
      colors: [
        const Color(0xFF0A192F),
        const Color(0xFF0D47A1),
        const Color(0xFF1A237E),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    final bgPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // ===== 2. WAVES (with perspective) =====
    final wavePaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (int i = 0; i < 25; i++) {
      final path = Path();
      final yBase = size.height * (0.05 + i * 0.038);
      final amplitude = 4 + i * 0.5;
      final freq = 0.02 + i * 0.001;
      for (double x = 0; x < size.width; x += 2) {
        final y = yBase +
            amplitude * sin(x * freq + time * 1.5 + i * 1.2) +
            amplitude * 0.5 * sin(x * freq * 2 + time * 2.0 + i * 0.8);
        if (x == 0) path.moveTo(x, y);
        else path.lineTo(x, y);
      }
      canvas.drawPath(path, wavePaint);
    }

    // ===== 3. LIGHT REFLECTIONS =====
    final reflectPaint = Paint()
      ..color = Colors.white.withOpacity(0.015)
      ..style = PaintingStyle.fill;
    for (int i = 0; i < 10; i++) {
      final x = size.width * (0.1 + i * 0.09);
      final y = size.height * (0.2 + sin(x * 0.01 + time) * 0.15);
      canvas.drawCircle(Offset(x, y), 40 + sin(time + i) * 15, reflectPaint);
    }
  }
}
