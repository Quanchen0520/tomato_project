import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:tomato_project/provider/background_provider.dart';
import 'package:tomato_project/provider/mode_Provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'main.dart'; // 引入 initNotifications 方法

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool notification = false;

  @override
  void initState() {
    super.initState();
    _checkNotificationStatus();
  }

  Future<void> _checkNotificationStatus() async {
    final status = await Permission.notification.status;
    setState(() {
      notification = status.isGranted;
    });
  }

  Future<void> _onNotificationSwitchChanged(bool value) async {
    if (value) {
      final status = await Permission.notification.request();
      if (status.isGranted) {
        await initNotifications();
        setState(() => notification = true);
      } else if (status.isDenied) {
        // 使用者第一次拒絕（還沒永久拒絕）
        setState(() => notification = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('請允許通知權限以啟用通知功能')));
      } else if (status.isPermanentlyDenied) {
        // 使用者選擇「不再詢問」 或 iOS 拒絕後的狀態
        setState(() => notification = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('請到系統設定中開啟通知權限')));
        openAppSettings(); // 直接帶去 app 設定頁
      }
    } else {
      setState(() => notification = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final modeProvider = context.watch<ModeProvider>();
    final bool _isDigitalMode = modeProvider.isDigitalMode;
    final bg = context.watch<BackgroundProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        foregroundColor: Colors.white,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration:
            bg.backgroundImage != null
                ? BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(bg.backgroundImage!),
                    fit: BoxFit.cover,
                  ),
                )
                : bg.backgroundAssetImage != null
                ? BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(bg.backgroundAssetImage!),
                    fit: BoxFit.cover,
                  ),
                )
                : BoxDecoration(
                  gradient: LinearGradient(
                    colors: [bg.backgroundColor, Colors.blue.shade300],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSectionTitle("Account & Background"),
              _buildGlassCard(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person, color: Colors.white),
                    title: const Text(
                      "Account",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {},
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  ListTile(
                    leading: const Icon(Icons.image, color: Colors.white),
                    title: const Text(
                      "Background",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: _showBackgroundDialog,
                  ),
                ],
              ),

              const SizedBox(height: 20),
              _buildSectionTitle("Notification & Mode"),
              _buildGlassCard(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                    ),
                    title: const Text(
                      "Notification",
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Switch(
                      value: notification,
                      onChanged: _onNotificationSwitchChanged,
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  ListTile(
                    leading: const Icon(Icons.av_timer, color: Colors.white),
                    title: const Text(
                      "Digital Mode",
                      style: TextStyle(color: Colors.white),
                    ),
                    trailing: Switch(
                      value: _isDigitalMode,
                      onChanged: (value) {
                        modeProvider.setMode(value);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              _buildSectionTitle("System"),
              _buildGlassCard(
                children: [
                  ListTile(
                    leading: const Icon(Icons.explore, color: Colors.white),
                    title: const Text(
                      "Instructions for use",
                      style: TextStyle(color: Colors.white),
                    ),
                    onTap: () {},
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.redAccent),
                    title: const Text(
                      "Log out",
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed('/login');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildGlassCard({required List<Widget> children}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(children: children),
        ),
      ),
    );
  }

  Future<void> _requestAndInitNotification() async {
    // Android/iOS 權限請求
    final status = await Permission.notification.request();
    await initNotifications(); // 這是 main.dart 裡的初始化方法

    if (status.isGranted) {
      // 可提示用戶未授權
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please allow notification permissions to enable notifications.',
          ),
        ),
      );
    }
  }

  void _showBackgroundDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text("選擇背景類型"),
          children: [
            SimpleDialogOption(
              child: const Text("圖片"),
              onPressed: () {
                Navigator.pop(context);
                _showImageOptions();
              },
            ),
            SimpleDialogOption(
              child: const Text("顏色"),
              onPressed: () {
                Navigator.pop(context);
                _showColorOptions();
              },
            ),
          ],
        );
      },
    );
  }

  void _showImageOptions() {
    final bg = context.read<BackgroundProvider>();
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text("選擇圖片"),
          children: [
            // 預設圖片
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  child: Image.asset('assets/space.jpg', width: 70, height: 70),
                  onTap: () {
                    bg.setAssetImage('assets/space.jpg');
                    Navigator.pop(context);
                  },
                ),
                GestureDetector(
                  child: Image.asset(
                    'assets/seasdie.jpg',
                    width: 70,
                    height: 70,
                  ),
                  onTap: () {
                    bg.setAssetImage('assets/seasdie.jpg');
                    Navigator.pop(context);
                  },
                ),
                GestureDetector(
                  child: Image.asset('assets/polar.jpg', width: 70, height: 70),
                  onTap: () {
                    bg.setAssetImage('assets/polar.jpg');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            SimpleDialogOption(
              child: const Text("從相簿匯入"),
              onPressed: () async {
                final picked = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );
                if (picked != null) {
                  bg.setFileImage(File(picked.path));
                }
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showColorOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text("choose Color Type"),
          children: [
            SimpleDialogOption(
              child: const Text("純色"),
              onPressed: () {
                Navigator.pop(context);
                _showSolidColorPicker();
              },
            ),
            SimpleDialogOption(
              child: const Text("漸層"),
              onPressed: () {
                Navigator.pop(context);
                _showGradientPicker();
              },
            ),
          ],
        );
      },
    );
  }

  void _showSolidColorPicker() {
    final bg = context.read<BackgroundProvider>();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("choose Solid Color"),
          content: BlockPicker(
            pickerColor: bg.backgroundColor,
            onColorChanged: (color) {
              bg.setColor(color);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("finish"),
            ),
          ],
        );
      },
    );
  }

  void _showGradientPicker() {
    final bg = context.read<BackgroundProvider>();
    // 預設幾組漸層
    final gradients = [
      [Colors.purple, Colors.blue],
      [Colors.orange, Colors.red],
      [Colors.green, Colors.teal],
    ];
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text("choose Gradient"),
          children:
              gradients.map((g) {
                return SimpleDialogOption(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: g),
                    ),
                  ),
                  onPressed: () {
                    bg.setColor(g[0]);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
        );
      },
    );
  }
}
