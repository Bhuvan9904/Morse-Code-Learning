// helper/user_info_helper.dart
import 'package:shared_preferences/shared_preferences.dart';

class UserInfoHelper {
  static const _nameKey = 'userName';
  static const _roleKey = 'userRole';

  static Future<void> saveUserInfo(String name, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
    await prefs.setString(_roleKey, role);
  }

  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey) ?? "User";
  }

  static Future<String> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey) ?? "Learner";
  }

  static Future<bool> isUserInfoAvailable() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_nameKey) && prefs.containsKey(_roleKey);
  }
}
