// game_screen.dart - Game screen

import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flutter/services.dart';
import '../game/ocean_game.dart';

class GameScreen extends StatelessWidget {
  static const routeName = '/game';
  
  final bool isOffline;
  final String shipType;
  
  const GameScreen({
    Key? key,
    this.isOffline = false,
    this.shipType = 'battleship',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    return Scaffold(
      body: GameWidget(
        game: OceanGame(
          isOffline: isOffline,
          shipType: shipType,
        ),
      ),
    );
  }
}
