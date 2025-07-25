import 'package:flutter/material.dart';

class Taskpage extends StatefulWidget {
  const Taskpage({super.key});

  @override
  State<Taskpage> createState() => _TaskpageState();
}

class _TaskpageState extends State<Taskpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          // image: DecorationImage(
          //   image: AssetImage('assets/space.jpg'), // 放在 assets 資料夾
          //   fit: BoxFit.cover, // 可選：cover、contain、fill
          // ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade400, Colors.blue.shade300],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: 8),
                Text(
                  'Task List',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    color: Colors.white70,
                    child: ListTile(
                      title: Text("read english"),
                      subtitle: Text("work 0 minute, rest 0 minute"),
                      trailing: IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                        ),
                        onPressed: () async {},
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
      // 新增任務按鈕
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addTaskDialog();
        },
        tooltip: 'Add Task',
        backgroundColor: Colors.purple.shade300,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
  void _addTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Add Task"),
          content: SizedBox(
            height: 250, // 給定固定高度
            width: double.maxFinite,
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: <Widget>[
                SizedBox(
                  width: 100,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Work Time',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                SizedBox(
                  width: 100,
                  child: TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Rest Time',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                // await TaskStorage.saveTask(workMinutes, restMinutes);
                // refreshTaskList(() {}); // 更新清單，不影響拖曳
                // Navigator.pop(context);
                Navigator.pop(context);
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }
}