// projectile_painter.dart - Rudal 3D isometric

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

class ProjectilePainter {
  static void paintProjectile(
    Canvas canvas,
    Size size,
    Color color,
    double angle,
    bool isNuke,
    List<Vector2> trailPoints,
  ) {
    canvas.save();
    
    // ===== ISOMETRIC TRANSFORM =====
    final matrix = Matrix4.identity()
      ..setEntry(1, 1, 0.5)
      ..setEntry(2, 2, 0.5)
      ..translate(size.width / 2, size.height / 2)
      ..rotateZ(angle);
    
    canvas.transform(matrix.storage);
    
    final w = size.width / 2;
    final h = size.height / 2;

    // ===== 1. SHADOW =====
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, h * 0.4), width: w * 0.6, height: h * 0.15),
      shadowPaint,
    );

    // ===== 2. BODY RUDAL =====
    final bodyPath = Path();
    bodyPath.moveTo(-w * 0.2, -h);
    bodyPath.quadraticBezierTo(-w * 0.35, 0, -w * 0.2, h);
    bodyPath.lineTo(w * 0.2, h);
    bodyPath.quadraticBezierTo(w * 0.35, 0, w * 0.2, -h);
    bodyPath.close();

    // Gradient body
    final gradient = LinearGradient(
      colors: [
        color,
        color.withOpacity(0.5),
        color.withOpacity(0.2),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );
    final bodyPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromLTWH(-w, -h, size.width, size.height),
      )
      ..style = PaintingStyle.fill;
    canvas.drawPath(bodyPath, bodyPaint);

    // ===== 3. WARHEAD (UJUNG) =====
    final warheadPaint = Paint()
      ..color = isNuke ? Colors.red : Colors.orange
      ..style = PaintingStyle.fill;
    final warheadPath = Path();
    warheadPath.moveTo(-w * 0.15, -h * 0.85);
    warheadPath.quadraticBezierTo(0, -h * 1.3, w * 0.15, -h * 0.85);
    warheadPath.close();
    canvas.drawPath(warheadPath, warheadPaint);

    // ===== 4. FIN (SAYAP) =====
    final finPaint = Paint()
      ..color = color.withOpacity(0.6)
      ..style = PaintingStyle.fill;
    
    // Kiri
    final finPath = Path();
    finPath.moveTo(-w * 0.15, h * 0.2);
    finPath.lineTo(-w * 0.6, h * 0.7);
    finPath.lineTo(-w * 0.15, h * 0.5);
    finPath.close();
    canvas.drawPath(finPath, finPaint);
    
    // Kanan
    final finPath2 = Path();
    finPath2.moveTo(w * 0.15, h * 0.2);
    finPath2.lineTo(w * 0.6, h * 0.7);
    finPath2.lineTo(w * 0.15, h * 0.5);
    finPath2.close();
    canvas.drawPath(finPath2, finPaint);

    // ===== 5. NUKE GLOW =====
    if (isNuke) {
      final glowPaint = Paint()
        ..color = Colors.orange.withOpacity(0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
      canvas.drawCircle(Offset.zero, w * 1.4, glowPaint);
      
      // Nuke warning text
      final textSpan = TextSpan(
        text: '☢️',
        style: TextStyle(
          fontSize: 14,
          color: Colors.red,
          shadows: [Shadow(color: Colors.red, blurRadius: 10)],
        ),
      );
      final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);
      tp.layout();
      tp.paint(canvas, Offset(-tp.width / 2, -h * 1.6));
    }

    // ===== 6. TRAIL ASAP =====
    if (trailPoints.length > 1) {
      final trailPaint = Paint()
        ..color = Colors.white.withOpacity(0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 + trailPoints.length * 0.1
        ..strokeCap = StrokeCap.round;
      
      final trailPath = Path();
      for (int i = 0; i < trailPoints.length; i++) {
        final p = trailPoints[i];
        if (i == 0) trailPath.moveTo(p.x, p.y);
        else trailPath.lineTo(p.x, p.y);
      }
      canvas.drawPath(trailPath, trailPaint);
    }

    canvas.restore();
  }
}
