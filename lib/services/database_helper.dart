import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:magic_app_1/models/game_session.dart';
import 'package:magic_app_1/models/player.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mtg_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textTypeNullable = 'TEXT';
    const integerType = 'INTEGER NOT NULL';
    const integerTypeNullable = 'INTEGER';
    const integerTypeDefault = 'INTEGER DEFAULT 0';

    await db.execute('''
CREATE TABLE game_sessions (
  id $idType,
  started_at $textType,
  ended_at $textTypeNullable,
  player_count $integerType,
  starting_life $integerType,
  winner_id $textTypeNullable,
  duration_seconds $integerTypeDefault
)
''');

    await db.execute('''
CREATE TABLE game_players (
  id $idType,
  game_session_id $textType,
  name $textType,
  starting_life $integerType,
  final_life $integerTypeNullable,
  commander_damage $textTypeNullable,
  placement $integerTypeNullable,
  is_eliminated $integerTypeDefault,
  FOREIGN KEY (game_session_id) REFERENCES game_sessions (id) ON DELETE CASCADE
)
''');

    await db.execute(
        'CREATE INDEX idx_game_session_id ON game_players(game_session_id)');
    await db.execute(
        'CREATE INDEX idx_started_at ON game_sessions(started_at)');
  }

  Future<void> saveGameSession(GameSession session) async {
    final db = await instance.database;

    await db.transaction((txn) async {
      // Insert or update session
      await txn.insert(
        'game_sessions',
        session.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Insert or update players
      for (final player in session.players) {
        final playerJson = player.toJson();
        // Add fields not in Player.toJson() but needed for DB
        playerJson['game_session_id'] = session.id;
        // toJson gives 'life' but Schema has 'final_life'
        playerJson['final_life'] = playerJson['life'];
        playerJson.remove('life'); // Remove 'life' key if it exists to avoid error if not in schema (it's not)
        
        // Ensure starting_life is set. If this is an update, we might want to preserve original starting life.
        // For simplicity, we assume we pass it or it's unchanging. 
        // Logic: The Player model doesn't store startingLife explicitly, only current life.
        // We should probably add startingLife to Player model or assume it's session.startingLife.
        // Actually, for the DB record of a COMPLETED game, final_life is what matters.
        // For an active game save, 'final_life' is current life.
        playerJson['starting_life'] = session.startingLife; // Assuming everyone starts with same life for now.

        await txn.insert(
          'game_players',
          playerJson,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<GameSession>> getGameHistory() async {
    final db = await instance.database;
    final result = await db.query('game_sessions', orderBy: 'started_at DESC', limit: 10);

    List<GameSession> sessions = [];
    for (var json in result) {
      final String sessionId = json['id'] as String;
      final playerResult = await db.query(
        'game_players',
        where: 'game_session_id = ?',
        whereArgs: [sessionId],
      );
      
      final players = playerResult.map((pJson) => Player.fromJson(pJson)).toList();
      sessions.add(GameSession.fromJson(json, players: players));
    }
    
    return sessions;
  }
}
