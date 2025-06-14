import 'package:flutter/material.dart';
import 'package:tomato_project/HomePage.dart';
import 'package:tomato_project/Splash%20Screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => Splash_Screen(),
        '/home': (context) => Homepage(),
      },
    );
  }
}