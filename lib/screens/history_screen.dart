import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:magic_app_1/providers/history_provider.dart';
import 'package:magic_app_1/models/game_session.dart';
import 'package:magic_app_1/models/player.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Game History'),
      ),
      body: historyAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history_toggle_off, size: 60, color: Colors.white54),
                  const SizedBox(height: 16),
                  const Text(
                    'No games yet!',
                    style: TextStyle(fontSize: 18, color: Colors.white54),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start your first game from home.',
                    style: TextStyle(fontSize: 14, color: Colors.white30),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            separatorBuilder: (context, index) => const Divider(color: Colors.white10),
            itemBuilder: (context, index) {
              final session = sessions[index];
              return _buildHistoryCard(context, session);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, GameSession session) {
    // Find winner
    final winner = session.players.firstWhere(
      (p) => p.id == session.winnerId,
      orElse: () => Player(id: '', name: 'Unknown', life: 0),
    );

    final duration = '${(session.durationSeconds / 60).round()} min';
    final dateStr = _formatDate(session.startedAt);

    return Card(
      color: Theme.of(context).cardColor,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.amber,
          child: Icon(Icons.emoji_events, color: Colors.black),
        ),
        title: Text(
          winner.name,
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        subtitle: Text(
          '$dateStr • $duration • ${session.playerCount} Players',
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    final timeStr = DateFormat.jm().format(date);

    if (dateOnly == today) {
      return 'Today, $timeStr';
    } else if (dateOnly == yesterday) {
      return 'Yesterday, $timeStr';
    } else {
      return DateFormat('MMM d, h:mm a').format(date);
    }
  }
}
