import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class TaskStorage {
  static const String _key = "tasks";

  /// 新增任務
  static Future<void> saveTask(String taskName, int workTime, int restTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tasks = prefs.getStringList(_key) ?? [];

    Map<String, dynamic> newTask = {
      "id": const Uuid().v4(), // 唯一 ID
      "taskName": taskName,
      "workTime": workTime,
      "restTime": restTime
    };

    tasks.add(jsonEncode(newTask));
    await prefs.setStringList(_key, tasks);
  }

  /// 讀取所有任務
  static Future<List<Map<String, dynamic>>> loadTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tasks = prefs.getStringList(_key) ?? [];

    return tasks.map((task) {
      return Map<String, dynamic>.from(jsonDecode(task));
    }).toList();
  }

  /// 依照 ID 更新任務
  static Future<void> updateTask(String id, String newName, int newWork, int newRest) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tasks = prefs.getStringList(_key) ?? [];

    List<Map<String, dynamic>> updatedTasks = tasks.map((taskStr) {
      Map<String, dynamic> task = jsonDecode(taskStr);
      if (task["id"] == id) {
        task["taskName"] = newName;
        task["workTime"] = newWork;
        task["restTime"] = newRest;
      }
      return task;
    }).toList();

    await prefs.setStringList(
      _key,
      updatedTasks.map((task) => jsonEncode(task)).toList(),
    );
  }

  /// 依照 ID 刪除任務
  static Future<void> deleteTask(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tasks = prefs.getStringList(_key) ?? [];

    tasks.removeWhere((taskStr) {
      Map<String, dynamic> task = jsonDecode(taskStr);
      return task["id"] == id;
    });

    await prefs.setStringList(_key, tasks);
  }

  /// 清空任務
  static Future<void> clearTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// 檢查任務是否存在
  static Future<bool> taskExists(String id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> tasks = prefs.getStringList(_key) ?? [];

    return tasks.any((taskStr) {
      Map<String, dynamic> task = jsonDecode(taskStr);
      return task["id"] == id;
    });
  }
}