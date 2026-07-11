// kill_cam.dart - Efek kill cam (zoom + slow motion)

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class KillCamEffect extends Component {
  Vector2 targetPosition;
  double duration = 0;
  double maxDuration = 1.0;
  bool isActive = false;
  bool isDone = false;
  
  // Zoom state
  double _zoomProgress = 0;
  double _currentZoom = 1.0;
  final double _maxZoom = 2.0;
  
  // Slow motion
  double _timeScale = 1.0;
  
  // UI elements
  late RectangleComponent vignette;
  late TextComponent killText;

  KillCamEffect({required this.targetPosition});

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // 1. Vignette (border hitam)
    vignette = RectangleComponent(
      size: Vector2(gameRef.size.x, gameRef.size.y),
      position: Vector2.zero(),
      paint: Paint()
        ..color = Colors.black.withOpacity(0)
        ..style = PaintingStyle.fill,
    );
    await gameRef.add(vignette);
    
    // 2. "KILL" text
    killText = TextComponent(
      text: '💀 KILL',
      position: Vector2(gameRef.size.x / 2, gameRef.size.y / 2 - 80),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.red,
          fontSize: 48,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(color: Colors.black, blurRadius: 10),
            Shadow(color: Colors.red, blurRadius: 20),
          ],
        ),
      ),
    );
    killText.scale = Vector2.zero();
    await gameRef.add(killText);
    
    // 3. "KILLER" text (nanti diisi)
    final killerText = TextComponent(
      text: '',
      position: Vector2(gameRef.size.x / 2, gameRef.size.y / 2 - 20),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 8)],
        ),
      ),
    );
    await gameRef.add(killerText);
    
    isActive = true;
    print('🎬 Kill Cam activated at (${targetPosition.x}, ${targetPosition.y})');
  }

  @override
  void update(double dt) {
    if (!isActive || isDone) return;
    
    duration += dt;
    _zoomProgress = (duration / maxDuration).clamp(0, 1);
    
    // ===== SLOW MOTION =====
    if (_zoomProgress < 0.3) {
      // Slow motion: 0.3x speed
      _timeScale = 0.3;
    } else if (_zoomProgress < 0.7) {
      // Kembali normal
      _timeScale = 0.5 + (_zoomProgress - 0.3) * 2.5;
    } else {
      _timeScale = 1.0;
    }
    
    // ===== ZOOM =====
    // Zoom in cepat, lalu zoom out
    if (_zoomProgress < 0.2) {
      _currentZoom = 1 + (_zoomProgress / 0.2) * (_maxZoom - 1);
    } else if (_zoomProgress < 0.6) {
      _currentZoom = _maxZoom - (_zoomProgress - 0.2) / 0.4 * (_maxZoom - 1) * 0.8;
    } else {
      _currentZoom = 1 + (1 - _zoomProgress) / 0.4 * 0.2;
    }
    
    // ===== VIGNETTE =====
    final vignetteOpacity = _zoomProgress < 0.5
        ? _zoomProgress * 0.6
        : (1 - _zoomProgress) * 0.6;
    vignette.paint.color = Colors.black.withOpacity(vignetteOpacity.clamp(0, 0.6));
    
    // ===== KILL TEXT =====
    // Muncul tiba-tiba di awal, lalu fade
    if (_zoomProgress < 0.1) {
      killText.scale = Vector2.all(_zoomProgress / 0.1);
    } else if (_zoomProgress < 0.8) {
      killText.scale = Vector2.all(1);
      killText.paint.color = Colors.red.withOpacity(1);
    } else {
      final fadeOut = (1 - (_zoomProgress - 0.8) / 0.2);
      killText.paint.color = Colors.red.withOpacity(fadeOut);
    }
    
    // ===== DONE =====
    if (_zoomProgress >= 1) {
      isDone = true;
      isActive = false;
      _timeScale = 1.0;
      _currentZoom = 1.0;
      
      // Hapus UI
      vignette.removeFromParent();
      killText.removeFromParent();
      
      print('🎬 Kill Cam finished');
    }
  }

  // ===== GETTER =====
  double get timeScale => _timeScale;
  double get zoom => _currentZoom;
  bool get active => isActive;
  bool get done => isDone;
  
  // Untuk camera offset (posisi kamera)
  Vector2 get cameraOffset {
    if (!isActive) return Vector2.zero();
    final progress = _zoomProgress.clamp(0, 0.5) * 2;
    final offsetX = (gameRef.size.x / 2 - targetPosition.x) * progress * 0.3;
    final offsetY = (gameRef.size.y / 2 - targetPosition.y) * progress * 0.3;
    return Vector2(offsetX, offsetY);
  }
}
