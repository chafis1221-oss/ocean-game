// player_card.dart - Card player di lobby

import 'package:flutter/material.dart';
import '../models/lobby.dart';

class PlayerCard extends StatelessWidget {
  final LobbyPlayer player;
  final bool isCurrentPlayer;
  final VoidCallback? onReadyToggle;
  final VoidCallback? onKick;
  final VoidCallback? onPromote;

  const PlayerCard({
    Key? key,
    required this.player,
    this.isCurrentPlayer = false,
    this.onReadyToggle,
    this.onKick,
    this.onPromote,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: _getTeamColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _getTeamColor(),
          width: isCurrentPlayer ? 2 : 0,
        ),
      ),
      child: Row(
        children: [
          // Avatar / Icon
          CircleAvatar(
            backgroundColor: _getTeamColor(),
            child: Text(
              player.username[0].toUpperCase(),
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player.username,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (player.isLeader) ...[
                      SizedBox(width: 4),
                      Icon(Icons.star, color: Colors.yellow, size: 14),
                    ],
                    if (isCurrentPlayer) ...[
                      SizedBox(width: 4),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'YOU',
                          style: TextStyle(color: Colors.white, fontSize: 8),
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      player.shipType == 'carrier' ? Icons.airplanemode_active : Icons.sailing,
                      color: Colors.white70,
                      size: 12,
                    ),
                    SizedBox(width: 4),
                    Text(
                      player.shipType.toUpperCase(),
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                    SizedBox(width: 12),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: player.team == 'A' ? Colors.blue : Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Team ${player.team}',
                        style: TextStyle(color: Colors.white, fontSize: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Actions
          if (isCurrentPlayer)
            _buildReadyButton()
          else if (player.isLeader)
            _buildLeaderActions(),
          if (player.isReady)
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 20,
            ),
        ],
      ),
    );
  }

  Color _getTeamColor() {
    return player.team == 'A' ? Colors.blue : Colors.red;
  }

  Widget _buildReadyButton() {
    return IconButton(
      onPressed: onReadyToggle,
      icon: Icon(
        player.isReady ? Icons.check_circle : Icons.circle_outlined,
        color: player.isReady ? Colors.green : Colors.grey,
      ),
      tooltip: player.isReady ? 'Not ready' : 'Ready',
    );
  }

  Widget _buildLeaderActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Kick button
        IconButton(
          onPressed: onKick,
          icon: Icon(Icons.person_remove, color: Colors.red, size: 18),
          tooltip: 'Kick player',
        ),
        // Promote button (jika bukan leader)
        if (!player.isLeader)
          IconButton(
            onPressed: onPromote,
            icon: Icon(Icons.star_border, color: Colors.yellow, size: 18),
            tooltip: 'Promote to leader',
          ),
      ],
    );
  }
}
