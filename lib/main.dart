import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tomato_project/AppPageController.dart';
import 'package:tomato_project/BackgroundSettingPage.dart';
import 'package:tomato_project/LoginPage.dart';
import 'package:tomato_project/RegisterPage.dart';
import 'package:tomato_project/SplashScreen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  runApp(const MyApp());
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
        '/BackgroundSetting': (context) => Backgroundsettingpage()
      },
    );
  }
}