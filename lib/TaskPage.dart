import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tomato_project/provider/background_provider.dart';
import 'package:tomato_project/provider/task_provider.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  late TextEditingController taskName;
  late TextEditingController workTime;
  late TextEditingController restTime;

  @override
  void initState() {
    super.initState();
    taskName = TextEditingController();
    workTime = TextEditingController();
    restTime = TextEditingController();
  }

  @override
  void dispose() {
    taskName.dispose();
    workTime.dispose();
    restTime.dispose();
    super.dispose();
  }

  Future<void> _addTask() async {
    if (taskName.text.isEmpty ||
        workTime.text.isEmpty ||
        restTime.text.isEmpty) {
      _showError("Please enter complete information!");
      return;
    }

    final _workTime = int.tryParse(workTime.text);
    final _restTime = int.tryParse(restTime.text);

    if (_workTime == null || _restTime == null) {
      _showError("Please enter a valid number!");
      return;
    }

    context.read<TaskProvider>().addTask(taskName.text, _workTime, _restTime);

    taskName.clear();
    workTime.clear();
    restTime.clear();
  }

  Future<void> _deleteTask(String id) async {
    context.read<TaskProvider>().deleteTask(id);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = context.watch<TaskProvider>();
    final tasks = taskProvider.tasks;
    final bg = Provider.of<BackgroundProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Task List",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: _buildBackground(bg),
        child: SafeArea(
          child:
              tasks.isEmpty
                  ? Center(
                    child: Text(
                      "No tasks yet.\nClick '+' to add a task",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  )
                  : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return _buildGlassTaskCard(task);
                    },
                  ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTaskDialog,
        backgroundColor: Colors.purple.shade300,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildGlassTaskCard(Map<String, dynamic> task) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: ListTile(
              title: Text(
                task["taskName"] ?? "",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                "Work ${task["workTime"]} min, Rest ${task["restTime"]} min",
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed:
                    () => _deleteTaskDialog(task["id"], task["taskName"]),
              ),
              onTap: () {
                _editTaskDialog(task);
              },
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildBackground(BackgroundProvider bg) {
    if (bg.backgroundImage != null) {
      return BoxDecoration(
        image: DecorationImage(
          image: FileImage(bg.backgroundImage!),
          fit: BoxFit.cover,
        ),
      );
    } else if (bg.backgroundAssetImage != null) {
      return BoxDecoration(
        image: DecorationImage(
          image: AssetImage(bg.backgroundAssetImage!),
          fit: BoxFit.cover,
        ),
      );
    } else if (bg.backgroundGradient != null) {
      print("漸層");
      return BoxDecoration(
        gradient: bg.backgroundGradient, // ← 直接使用 provider 中的 gradient
      );
    } else {
      print("純色");
      return BoxDecoration(
        color: bg.backgroundColor, // 純色
      );
    }
  }

  void _addTaskDialog() {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent, // 透明底
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Add Task",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: taskName,
                        decoration: InputDecoration(
                          labelText: 'Task Name',
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white70),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: workTime,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Work Time',
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white70),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: restTime,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Rest Time',
                          labelStyle: const TextStyle(color: Colors.white70),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white70),
                          ),
                        ),
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _dialogButton("Cancel", Colors.grey, () {
                            Navigator.pop(context);
                          }),
                          const SizedBox(width: 8),
                          _dialogButton("Add", Colors.purple.shade300, () {
                            Navigator.pop(context);
                            _addTask();
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  void _deleteTaskDialog(String id, String taskName) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Are you sure you want to delete task '$taskName' ?",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _dialogButton("Cancel", Colors.grey, () {
                            Navigator.pop(context);
                          }),
                          const SizedBox(width: 8),
                          _dialogButton("Delete", Colors.redAccent, () async {
                            Navigator.pop(context);
                            await _deleteTask(id);
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  void _editTaskDialog(Map<String, dynamic> task) {
    taskName.text = task["taskName"];
    workTime.text = task["workTime"].toString();
    restTime.text = task["restTime"].toString();

    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Edit Task",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: taskName,
                        style: const TextStyle(color: Colors.white),
                      ),
                      TextField(
                        controller: workTime,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                      ),
                      TextField(
                        controller: restTime,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _dialogButton(
                            "Cancel",
                            Colors.grey,
                            () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          _dialogButton("Save", Colors.purple.shade300, () {
                            final _workTime = int.tryParse(workTime.text);
                            final _restTime = int.tryParse(restTime.text);
                            if (taskName.text.isEmpty ||
                                _workTime == null ||
                                _restTime == null) {
                              _showError("Please enter valid info!");
                              return;
                            }
                            context.read<TaskProvider>().updateTask(
                              task["id"],
                              taskName.text,
                              _workTime,
                              _restTime,
                            );
                            Navigator.pop(context);
                            taskName.clear();
                            workTime.clear();
                            restTime.clear();
                          }),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  // Dialog 按鈕自訂樣式
  Widget _dialogButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
