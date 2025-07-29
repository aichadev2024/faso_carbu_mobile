import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId'); // ou autre clé que tu utilises
  }

  static Future<void> setUserId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', id);
  }
}
