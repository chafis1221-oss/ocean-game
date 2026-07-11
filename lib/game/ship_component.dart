// ship_component.dart - Kapal (dengan suara)

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:forge2d/forge2d.dart';
import 'physics/physics_world.dart';
import 'painters/ship_painter.dart';
import 'particles/explosion.dart';
import 'hud/damage_text.dart';
import 'effects/screen_shake.dart';
import 'systems/resource_manager.dart';
import 'audio/sound_manager.dart';

class ShipComponent extends PositionComponent {
  bool isPlayer;
  bool isCarrier;
  bool usePhysics = false;
  
  double hp = 100;
  double maxHp = 100;
  double _speed = 120;
  double _turnRate = 2.0;
  double _currentAngle = 0;
  bool _isDead = false;
  Vector2 _targetDirection = Vector2(0, -1);
  String playerId = '';
  String username = '';
  
  Body? _body;
  OceanGame? _game;

  ShipComponent({
    required this.isPlayer,
    required this.isCarrier,
    Vector2? position,
    this.usePhysics = false,
    this.playerId = '',
    this.username = '',
  }) : super(position: position);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _game = findAncestorByName('OceanGame') as OceanGame?;
    
    if (playerId.isEmpty) playerId = isPlayer ? 'player_1' : 'enemy_1';
    if (username.isEmpty) username = isPlayer ? 'You' : 'Enemy';

    _speed = isCarrier ? 120 : 90;
    _turnRate = isCarrier ? 2.0 : 1.2;
    size = isCarrier ? Vector2(80, 40) : Vector2(70, 50);
    anchor = Anchor.center;

    if (usePhysics && _game != null) {
      final pw = _game!.physicsWorld;
      _body = pw.createShipBody(position, size, true);
      _body!.userData = this;
    }

    if (isPlayer) {
      ResourceManager.currentShipHp = hp;
      ResourceManager.maxShipHp = maxHp;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final baseColor = isPlayer ? const Color(0xFF2196F3) : const Color(0xFFF44336);
    ShipPainter.paintShip(canvas, size, baseColor, isPlayer, isCarrier, angle, hp / maxHp);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_body != null) {
      position = PhysicsWorld.toPixel(_body!.position);
      angle = _body!.angle;
    }
    if (isPlayer) ResourceManager.currentShipHp = hp;
  }

  void applyForce(Vector2 force) {
    if (_body == null) return;
    _body!.applyForceToCenter(force / PhysicsWorld.unitScale);
  }
  
  void moveToward(Vector2 target, double dt) {
    if (_body == null) return;
    final dir = (target - position).normalized();
    final force = dir * _speed * dt * 50;
    _body!.applyForceToCenter(force / PhysicsWorld.unitScale);
  }

  void setVelocity(Vector2 velocity) {
    if (_body == null) return;
    _body!.setLinearVelocity(velocity / PhysicsWorld.unitScale);
  }

  Vector2 get velocity {
    if (_body == null) return Vector2.zero();
    return PhysicsWorld.toPixel(_body!.linearVelocity);
  }

  Body? get physicsBody => _body;

  void takeDamage(double damage, {bool triggerExplosion = true}) {
    hp = max(0, hp - damage);
    if (hp > 0) SoundManager().play(SoundType.hit);
    if (hp <= 0 && !_isDead) {
      _isDead = true;
      if (triggerExplosion) _triggerExplosion();
    }
  }

  void updateHp(double newHp, {bool triggerExplosion = true}) {
    hp = newHp.clamp(0, maxHp);
    if (hp <= 0 && !_isDead) {
      _isDead = true;
      if (triggerExplosion) _triggerExplosion();
    }
  }

  void rotateToDirection(Vector2 direction) {
    if (direction.length > 0.1) {
      _targetDirection = direction.normalized();
      final targetAngle = _targetDirection.angle();
      var diff = targetAngle - _currentAngle;
      while (diff > 3.14159) diff -= 2 * 3.14159;
      while (diff < -3.14159) diff += 2 * 3.14159;
      final maxTurn = _turnRate * 0.05;
      final turnAmount = diff.clamp(-maxTurn, maxTurn);
      _currentAngle += turnAmount;
      if (_body == null) angle = _currentAngle;
    }
  }

  double getSpeed() => _speed;
  bool get isDead => _isDead;

  void _triggerExplosion() {
    if (_game == null) return;
    SoundManager().play(SoundType.explosion);
    if (isCarrier) SoundManager().play(SoundType.nuke);
    
    final explosion = Explosion(
      position: position,
      radius: isCarrier ? 50 : 40,
      isBig: isCarrier,
      victimName: username,
    );
    _game!.add(explosion);
    
    final shake = _game!.children.whereType<ScreenShake>().firstOrNull;
    if (shake != null) shake.shake(intensity: isCarrier ? 25 : 15, duration: 0.5);
    
    final damageText = DamageText(
      position: Vector2(position.x, position.y - 20),
      damage: 999,
      color: Colors.red,
    );
    _game!.add(damageText);
    _game!.startSlowMotion(0.3, 1.2);
    print('💥 ${isPlayer ? "Player" : "Enemy"} destroyed!');
  }
}
