// lobby.dart - Lobby state & model

class LobbyPlayer {
  final String id;
  final String username;
  final String shipType; // carrier / battleship
  final String team; // A / B
  final bool isReady;
  final bool isLeader;
  final int? avatarIndex;

  LobbyPlayer({
    required this.id,
    required this.username,
    this.shipType = 'battleship',
    this.team = 'A',
    this.isReady = false,
    this.isLeader = false,
    this.avatarIndex,
  });

  LobbyPlayer copyWith({
    String? id,
    String? username,
    String? shipType,
    String? team,
    bool? isReady,
    bool? isLeader,
    int? avatarIndex,
  }) {
    return LobbyPlayer(
      id: id ?? this.id,
      username: username ?? this.username,
      shipType: shipType ?? this.shipType,
      team: team ?? this.team,
      isReady: isReady ?? this.isReady,
      isLeader: isLeader ?? this.isLeader,
      avatarIndex: avatarIndex ?? this.avatarIndex,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'shipType': shipType,
    'team': team,
    'isReady': isReady,
    'isLeader': isLeader,
  };

  factory LobbyPlayer.fromJson(Map<String, dynamic> json) {
    return LobbyPlayer(
      id: json['id'] ?? '',
      username: json['username'] ?? 'Player',
      shipType: json['shipType'] ?? 'battleship',
      team: json['team'] ?? 'A',
      isReady: json['isReady'] ?? false,
      isLeader: json['isLeader'] ?? false,
      avatarIndex: json['avatarIndex'],
    );
  }
}

class LobbyState {
  final String lobbyId;
  final List<LobbyPlayer> players;
  final int maxPlayers;
  final bool isLocked;
  final String? matchId;

  LobbyState({
    required this.lobbyId,
    this.players = const [],
    this.maxPlayers = 8,
    this.isLocked = false,
    this.matchId,
  });

  int get teamACount => players.where((p) => p.team == 'A').length;
  int get teamBCount => players.where((p) => p.team == 'B').length;
  bool get isFull => players.length >= maxPlayers;
  bool get allReady => players.isNotEmpty && players.every((p) => p.isReady);

  LobbyState copyWith({
    String? lobbyId,
    List<LobbyPlayer>? players,
    int? maxPlayers,
    bool? isLocked,
    String? matchId,
  }) {
    return LobbyState(
      lobbyId: lobbyId ?? this.lobbyId,
      players: players ?? this.players,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      isLocked: isLocked ?? this.isLocked,
      matchId: matchId ?? this.matchId,
    );
  }

  factory LobbyState.fromJson(Map<String, dynamic> json) {
    final playersList = json['players'] as List? ?? [];
    return LobbyState(
      lobbyId: json['lobbyId'] ?? '',
      players: playersList.map((p) => LobbyPlayer.fromJson(p)).toList(),
      maxPlayers: json['maxPlayers'] ?? 8,
      isLocked: json['isLocked'] ?? false,
      matchId: json['matchId'],
    );
  }
}
