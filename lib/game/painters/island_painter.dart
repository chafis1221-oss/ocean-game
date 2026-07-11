// island_painter.dart - 3D Island

import 'package:flutter/material.dart';

class IslandPainter {
  static void paintIsland(Canvas canvas, Size size, Vector2 position) {
    canvas.save();
    canvas.translate(size.width / 2, size.height / 2);

    final w = size.width / 2;
    final h = size.height / 2;

    // ===== 1. SHADOW =====
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    canvas.drawEllipse(
      Rect.fromCenter(center: Offset(0, h * 0.1), width: w * 1.6, height: h * 0.3),
      shadowPaint,
    );

    // ===== 2. ISLAND BODY (3D) =====
    final islandPath = Path();
    islandPath.moveTo(-w * 0.9, 0);
    islandPath.quadraticBezierTo(-w * 0.7, -h * 0.6, 0, -h * 0.8);
    islandPath.quadraticBezierTo(w * 0.7, -h * 0.6, w * 0.9, 0);
    islandPath.quadraticBezierTo(w * 0.6, h * 0.7, 0, h * 0.8);
    islandPath.quadraticBezierTo(-w * 0.6, h * 0.7, -w * 0.9, 0);
    islandPath.close();

    final gradient = RadialGradient(
      colors: [
        Colors.green.shade300,
        Colors.green.shade600,
        Colors.brown.shade700,
      ],
      radius: 1.2,
    );
    final paint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(-w, -h, size.width, size.height),
      )
      ..style = PaintingStyle.fill;
    canvas.drawPath(islandPath, paint);

    // ===== 3. TREES (3D) =====
    final random = Random(42);
    for (int i = 0; i < 15; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final dist = 0.2 + random.nextDouble() * 0.6;
      final x = cos(angle) * w * dist;
      final y = sin(angle) * h * dist * 0.7;
      final treeSize = 4 + random.nextDouble() * 8;
      _drawTree3D(canvas, Offset(x, y), treeSize);
    }

    // ===== 4. BEACH =====
    final beachPaint = Paint()
      ..color = Colors.yellow.shade100.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(islandPath, beachPaint);

    canvas.restore();
  }

  static void _drawTree3D(Canvas canvas, Offset pos, double size) {
    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(pos.dx, pos.dy + size * 0.3), size * 0.4, shadowPaint);

    // Trunk
    final trunkPaint = Paint()
      ..color = Colors.brown.shade800
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromLTWH(pos.dx - 1.5, pos.dy - size * 0.5, 3, size * 0.5),
      trunkPaint,
    );

    // Leaves (3D sphere effect)
    final leafPaint = Paint()
      ..color = Colors.green.shade600
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(pos.dx, pos.dy - size * 0.5), size * 0.35, leafPaint);
    canvas.drawCircle(Offset(pos.dx - size * 0.25, pos.dy - size * 0.4), size * 0.25, leafPaint);
    canvas.drawCircle(Offset(pos.dx + size * 0.25, pos.dy - size * 0.4), size * 0.25, leafPaint);
  }
}
