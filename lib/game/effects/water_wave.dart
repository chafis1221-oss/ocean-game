// water_wave.dart - Animasi ombak laut (tanpa gambar)

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class WaterWaveComponent extends PositionComponent {
  final double amplitude = 6.0;
  final double frequency = 0.025;
  final double speed = 1.2;
  late ui.PictureRecorder recorder;
  late Canvas canvas;
  late ui.Image image;
  double _time = 0;

  @override
  Future<void> onLoad() async {
    size = Vector2(gameRef.size.x, gameRef.size.y);
    position = Vector2.zero();
    await _generateWaveImage();
    return super.onLoad();
  }

  Future<void> _generateWaveImage() async {
    recorder = ui.PictureRecorder();
    canvas = Canvas(recorder, Rect.fromLTWH(0, 0, size.x, size.y));
    
    // 1. Background laut (gradien)
    final gradient = ui.Gradient.linear(
      Offset(0, 0),
      Offset(0, size.y),
      [const Color(0xFF0D47A1), const Color(0xFF1A237E)],
    );
    final paint = Paint()..shader = gradient;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), paint);

    // 2. Garis ombak (wave pattern)
    final wavePaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < 12; i++) {
      final path = Path();
      final yBase = (size.y / 14) * (i + 2);
      for (double x = 0; x < size.x; x++) {
        final y = yBase + amplitude * 
            (i % 2 == 0 ? 1 : -1) * 
            (x / size.x * 10).sin() * 
            (1 + (i / 12));
        if (x == 0) path.moveTo(x, y);
        else path.lineTo(x, y);
      }
      canvas.drawPath(path, wavePaint);
    }

    final picture = recorder.endRecording();
    image = await picture.toImage(size.x.toInt(), size.y.toInt());
  }

  @override
  void render(Canvas canvas) {
    if (image != null) {
      // Geser ombak sesuai waktu (untuk animasi)
      _time += 0.01;
      final offsetX = (_time * speed * 10) % size.x;
      canvas.drawImage(image, Offset(offsetX, 0), Paint());
      canvas.drawImage(image, Offset(offsetX - size.x, 0), Paint());
    }
  }
}
