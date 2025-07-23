import 'package:shared_preferences/shared_preferences.dart';

class LetterUnlockManager {
  static const String _key = 'unlocked_letters';

  static List<String> defaultLetters = ['E', 'T'];

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_key)) {
      await prefs.setStringList(_key, defaultLetters);
    }
  }

  static Future<List<String>> getUnlockedLetters() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? defaultLetters;
  }

  static Future<void> unlockNextLetters(List<String> nextLetters) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> current = await getUnlockedLetters();
    Set<String> updated = {...current, ...nextLetters};
    await prefs.setStringList(_key, updated.toList());
  }

  static Future<bool> isLetterUnlocked(String letter) async {
    final letters = await getUnlockedLetters();
    return letters.contains(letter);
  }
}
