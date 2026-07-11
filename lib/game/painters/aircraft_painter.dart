// aircraft_painter.dart - Pesawat 3D isometric

import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart';

class AircraftPainter {
  static void paintAircraft(
    Canvas canvas,
    Size size,
    Color color,
    String type,
    double angle,
    double propellerAngle,
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
    final isHelicopter = type == 'helicopter';

    // ===== 1. SHADOW =====
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(0, h * 0.3), width: w * 1.2, height: h * 0.2),
      shadowPaint,
    );

    // ===== 2. BODY =====
    final bodyPath = Path();
    bodyPath.moveTo(-w * 0.3, -h * 0.4);
    bodyPath.quadraticBezierTo(0, -h * 0.9, w * 0.3, -h * 0.4);
    bodyPath.lineTo(w * 0.3, h * 0.4);
    bodyPath.quadraticBezierTo(0, h * 0.9, -w * 0.3, h * 0.4);
    bodyPath.close();

    final gradient = LinearGradient(
      colors: [
        color,
        color.withOpacity(0.6),
        color.withOpacity(0.3),
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

    // ===== 3. WINGS (untuk fixed-wing) =====
    if (!isHelicopter) {
      final wingPaint = Paint()
        ..color = color.withOpacity(0.7)
        ..style = PaintingStyle.fill;

      // Sayap kiri
      final wingLeft = Path();
      wingLeft.moveTo(-w * 0.2, -h * 0.15);
      wingLeft.lineTo(-w * 1.0, -h * 0.5);
      wingLeft.lineTo(-w * 1.0, -h * 0.15);
      wingLeft.close();
      canvas.drawPath(wingLeft, wingPaint);

      // Sayap kanan
      final wingRight = Path();
      wingRight.moveTo(w * 0.2, -h * 0.15);
      wingRight.lineTo(w * 1.0, -h * 0.5);
      wingRight.lineTo(w * 1.0, -h * 0.15);
      wingRight.close();
      canvas.drawPath(wingRight, wingPaint);

      // ===== 4. TAIL =====
      final tailPaint = Paint()
        ..color = color.withOpacity(0.6)
        ..style = PaintingStyle.fill;
      final tailPath = Path();
      tailPath.moveTo(-w * 0.2, h * 0.5);
      tailPath.lineTo(0, h * 0.9);
      tailPath.lineTo(w * 0.2, h * 0.5);
      tailPath.close();
      canvas.drawPath(tailPath, tailPaint);

      // ===== 5. COCKPIT =====
      final cockpitPaint = Paint()
        ..color = Colors.cyan.withOpacity(0.4)
        ..style = PaintingStyle.fill;
      final cockpitPath = Path();
      cockpitPath.moveTo(-w * 0.12, -h * 0.35);
      cockpitPath.quadraticBezierTo(0, -h * 0.6, w * 0.12, -h * 0.35);
      cockpitPath.close();
      canvas.drawPath(cockpitPath, cockpitPaint);

      // ===== 6. PROPELLER (BERPUTAR) =====
      final propPaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(0, -h * 0.85);
      canvas.rotate(propellerAngle);

      final prop1 = Path()
        ..moveTo(-w * 0.12, 0)
        ..lineTo(-w * 0.25, -1)
        ..lineTo(-w * 0.25, 1)
        ..close();
      canvas.drawPath(prop1, propPaint);

      final prop2 = Path()
        ..moveTo(w * 0.12, 0)
        ..lineTo(w * 0.25, -1)
        ..lineTo(w * 0.25, 1)
        ..close();
      canvas.drawPath(prop2, propPaint);

      canvas.restore();
      
    } else {
      // ===== HELICOPTER =====
      // Rotor muter
      final rotorPaint = Paint()
        ..color = Colors.white.withOpacity(0.4)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(0, -h * 0.9);
      canvas.rotate(propellerAngle * 2);

      final rotor1 = Path()
        ..moveTo(-w * 0.7, 0)
        ..lineTo(-w * 0.6, -1.5)
        ..lineTo(-w * 0.6, 1.5)
        ..close();
      canvas.drawPath(rotor1, rotorPaint);

      final rotor2 = Path()
        ..moveTo(w * 0.7, 0)
        ..lineTo(w * 0.6, -1.5)
        ..lineTo(w * 0.6, 1.5)
        ..close();
      canvas.drawPath(rotor2, rotorPaint);

      canvas.restore();

      // Skid (landing gear)
      final skidPaint = Paint()
        ..color = Colors.grey.shade600
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset(-w * 0.2, h * 0.4), Offset(-w * 0.4, h * 0.7), skidPaint);
      canvas.drawLine(Offset(w * 0.2, h * 0.4), Offset(w * 0.4, h * 0.7), skidPaint);
    }

    canvas.restore();
  }
}
