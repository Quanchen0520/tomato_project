import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TaskStorage {
  static Future<void> saveTask(int workMinutes, int restMinutes) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tasks = prefs.getStringList("tasks") ?? [];

    Map<String, dynamic> newTask = {
      "workMinutes": workMinutes,
      "restMinutes": restMinutes
    };

    tasks.add(jsonEncode(newTask));
    await prefs.setStringList("tasks", tasks);
  }

  static Future<List<Map<String, dynamic>>> loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tasks = prefs.getStringList("tasks") ?? [];

    // 明確轉型為 List<Map<String, dynamic>>
    List<Map<String, dynamic>> parsedTasks = tasks.map((task) {
      return Map<String, dynamic>.from(jsonDecode(task));
    }).toList();

    return parsedTasks;
  }

  static Future<void> deleteTask(int index) async {
    final prefs = await SharedPreferences.getInstance();

    // 讀取現有任務列表
    List<String> tasks = prefs.getStringList("tasks") ?? [];

    // 確保索引有效
    if (index >= 0 && index < tasks.length) {
      // 刪除指定索引的任務
      tasks.removeAt(index);

      // 保存更新後的任務列表
      await prefs.setStringList("tasks", tasks);
    }
  }
}