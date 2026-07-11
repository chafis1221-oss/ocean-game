// island_component.dart - Pulau dengan physics body

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:forge2d/forge2d.dart';
import 'physics/physics_world.dart';
import 'painters/island_painter.dart';

class IslandComponent extends PositionComponent {
  bool usePhysics = false;
  Body? _body;
  OceanGame? _game;

  IslandComponent({
    Vector2? position,
    Vector2? size,
    this.usePhysics = false,
  }) : super(position: position, size: size ?? Vector2(120, 80));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _game = findAncestorByName('OceanGame') as OceanGame?;
    
    if (usePhysics && _game != null) {
      final pw = _game!.physicsWorld;
      _body = pw.createIslandBody(position, size);
      _body!.userData = this;
    }
  }

  @override
  void render(Canvas canvas) {
    IslandPainter.paintIsland(canvas, size, position);
  }
}
