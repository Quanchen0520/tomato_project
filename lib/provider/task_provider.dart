import 'package:flutter/material.dart';
import 'package:tomato_project/utils/task_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TaskProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> _completedTasksHistory = []; // 存儲完成任務的歷史記錄

  List<Map<String, dynamic>> get tasks => _tasks;
  List<Map<String, dynamic>> get history => _completedTasksHistory;

  TaskProvider() {
    _init();
  }

  /// 初始化 Provider
  Future<void> _init() async {
    await loadTasks();
    await _loadCompletedHistory();
  }

  /// 初始化時讀取任務
  Future<void> loadTasks() async {
    _tasks = await TaskStorage.loadTasks();
    // 確保每個任務都有完成狀態和時間戳
    for (var task in _tasks) {
      task['isCompleted'] ??= false;
      task['createdAt'] ??= DateTime.now().toIso8601String();
      task['completedAt'] ??= null;
    }
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
    // 如果要刪除的任務在完成歷史中，也要移除
    _completedTasksHistory.removeWhere((task) => task['id'] == id);
    await _saveCompletedHistory();

    await TaskStorage.deleteTask(id);
    await loadTasks();
  }

  /// 清空任務
  Future<void> clearAll() async {
    await TaskStorage.clearTasks();
    _tasks = [];
    notifyListeners();
  }

  // 切換任務完成狀態
  Future<void> toggleTaskCompletion(String id) async {
    final index = _tasks.indexWhere((task) => task['id'] == id);
    if (index != -1) {
      final wasCompleted = _tasks[index]['isCompleted'] ?? false;
      _tasks[index]['isCompleted'] = !wasCompleted;

      if (!wasCompleted) {
        // 任務被標記為完成
        _tasks[index]['completedAt'] = DateTime.now().toIso8601String();

        // 添加到完成歷史記錄
        final completedTask = Map<String, dynamic>.from(_tasks[index]);
        _completedTasksHistory.add(completedTask);
        await _saveCompletedHistory();
      } else {
        // 任務被取消完成
        _tasks[index]['completedAt'] = null;

        // 從完成歷史記錄中移除
        _completedTasksHistory.removeWhere((task) => task['id'] == id);
        await _saveCompletedHistory();
      }

      // 更新任務狀態到 TaskStorage
      await TaskStorage.updateTaskCompletion(
        id,
        !wasCompleted,
        _tasks[index]['completedAt'],
      );

      notifyListeners();
    }
  }

  // 獲取統計數據
  Map<String, dynamic> getStatistics() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 基本統計
    final totalTasks = _tasks.length;
    final completedTasks = _tasks.where((task) => task['isCompleted'] == true).length;

    // 今日完成的任務
    final todayCompletedTasks = _completedTasksHistory.where((task) {
      if (task['completedAt'] == null) return false;
      final completedDate = DateTime.parse(task['completedAt']);
      final completedDay = DateTime(completedDate.year, completedDate.month, completedDate.day);
      return completedDay.isAtSameMomentAs(today);
    }).toList();

    // 計算平均工作時間和休息時間
    double avgWorkTime = 0;
    double avgRestTime = 0;
    if (_tasks.isNotEmpty) {
      final totalWorkTime = _tasks.fold<int>(0, (sum, task) => sum + (task['workTime'] as int));
      final totalRestTime = _tasks.fold<int>(0, (sum, task) => sum + (task['restTime'] as int));
      avgWorkTime = totalWorkTime / _tasks.length;
      avgRestTime = totalRestTime / _tasks.length;
    }

    // 計算今日總工作時間（小時）
    double totalWorkHours = 0;
    for (final task in todayCompletedTasks) {
      totalWorkHours += (task['workTime'] as int) / 60.0;
    }

    // 設定每日目標（可以根據需要調整）
    const double dailyGoal = 8.0; // 8小時目標

    return {
      'totalTasks': totalTasks,
      'completedTasks': completedTasks,
      'avgWorkTime': avgWorkTime.round(),
      'avgRestTime': avgRestTime.round(),
      'totalWorkHours': totalWorkHours,
      'dailyGoal': dailyGoal,
      'todayCompletedTasks': todayCompletedTasks.length,
      'completionRate': totalTasks > 0 ? (completedTasks / totalTasks * 100).round() : 0,
    };
  }

  // 獲取週統計
  Map<String, dynamic> getWeeklyStatistics() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDay = DateTime(weekStart.year, weekStart.month, weekStart.day);

    final weeklyCompleted = _completedTasksHistory.where((task) {
      if (task['completedAt'] == null) return false;
      final completedDate = DateTime.parse(task['completedAt']);
      return completedDate.isAfter(weekStartDay) && completedDate.isBefore(now.add(Duration(days: 1)));
    }).toList();

    // 按日期分組
    final Map<String, List<Map<String, dynamic>>> dailyTasks = {};
    for (final task in weeklyCompleted) {
      final completedDate = DateTime.parse(task['completedAt']);
      final dateKey = DateTime(completedDate.year, completedDate.month, completedDate.day).toIso8601String().split('T')[0];

      if (!dailyTasks.containsKey(dateKey)) {
        dailyTasks[dateKey] = [];
      }
      dailyTasks[dateKey]!.add(task);
    }

    return {
      'weeklyCompletedTasks': weeklyCompleted.length,
      'dailyBreakdown': dailyTasks,
      'averageDailyTasks': weeklyCompleted.length / 7,
    };
  }

  // 獲取最受歡迎的工作時長
  Map<int, int> getPopularWorkTimes() {
    final Map<int, int> workTimeCount = {};
    for (final task in _tasks) {
      final workTime = task['workTime'] as int;
      workTimeCount[workTime] = (workTimeCount[workTime] ?? 0) + 1;
    }
    return workTimeCount;
  }

  // 獲取生產力趨勢（過去7天每天的完成任務數）
  List<Map<String, dynamic>> getProductivityTrend() {
    final now = DateTime.now();
    final List<Map<String, dynamic>> trend = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateDay = DateTime(date.year, date.month, date.day);

      final dayCompleted = _completedTasksHistory.where((task) {
        if (task['completedAt'] == null) return false;
        final completedDate = DateTime.parse(task['completedAt']);
        final completedDay = DateTime(completedDate.year, completedDate.month, completedDate.day);
        return completedDay.isAtSameMomentAs(dateDay);
      }).length;

      trend.add({
        'date': dateDay.toIso8601String().split('T')[0],
        'completedTasks': dayCompleted,
        'dayName': _getDayName(dateDay.weekday),
      });
    }

    return trend;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  // 清除已完成的任務
  Future<void> clearCompletedTasks() async {
    final completedTaskIds = _tasks
        .where((task) => task['isCompleted'] == true)
        .map((task) => task['id'] as String)
        .toList();

    for (final id in completedTaskIds) {
      await TaskStorage.deleteTask(id);
    }

    await loadTasks();
    notifyListeners();
  }

  // 重置所有統計數據
  Future<void> resetStatistics() async {
    _completedTasksHistory.clear();
    await _saveCompletedHistory();
    notifyListeners();
  }

  // 保存完成歷史記錄
  Future<void> _saveCompletedHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = jsonEncode(_completedTasksHistory);
    await prefs.setString('completed_history', historyJson);
  }

  // 加載完成歷史記錄
  Future<void> _loadCompletedHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString('completed_history');
    if (historyJson != null) {
      final historyList = jsonDecode(historyJson) as List;
      _completedTasksHistory = historyList.map((task) => Map<String, dynamic>.from(task)).toList();
    }
  }

  // 獲取任務完成率
  double getCompletionRate() {
    if (_tasks.isEmpty) return 0.0;
    final completedCount = _tasks.where((task) => task['isCompleted'] == true).length;
    return (completedCount / _tasks.length) * 100;
  }

  // 獲取今日目標進度
  double getTodayProgress() {
    final stats = getStatistics();
    final totalHours = stats['totalWorkHours'] as double;
    final goal = stats['dailyGoal'] as double;
    return goal > 0 ? (totalHours / goal).clamp(0.0, 1.0) : 0.0;
  }

  // 獲取本週目標進度
  double getWeeklyProgress() {
    final weeklyStats = getWeeklyStatistics();
    final weeklyCompleted = weeklyStats['weeklyCompletedTasks'] as int;
    const weeklyGoal = 35; // 每週目標35個任務（每天5個）
    return weeklyGoal > 0 ? (weeklyCompleted / weeklyGoal).clamp(0.0, 1.0) : 0.0;
  }
}