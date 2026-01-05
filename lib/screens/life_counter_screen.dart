import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // Wait, why did I auto-complete this? NOT NEEDED.
// Correct imports:
import 'package:magic_app_1/providers/game_provider.dart';
import 'package:magic_app_1/widgets/player_life_widget.dart';
import 'package:magic_app_1/models/player.dart';
import 'package:magic_app_1/widgets/commander_damage_modal.dart';
import 'package:google_fonts/google_fonts.dart';

class LifeCounterScreen extends ConsumerWidget {
  const LifeCounterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final GameNotifier notifier = ref.read(gameProvider.notifier);

    if (gameState == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Quit Game?'),
            content: const Text('Are you sure you want to quit? Current game progress will be saved.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Quit')),
            ],
          ),
        );
        return shouldPop ?? false;
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Top Bar
              Container(
                height: 60,
                color: Theme.of(context).cardColor,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(gameState.isPaused ? Icons.play_arrow : Icons.pause),
                      onPressed: () {
                        if (gameState.isPaused) {
                          notifier.resumeTimer();
                        } else {
                          notifier.pauseTimer();
                        }
                      },
                    ),
                    const SizedBox(width: 16),
                    Text(
                      _formatDuration(gameState.durationSeconds),
                      style: GoogleFonts.inter(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () => _showEndGameDialog(context, ref, gameState.players),
                      icon: const Icon(Icons.flag),
                      label: const Text('End Game'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Player Grid
              Expanded(
                child: _buildPlayerGrid(context, gameState.players, notifier),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildPlayerGrid(BuildContext context, List<Player> players, GameNotifier notifier) {
    // Determine layout based on player count
    if (players.length == 2) {
      return Column(
        children: [
          // Rotate top player for 2-player head-to-head?
          // Let's keep it simple upright for now as per v1 requirements unless requested.
          PlayerLifeWidget(
            player: players[0],
            onLifeIncrement: () => notifier.updateLife(players[0].id, 1),
            onLifeDecrement: () => notifier.updateLife(players[0].id, -1),
            onLifeAdjust: (delta) => notifier.updateLife(players[0].id, delta),
            onCommanderDamageTap: () => _showCmdModal(context, players[0], players),
          ),
          Container(height: 2, color: Colors.white10),
          PlayerLifeWidget(
            player: players[1],
            onLifeIncrement: () => notifier.updateLife(players[1].id, 1),
            onLifeDecrement: () => notifier.updateLife(players[1].id, -1),
            onLifeAdjust: (delta) => notifier.updateLife(players[1].id, delta),
            onCommanderDamageTap: () => _showCmdModal(context, players[1], players),
          ),
        ],
      );
    } else if (players.length == 3) {
      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                PlayerLifeWidget(
                   player: players[0],
                   onLifeIncrement: () => notifier.updateLife(players[0].id, 1),
                   onLifeDecrement: () => notifier.updateLife(players[0].id, -1),
                   onLifeAdjust: (delta) => notifier.updateLife(players[0].id, delta),
                   onCommanderDamageTap: () => _showCmdModal(context, players[0], players),
                ),
                Container(width: 2, color: Colors.white10),
                PlayerLifeWidget(
                   player: players[1],
                   onLifeIncrement: () => notifier.updateLife(players[1].id, 1),
                   onLifeDecrement: () => notifier.updateLife(players[1].id, -1),
                   onLifeAdjust: (delta) => notifier.updateLife(players[1].id, delta),
                   onCommanderDamageTap: () => _showCmdModal(context, players[1], players),
                ),
              ],
            ),
          ),
          Container(height: 2, color: Colors.white10),
          PlayerLifeWidget(
             player: players[2],
             onLifeIncrement: () => notifier.updateLife(players[2].id, 1),
             onLifeDecrement: () => notifier.updateLife(players[2].id, -1),
             onLifeAdjust: (delta) => notifier.updateLife(players[2].id, delta),
             onCommanderDamageTap: () => _showCmdModal(context, players[2], players),
          ),
        ],
      );
    } else {
      // 4 Players
      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                PlayerLifeWidget(
                   player: players[0],
                   onLifeIncrement: () => notifier.updateLife(players[0].id, 1),
                   onLifeDecrement: () => notifier.updateLife(players[0].id, -1),
                   onLifeAdjust: (delta) => notifier.updateLife(players[0].id, delta),
                   onCommanderDamageTap: () => _showCmdModal(context, players[0], players),
                ),
                Container(width: 2, color: Colors.white10),
                PlayerLifeWidget(
                   player: players[1],
                   onLifeIncrement: () => notifier.updateLife(players[1].id, 1),
                   onLifeDecrement: () => notifier.updateLife(players[1].id, -1),
                   onLifeAdjust: (delta) => notifier.updateLife(players[1].id, delta),
                   onCommanderDamageTap: () => _showCmdModal(context, players[1], players),
                ),
              ],
            ),
          ),
          Container(height: 2, color: Colors.white10),
          Expanded(
            child: Row(
              children: [
                PlayerLifeWidget(
                   player: players[2],
                   onLifeIncrement: () => notifier.updateLife(players[2].id, 1),
                   onLifeDecrement: () => notifier.updateLife(players[2].id, -1),
                   onLifeAdjust: (delta) => notifier.updateLife(players[2].id, delta),
                   onCommanderDamageTap: () => _showCmdModal(context, players[2], players),
                ),
                Container(width: 2, color: Colors.white10),
                PlayerLifeWidget(
                   player: players[3],
                   onLifeIncrement: () => notifier.updateLife(players[3].id, 1),
                   onLifeDecrement: () => notifier.updateLife(players[3].id, -1),
                   onLifeAdjust: (delta) => notifier.updateLife(players[3].id, delta),
                   onCommanderDamageTap: () => _showCmdModal(context, players[3], players),
                ),
              ],
            ),
          ),
        ],
      );
    }
  }

  void _showEndGameDialog(BuildContext context, WidgetRef ref, List<Player> players) {
    String? selectedWinnerId;
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Select Winner'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...players.map((p) => RadioListTile<String>(
                  title: Text('${p.name} (${p.life})'),
                  value: p.id,
                  groupValue: selectedWinnerId,
                  onChanged: (val) {
                    setDialogState(() {
                      selectedWinnerId = val;
                    });
                  },
                )),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: selectedWinnerId == null ? null : () {
                  ref.read(gameProvider.notifier).endGame(selectedWinnerId!);
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Return to home
                  // Or navigate to History? Home is safer.
                },
                child: const Text('Confirm & Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showCmdModal(BuildContext context, Player victim, List<Player> allPlayers) {
    final opponents = allPlayers.where((p) => p.id != victim.id).toList();
    if (opponents.isEmpty) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CommanderDamageModal(victim: victim, opponents: opponents),
    );
  }
}
