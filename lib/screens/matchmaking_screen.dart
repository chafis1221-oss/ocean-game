// matchmaking_screen.dart - Cari match (redirect ke lobby)

import 'package:flutter/material.dart';
import '../network/websocket.dart';
import '../core/routes.dart';

class MatchmakingScreen extends StatefulWidget {
  @override
  _MatchmakingScreenState createState() => _MatchmakingScreenState();
}

class _MatchmakingScreenState extends State<MatchmakingScreen> {
  bool _isSearching = false;
  String _status = 'Tekan tombol untuk cari match';
  String _queuePosition = '';

  @override
  void initState() {
    super.initState();
    _setupWebSocket();
  }

  void _setupWebSocket() {
    // Connect ke backend
    WebSocketManager.connect('token', onMessage: (data) {
      final type = data['type'] ?? '';
      
      switch (type) {
        case 'match_found':
          setState(() {
            _status = '🎯 Match found! Masuk lobby...';
            _isSearching = false;
          });
          // Navigasi ke lobby
          Future.delayed(Duration(milliseconds: 500), () {
            Navigator.pushReplacementNamed(context, AppRoutes.lobby);
          });
          break;
          
        case 'error':
          setState(() {
            _status = '❌ ${data['error']}';
            _isSearching = false;
          });
          break;
          
        default:
          print('WS: $data');
      }
    });
  }

  @override
  void dispose() {
    WebSocketManager.disconnect();
    super.dispose();
  }

  Future<void> _startMatchmaking() async {
    setState(() {
      _isSearching = true;
      _status = 'Mencari match...';
      _queuePosition = '';
    });

    // Join match
    WebSocketManager.joinMatch(shipType: 'battleship');

    // Simulasi queue (nanti dari server)
    int pos = 1;
    while (_isSearching && pos <= 8) {
      await Future.delayed(Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _queuePosition = 'Antrian posisi: $pos';
          pos++;
        });
      }
    }
  }

  void _cancelMatchmaking() {
    WebSocketManager.leaveMatch();
    setState(() {
      _isSearching = false;
      _status = 'Matchmaking dibatalkan';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('MATCHMAKING', style: TextStyle(fontSize: 28, color: Colors.white)),
              SizedBox(height: 40),
              if (_isSearching) ...[
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text(_status, style: TextStyle(color: Colors.white70)),
                SizedBox(height: 10),
                Text(_queuePosition, style: TextStyle(color: Colors.white60)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _cancelMatchmaking,
                  child: Text('❌ Batal', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
              ] else ...[
                Text(_status, style: TextStyle(color: Colors.white70)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _startMatchmaking,
                  child: Text('🔍 Cari Match', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 55),
                  ),
                ),
              ],
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  WebSocketManager.disconnect();
                  Navigator.pop(context);
                },
                child: Text('Kembali', style: TextStyle(color: Colors.white70)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
