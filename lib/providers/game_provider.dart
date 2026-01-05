import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:magic_app_1/models/game_session.dart';
import 'package:magic_app_1/models/player.dart';
import 'package:magic_app_1/services/database_helper.dart';

final gameProvider = StateNotifierProvider<GameNotifier, GameSession?>((ref) {
  return GameNotifier();
});

class GameNotifier extends StateNotifier<GameSession?> {
  GameNotifier() : super(null);

  Timer? _timer;

  void startGame({
    required int playerCount,
    required int startingLife,
    required List<String> playerNames,
  }) {
    final String sessionId = const Uuid().v4();
    final List<Player> players = [];

    for (int i = 0; i < playerCount; i++) {
      players.add(Player(
        id: const Uuid().v4(),
        name: playerNames[i],
        life: startingLife,
      ));
    }

    state = GameSession(
      id: sessionId,
      startedAt: DateTime.now(),
      playerCount: playerCount,
      startingLife: startingLife,
      players: players,
      durationSeconds: 0,
      isPaused: false,
    );

    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state != null && !state!.isPaused && state!.endedAt == null) {
        state = state!.copyWith(
          durationSeconds: state!.durationSeconds + 1,
        );
        // Auto-save every 30 seconds
        if (state!.durationSeconds % 30 == 0) {
          saveGame();
        }
      }
    });
  }

  void pauseTimer() {
    if (state != null) {
      state = state!.copyWith(isPaused: true);
    }
  }

  void resumeTimer() {
    if (state != null) {
      state = state!.copyWith(isPaused: false);
    }
  }

  void updateLife(String playerId, int delta) {
    if (state == null) return;

    final updatedPlayers = state!.players.map((p) {
      if (p.id == playerId) {
        return p.copyWith(life: p.life + delta);
      }
      return p;
    }).toList();

    state = state!.copyWith(players: updatedPlayers);
  }

  void updateCommanderDamage(String victimId, String attackerId, int delta) {
    if (state == null) return;

    final updatedPlayers = state!.players.map((p) {
      if (p.id == victimId) {
        final currentDamage = p.commanderDamage[attackerId] ?? 0;
        final newDamage = currentDamage + delta;
        if (newDamage < 0) return p;

        final newCommanderDamage = Map<String, int>.from(p.commanderDamage);
        newCommanderDamage[attackerId] = newDamage;

        // Check if damage >= 21? Not implementing automatic elimination yet, just tracking.
        return p.copyWith(commanderDamage: newCommanderDamage);
      }
      return p;
    }).toList();

    state = state!.copyWith(players: updatedPlayers);
    
    // Also update life totals! Commander damage reduces life.
    // Rule: Commander damage also causes loss of life.
    // The requirement says "Track life totals and commander damage".
    // Usually commander damage IS damage, so it reduces life.
    // If I change commander damage, I should arguably change life too.
    // However, sometimes apps treat them separately to allow manual correction.
    // I will assume for now that changing commander damage SHOULD reduce life if delta is positive (damage dealt),
    // and increase life if delta is negative (correction).
    // Wait, the prompt lists "Life adjustment buttons" separately from "Commander damage indicator".
    // It's safer to NOT link them automatically unless specified, to avoid double counting if user adjusts both.
    // But standard MTG rules say commander damage reduces life.
    // I'll leave them separate for manual control as is common in life counter apps, or better yet,
    // I'll make the commander damage modal ONLY track commander damage, but the user still adjusts life manually?
    // "Tap commander damage section to open tracking modal... List each opponent with current damage dealt... +/- buttons".
    // Most apps: updating CMD damage DOES update life.
    // I will decouple them for v1 to avoid confusion or "fighting" the UI, 
    // BUT I will add a comment about this decision.
    // UPDATED DECISION: Decoupled. User manages life and CMD damage separately to ensure total control.
  }

  Future<void> endGame(String winnerId) async {
    if (state == null) return;
    
    _timer?.cancel();

    // Mark winner
    final updatedPlayers = state!.players.map((p) {
       // logic for placement can be complex, just marking winner for now
       if (p.id == winnerId) {
         return p.copyWith(placement: 1);
       }
       return p; 
    }).toList();

    state = state!.copyWith(
      endedAt: DateTime.now(),
      winnerId: winnerId,
      players: updatedPlayers,
      isPaused: true,
    );

    await saveGame();
  }
  
  Future<void> saveGame() async {
    if (state != null) {
      await DatabaseHelper.instance.saveGameSession(state!);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
