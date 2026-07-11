// physics_world.dart - World & Body management (dengan getter bodies)

import 'package:forge2d/forge2d.dart';

class PhysicsWorld {
  static final PhysicsWorld _instance = PhysicsWorld._internal();
  factory PhysicsWorld() => _instance;
  PhysicsWorld._internal();

  World? _world;
  List<Body> _bodies = [];
  
  static const double gravity = 0.0;
  static const double unitScale = 10.0;
  static const double timeStep = 1.0 / 60.0;
  static const int velocityIterations = 8;
  static const int positionIterations = 3;

  World get world {
    if (_world == null) {
      _world = World(Vector2(0, gravity));
    }
    return _world!;
  }

  List<Body> get bodies => _bodies;

  void init() {
    _world = World(Vector2(0, gravity));
    _bodies.clear();
    print('⚙️ Physics World initialized');
  }

  Body createShipBody(Vector2 position, Size size, bool isDynamic) {
    final bodyDef = BodyDef()
      ..type = isDynamic ? BodyType.dynamic : BodyType.static
      ..position = position / unitScale
      ..angle = 0
      ..linearDamping = 0.5
      ..angularDamping = 0.8;

    final body = world.createBody(bodyDef);
    
    final shape = PolygonShape();
    final halfW = size.width / 2 / unitScale;
    final halfH = size.height / 2 / unitScale;
    shape.setAsBox(halfW, halfH);

    final fixture = FixtureDef(shape)
      ..density = 1.0
      ..friction = 0.3
      ..restitution = 0.1;

    body.createFixture(fixture);
    _bodies.add(body);
    return body;
  }

  Body createProjectileBody(Vector2 position, Size size, Vector2 velocity) {
    final bodyDef = BodyDef()
      ..type = BodyType.dynamic
      ..position = position / unitScale
      ..angle = velocity.angle()
      ..linearDamping = 0.0
      ..angularDamping = 0.0;

    final body = world.createBody(bodyDef);
    body.setLinearVelocity(velocity / unitScale);

    final shape = PolygonShape();
    final halfW = size.width / 2 / unitScale;
    final halfH = size.height / 2 / unitScale;
    shape.setAsBox(halfW, halfH);

    final fixture = FixtureDef(shape)
      ..density = 0.5
      ..friction = 0.0
      ..restitution = 0.0
      ..isSensor = true;

    body.createFixture(fixture);
    _bodies.add(body);
    return body;
  }

  Body createIslandBody(Vector2 position, Size size) {
    final bodyDef = BodyDef()
      ..type = BodyType.static
      ..position = position / unitScale;

    final body = world.createBody(bodyDef);
    
    final shape = PolygonShape();
    final halfW = size.width / 2 / unitScale;
    final halfH = size.height / 2 / unitScale;
    shape.setAsBox(halfW * 0.8, halfH * 0.8);

    final fixture = FixtureDef(shape)
      ..density = 0.0
      ..friction = 0.8
      ..restitution = 0.0;

    body.createFixture(fixture);
    _bodies.add(body);
    return body;
  }

  void update(double dt) {
    world.step(timeStep, velocityIterations, positionIterations);
  }

  static Vector2 toPhysics(Vector2 pixel) => pixel / unitScale;
  static Vector2 toPixel(Vector2 physics) => physics * unitScale;

  void dispose() {
    world.dispose();
    _bodies.clear();
  }
}
