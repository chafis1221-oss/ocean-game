// ship_painter.dart - 3D Isometric Ship

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

class ShipPainter {
  static void paintShip(
    Canvas canvas,
    Size size,
    Color baseColor,
    bool isPlayer,
    bool isCarrier,
    double angle,
    double hpRatio,
  ) {
    canvas.save();
    
    // ===== ISOMETRIC TRANSFORM =====
    final matrix = Matrix4.identity()
      ..setEntry(1, 1, 0.5) // Skala Y
      ..setEntry(2, 2, 0.5)
      ..translate(size.width / 2, size.height / 2)
      ..rotateZ(angle);
    
    canvas.transform(matrix.storage);
    
    final w = size.width / 2;
    final h = size.height / 2;

    // ===== 1. SHADOW =====
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, h * 0.2), width: w * 1.6, height: h * 0.4),
      shadowPaint,
    );

    // ===== 2. HULL 3D =====
    final hullPath = Path();
    hullPath.moveTo(-w * 0.8, -h * 0.2);
    hullPath.quadraticBezierTo(-w * 0.9, 0, -w * 0.7, h * 0.3);
    hullPath.quadraticBezierTo(0, h * 0.6, w * 0.7, h * 0.3);
    hullPath.quadraticBezierTo(w * 0.9, 0, w * 0.8, -h * 0.2);
    hullPath.quadraticBezierTo(0, -h * 0.7, -w * 0.8, -h * 0.2);
    hullPath.close();

    final gradient = LinearGradient(
      colors: [
        baseColor,
        baseColor.withOpacity(0.6),
        baseColor.withOpacity(0.3),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    final hullPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(-w, -h, size.width, size.height),
      )
      ..style = PaintingStyle.fill;
    canvas.drawPath(hullPath, hullPaint);

    // ===== 3. DECK 3D =====
    final deckPath = Path();
    deckPath.moveTo(-w * 0.6, -h * 0.1);
    deckPath.quadraticBezierTo(0, -h * 0.4, w * 0.6, -h * 0.1);
    deckPath.lineTo(w * 0.5, h * 0.1);
    deckPath.lineTo(-w * 0.5, h * 0.1);
    deckPath.close();

    final deckPaint = Paint()
      ..color = Colors.grey.shade800.withOpacity(0.5)
      ..style = PaintingStyle.fill;
    canvas.drawPath(deckPath, deckPaint);

    // ===== 4. TURRET 3D =====
    if (!isCarrier) {
      _drawTurret3D(canvas, Offset(w * 0.4, -h * 0.1), 10, baseColor);
      _drawTurret3D(canvas, Offset(-w * 0.4, -h * 0.1), 10, baseColor);
      _drawTurret3D(canvas, Offset(0, h * 0.2), 14, baseColor);
    } else {
      // Carrier: runway
      final runwayPaint = Paint()
        ..color = Colors.grey.shade700.withOpacity(0.6)
        ..style = PaintingStyle.fill;
      final runwayPath = Path();
      runwayPath.moveTo(-w * 0.35, -h * 0.25);
      runwayPath.lineTo(w * 0.35, -h * 0.25);
      runwayPath.lineTo(w * 0.3, h * 0.1);
      runwayPath.lineTo(-w * 0.3, h * 0.1);
      runwayPath.close();
      canvas.drawPath(runwayPath, runwayPaint);
    }

    // ===== 5. HP BAR 3D =====
    _drawHpBar3D(canvas, Size(w * 1.2, 4), Offset(0, -h * 1.2), hpRatio);

    // ===== 6. LAMPU =====
    final lightColor = isPlayer ? Colors.blue : Colors.red;
    final lightPaint = Paint()
      ..color = lightColor.withOpacity(0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset(w * 0.3, -h * 0.4), 4, lightPaint);

    canvas.restore();
  }

  static void _drawTurret3D(Canvas canvas, Offset pos, double radius, Color baseColor) {
    // Base
    final paint = Paint()
      ..color = baseColor.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(pos, radius, paint);

    // Barrel
    final barrelPaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.fill;
    final barrel = Rect.fromLTWH(pos.dx - 2, pos.dy - radius - 8, 4, 10);
    canvas.drawRect(barrel, barrelPaint);

    // Highlight
    final highlight = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(pos.dx - 3, pos.dy - 3), radius * 0.3, highlight);
  }

  static void _drawHpBar3D(Canvas canvas, Size size, Offset pos, double ratio) {
    final bgPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromCenter(center: pos, width: size.width, height: size.height),
      bgPaint,
    );

    final color = ratio > 0.5 ? Colors.green : (ratio > 0.25 ? Colors.orange : Colors.red);
    final hpPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(pos.dx - size.width * (1 - ratio) / 2, pos.dy),
        width: size.width * ratio,
        height: size.height,
      ),
      hpPaint,
    );
  }
}
