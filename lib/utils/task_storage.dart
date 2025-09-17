import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TaskStorage {
  static const String _tasksKey = 'tasks';

  /// 載入所有任務
  static Future<List<Map<String, dynamic>>> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksString = prefs.getString(_tasksKey) ?? '[]';
      final List<dynamic> tasksList = json.decode(tasksString);

      return tasksList.map((task) {
        final Map<String, dynamic> taskMap = Map<String, dynamic>.from(task);
        // 確保必要的字段存在
        taskMap['isCompleted'] ??= false;
        taskMap['createdAt'] ??= DateTime.now().toIso8601String();
        taskMap['completedAt'] ??= null;
        return taskMap;
      }).toList();
    } catch (e) {
      print('Error loading tasks: $e');
      return [];
    }
  }

  /// 保存任務列表
  static Future<void> _saveTasks(List<Map<String, dynamic>> tasks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksString = json.encode(tasks);
      await prefs.setString(_tasksKey, tasksString);
    } catch (e) {
      print('Error saving tasks: $e');
    }
  }

  /// 新增任務
  static Future<void> saveTask(String taskName, int workTime, int restTime) async {
    try {
      final tasks = await loadTasks();
      final newTask = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'taskName': taskName,
        'workTime': workTime,
        'restTime': restTime,
        'isCompleted': false,
        'createdAt': DateTime.now().toIso8601String(),
        'completedAt': null,
      };

      tasks.add(newTask);
      await _saveTasks(tasks);
    } catch (e) {
      print('Error saving task: $e');
    }
  }

  /// 更新任務
  static Future<void> updateTask(
      String id,
      String taskName,
      int workTime,
      int restTime, {
        bool? isCompleted,
        String? completedAt,
      }) async {
    try {
      final tasks = await loadTasks();
      final index = tasks.indexWhere((task) => task['id'] == id);

      if (index != -1) {
        tasks[index] = {
          ...tasks[index],
          'taskName': taskName,
          'workTime': workTime,
          'restTime': restTime,
          'isCompleted': isCompleted ?? tasks[index]['isCompleted'],
          'completedAt': completedAt ?? tasks[index]['completedAt'],
        };

        await _saveTasks(tasks);
      }
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  /// 更新任務完成狀態
  static Future<void> updateTaskCompletion(
      String id,
      bool isCompleted,
      String? completedAt
      ) async {
    try {
      final tasks = await loadTasks();
      final index = tasks.indexWhere((task) => task['id'] == id);

      if (index != -1) {
        tasks[index]['isCompleted'] = isCompleted;
        tasks[index]['completedAt'] = completedAt;
        await _saveTasks(tasks);
      }
    } catch (e) {
      print('Error updating task completion: $e');
    }
  }

  /// 刪除任務
  static Future<void> deleteTask(String id) async {
    try {
      final tasks = await loadTasks();
      tasks.removeWhere((task) => task['id'] == id);
      await _saveTasks(tasks);
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  /// 清空所有任務
  static Future<void> clearTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tasksKey);
    } catch (e) {
      print('Error clearing tasks: $e');
    }
  }

  /// 根據 ID 查找任務
  static Future<Map<String, dynamic>?> findTaskById(String id) async {
    try {
      final tasks = await loadTasks();
      final index = tasks.indexWhere((task) => task['id'] == id);
      return index != -1 ? tasks[index] : null;
    } catch (e) {
      print('Error finding task: $e');
      return null;
    }
  }

  /// 獲取已完成的任務
  static Future<List<Map<String, dynamic>>> getCompletedTasks() async {
    try {
      final tasks = await loadTasks();
      return tasks.where((task) => task['isCompleted'] == true).toList();
    } catch (e) {
      print('Error getting completed tasks: $e');
      return [];
    }
  }

  /// 獲取未完成的任務
  static Future<List<Map<String, dynamic>>> getPendingTasks() async {
    try {
      final tasks = await loadTasks();
      return tasks.where((task) => task['isCompleted'] == false).toList();
    } catch (e) {
      print('Error getting pending tasks: $e');
      return [];
    }
  }

  /// 獲取今日完成的任務
  static Future<List<Map<String, dynamic>>> getTodayCompletedTasks() async {
    try {
      final tasks = await getCompletedTasks();
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);

      return tasks.where((task) {
        if (task['completedAt'] == null) return false;
        final completedDate = DateTime.parse(task['completedAt']);
        final completedDay = DateTime(completedDate.year, completedDate.month, completedDate.day);
        return completedDay.isAtSameMomentAs(todayStart);
      }).toList();
    } catch (e) {
      print('Error getting today completed tasks: $e');
      return [];
    }
  }

  /// 備份任務數據
  static Future<String> backupTasks() async {
    try {
      final tasks = await loadTasks();
      return json.encode({
        'tasks': tasks,
        'backup_date': DateTime.now().toIso8601String(),
        'version': '1.0',
      });
    } catch (e) {
      print('Error backing up tasks: $e');
      return '{}';
    }
  }

  /// 從備份恢復任務數據
  static Future<bool> restoreFromBackup(String backupData) async {
    try {
      final Map<String, dynamic> backup = json.decode(backupData);
      final List<dynamic> tasks = backup['tasks'] ?? [];

      final List<Map<String, dynamic>> tasksList = tasks
          .map((task) => Map<String, dynamic>.from(task))
          .toList();

      await _saveTasks(tasksList);
      return true;
    } catch (e) {
      print('Error restoring from backup: $e');
      return false;
    }
  }

  /// 統計方法：獲取任務數量統計
  static Future<Map<String, int>> getTaskCounts() async {
    try {
      final tasks = await loadTasks();
      final completedCount = tasks.where((task) => task['isCompleted'] == true).length;
      final pendingCount = tasks.length - completedCount;

      return {
        'total': tasks.length,
        'completed': completedCount,
        'pending': pendingCount,
      };
    } catch (e) {
      print('Error getting task counts: $e');
      return {'total': 0, 'completed': 0, 'pending': 0};
    }
  }
}