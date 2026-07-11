// menu_screen.dart - Main menu (ONLINE + BOT)

import 'package:flutter/material.dart';
import '../widgets/custom_button.dart';
import '../core/routes.dart';
import '../network/websocket.dart';

class MenuScreen extends StatelessWidget {
  void _joinMatch(BuildContext context, {required bool isBot, String shipType = 'battleship'}) {
    // Connect ke WebSocket dulu
    WebSocketManager.connect('dummy_token', onMessage: (data) {
      final type = data['type'] ?? '';
      if (type == 'match_found' || type == 'bot_match_created') {
        // Navigasi ke lobby atau game
        Navigator.pushReplacementNamed(context, AppRoutes.lobby);
      }
    });

    if (isBot) {
      WebSocketManager.joinBotMatch(shipType: shipType);
    } else {
      WebSocketManager.joinOnlineMatch(shipType: shipType);
    }
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
              Text('OCEAN COMMAND', style: TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold)),
              SizedBox(height: 60),
              
              // ONLINE
              CustomButton(
                text: '🌐 ONLINE (4v4 Real Player)',
                onPressed: () => _joinMatch(context, isBot: false),
              ),
              SizedBox(height: 12),
              
              // BOT
              CustomButton(
                text: '🤖 BOT (1 Player + 7 AI)',
                onPressed: () => _joinMatch(context, isBot: true),
              ),
              SizedBox(height: 12),
              
              // OFFLINE (local, tanpa server)
              CustomButton(
                text: '🛠️ OFFLINE (Local AI)',
                onPressed: () => Navigator.pushNamed(context, AppRoutes.game, arguments: {'offline': true}),
              ),
              SizedBox(height: 16),
              
              CustomButton(
                text: '📊 Leaderboard',
                onPressed: () {},
              ),
              SizedBox(height: 16),
              CustomButton(
                text: '🚪 Logout',
                onPressed: () {
                  WebSocketManager.disconnect();
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
                isOutlined: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
