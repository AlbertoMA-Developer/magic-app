import 'package:magic_app_1/models/player.dart';

class GameSession {
  final String id;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int playerCount;
  final int startingLife;
  final List<Player> players;
  final String? winnerId;
  final int durationSeconds;
  final bool isPaused; // Runtime state, probably not saved to DB unless we want to resume exactly state

  GameSession({
    required this.id,
    required this.startedAt,
    this.endedAt,
    required this.playerCount,
    required this.startingLife,
    required this.players,
    this.winnerId,
    this.durationSeconds = 0,
    this.isPaused = false,
  });

  GameSession copyWith({
    String? id,
    DateTime? startedAt,
    DateTime? endedAt,
    int? playerCount,
    int? startingLife,
    List<Player>? players,
    String? winnerId,
    int? durationSeconds,
    bool? isPaused,
  }) {
    return GameSession(
      id: id ?? this.id,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      playerCount: playerCount ?? this.playerCount,
      startingLife: startingLife ?? this.startingLife,
      players: players ?? this.players,
      winnerId: winnerId ?? this.winnerId,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
      'player_count': playerCount,
      'starting_life': startingLife,
      'winner_id': winnerId,
      'duration_seconds': durationSeconds,
      // players are stored in a separate table
    };
  }

  factory GameSession.fromJson(Map<String, dynamic> map, {List<Player>? players}) {
    return GameSession(
      id: map['id'],
      startedAt: DateTime.parse(map['started_at']),
      endedAt: map['ended_at'] != null ? DateTime.parse(map['ended_at']) : null,
      playerCount: map['player_count'],
      startingLife: map['starting_life'],
      players: players ?? [], // Players must be loaded separately or passed in
      winnerId: map['winner_id'],
      durationSeconds: map['duration_seconds'] ?? 0,
      isPaused: false, // Default to false when loading from DB
    );
  }
}
