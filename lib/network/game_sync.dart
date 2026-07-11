// game_sync.dart - Sync game state dengan server

import 'websocket.dart';
import 'dart:convert';

class GameSync {
  static String? _playerId;
  static String? _roomId;
  static Function(Map<String, dynamic>)? onGameState;
  static Function(Map<String, dynamic>)? onPlayerJoined;
  static Function(String)? onPlayerLeft;
  static Function(Map<String, dynamic>)? onProjectileFired;
  static Function(Map<String, dynamic>)? onAircraftLaunched;
  static Function(Map<String, dynamic>)? onMatchEnd;

  static void init({required String playerId, required String roomId}) {
    _playerId = playerId;
    _roomId = roomId;

    WebSocketManager.connect('dummy_token', onMessage: (data) {
      final type = data['type'] ?? '';
      switch (type) {
        case 'game_state':
          if (onGameState != null) onGameState!(data['data']);
          break;
        case 'player_joined':
          if (onPlayerJoined != null) onPlayerJoined!(data['data']);
          break;
        case 'player_left':
          if (onPlayerLeft != null) onPlayerLeft!(data['playerId']);
          break;
        case 'projectile_fired':
          if (onProjectileFired != null) onProjectileFired!(data['data']);
          break;
        case 'aircraft_launched':
          if (onAircraftLaunched != null) onAircraftLaunched!(data['data']);
          break;
        case 'match_end':
          if (onMatchEnd != null) onMatchEnd!(data['data']);
          break;
        default:
          print('Unknown WS type: $type');
      }
    });
  }

  static void sendMove(Vector2 delta) {
    WebSocketManager.send({
      'type': 'move',
      'playerId': _playerId,
      'x': delta.x,
      'y': delta.y,
    });
  }

  static void sendShoot(double x, double y, String targetId) {
    WebSocketManager.send({
      'type': 'shoot',
      'playerId': _playerId,
      'x': x,
      'y': y,
      'targetId': targetId,
    });
  }

  static void sendLaunchAircraft(String aircraftType) {
    WebSocketManager.send({
      'type': 'launch_aircraft',
      'playerId': _playerId,
      'aircraftType': aircraftType,
    });
  }

  static void sendNuke(double x, double y, String targetId) {
    WebSocketManager.send({
      'type': 'nuke',
      'playerId': _playerId,
      'x': x,
      'y': y,
      'targetId': targetId,
    });
  }

  static void disconnect() {
    WebSocketManager.disconnect();
  }
}
