import 'dart:convert';

class Player {
  final String id;
  final String name;
  int life;
  Map<String, int> commanderDamage; // opponentId -> damage
  bool isEliminated;
  int? placement; // 1=winner, 2=second, etc.

  Player({
    required this.id,
    required this.name,
    required this.life,
    this.commanderDamage = const {},
    this.isEliminated = false,
    this.placement,
  });

  Player copyWith({
    String? id,
    String? name,
    int? life,
    Map<String, int>? commanderDamage,
    bool? isEliminated,
    int? placement,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      life: life ?? this.life,
      commanderDamage: commanderDamage ?? Map.from(this.commanderDamage),
      isEliminated: isEliminated ?? this.isEliminated,
      placement: placement ?? this.placement,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'starting_life': life, // Note: In DB structure it might be handled differently, but for JSON serialization this works. 
      // Actually DB schema has final_life for saved games.
      // We will map this to match DB schema in DatabaseHelper or keep a consistent JSON structure.
      'life': life,
      'commander_damage': jsonEncode(commanderDamage),
      'is_eliminated': isEliminated ? 1 : 0,
      'placement': placement,
    };
  }

  factory Player.fromJson(Map<String, dynamic> map) {
    return Player(
      id: map['id'],
      name: map['name'],
      life: map['life'] ?? map['final_life'] ?? 40,
      commanderDamage: map['commander_damage'] != null
          ? Map<String, int>.from(jsonDecode(map['commander_damage']))
          : {},
      isEliminated: (map['is_eliminated'] is int)
          ? map['is_eliminated'] == 1
          : map['is_eliminated'] ?? false,
      placement: map['placement'],
    );
  }
}
