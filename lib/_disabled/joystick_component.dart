// joystick_component.dart - Virtual joystick buat mobile

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class JoystickComponent extends PositionComponent with DragCallbacks {
  final Function(Vector2) onMove;
  
  Vector2 _delta = Vector2.zero();
  bool _isDragging = false;
  double _radius = 50;
  Vector2 _center = Vector2.zero();
  
  JoystickComponent({
    required this.onMove,
    Vector2? position,
    double? radius,
  }) : super(position: position) {
    _radius = radius ?? 50;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    size = Vector2(_radius * 3, _radius * 3);
    _center = size / 2;
  }

  @override
  void onDragStart(DragStartEvent event) {
    _isDragging = true;
    _updateDelta(event.localPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_isDragging) {
      _updateDelta(event.localPosition);
    }
  }

  @override
  void onDragEnd(DragEndEvent event) {
    _isDragging = false;
    _delta = Vector2.zero();
    onMove(_delta);
  }

  void _updateDelta(Vector2 localPos) {
    final delta = localPos - _center;
    final distance = delta.length;
    
    if (distance < 10) {
      _delta = Vector2.zero();
    } else if (distance > _radius) {
      _delta = delta.normalized() * (distance / _radius);
    } else {
      _delta = delta / _radius;
    }
    
    // Clamp biar ga lebih dari 1
    if (_delta.length > 1) {
      _delta = _delta.normalized();
    }
    
    onMove(_delta);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final paint = Paint()..color = Colors.white.withOpacity(0.3);
    final center = _center;
    final radius = _radius;
    
    // Lingkaran luar
    canvas.drawCircle(center, radius, paint);
    
    // Lingkaran dalam (thumb)
    final thumbPos = center + (_delta * radius);
    final thumbPaint = Paint()
      ..color = Colors.white.withOpacity(0.6);
    canvas.drawCircle(thumbPos, 20, thumbPaint);
    
    // Garis panduan
    if (_isDragging) {
      final guidePaint = Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.stroke;
      canvas.drawLine(center, thumbPos, guidePaint);
    }
  }
}
