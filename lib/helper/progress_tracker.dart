import 'package:shared_preferences/shared_preferences.dart';

class ProgressTracker {
  static const _levelKey = 'unlockedLevel';
  static const _dailyGoalKey = 'dailyPracticeGoal';

  // Level system
  static Future<int> getUnlockedLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_levelKey) ?? 1; // Default to level 1 (E, T)
  }

  static Future<void> unlockNextLevel() async {
    final prefs = await SharedPreferences.getInstance();
    int current = await getUnlockedLevel();
    await prefs.setInt(_levelKey, current + 1);
  }

  static Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_levelKey, 1);
  }

  static Future<List<String>> getUnlockedLetters() async {
    int level = await getUnlockedLevel();
    List<List<String>> letterSets = [
      ['E', 'T'],
      ['A', 'N'],
      ['M', 'I'],
      ['S', 'O'],
      ['R', 'D'],
      ['G', 'K'],
      ['U', 'B'],
      ['C', 'Y'],
      ['W', 'F'],
      ['L', 'H'],
    ];

    List<String> result = [];
    for (int i = 0; i < level && i < letterSets.length; i++) {
      result.addAll(letterSets[i]);
    }
    return result;
  }

  // Daily practice goal
  static Future<int> getDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_dailyGoalKey) ?? 5; // default: 5 minutes
  }

  static Future<void> setDailyGoal(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_dailyGoalKey, minutes);
  }
}
