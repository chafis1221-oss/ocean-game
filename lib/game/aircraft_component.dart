// aircraft_component.dart - Pesawat dengan painter 3D

import 'package:flame/components.dart';
import 'painters/aircraft_painter.dart';

enum AircraftType { fighter, bomber, antiMissile, helicopter }

class AircraftComponent extends PositionComponent {
  final AircraftType type;
  final bool isFriendly;
  final double maxAmmo;
  double ammo;
  final double speed;
  final double damage;
  bool isReturning = false;
  Vector2? targetPosition;
  Vector2? carrierPosition;
  String? targetId;
  double _propellerAngle = 0;

  AircraftComponent({
    required this.type,
    required this.isFriendly,
    required this.maxAmmo,
    required this.speed,
    required this.damage,
    Vector2? position,
    this.targetPosition,
    this.carrierPosition,
    this.targetId,
  }) : super(position: position) {
    ammo = maxAmmo;
    switch (type) {
      case AircraftType.fighter: size = Vector2(30, 16); break;
      case AircraftType.bomber: size = Vector2(40, 22); break;
      case AircraftType.antiMissile: size = Vector2(20, 12); break;
      case AircraftType.helicopter: size = Vector2(24, 24); break;
    }
  }

  @override
  void render(Canvas canvas) {
    final color = isFriendly ? Colors.cyan : Colors.orange;
    final typeStr = type == AircraftType.helicopter ? 'helicopter' : 'aircraft';
    AircraftPainter.paintAircraft(
      canvas,
      size,
      color,
      typeStr,
      angle,
      _propellerAngle,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    _propellerAngle += dt * 20;
    if (velocity.length > 1) angle = velocity.angle();
  }

  void setTarget(Vector2 target) { targetPosition = target; }
  void returnToCarrier(Vector2 carrierPos) {
    carrierPosition = carrierPos;
    isReturning = true;
  }
  bool hasAmmo() => ammo > 0;
  void useAmmo() { if (ammo > 0) ammo--; }
}
