import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:magic_app_1/models/game_session.dart';
import 'package:magic_app_1/services/database_helper.dart';

final historyProvider = FutureProvider.autoDispose<List<GameSession>>((ref) async {
  return await DatabaseHelper.instance.getGameHistory();
});
