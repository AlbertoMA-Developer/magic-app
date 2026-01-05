import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:magic_app_1/providers/game_provider.dart';

class GameSetupScreen extends ConsumerStatefulWidget {
  const GameSetupScreen({super.key});

  @override
  ConsumerState<GameSetupScreen> createState() => _GameSetupScreenState();
}

class _GameSetupScreenState extends ConsumerState<GameSetupScreen> {
  int _playerCount = 4;
  int _startingLife = 40;
  final List<TextEditingController> _nameControllers = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Determine how many controllers we need
    // We'll keep 4 controllers always initialized to avoid recreating them
    if (_nameControllers.isEmpty) {
      for (int i = 0; i < 4; i++) {
        _nameControllers.add(TextEditingController(text: 'Player ${i + 1}'));
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startGame() {
    final names = _nameControllers.take(_playerCount).map((c) => c.text.isEmpty ? 'Player' : c.text).toList();
    
    ref.read(gameProvider.notifier).startGame(
      playerCount: _playerCount,
      startingLife: _startingLife,
      playerNames: names,
    );

    Navigator.pushReplacementNamed(context, '/game');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Game Session'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Number of Players'),
            const SizedBox(height: 16),
            _buildPlayerCountToggle(),
            const SizedBox(height: 32),
            _buildSectionTitle('Starting Life'),
            const SizedBox(height: 16),
            _buildLifeSelector(),
            const SizedBox(height: 32),
            _buildSectionTitle('Player Names'),
            const SizedBox(height: 16),
            ...List.generate(_playerCount, (index) => _buildNameInput(index)),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _startGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Start Game',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white70,
      ),
    );
  }

  Widget _buildPlayerCountToggle() {
    return Row(
      children: [2, 3, 4].map((count) {
        final isSelected = _playerCount == count;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _playerCount = count;
                });
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white24,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$count Players',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLifeSelector() {
    return Row(
      children: [20, 30, 40].map((life) {
        final isSelected = _startingLife == life;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _startingLife = life;
                });
              },
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? Theme.of(context).colorScheme.primary : Colors.white24,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$life HP',
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white60,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNameInput(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: _nameControllers[index],
        decoration: InputDecoration(
          labelText: 'Player ${index + 1}',
          filled: true,
          fillColor: Theme.of(context).colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          prefixIcon: const Icon(Icons.person_outline, color: Colors.white54),
        ),
      ),
    );
  }
}
