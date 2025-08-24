import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModeProvider extends ChangeNotifier {
  bool _isDigitalMode = false;
  bool get isDigitalMode => _isDigitalMode;

  ModeProvider() {
    _loadMode();
  }

  void setMode(bool value) async {
    _isDigitalMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDigitalMode', value);
  }

  void _loadMode() async {
    final prefs = await SharedPreferences.getInstance();
    _isDigitalMode = prefs.getBool('isDigitalMode') ?? false;
    notifyListeners();
  }
}