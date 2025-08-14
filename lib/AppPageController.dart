import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'SettingPage.dart';
import 'TaskPage.dart';

class Apppagecontroller extends StatefulWidget {
  const Apppagecontroller({super.key});

  @override
  State<Apppagecontroller> createState() => _ApppagecontrollerState();
}

class _ApppagecontrollerState extends State<Apppagecontroller> {
  final List<Widget> _pages = [Taskpage(), Homepage(), SettingPage()];

  int currentPageIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: NavigationBar(
        backgroundColor: Color.fromRGBO(255, 255, 255, 0.50), // 改透明度
        indicatorColor: Colors.blue.shade300, // 選取指示器顏色
        surfaceTintColor: Colors.transparent, // 移除默認疊色
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        selectedIndex: currentPageIndex,
        destinations: const <Widget>[
          NavigationDestination(icon: Icon(Icons.list_alt), label: 'Task'),
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Setting'),
        ],
      ),
      body: IndexedStack(index: currentPageIndex, children: _pages),
    );
  }
}
