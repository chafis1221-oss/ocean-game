// lobby_screen.dart - Lobby sebelum match

import 'package:flutter/material.dart';
import '../models/lobby.dart';
import '../widgets/player_card.dart';
import '../network/websocket.dart';

class LobbyScreen extends StatefulWidget {
  static const routeName = '/lobby';
  
  final String lobbyId;
  final bool isLeader;

  const LobbyScreen({
    Key? key,
    required this.lobbyId,
    this.isLeader = false,
  }) : super(key: key);

  @override
  _LobbyScreenState createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  late LobbyState _lobby;
  bool _isLoading = true;
  String _selectedShip = 'battleship';
  
  // Dummy players untuk demo
  final List<LobbyPlayer> _dummyPlayers = [
    LobbyPlayer(id: 'p1', username: 'Kapten', team: 'A', isLeader: true),
    LobbyPlayer(id: 'p2', username: 'Laksamana', team: 'A'),
    LobbyPlayer(id: 'p3', username: 'Nakhoda', team: 'B'),
    LobbyPlayer(id: 'p4', username: 'Bos', team: 'B'),
  ];

  @override
  void initState() {
    super.initState();
    _lobby = LobbyState(
      lobbyId: widget.lobbyId,
      players: _dummyPlayers,
    );
    _isLoading = false;
    
    // Setup WebSocket listener
    // TODO: Connect ke backend untuk realtime update
  }

  void _toggleReady() {
    setState(() {
      // Toggle ready untuk current player
      final currentPlayerIndex = _lobby.players.indexWhere((p) => p.id == 'p1');
      if (currentPlayerIndex != -1) {
        final updated = _lobby.players[currentPlayerIndex].copyWith(
          isReady: !_lobby.players[currentPlayerIndex].isReady,
        );
        _lobby.players[currentPlayerIndex] = updated;
      }
    });
  }

  void _changeShip(String shipType) {
    setState(() {
      _selectedShip = shipType;
      // Update ship di server
    });
  }

  void _startMatch() {
    if (!_lobby.allReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tunggu semua player ready!')),
      );
      return;
    }
    
    // Kirim signal start match ke server
    // WebSocketManager.send({'type': 'start_match', 'lobbyId': widget.lobbyId});
    
    // Navigasi ke game
    Navigator.pushReplacementNamed(
      context,
      '/game',
      arguments: {
        'isOffline': false,
        'shipType': _selectedShip,
      },
    );
  }

  void _kickPlayer(String playerId) {
    setState(() {
      _lobby.players.removeWhere((p) => p.id == playerId);
    });
  }

  void _promotePlayer(String playerId) {
    setState(() {
      for (var player in _lobby.players) {
        player.isLeader = player.id == playerId;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentPlayer = _lobby.players.firstWhere(
      (p) => p.id == 'p1',
      orElse: () => _lobby.players.first,
    );

    return Scaffold(
      backgroundColor: Colors.blue[900],
      appBar: AppBar(
        title: Text('🏠 LOBBY ${widget.lobbyId}'),
        backgroundColor: Colors.blue[800],
        actions: [
          // Timer
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.timer, color: Colors.white70),
                SizedBox(width: 4),
                Text(
                  '30s',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Match info
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.blue[800],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text('Team A', style: TextStyle(color: Colors.blue[200])),
                    Text(
                      '${_lobby.teamACount}',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_lobby.players.length}/${_lobby.maxPlayers}',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                Column(
                  children: [
                    Text('Team B', style: TextStyle(color: Colors.red[200])),
                    Text(
                      '${_lobby.teamBCount}',
                      style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Ship selection
          Container(
            padding: EdgeInsets.all(12),
            color: Colors.blue[700],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Pilih Kapal:', style: TextStyle(color: Colors.white70)),
                SizedBox(width: 16),
                _buildShipButton('battleship', 'Battleship', Icons.sailing),
                SizedBox(width: 8),
                _buildShipButton('carrier', 'Carrier', Icons.airplanemode_active),
              ],
            ),
          ),
          
          // Players list
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(8),
              itemCount: _lobby.players.length,
              itemBuilder: (context, index) {
                final player = _lobby.players[index];
                final isCurrent = player.id == 'p1';
                return PlayerCard(
                  player: player,
                  isCurrentPlayer: isCurrent,
                  onReadyToggle: isCurrent ? _toggleReady : null,
                  onKick: widget.isLeader && !isCurrent ? () => _kickPlayer(player.id) : null,
                  onPromote: widget.isLeader && !isCurrent && !player.isLeader
                      ? () => _promotePlayer(player.id)
                      : null,
                );
              },
            ),
          ),
          
          // Actions
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.blue[800],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Leave
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.exit_to_app, color: Colors.white70),
                  label: Text('Keluar', style: TextStyle(color: Colors.white70)),
                ),
                
                // Start (hanya leader)
                if (widget.isLeader)
                  ElevatedButton.icon(
                    onPressed: _startMatch,
                    icon: Icon(Icons.play_arrow),
                    label: Text(
                      _lobby.allReady ? '🚀 START MATCH' : 'TUNGGU READY',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _lobby.allReady ? Colors.green : Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShipButton(String type, String label, IconData icon) {
    final isSelected = _selectedShip == type;
    return GestureDetector(
      onTap: () => _changeShip(type),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[300] : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 16),
            SizedBox(width: 4),
            Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
