// lib/services/stats_service.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/locale_provider.dart';

const String _keyGamesPlayed = 'stats_games_played';
const String _keyDaresCompleted = 'stats_dares_completed';
const String _keyRoundsPlayed = 'stats_rounds_played';

class StatsService {
  final SharedPreferences _prefs;

  StatsService(this._prefs);

  int get gamesPlayed => _prefs.getInt(_keyGamesPlayed) ?? 0;
  int get daresCompleted => _prefs.getInt(_keyDaresCompleted) ?? 0;
  int get roundsPlayed => _prefs.getInt(_keyRoundsPlayed) ?? 0;

  Future<void> incrementGamesPlayed() async {
    await _prefs.setInt(_keyGamesPlayed, gamesPlayed + 1);
  }

  Future<void> incrementDaresCompleted() async {
    await _prefs.setInt(_keyDaresCompleted, daresCompleted + 1);
  }

  Future<void> incrementRoundsPlayed() async {
    await _prefs.setInt(_keyRoundsPlayed, roundsPlayed + 1);
  }
}

final statsServiceProvider = Provider<StatsService?>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  return prefsAsync.whenOrNull(data: (prefs) => StatsService(prefs));
});

final gamesPlayedProvider = Provider<int>((ref) {
  return ref.watch(statsServiceProvider)?.gamesPlayed ?? 0;
});

final daresCompletedProvider = Provider<int>((ref) {
  return ref.watch(statsServiceProvider)?.daresCompleted ?? 0;
});

final roundsPlayedProvider = Provider<int>((ref) {
  return ref.watch(statsServiceProvider)?.roundsPlayed ?? 0;
});
