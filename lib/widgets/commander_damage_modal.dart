import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:magic_app_1/models/player.dart';
import 'package:magic_app_1/providers/game_provider.dart';

class CommanderDamageModal extends ConsumerWidget {
  final Player victim;
  final List<Player> opponents;

  const CommanderDamageModal({
    super.key,
    required this.victim,
    required this.opponents,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We need to access the LATEST state of the victim to show current damage
    // The passed 'victim' might be stale if we don't watch logic, 
    // BUT this modal is rebuilt if parent matching works. 
    // SAFEST: Access via provider inside the modal for finding current values.
    final gameState = ref.watch(gameProvider);
    if (gameState == null) return const SizedBox();

    final currentVictim = gameState.players.firstWhere((p) => p.id == victim.id, orElse: () => victim);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Commander Damage to ${currentVictim.name}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          ...opponents.map((opponent) {
            final damage = currentVictim.commanderDamage[opponent.id] ?? 0;
            final isLethal = damage >= 21;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'From ${opponent.name}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                    onPressed: () {
                      ref.read(gameProvider.notifier).updateCommanderDamage(
                        currentVictim.id,
                        opponent.id,
                        -1,
                      );
                    },
                  ),
                  SizedBox(
                    width: 60,
                    child: Text(
                      '$damage / 21',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isLethal ? Colors.red : Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline, color: Colors.green),
                    onPressed: () {
                      ref.read(gameProvider.notifier).updateCommanderDamage(
                        currentVictim.id,
                        opponent.id,
                        1,
                      );
                    },
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
