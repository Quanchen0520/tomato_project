import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:provider/provider.dart';
import 'package:tomato_project/provider/background_provider.dart';
import 'package:tomato_project/provider/mode_Provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'main.dart';

// ------------------------- 共用元件 -------------------------

/// 毛玻璃 Dialog
class GlassDialog extends StatelessWidget {
  final Widget child;
  final double sigmaX;
  final double sigmaY;
  final EdgeInsetsGeometry padding;

  const GlassDialog({
    super.key,
    required this.child,
    this.sigmaX = 12,
    this.sigmaY = 12,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigmaX, sigmaY: sigmaY),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 1.5,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 每個設定選項的統一樣式
class SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color iconColor;
  final Color textColor;

  const SettingTile({
    super.key,
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.iconColor = Colors.white,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title, style: TextStyle(color: textColor)),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

/// 區塊標題
class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// 玻璃卡片樣式容器
class GlassCard extends StatelessWidget {
  final List<Widget> children;
  const GlassCard({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
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
}

// ------------------------- 主頁面 -------------------------

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
    setState(() => notification = status.isGranted);
  }

  Future<void> _onNotificationSwitchChanged(bool value) async {
    if (value) {
      final status = await Permission.notification.request();
      if (status.isGranted) {
        await initNotifications();
        setState(() => notification = true);
      } else if (status.isDenied) {
        setState(() => notification = false);
        _showSnackBar('請允許通知權限以啟用通知功能');
      } else if (status.isPermanentlyDenied) {
        setState(() => notification = false);
        _showSnackBar('請到系統設定中開啟通知權限');
        openAppSettings();
      }
    } else {
      setState(() => notification = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final modeProvider = context.watch<ModeProvider>();
    final bg = context.watch<BackgroundProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
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
        decoration: _buildBackground(bg),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SectionTitle("Account & Background"),
              GlassCard(
                children: [
                  SettingTile(
                    icon: Icons.person,
                    title: "Account",
                    onTap: () {},
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  SettingTile(
                    icon: Icons.image,
                    title: "Background",
                    onTap: _showBackgroundDialog,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const SectionTitle("Notification & Mode"),
              GlassCard(
                children: [
                  SettingTile(
                    icon: Icons.notifications,
                    title: "Notification",
                    trailing: Switch(
                      value: notification,
                      onChanged: _onNotificationSwitchChanged,
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  SettingTile(
                    icon: Icons.av_timer,
                    title: "Digital Mode",
                    trailing: Switch(
                      value: modeProvider.isDigitalMode,
                      onChanged: modeProvider.setMode,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              const SectionTitle("System"),
              GlassCard(
                children: [
                  SettingTile(
                    icon: Icons.explore,
                    title: "Instructions for use",
                    onTap: () {},
                  ),
                  const Divider(color: Colors.white24, height: 1),
                  SettingTile(
                    icon: Icons.logout,
                    title: "Log out",
                    iconColor: Colors.redAccent,
                    textColor: Colors.redAccent,
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

  // ------------------------- 背景 -------------------------
  // BoxDecoration _buildBackground(BackgroundProvider bg) {
  //   if (bg.backgroundImage != null) {
  //     return BoxDecoration(
  //       image: DecorationImage(
  //         image: FileImage(bg.backgroundImage!),
  //         fit: BoxFit.cover,
  //       ),
  //     );
  //   } else if (bg.backgroundAssetImage != null) {
  //     return BoxDecoration(
  //       image: DecorationImage(
  //         image: AssetImage(bg.backgroundAssetImage!),
  //         fit: BoxFit.cover,
  //       ),
  //     );
  //   } else if (bg.backgroundGradient != null) {
  //     return BoxDecoration(
  //       gradient: LinearGradient(
  //         colors: [bg.backgroundColor, Colors.blue.shade300],
  //         begin: Alignment.topLeft,
  //         end: Alignment.bottomRight,
  //       ),
  //     );
  // } else {
  //     return BoxDecoration(
  //       color: bg.backgroundColor, // 純色
  //     );
  //   }
  // }

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

  // ------------------------- 背景選擇 Dialog -------------------------
  void _showBackgroundDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return GlassDialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("選擇背景類型",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 12),
              ListTile(
                title: const Text("圖片", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showImageOptions();
                },
              ),
              ListTile(
                title: const Text("顏色", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showColorOptions();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showImageOptions() {
    final bg = context.read<BackgroundProvider>();
    showDialog(
      context: context,
      builder: (context) {
        return GlassDialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("選擇圖片",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _imageOption(bg, 'assets/space.jpg'),
                  _imageOption(bg, 'assets/seasdie.jpg'),
                  _imageOption(bg, 'assets/polar.jpg'),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                title:
                const Text("從相簿匯入", style: TextStyle(color: Colors.white)),
                onTap: () async {
                  final picked = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (picked != null) bg.setFileImage(File(picked.path));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _imageOption(BackgroundProvider bg, String asset) {
    return GestureDetector(
      child: Image.asset(asset, width: 70, height: 70),
      onTap: () {
        bg.setAssetImage(asset);
        Navigator.pop(context);
      },
    );
  }

  void _showColorOptions() {
    showDialog(
      context: context,
      builder: (context) {
        return GlassDialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Choose Color Type",
                  style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 12),
              ListTile(
                title: const Text("純色", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showSolidColorPicker();
                },
              ),
              ListTile(
                title: const Text("漸層", style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showGradientPicker();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSolidColorPicker() {
    final bg = context.read<BackgroundProvider>();
    // bg.clearGradient();
    showDialog(
      context: context,
      builder: (context) {
        return GlassDialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Choose Solid Color",
                  style: TextStyle(color: Colors.white, fontSize: 12)),
              const SizedBox(height: 12),
              BlockPicker(
                pickerColor: bg.backgroundColor,
                onColorChanged: bg.setColor,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("完成",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGradientPicker() {
    final bg = context.read<BackgroundProvider>();
    final gradients = [
      // 這些是預設的漸層顏色組合
      // 每個子列表代表一個漸層的顏色
      // 例如：[開始顏色, 結束顏色]
      [Colors.purple.shade300, Colors.blue.shade300], // 紫色到藍色
      [Colors.orange.shade300, Colors.red.shade300],   // 橘色到紅色
      [Colors.green.shade300, Colors.teal.shade300],   // 綠色到藍綠色
      // 您可以根據需要新增更多漸層組合
      [const Color(0xFFF8BBD0), const Color(0xFFEC407A)], // 淺粉紅到深粉紅
      [const Color(0xFF80DEEA), const Color(0xFF00ACC1)], // 淺藍綠到藍綠
    ];

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) { // 建議為 builder 的 context 加上型別
        return GlassDialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch, // 讓按鈕寬度一致
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0), // 增加標題和選項間的距離
                child: Text(
                  "Choose Gradient",
                  textAlign: TextAlign.center, // 標題置中
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20, // 稍微加大字體
                      fontWeight: FontWeight.bold),
                ),
              ),
              ...gradients.map((colorList) { // 將 'g' 改名為 'colorList' 更清晰
                // 建立預覽用的 LinearGradient
                final previewGradient = LinearGradient(
                  colors: colorList,
                  begin: Alignment.centerLeft, // 預覽用，可以簡單一點
                  end: Alignment.centerRight,
                );

                return GestureDetector(
                  onTap: () {
                    // 建立要應用的 LinearGradient
                    // 您可以設定不同的 begin 和 end 來改變漸層方向
                    final selectedGradient = LinearGradient(
                      colors: colorList,
                      begin: Alignment.topLeft, // 例如：左上到右下
                      end: Alignment.bottomRight,
                      // stops: [0.0, 1.0], // 可選：控制顏色過渡的位置
                    );

                    // 呼叫 Provider 中的 setGradient 方法
                    bg.setGradient(selectedGradient);
                    Navigator.pop(dialogContext); // 使用 dialogContext 來關閉 Dialog
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0), // 調整間距
                    height: 50, // 稍微加高選項
                    decoration: BoxDecoration(
                        gradient: previewGradient, // 應用預覽漸層
                        borderRadius: BorderRadius.circular(12), // 調整圓角
                        border: Border.all( // 可選：增加邊框
                          color: Colors.white.withOpacity(0.5),
                          width: 1,
                        )
                    ),
                    // 可選：在漸層條上顯示文字或圖示
                    // child: Center(
                    //   child: Text(
                    //     "Gradient Option",
                    //     style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    //   ),
                    // ),
                  ),
                );
              }).toList(),
              // 可選：新增一個 "完成" 或 "取消" 按鈕
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}
