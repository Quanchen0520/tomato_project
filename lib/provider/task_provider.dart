import 'package:flutter/material.dart';
import 'package:tomato_project/utils/task_storage.dart';

class TaskProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _tasks = [];

  List<Map<String, dynamic>> get tasks => _tasks;

  /// 初始化時讀取任務
  Future<void> loadTasks() async {
    _tasks = await TaskStorage.loadTasks();
    notifyListeners();
  }

  /// 新增任務
  Future<void> addTask(String taskName, int workTime, int restTime) async {
    await TaskStorage.saveTask(taskName, workTime, restTime);
    await loadTasks(); // 重新載入資料
  }

  /// 更新任務
  Future<void> updateTask(String id, String newName, int newWork, int newRest) async {
    await TaskStorage.updateTask(id, newName, newWork, newRest);
    await loadTasks();
  }

  /// 刪除任務
  Future<void> deleteTask(String id) async {
    await TaskStorage.deleteTask(id);
    await loadTasks();
  }

  /// 清空任務
  Future<void> clearAll() async {
    await TaskStorage.clearTasks();
    _tasks = [];
    notifyListeners();
  }
}