import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tomato_project/AppPageController.dart';
import 'package:tomato_project/BackgroundSettingPage.dart';
import 'package:tomato_project/LoginPage.dart';
import 'package:tomato_project/RegisterPage.dart';
import 'package:tomato_project/SplashScreen.dart';
import 'package:tomato_project/provider/background_provider.dart';
import 'package:tomato_project/provider/mode_Provider.dart';
import 'package:tomato_project/provider/task_provider.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'notification_service.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  await Permission.notification.request();  // 請求通知權限（Android 13+ 必須）

  // iOS 的初始化設定
  const DarwinInitializationSettings initializationSettingsIOS =
  DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,

    notificationCategories: [], // 前台通知
  );

  // 初始化 Android 的通知設定
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher'); // 通知圖示

  // 組合各平台的初始化設定
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  // 初始化通知插件
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Taipei'));
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // await NotificationService.init();

  runApp(
    MultiProvider(
      // 註冊 providers
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => BackgroundProvider()),
        ChangeNotifierProvider(create: (_) => ModeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => Apppagecontroller(), // Splash_Screen
        '/login': (context) => Loginpage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) => Apppagecontroller(),
        '/BackgroundSetting': (context) => Backgroundsettingpage(),
      },
    );
  }
}
