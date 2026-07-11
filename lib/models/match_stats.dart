// match_stats.dart - Statistik player di match

class MatchStats {
  String playerId;
  String username;
  String shipType;
  String team;
  int damageDealt;
  int damageTaken;
  int kills;
  bool isAlive;
  bool isMVP;

  MatchStats({
    required this.playerId,
    required this.username,
    required this.shipType,
    required this.team,
    this.damageDealt = 0,
    this.damageTaken = 0,
    this.kills = 0,
    this.isAlive = true,
    this.isMVP = false,
  });

  // ===== MVP SCORE =====
  int get mvpScore => (damageDealt * 2) + (kills * 50);

  Map<String, dynamic> toJson() => {
    'playerId': playerId,
    'username': username,
    'shipType': shipType,
    'team': team,
    'damageDealt': damageDealt,
    'damageTaken': damageTaken,
    'kills': kills,
    'isAlive': isAlive,
    'isMVP': isMVP,
  };

  factory MatchStats.fromJson(Map<String, dynamic> json) {
    return MatchStats(
      playerId: json['playerId'] ?? '',
      username: json['username'] ?? 'Player',
      shipType: json['shipType'] ?? 'battleship',
      team: json['team'] ?? 'A',
      damageDealt: json['damageDealt'] ?? 0,
      damageTaken: json['damageTaken'] ?? 0,
      kills: json['kills'] ?? 0,
      isAlive: json['isAlive'] ?? true,
      isMVP: json['isMVP'] ?? false,
    );
  }
}

class MatchResult {
  String matchId;
  String winnerTeam;
  List<MatchStats> players;
  int duration;

  MatchResult({
    required this.matchId,
    required this.winnerTeam,
    required this.players,
    this.duration = 0,
  });

  MatchStats? get mvp {
    if (players.isEmpty) return null;
    return players.reduce((a, b) => a.mvpScore > b.mvpScore ? a : b);
  }

  List<MatchStats> get sortedByDamage =>
    [...players]..sort((a, b) => b.damageDealt.compareTo(a.damageDealt));
}
