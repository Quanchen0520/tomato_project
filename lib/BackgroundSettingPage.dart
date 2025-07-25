import 'package:flutter/material.dart';

class Backgroundsettingpage extends StatefulWidget {
  const Backgroundsettingpage({super.key});

  @override
  State<Backgroundsettingpage> createState() => _BackgroundsettingpageState();
}

class _BackgroundsettingpageState extends State<Backgroundsettingpage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.purple.shade400, Colors.blue.shade300],
          ),
        ),
    );
  }
}
