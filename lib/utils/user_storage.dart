import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class UserStorage {
  // 儲存使用者帳密（覆蓋同名帳號）
  static Future<void> saveUser(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final userMapString = prefs.getString('userMap') ?? '{}';
    final userMap = Map<String, String>.from(
      jsonDecode(userMapString),
    );
    userMap[username] = password;
    await prefs.setString('userMap', jsonEncode(userMap));
  }

  // 登入驗證
  static Future<bool> checkLogin(String username, String password) async {
    final prefs = await SharedPreferences.getInstance();
    final userMapString = prefs.getString('userMap') ?? '{}';
    final userMap = Map<String, String>.from(
      jsonDecode(userMapString),
    );
    return userMap.containsKey(username) && userMap[username] == password;
  }

  // 取得所有帳號（可選功能）
  static Future<List<String>> getAllUsernames() async {
    final prefs = await SharedPreferences.getInstance();
    final userMapString = prefs.getString('userMap') ?? '{}';
    final userMap = Map<String, String>.from(jsonDecode(userMapString));
    return userMap.keys.toList();
  }
}
