import 'package:shared_preferences/shared_preferences.dart';

class SmartReviewManager {
  static const _key = 'weakLetters';

  // Save wrong answers for review
  static Future<void> addWeakLetters(List<String> letters) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_key) ?? [];

    // Merge and avoid duplicates
    final updated = {...current, ...letters}.toList();
    await prefs.setStringList(_key, updated);
  }

  // Get weak letters to review
  static Future<List<String>> getWeakLetters() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  // Clear after successful review
  static Future<void> clearWeakLetters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
