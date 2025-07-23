import 'package:shared_preferences/shared_preferences.dart';

class ReviewTracker {
  static const _keyPrefix = 'review_';

  // Increment wrong count
  static Future<void> addMistake(String letter) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_keyPrefix$letter';
    final current = prefs.getInt(key) ?? 0;
    await prefs.setInt(key, current + 1);
  }

  // Get letters with mistake count >= threshold
  static Future<List<String>> getWeakLetters({int threshold = 2}) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    final weak = <String>[];

    for (final key in keys) {
      if (key.startsWith(_keyPrefix)) {
        final letter = key.replaceFirst(_keyPrefix, '');
        final count = prefs.getInt(key) ?? 0;
        if (count >= threshold) {
          weak.add(letter);
        }
      }
    }
    return weak;
  }

  // Optional: clear all review history
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_keyPrefix)) {
        await prefs.remove(key);
      }
    }
  }
}
