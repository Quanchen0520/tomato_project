import 'package:flutter/material.dart';

class Settingpage extends StatefulWidget {
  const Settingpage({super.key});

  @override
  State<Settingpage> createState() => _SettingpageState();
}

class _SettingpageState extends State<Settingpage> {
  bool showMode = false; // false = 指針

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
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
                  'Setting',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    elevation: 8,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        height: 200,
                        child: ListView(
                          children: [
                            ListTile(
                              title: Text("Account Settings"),
                              onTap: () {},
                            ),
                            SizedBox(
                              height: 1,
                              child: Container(color: Colors.grey),
                            ),
                            ListTile(
                              title: Text("Background"),
                              onTap: () {
                                // Navigator.of(context).pushReplacementNamed('/BackgroundSetting');
                                _Dialog();
                              },
                            ),
                            SizedBox(
                              height: 1,
                              child: Container(color: Colors.grey),
                            ),
                            // 數字模式切換開關
                            Row(
                              children: [
                                SizedBox(width: 16),
                                Text("Digital Mode"),
                                Spacer(),
                                Switch(
                                  value: showMode,
                                  onChanged: (bool value) {
                                    setState(() {
                                      showMode = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                // 登出按鈕
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                  child: Text(
                    "Log out",
                    style: TextStyle(
                      color: Colors.red.shade400,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _Dialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Background Setting"),
          content: SizedBox(
            height: 250, // 給定固定高度
            width: double.maxFinite,
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
              Navigator.pop(context);
            },
            child: Text("OK"),
          ),
        ],
        );
      },
    );
  }
}