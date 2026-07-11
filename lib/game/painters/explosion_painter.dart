// explosion_painter.dart - Ledakan 3D (partikel)

import 'package:flutter/material.dart';
import 'dart:math';

class ExplosionPainter {
  static void paintExplosion(
    Canvas canvas,
    Vector2 position,
    double radius,
    double progress,
    bool isBig,
  ) {
    final random = Random(42 + (progress * 100).toInt());
    final count = isBig ? 60 : 30;

    // ===== 1. FLASH (di awal) =====
    if (progress < 0.15) {
      final flashPaint = Paint()
        ..color = Colors.white.withOpacity(0.7 * (1 - progress / 0.15))
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawCircle(
        Offset(position.x, position.y),
        radius * (1 + progress * 2),
        flashPaint,
      );
    }

    // ===== 2. FIRE PARTICLES =====
    for (int i = 0; i < count; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final dist = (random.nextDouble() * radius * 2) * progress;
      final size = (2 + random.nextDouble() * 8) * (1 - progress);
      
      if (size < 0.5) continue;

      final x = position.x + cos(angle) * dist;
      final y = position.y + sin(angle) * dist - progress * 30;

      final colorProgress = progress * 2;
      final colors = [
        Colors.yellow,
        Colors.orange,
        Colors.red,
        Colors.red.shade900,
      ];
      final colorIndex = (colorProgress * colors.length).toInt().clamp(0, colors.length - 1);
      
      final firePaint = Paint()
        ..color = colors[colorIndex].withOpacity(1 - progress)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      
      canvas.drawCircle(Offset(x, y), size, firePaint);
    }

    // ===== 3. SMOKE =====
    if (progress > 0.2) {
      final smokeCount = count ~/ 2;
      for (int i = 0; i < smokeCount; i++) {
        final angle = random.nextDouble() * 2 * pi;
        final dist = (random.nextDouble() * radius * 3) * (progress - 0.2);
        final size = (5 + random.nextDouble() * 20) * progress;

        if (size < 1) continue;

        final x = position.x + cos(angle) * dist;
        final y = position.y + sin(angle) * dist - progress * 20;

        final smokePaint = Paint()
          ..color = Colors.grey.shade700.withOpacity(0.3 * (1 - progress))
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

        canvas.drawCircle(Offset(x, y), size, smokePaint);
      }
    }

    // ===== 4. SHRAPNEL =====
    if (progress < 0.5) {
      final shrapCount = count ~/ 3;
      for (int i = 0; i < shrapCount; i++) {
        final angle = random.nextDouble() * 2 * pi;
        final dist = (random.nextDouble() * radius * 3) * progress * 2;
        final size = (1 + random.nextDouble() * 3) * (1 - progress * 2);

        if (size < 0.3) continue;

        final x = position.x + cos(angle) * dist;
        final y = position.y + sin(angle) * dist;

        final shrapPaint = Paint()
          ..color = Colors.orange.shade300.withOpacity(1 - progress * 2)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(x, y), size, shrapPaint);
      }
    }
  }
}
