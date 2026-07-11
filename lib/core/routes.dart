// routes.dart - Navigasi

import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/menu_screen.dart';
import '../screens/matchmaking_screen.dart';
import '../screens/game_screen.dart';
import '../screens/lobby_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String menu = '/menu';
  static const String matchmaking = '/matchmaking';
  static const String lobby = '/lobby';
  static const String game = '/game';

  static Map<String, WidgetBuilder> get routes => {
    login: (context) => LoginScreen(),
    menu: (context) => MenuScreen(),
    matchmaking: (context) => MatchmakingScreen(),
    lobby: (context) => LobbyScreen(lobbyId: 'LOBBY_001'),
    game: (context) => GameScreen(
      isOffline: false,
      shipType: 'battleship',
    ),
  };
}
